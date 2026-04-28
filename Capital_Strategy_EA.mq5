#property strict
#property version "1.00"

#include <Trade/Trade.mqh>

input group "Capital Strategy (from capital_100.pine)"
input bool InpEnabled = true;
input int InpItalyOffsetHours = 2;
input double InpLots = 0.10;
input int InpDeviationPoints = 50;

input bool InpUseStopLoss = true;
input bool InpUseTakeProfit = true;
input double InpRiskReward = 1.0;
input bool InpCloseOpposite = true;
input bool InpMaxOneTradePerDayPerSide = true;

input group "Filters"
input bool InpUseDailyOpenFilter = true;
input bool InpUseIbMidFilter = true;
input bool InpRequireManipulation = false;
input int InpSweepBufferPoints = 0;
input int InpReclaimMaxBars = 6;
input bool InpMidnightSignalsEnabled = true;

input group "Alerts"
input bool InpSendAlert = true;
input bool InpSendPush = false;
input bool InpNotifyHistorical = false;

CTrade trade;

string g_prefix = "CAP_EA_";
datetime g_last_bar_time = 0;
int g_day_key = 0;
datetime g_day_start_time = 0;
double g_daily_open = 0.0;
bool g_daily_has = false;
double g_mid_high = 0.0;
double g_mid_low = 0.0;
bool g_mid_has = false;
datetime g_mid_time = 0;
bool g_mid_sweep_down = false;
bool g_mid_sweep_up = false;
int g_mid_sweep_down_bar = -1;
int g_mid_sweep_up_bar = -1;
bool g_mid_long_done = false;
bool g_mid_short_done = false;
bool g_ib_sweep_down = false;
bool g_ib_sweep_up = false;
int g_ib_sweep_down_bar = -1;
int g_ib_sweep_up_bar = -1;
int g_update_calls = 0;

double g_ib_high = 0.0, g_ib_low = 0.0;
bool g_ib_has = false;

double g_h13_high = 0.0, g_h13_low = 0.0;
bool g_h13_has = false;

bool g_buy_done = false;
bool g_sell_done = false;

datetime LocalTime(const datetime tServer) { return tServer + (datetime)InpItalyOffsetHours * 3600; }

int DayKeyLocal(const datetime tServer)
{
   MqlDateTime dt;
   TimeToStruct(LocalTime(tServer), dt);
   return dt.year * 10000 + dt.mon * 100 + dt.day;
}

int MinuteOfDayLocal(const datetime tServer)
{
   MqlDateTime dt;
   TimeToStruct(LocalTime(tServer), dt);
   return dt.hour * 60 + dt.min;
}

bool InWindowLocal(const datetime tServer, const int sh, const int sm, const int eh, const int em)
{
   int cur = MinuteOfDayLocal(tServer);
   int a = sh * 60 + sm;
   int b = eh * 60 + em;
   return (cur >= a && cur < b);
}

bool IsLocalTime(const datetime tServer, const int h, const int m)
{
   MqlDateTime dt;
   TimeToStruct(LocalTime(tServer), dt);
   return (dt.hour == h && dt.min == m);
}

bool IsEntryTimeLocal(const datetime tServer)
{
   MqlDateTime dt;
   TimeToStruct(LocalTime(tServer), dt);
   if(_Period == PERIOD_M1)
      return ((dt.hour == 12 && dt.min == 59) || (dt.hour == 15 && dt.min == 59));
   return (dt.min == 0 && (dt.hour == 13 || dt.hour == 16));
}

void DeleteByPrefix(const string pfx)
{
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string n = ObjectName(0, i);
      if(StringFind(n, pfx) == 0) ObjectDelete(0, n);
   }
}

void CreateOrUpdateRay(const string name, const datetime t1, const double price, const color clr, const int width)
{
   datetime t2 = t1 + (datetime)PeriodSeconds(_Period);
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price)) return;
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
   ObjectMove(0, name, 0, t1, price);
   ObjectMove(0, name, 1, t2, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}

