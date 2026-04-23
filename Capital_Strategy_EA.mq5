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

input group "Alerts"
input bool InpSendAlert = true;
input bool InpSendPush = false;
input bool InpNotifyHistorical = false;

CTrade trade;

datetime g_last_bar_time = 0;
int g_day_key = 0;
datetime g_day_start_time = 0;

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

void ResetDay(const int dayKey, const datetime firstBarOpen)
{
   g_day_key = dayKey;
   g_day_start_time = firstBarOpen;
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
   int dk = DayKeyLocal(tBarOpen);
   if(dk != g_day_key) ResetDay(dk, tBarOpen);

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

   datetime tBarOpen = iTime(_Symbol, _Period, 1);
   if(tBarOpen == 0) { g_last_bar_time = t0; return; }

   double h = iHigh(_Symbol, _Period, 1);
   double l = iLow(_Symbol, _Period, 1);
   double c = iClose(_Symbol, _Period, 1);
   if(h <= 0.0 || l <= 0.0 || c <= 0.0) { g_last_bar_time = t0; return; }

   UpdateLevelsWithClosedBar(tBarOpen, h, l);

   if(g_ib_has && g_h13_has)
   {
      double ibMid = (g_ib_high + g_ib_low) / 2.0;
      bool isKill = InWindowLocal(tBarOpen, 14, 30, 16, 30);
      bool validB = (c > g_h13_high && c > ibMid && isKill && !g_buy_done);
      bool validS = (c < g_h13_low && c < ibMid && isKill && !g_sell_done);

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

   g_last_bar_time = t0;
}

int OnInit()
{
   trade.SetAsyncMode(false);
   g_last_bar_time = 0;
   g_day_key = 0;
   return INIT_SUCCEEDED;
}

void OnTick()
{
   if(!InpEnabled) return;
   ProcessSignalOnNewBar();
}