void DrawMidnightCandleLevels()
{
   if(!g_mid_has || g_day_key == 0) return;
   string dayPfx = g_prefix + IntegerToString(g_day_key) + "_";
   datetime tStart = (g_mid_time == 0 ? TimeCurrent() : g_mid_time);
   CreateOrUpdateRay(dayPfx + "MID_H", tStart, g_mid_high, clrGreen, 2);
   CreateOrUpdateRay(dayPfx + "MID_L", tStart, g_mid_low, clrGreen, 2);
}

void ResetDay(const int dayKey, const datetime firstBarOpen)
{
   DeleteByPrefix(g_prefix);
   g_day_key = dayKey;
   g_day_start_time = firstBarOpen;
   g_daily_open = 0.0; g_daily_has = false;
   g_mid_high = 0.0; g_mid_low = 0.0; g_mid_has = false; g_mid_time = 0;
   g_mid_sweep_down = false; g_mid_sweep_up = false;
   g_mid_sweep_down_bar = -1; g_mid_sweep_up_bar = -1;
   g_mid_long_done = false; g_mid_short_done = false;
   g_ib_sweep_down = false; g_ib_sweep_up = false;
   g_ib_sweep_down_bar = -1; g_ib_sweep_up_bar = -1;
   g_update_calls = 0;
   g_ib_high = 0.0; g_ib_low = 0.0; g_ib_has = false;
   g_h13_high = 0.0; g_h13_low = 0.0; g_h13_has = false;
   g_buy_done = false;
   g_sell_done = false;
}

bool HasPosition(const int dir)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      if(sym != _Symbol) continue;
      long type = PositionGetInteger(POSITION_TYPE);
      if(dir > 0 && type == POSITION_TYPE_BUY) return true;
      if(dir < 0 && type == POSITION_TYPE_SELL) return true;
   }
   return false;
}

void ClosePositions(const int dir)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      if(sym != _Symbol) continue;
      long type = PositionGetInteger(POSITION_TYPE);
      if(dir > 0 && type != POSITION_TYPE_BUY) continue;
      if(dir < 0 && type != POSITION_TYPE_SELL) continue;
      trade.PositionClose(ticket);
   }
}

void Notify(const string txt, const datetime tBarOpen)
{
   if(!InpSendAlert && !InpSendPush) return;
   if(!InpNotifyHistorical)
   {
      datetime ref = iTime(_Symbol, _Period, 1);
      if(tBarOpen != ref) return;
   }
   string msg = txt + " on " + _Symbol + " TF=" + EnumToString(_Period);
   if(InpSendAlert) Alert(msg);
   if(InpSendPush) SendNotification(msg);
}

void UpdateLevelsWithClosedBar(const datetime tBarOpen, const double h, const double l)
{
   g_update_calls++;
   int dk = DayKeyLocal(tBarOpen);
   if(dk != g_day_key) ResetDay(dk, tBarOpen);

   if(IsLocalTime(tBarOpen, 0, 0))
   {
      g_daily_open = iOpen(_Symbol, _Period, 1);
      g_daily_has = (g_daily_open > 0.0);
      g_mid_time = tBarOpen;
      g_mid_high = h;
      g_mid_low = l;
      g_mid_has = true;
      g_mid_sweep_down = false;
      g_mid_sweep_up = false;
      g_mid_sweep_down_bar = -1;
      g_mid_sweep_up_bar = -1;
      g_mid_long_done = false;
      g_mid_short_done = false;
      g_ib_sweep_down = false;
      g_ib_sweep_up = false;
      g_ib_sweep_down_bar = -1;
      g_ib_sweep_up_bar = -1;
      g_buy_done = false;
      g_sell_done = false;
   }

   if(InWindowLocal(tBarOpen, 9, 0, 10, 0))
   {
      if(!g_ib_has) { g_ib_high = h; g_ib_low = l; g_ib_has = true; }
      else { if(h > g_ib_high) g_ib_high = h; if(l < g_ib_low) g_ib_low = l; }
   }

   if(InWindowLocal(tBarOpen, 13, 0, 14, 0))
   {
      if(!g_h13_has) { g_h13_high = h; g_h13_low = l; g_h13_has = true; }
      else { if(h > g_h13_high) g_h13_high = h; if(l < g_h13_low) g_h13_low = l; }
   }

   if(IsLocalTime(tBarOpen, 0, 0))
   {
      g_buy_done = false;
      g_sell_done = false;
   }

   double sweepBuf = (double)InpSweepBufferPoints * _Point;
   if(g_mid_has)
   {
      if(!g_mid_sweep_down && l < (g_mid_low - sweepBuf)) { g_mid_sweep_down = true; g_mid_sweep_down_bar = g_update_calls; }
      if(!g_mid_sweep_up && h > (g_mid_high + sweepBuf)) { g_mid_sweep_up = true; g_mid_sweep_up_bar = g_update_calls; }
   }
   if(g_ib_has)
   {
      if(!g_ib_sweep_down && l < (g_ib_low - sweepBuf)) { g_ib_sweep_down = true; g_ib_sweep_down_bar = g_update_calls; }
      if(!g_ib_sweep_up && h > (g_ib_high + sweepBuf)) { g_ib_sweep_up = true; g_ib_sweep_up_bar = g_update_calls; }
   }

   DrawMidnightCandleLevels();
}

bool TryEnter(const bool isBuy, const datetime tBarOpen, const double barClose)
{
   double entry = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(entry <= 0.0) entry = barClose;

   double sl = 0.0, tp = 0.0;
   if(InpUseStopLoss)
      sl = isBuy ? g_h13_low : g_h13_high;

   if(InpUseStopLoss && InpUseTakeProfit && InpRiskReward > 0.0)
   {
      double risk = isBuy ? (entry - sl) : (sl - entry);
      if(risk > 0.0)
         tp = isBuy ? (entry + InpRiskReward * risk) : (entry - InpRiskReward * risk);
   }

   trade.SetDeviationInPoints(InpDeviationPoints);
   bool ok = isBuy ? trade.Buy(InpLots, _Symbol, 0.0, sl, tp) : trade.Sell(InpLots, _Symbol, 0.0, sl, tp);
   if(ok) Notify(isBuy ? "BUY Capital" : "SELL Capital", tBarOpen);
   return ok;
}

void ProcessSignalOnNewBar()
{
   datetime t0 = iTime(_Symbol, _Period, 0);
   if(t0 == 0) return;
   if(t0 == g_last_bar_time) return;

   int dkCur = DayKeyLocal(t0);
   if(dkCur != g_day_key) ResetDay(dkCur, t0);

   if(_Period == PERIOD_M1 && IsLocalTime(t0, 0, 0))
   {
      double o0 = iOpen(_Symbol, _Period, 0);
      double h0 = iHigh(_Symbol, _Period, 0);
      double l0 = iLow(_Symbol, _Period, 0);
      if(o0 > 0.0 && h0 > 0.0 && l0 > 0.0)
      {
         g_daily_open = o0;
         g_daily_has = true;
         g_mid_time = t0;
         g_mid_high = h0;
         g_mid_low = l0;
         g_mid_has = true;
         DrawMidnightCandleLevels();
      }
   }

   datetime tBarOpen = iTime(_Symbol, _Period, 1);
   if(tBarOpen == 0) { g_last_bar_time = t0; return; }

   double h = iHigh(_Symbol, _Period, 1);
   double l = iLow(_Symbol, _Period, 1);
   double c = iClose(_Symbol, _Period, 1);
   if(h <= 0.0 || l <= 0.0 || c <= 0.0) { g_last_bar_time = t0; return; }

   UpdateLevelsWithClosedBar(tBarOpen, h, l);

   bool isEntryTime = IsEntryTimeLocal(tBarOpen);

   if(g_ib_has && g_h13_has)
   {
      double ibMid = (g_ib_high + g_ib_low) / 2.0;
      bool dailyOkB = (!InpUseDailyOpenFilter || (g_daily_has && c > g_daily_open));
      bool dailyOkS = (!InpUseDailyOpenFilter || (g_daily_has && c < g_daily_open));
      bool ibOkB = (!InpUseIbMidFilter || (c > ibMid));
      bool ibOkS = (!InpUseIbMidFilter || (c < ibMid));
      bool manipOkB = (!InpRequireManipulation || g_mid_sweep_down || g_ib_sweep_down);
      bool manipOkS = (!InpRequireManipulation || g_mid_sweep_up || g_ib_sweep_up);
      bool validB = (c > g_h13_high && isEntryTime && !g_buy_done && dailyOkB && ibOkB && manipOkB);
      bool validS = (c < g_h13_low && isEntryTime && !g_sell_done && dailyOkS && ibOkS && manipOkS);

      if(validB)
      {
         if(InpMaxOneTradePerDayPerSide && g_buy_done) { g_last_bar_time = t0; return; }
         if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
         if(!HasPosition(+1))
         {
            if(TryEnter(true, tBarOpen, c)) g_buy_done = true;
         }
      }

      if(validS)
      {
         if(InpMaxOneTradePerDayPerSide && g_sell_done) { g_last_bar_time = t0; return; }
         if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
         if(!HasPosition(-1))
         {
            if(TryEnter(false, tBarOpen, c)) g_sell_done = true;
         }
      }
   }

   if(InpMidnightSignalsEnabled && g_mid_has && g_ib_has)
   {
      double ibMid = (g_ib_high + g_ib_low) / 2.0;
      bool dailyOkB = (!InpUseDailyOpenFilter || (g_daily_has && c > g_daily_open));
      bool dailyOkS = (!InpUseDailyOpenFilter || (g_daily_has && c < g_daily_open));
      bool ibOkB = (!InpUseIbMidFilter || (c > ibMid));
      bool ibOkS = (!InpUseIbMidFilter || (c < ibMid));

      bool canLong = g_mid_sweep_down && !g_mid_long_done;
      if(canLong && InpReclaimMaxBars > 0 && g_mid_sweep_down_bar >= 0)
      {
         int barsSince = g_update_calls - g_mid_sweep_down_bar;
         if(barsSince > InpReclaimMaxBars) canLong = false;
      }
      bool longSig = (canLong && c > g_mid_low && isEntryTime && dailyOkB && ibOkB);

      bool canShort = g_mid_sweep_up && !g_mid_short_done;
      if(canShort && InpReclaimMaxBars > 0 && g_mid_sweep_up_bar >= 0)
      {
         int barsSince = g_update_calls - g_mid_sweep_up_bar;
         if(barsSince > InpReclaimMaxBars) canShort = false;
      }
      bool shortSig = (canShort && c < g_mid_high && isEntryTime && dailyOkS && ibOkS);

      if(longSig)
      {
         if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
         if(!HasPosition(+1))
         {
            if(TryEnter(true, tBarOpen, c)) g_mid_long_done = true;
         }
      }
      if(shortSig)
      {
         if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
         if(!HasPosition(-1))
         {
            if(TryEnter(false, tBarOpen, c)) g_mid_short_done = true;
         }
      }
   }

   g_last_bar_time = t0;
}

int OnInit()
{
   trade.SetAsyncMode(false);
   g_last_bar_time = 0;
   g_day_key = 0;
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   DeleteByPrefix(g_prefix);
}

void OnTick()
{
   if(!InpEnabled) return;
   ProcessSignalOnNewBar();
}
