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

input group "Break Even"
input bool InpBreakEvenEnabled = true;
input double InpBreakEvenAtRR = 1.0;
input int InpBreakEvenPlusPoints = 0;

input group "Partial TP"
input bool InpPartialTpEnabled = true;
input double InpPartialTpAtRR = 1.0;
input int InpPartialTpPercent = 50;

input group "Filters"
input bool InpUseDailyOpenFilter = true;
input bool InpUseIbMidFilter = true;
input bool InpRequireManipulation = false;
input bool InpUseAsiaTrendFilter = true;
input bool InpDrawAsiaBiasArrow = true;
input bool InpUseAsiaLondonSell13 = true;
input bool InpUseHammerSlots = true;
input double InpHammerFibLevel = 0.382;
input bool InpTradeOnlyAt13_16_18 = true;
input int InpBreakoutBufferPoints = 0;
input int InpMinH13RangePoints = 0;
input bool InpSpreadFilterEnabled = false;
input int InpMaxSpreadPoints = 50;
input bool InpUseAtrStop = false;
input int InpAtrPeriod = 14;
input double InpAtrSlMult = 1.5;
input int InpSweepBufferPoints = 0;
input int InpReclaimMaxBars = 6;
input bool InpMidnightSignalsEnabled = true;

input group "Hammer Fib Retrace"
input bool InpHammerFibRetraceEnabled = true;
input bool InpHammerFibConfirmNextCandle = true;
input bool InpHammerFibUse05 = true;
input bool InpHammerFibUse0382 = true;

input group "Swing Pattern Strategy"
input bool InpTradeOnlyInstitutionalSwing = true;
input bool InpTradeOnlySwingPattern = false;
input bool InpSwingUseEntryTimeFilter = false;
input bool InpSwingUseInstitutionalSwings = false;
input bool InpSwingRequireReclaimAfterSweep = false;
input int InpSwingLeftBars = 2;
input int InpSwingRightBars = 2;
input int InpSwingMinSwingRangePoints = 0;
input int InpSwingMinReactionSepPoints = 1;
input bool InpSwingConfirmBos = true;

enum ENUM_MTF_RETEST_ZONE_TYPE
{
   MTF_ZONE_OB = 0,
   MTF_ZONE_FVG = 1,
   MTF_ZONE_OB_FVG = 2
};

input group "MTF Entry (H1->M1)"
input bool InpTradeH1SwingWithM1Entries = false;
input bool InpMtfUseSetupA_ReclaimBreak = true;
input bool InpMtfUseSetupB_SweepSfp = true;
input bool InpMtfUseSetupC_ChoChRetest = false;
input int InpMtfChoChPivotLen = 1;
input ENUM_MTF_RETEST_ZONE_TYPE InpMtfRetestZoneType = MTF_ZONE_OB_FVG;
input int InpMtfObLookbackBars = 5;
input int InpMtfSlBufferPoints = 0;
input int InpMtfH1LeftBars = 2;
input int InpMtfH1RightBars = 2;
input bool InpMtfH1ConfirmBos = true;
input int InpMtfMaxM1BarsAfterH1Signal = 180;
input int InpMtfSweepLookbackBars = 5;
input int InpMtfSweepBufferPoints = 0;

input group "Alerts"
input bool InpSendAlert = true;
input bool InpSendPush = false;
input bool InpNotifyHistorical = false;

CTrade trade;

int g_atr_handle = INVALID_HANDLE;
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

double g_h02_high = 0.0, g_h02_low = 0.0;
bool g_h02_has = false;

double g_asia_open = 0.0;
double g_asia_close = 0.0;
bool g_asia_has = false;
double g_asia_high = 0.0;
double g_asia_low = 0.0;
bool g_asia_range_has = false;

double g_london_high = 0.0;
double g_london_low = 0.0;
bool g_london_range_has = false;

bool g_buy_done = false;
bool g_sell_done = false;

ulong g_partial_ticket_buy_done = 0;
ulong g_partial_ticket_sell_done = 0;

bool g_hs_prev_hammer = false;
bool g_hs_prev_shoot = false;
datetime g_hs_prev_time = 0;
double g_hs_prev_high = 0.0;
double g_hs_prev_low = 0.0;

bool g_hsfib_pending = false;
int g_hsfib_dir = 0;
datetime g_hsfib_pattern_time = 0;
double g_hsfib_high = 0.0;
double g_hsfib_low = 0.0;
datetime g_hsfib_expiry = 0;

double g_swing_last_sweep_low_level = 0.0;
double g_swing_last_sweep_high_level = 0.0;
bool g_swing_allow_buy = true;
bool g_swing_allow_sell = true;

enum { EA_INST_CAP = 300 };
datetime g_inst_time[EA_INST_CAP];
double g_inst_high[EA_INST_CAP];
double g_inst_low[EA_INST_CAP];
int g_inst_head = -1;
int g_inst_count = 0;
double g_inst_swing_high = 0.0;
bool g_inst_swing_high_has = false;
double g_inst_swing_low = 0.0;
bool g_inst_swing_low_has = false;
datetime g_inst_touch_buy_time = 0;
datetime g_inst_touch_sell_time = 0;
datetime g_inst_last_touch_high_time = 0;
datetime g_inst_last_touch_low_time = 0;

datetime g_mtf_last_h1_close_time = 0;
datetime g_mtf_last_h1_sh_time = 0;
double g_mtf_last_h1_sh_price = 0.0;
datetime g_mtf_last_h1_sl_time = 0;
double g_mtf_last_h1_sl_price = 0.0;

bool g_mtf_buy_active = false;
datetime g_mtf_buy_h1_time = 0;
double g_mtf_buy_level = 0.0;
int g_mtf_buy_bars = 0;

bool g_mtf_sell_active = false;
datetime g_mtf_sell_h1_time = 0;
double g_mtf_sell_level = 0.0;
int g_mtf_sell_bars = 0;

int g_mtfA_buy_state = 0;
double g_mtfA_buy_reclaim_high = 0.0;
double g_mtfA_buy_reclaim_low = 0.0;

int g_mtfA_sell_state = 0;
double g_mtfA_sell_reclaim_high = 0.0;
double g_mtfA_sell_reclaim_low = 0.0;

int g_mtfC_buy_state = 0;
double g_mtfC_buy_last_pivot_high = 0.0;
double g_mtfC_buy_zone_low = 0.0;
double g_mtfC_buy_zone_high = 0.0;
double g_mtfC_buy_struct_low = 0.0;

int g_mtfC_sell_state = 0;
double g_mtfC_sell_last_pivot_low = 0.0;
double g_mtfC_sell_zone_low = 0.0;
double g_mtfC_sell_zone_high = 0.0;
double g_mtfC_sell_struct_high = 0.0;

datetime LocalTime(const datetime tServer) { return tServer + (datetime)InpItalyOffsetHours * 3600; }

datetime NextLocalMidnightServer(const datetime tServer)
{
   datetime local = LocalTime(tServer);
   MqlDateTime dt;
   TimeToStruct(local, dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime localMid = StructToTime(dt);
   datetime serverMid = localMid - (datetime)InpItalyOffsetHours * 3600;
   return serverMid + 86400;
}

void EaInstReset()
{
   g_inst_head = -1;
   g_inst_count = 0;
   g_inst_swing_high = 0.0;
   g_inst_swing_high_has = false;
   g_inst_swing_low = 0.0;
   g_inst_swing_low_has = false;
   g_inst_touch_buy_time = 0;
   g_inst_touch_sell_time = 0;
   g_inst_last_touch_high_time = 0;
   g_inst_last_touch_low_time = 0;
}

int EaInstIdx(const int offsetFromNewest)
{
   int idx = g_inst_head - offsetFromNewest;
   while(idx < 0) idx += EA_INST_CAP;
   return (idx % EA_INST_CAP);
}

void EaInstPushBar(const datetime t, const double h, const double l)
{
   g_inst_head = (g_inst_head + 1) % EA_INST_CAP;
   g_inst_time[g_inst_head] = t;
   g_inst_high[g_inst_head] = h;
   g_inst_low[g_inst_head] = l;
   if(g_inst_count < EA_INST_CAP) g_inst_count++;
}

void EaInstUpdate(const datetime tBarOpen, const double h, const double l)
{
   const int lbLeft = 20;
   const int lbRight = 20;
   const int win = lbLeft + lbRight + 1;
   if(win >= EA_INST_CAP) return;

   EaInstPushBar(tBarOpen, h, l);
   if(g_inst_count < win) return;

   int centerOff = lbRight;
   int centerIdx = EaInstIdx(centerOff);
   double lowC = g_inst_low[centerIdx];
   double highC = g_inst_high[centerIdx];

   bool pLow = true;
   for(int off = 0; off < win; off++)
   {
      if(off == centerOff) continue;
      if(g_inst_low[EaInstIdx(off)] <= lowC) { pLow = false; break; }
   }
   bool pHigh = true;
   for(int off = 0; off < win; off++)
   {
      if(off == centerOff) continue;
      if(g_inst_high[EaInstIdx(off)] >= highC) { pHigh = false; break; }
   }

   if(pLow) { g_inst_swing_low = lowC; g_inst_swing_low_has = true; }
   if(pHigh) { g_inst_swing_high = highC; g_inst_swing_high_has = true; }

   double epsTouch = _Point * 0.1;
   double prevH = h;
   double prevL = l;
   if(g_inst_count >= 2)
   {
      prevH = g_inst_high[EaInstIdx(1)];
      prevL = g_inst_low[EaInstIdx(1)];
   }

   if(g_inst_swing_high_has && prevH < (g_inst_swing_high - epsTouch) && h >= (g_inst_swing_high - epsTouch) && g_inst_last_touch_high_time != tBarOpen)
   {
      g_inst_touch_sell_time = tBarOpen;
      g_inst_last_touch_high_time = tBarOpen;
   }
   if(g_inst_swing_low_has && prevL > (g_inst_swing_low + epsTouch) && l <= (g_inst_swing_low + epsTouch) && g_inst_last_touch_low_time != tBarOpen)
   {
      g_inst_touch_buy_time = tBarOpen;
      g_inst_last_touch_low_time = tBarOpen;
   }
}

void ManageBreakEven()
{
   if(!InpBreakEvenEnabled) return;
   if(!InpUseStopLoss) return;
   if(InpBreakEvenAtRR <= 0.0) return;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(bid <= 0.0 || ask <= 0.0) return;

   int stopsLevelPts = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   double stops = (double)stopsLevelPts * _Point;
   double plus = (double)InpBreakEvenPlusPoints * _Point;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      if(sym != _Symbol) continue;

      long type = PositionGetInteger(POSITION_TYPE);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      if(entry <= 0.0 || sl <= 0.0) continue;

      if(type == POSITION_TYPE_BUY)
      {
         double risk = entry - sl;
         if(risk <= 0.0) continue;
         double moved = bid - entry;
         if(moved < risk * InpBreakEvenAtRR) continue;

         double newSl = entry + plus;
         if(sl >= newSl) continue;
         double maxSl = bid - stops;
         if(maxSl <= 0.0) continue;
         if(newSl > maxSl) newSl = maxSl;
         if(newSl <= sl) continue;

         trade.PositionModify(ticket, NormalizeDouble(newSl, _Digits), tp);
      }
      else if(type == POSITION_TYPE_SELL)
      {
         double risk = sl - entry;
         if(risk <= 0.0) continue;
         double moved = entry - ask;
         if(moved < risk * InpBreakEvenAtRR) continue;

         double newSl = entry - plus;
         if(sl <= newSl) continue;
         double minSl = ask + stops;
         if(minSl <= 0.0) continue;
         if(newSl < minSl) newSl = minSl;
         if(newSl >= sl) continue;

         trade.PositionModify(ticket, NormalizeDouble(newSl, _Digits), tp);
      }
   }
}

double NormalizeVolumeDown(const double vol)
{
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minv = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(step <= 0.0) return vol;
   double v = MathFloor(vol / step) * step;
   v = NormalizeDouble(v, 8);
   if(v < minv) return 0.0;
   return v;
}

void ManagePartialTp()
{
   if(!InpPartialTpEnabled) return;
   if(InpPartialTpAtRR <= 0.0) return;
   if(InpPartialTpPercent <= 0 || InpPartialTpPercent >= 100) return;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(bid <= 0.0 || ask <= 0.0) return;

   trade.SetDeviationInPoints(InpDeviationPoints);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      if(sym != _Symbol) continue;

      long type = PositionGetInteger(POSITION_TYPE);
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);
      double sl = PositionGetDouble(POSITION_SL);
      double vol = PositionGetDouble(POSITION_VOLUME);
      if(entry <= 0.0 || sl <= 0.0 || vol <= 0.0) continue;

      if(type == POSITION_TYPE_BUY && ticket == g_partial_ticket_buy_done) continue;
      if(type == POSITION_TYPE_SELL && ticket == g_partial_ticket_sell_done) continue;

      double risk = (type == POSITION_TYPE_BUY) ? (entry - sl) : (sl - entry);
      if(risk <= 0.0) continue;
      double moved = (type == POSITION_TYPE_BUY) ? (bid - entry) : (entry - ask);
      if(moved < risk * InpPartialTpAtRR) continue;

      double closeVolRaw = vol * ((double)InpPartialTpPercent / 100.0);
      double closeVol = NormalizeVolumeDown(closeVolRaw);
      if(closeVol <= 0.0) continue;
      if(closeVol >= vol) continue;

      bool ok = trade.PositionClosePartial(_Symbol, closeVol);
      if(ok)
      {
         if(type == POSITION_TYPE_BUY) g_partial_ticket_buy_done = ticket;
         if(type == POSITION_TYPE_SELL) g_partial_ticket_sell_done = ticket;
         Notify("PARTIAL TP " + IntegerToString(InpPartialTpPercent) + "%", TimeCurrent());
      }
   }
}

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
   if(_Period == PERIOD_M1)
   {
      MqlDateTime dt;
      TimeToStruct(LocalTime(tServer), dt);
      if(InpTradeOnlyAt13_16_18)
         return ((dt.hour == 12 && dt.min == 59) || (dt.hour == 15 && dt.min == 59) || (dt.hour == 17 && dt.min == 59));
      return ((dt.hour == 12 && dt.min == 59) || (dt.hour == 15 && dt.min == 59));
   }

   datetime tRef = tServer + (datetime)PeriodSeconds(_Period);
   MqlDateTime dt;
   TimeToStruct(LocalTime(tRef), dt);
   if(InpTradeOnlyAt13_16_18)
      return (dt.min == 0 && (dt.hour == 13 || dt.hour == 16 || dt.hour == 18));
   return (dt.min == 0 && (dt.hour == 13 || dt.hour == 16));
}

int EntrySlotLocal(const datetime tServer)
{
   if(_Period == PERIOD_M1)
   {
      MqlDateTime dt;
      TimeToStruct(LocalTime(tServer), dt);
      if(dt.hour == 12 && dt.min == 59) return 13;
      if(dt.hour == 15 && dt.min == 59) return 16;
      if(InpTradeOnlyAt13_16_18 && dt.hour == 17 && dt.min == 59) return 18;
      return 0;
   }

   datetime tRef = tServer + (datetime)PeriodSeconds(_Period);
   MqlDateTime dt;
   TimeToStruct(LocalTime(tRef), dt);
   if(InpTradeOnlyAt13_16_18)
   {
      if(dt.min == 0 && (dt.hour == 13 || dt.hour == 16 || dt.hour == 18)) return dt.hour;
   }
   else
   {
      if(dt.min == 0 && (dt.hour == 13 || dt.hour == 16)) return dt.hour;
   }
   return 0;
}

bool GetAtrValue(const int shift, double &atrValue)
{
   atrValue = 0.0;
   if(g_atr_handle == INVALID_HANDLE) return false;
   double buf[1];
   if(CopyBuffer(g_atr_handle, 0, shift, 1, buf) <= 0) return false;
   atrValue = buf[0];
   return (atrValue > 0.0);
}

bool SpreadOk()
{
   if(!InpSpreadFilterEnabled) return true;
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(ask <= 0.0 || bid <= 0.0 || _Point <= 0.0) return true;
   int spreadPts = (int)MathRound((ask - bid) / _Point);
   return (spreadPts <= InpMaxSpreadPoints);
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
   datetime t2 = NextLocalMidnightServer(t1);
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price)) return;
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
   ObjectMove(0, name, 0, t1, price);
   ObjectMove(0, name, 1, t2, price);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
}

void CreateOrUpdateTrendSegment(const string name, const datetime t1, const double p1, const datetime t2, const double p2, const color clr, const ENUM_LINE_STYLE style, const int width)
{
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2)) return;
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
   }
   ObjectMove(0, name, 0, t1, p1);
   ObjectMove(0, name, 1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

void CreateOrUpdateArrow(const string name, const datetime t, const double price, const bool isBuy)
{
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, isBuy ? OBJ_ARROW_BUY : OBJ_ARROW_SELL, 0, t, price)) return;
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
   ObjectMove(0, name, 0, t, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, isBuy ? clrLimeGreen : clrRed);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
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
   g_h02_high = 0.0; g_h02_low = 0.0; g_h02_has = false;
   g_asia_open = 0.0; g_asia_close = 0.0; g_asia_has = false;
   g_asia_high = 0.0; g_asia_low = 0.0; g_asia_range_has = false;
   g_london_high = 0.0; g_london_low = 0.0; g_london_range_has = false;
   g_buy_done = false;
   g_sell_done = false;
   g_partial_ticket_buy_done = 0;
   g_partial_ticket_sell_done = 0;
   g_hs_prev_hammer = false;
   g_hs_prev_shoot = false;
   g_hs_prev_time = 0;
   g_hs_prev_high = 0.0;
   g_hs_prev_low = 0.0;
   g_hsfib_pending = false;
   g_hsfib_dir = 0;
   g_hsfib_pattern_time = 0;
   g_hsfib_high = 0.0;
   g_hsfib_low = 0.0;
   g_hsfib_expiry = 0;
   g_swing_last_sweep_low_level = 0.0;
   g_swing_last_sweep_high_level = 0.0;
   g_swing_allow_buy = true;
   g_swing_allow_sell = true;
   EaInstReset();

   g_mtf_last_h1_close_time = 0;
   g_mtf_last_h1_sh_time = 0;
   g_mtf_last_h1_sh_price = 0.0;
   g_mtf_last_h1_sl_time = 0;
   g_mtf_last_h1_sl_price = 0.0;
   g_mtf_buy_active = false;
   g_mtf_buy_h1_time = 0;
   g_mtf_buy_level = 0.0;
   g_mtf_buy_bars = 0;
   g_mtf_sell_active = false;
   g_mtf_sell_h1_time = 0;
   g_mtf_sell_level = 0.0;
   g_mtf_sell_bars = 0;
   g_mtfA_buy_state = 0;
   g_mtfA_buy_reclaim_high = 0.0;
   g_mtfA_buy_reclaim_low = 0.0;
   g_mtfA_sell_state = 0;
   g_mtfA_sell_reclaim_high = 0.0;
   g_mtfA_sell_reclaim_low = 0.0;
   g_mtfC_buy_state = 0;
   g_mtfC_buy_last_pivot_high = 0.0;
   g_mtfC_buy_zone_low = 0.0;
   g_mtfC_buy_zone_high = 0.0;
   g_mtfC_buy_struct_low = 0.0;
   g_mtfC_sell_state = 0;
   g_mtfC_sell_last_pivot_low = 0.0;
   g_mtfC_sell_zone_low = 0.0;
   g_mtfC_sell_zone_high = 0.0;
   g_mtfC_sell_struct_high = 0.0;
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
      g_swing_last_sweep_low_level = 0.0;
      g_swing_last_sweep_high_level = 0.0;
      g_swing_allow_buy = true;
      g_swing_allow_sell = true;
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

   EaInstUpdate(tBarOpen, h, l);
   DrawMidnightCandleLevels();
}

double LowestPrevLow(const int lookbackBars)
{
   int n = lookbackBars;
   if(n < 1) n = 1;
   if(iBars(_Symbol, _Period) < (n + 2)) return 0.0;
   double v = iLow(_Symbol, _Period, 2);
   for(int sh = 3; sh <= n + 1; sh++)
   {
      double x = iLow(_Symbol, _Period, sh);
      if(x > 0.0 && (v <= 0.0 || x < v)) v = x;
   }
   return v;
}

double HighestPrevHigh(const int lookbackBars)
{
   int n = lookbackBars;
   if(n < 1) n = 1;
   if(iBars(_Symbol, _Period) < (n + 2)) return 0.0;
   double v = iHigh(_Symbol, _Period, 2);
   for(int sh = 3; sh <= n + 1; sh++)
   {
      double x = iHigh(_Symbol, _Period, sh);
      if(x > 0.0 && (v <= 0.0 || x > v)) v = x;
   }
   return v;
}

void UpdateMtfH1SwingSignals()
{
   datetime h1BarOpen = iTime(_Symbol, PERIOD_H1, 1);
   if(h1BarOpen == 0) return;
   if(h1BarOpen == g_mtf_last_h1_close_time) return;
   g_mtf_last_h1_close_time = h1BarOpen;

   int left = MathMax(1, InpMtfH1LeftBars);
   int right = MathMax(1, InpMtfH1RightBars);
   int centerShift = right + 1;
   int needBars = centerShift + left + 2;
   if(iBars(_Symbol, PERIOD_H1) < needBars) return;

   double hC = iHigh(_Symbol, PERIOD_H1, centerShift);
   double lC = iLow(_Symbol, PERIOD_H1, centerShift);
   if(hC <= 0.0 || lC <= 0.0) return;

   bool sh = true;
   bool sl = true;
   for(int off = -right; off <= left; off++)
   {
      int s = centerShift + off;
      if(s == centerShift) continue;
      double hh = iHigh(_Symbol, PERIOD_H1, s);
      if(hh >= hC) sh = false;
      double ll = iLow(_Symbol, PERIOD_H1, s);
      if(ll <= lC) sl = false;
   }

   for(int k = left; sh && k >= 1; k--)
   {
      if(iHigh(_Symbol, PERIOD_H1, centerShift + k) >= iHigh(_Symbol, PERIOD_H1, centerShift + k - 1)) sh = false;
   }
   for(int k = 1; sh && k <= right; k++)
   {
      if(iHigh(_Symbol, PERIOD_H1, centerShift - k) >= iHigh(_Symbol, PERIOD_H1, centerShift - k + 1)) sh = false;
   }

   for(int k = left; sl && k >= 1; k--)
   {
      if(iLow(_Symbol, PERIOD_H1, centerShift + k) <= iLow(_Symbol, PERIOD_H1, centerShift + k - 1)) sl = false;
   }
   for(int k = 1; sl && k <= right; k++)
   {
      if(iLow(_Symbol, PERIOD_H1, centerShift - k) <= iLow(_Symbol, PERIOD_H1, centerShift - k + 1)) sl = false;
   }

   double sep = (double)InpSwingMinReactionSepPoints * _Point;
   double minRange = (double)InpSwingMinSwingRangePoints * _Point;
   bool rangeOk = ((hC - lC) >= minRange);

   double cR = iClose(_Symbol, PERIOD_H1, right);
   double oR = iOpen(_Symbol, PERIOD_H1, right);
   double hR = iHigh(_Symbol, PERIOD_H1, right);
   double lR = iLow(_Symbol, PERIOD_H1, right);
   double cNow = iClose(_Symbol, PERIOD_H1, 1);

   bool reactBearOk = (cR < oR && hR < (hC - sep) && oR < (hC - sep) && cR < (hC - sep));
   bool reactBullOk = (cR > oR && lR > (lC + sep) && oR > (lC + sep) && cR > (lC + sep));

   bool bosBearOk = true;
   bool bosBullOk = true;
   if(InpMtfH1ConfirmBos)
   {
      if(right == 1)
      {
         bosBearOk = (cNow < lC);
         bosBullOk = (cNow > hC);
      }
      else
      {
         bosBearOk = (cNow < lR);
         bosBullOk = (cNow > hR);
      }
   }

   sh = sh && rangeOk && reactBearOk && bosBearOk;
   sl = sl && rangeOk && reactBullOk && bosBullOk;

   datetime tPivot = iTime(_Symbol, PERIOD_H1, centerShift);
   if(tPivot == 0) return;

   if(sl && tPivot != g_mtf_last_h1_sl_time)
   {
      g_mtf_last_h1_sl_time = tPivot;
      g_mtf_last_h1_sl_price = lC;
      g_mtf_buy_active = true;
      g_mtf_buy_h1_time = tPivot;
      g_mtf_buy_level = lC;
      g_mtf_buy_bars = 0;
      g_mtfA_buy_state = 0;
      g_mtfA_buy_reclaim_high = 0.0;
      g_mtfA_buy_reclaim_low = 0.0;
      g_mtfC_buy_state = 0;
      g_mtfC_buy_last_pivot_high = 0.0;
      g_mtfC_buy_zone_low = 0.0;
      g_mtfC_buy_zone_high = 0.0;
      g_mtfC_buy_struct_low = 0.0;
      g_mtf_sell_active = false;
      g_mtf_sell_bars = 0;
      g_mtfA_sell_state = 0;
      g_mtfC_sell_state = 0;
      return;
   }
   if(sh && tPivot != g_mtf_last_h1_sh_time)
   {
      g_mtf_last_h1_sh_time = tPivot;
      g_mtf_last_h1_sh_price = hC;
      g_mtf_sell_active = true;
      g_mtf_sell_h1_time = tPivot;
      g_mtf_sell_level = hC;
      g_mtf_sell_bars = 0;
      g_mtfA_sell_state = 0;
      g_mtfA_sell_reclaim_high = 0.0;
      g_mtfA_sell_reclaim_low = 0.0;
      g_mtfC_sell_state = 0;
      g_mtfC_sell_last_pivot_low = 0.0;
      g_mtfC_sell_zone_low = 0.0;
      g_mtfC_sell_zone_high = 0.0;
      g_mtfC_sell_struct_high = 0.0;
      g_mtf_buy_active = false;
      g_mtf_buy_bars = 0;
      g_mtfA_buy_state = 0;
      g_mtfC_buy_state = 0;
      return;
   }
}

bool TryEnterWithSLTag(const bool isBuy, const datetime tBarOpen, const double barClose, const double slFixed, const string tag)
{
   double entry = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(entry <= 0.0) entry = barClose;

   double sl = 0.0, tp = 0.0;
   if(InpUseStopLoss)
   {
      if(slFixed <= 0.0) return false;
      double risk = isBuy ? (entry - slFixed) : (slFixed - entry);
      if(risk <= 0.0) return false;
      sl = slFixed;
      if(InpUseTakeProfit && InpRiskReward > 0.0)
         tp = isBuy ? (entry + InpRiskReward * risk) : (entry - InpRiskReward * risk);
   }

   trade.SetDeviationInPoints(InpDeviationPoints);
   bool ok = isBuy ? trade.Buy(InpLots, _Symbol, 0.0, sl, tp) : trade.Sell(InpLots, _Symbol, 0.0, sl, tp);
   if(ok) Notify(tag, tBarOpen);
   return ok;
}

bool TryEnterWithSL(const bool isBuy, const datetime tBarOpen, const double barClose, const double slFixed)
{
   return TryEnterWithSLTag(isBuy, tBarOpen, barClose, slFixed, isBuy ? "BUY Fib" : "SELL Fib");
}

bool TryEnter(const bool isBuy, const datetime tBarOpen, const double barClose)
{
   double entry = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(entry <= 0.0) entry = barClose;

   double sl = 0.0, tp = 0.0;
   if(InpUseStopLoss)
   {
      if(InpUseAtrStop)
      {
         double atr = 0.0;
         if(GetAtrValue(1, atr))
            sl = isBuy ? (entry - InpAtrSlMult * atr) : (entry + InpAtrSlMult * atr);
         else
            sl = isBuy ? g_h13_low : g_h13_high;
      }
      else
      {
         sl = isBuy ? g_h13_low : g_h13_high;
      }
   }

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

   double o = iOpen(_Symbol, _Period, 1);
   double h = iHigh(_Symbol, _Period, 1);
   double l = iLow(_Symbol, _Period, 1);
   double c = iClose(_Symbol, _Period, 1);
   if(o <= 0.0 || h <= 0.0 || l <= 0.0 || c <= 0.0) { g_last_bar_time = t0; return; }

   UpdateLevelsWithClosedBar(tBarOpen, h, l);

   if(IsLocalTime(tBarOpen, 2, 0))
   {
      g_h02_high = h;
      g_h02_low = l;
      g_h02_has = true;
   }

   if(InWindowLocal(tBarOpen, 0, 0, 8, 0))
   {
      if(!g_asia_has) g_asia_open = o;
      g_asia_close = c;
      g_asia_has = true;
      if(!g_asia_range_has) { g_asia_high = h; g_asia_low = l; g_asia_range_has = true; }
      else { if(h > g_asia_high) g_asia_high = h; if(l < g_asia_low) g_asia_low = l; }
   }
   if(InWindowLocal(tBarOpen, 9, 0, 17, 30))
   {
      if(!g_london_range_has) { g_london_high = h; g_london_low = l; g_london_range_has = true; }
      else { if(h > g_london_high) g_london_high = h; if(l < g_london_low) g_london_low = l; }
   }
   if(InpDrawAsiaBiasArrow && IsLocalTime(tBarOpen, 9, 0) && g_asia_has && g_asia_open > 0.0)
   {
      bool buyBias = (g_asia_high > 0.0 && l > g_asia_high);
      bool sellBias = (g_asia_low > 0.0 && h < g_asia_low);
      if(buyBias || sellBias)
      {
         string n = g_prefix + IntegerToString(g_day_key) + "_ASIA_BIAS_" + IntegerToString((long)tBarOpen);
         CreateOrUpdateArrow(n, tBarOpen, buyBias ? (l - 12 * _Point) : (h + 12 * _Point), buyBias);
      }
   }

   if(InpTradeH1SwingWithM1Entries)
   {
      if(_Period != PERIOD_M1) { g_last_bar_time = t0; return; }

      UpdateMtfH1SwingSignals();

      int maxBars = InpMtfMaxM1BarsAfterH1Signal;
      if(maxBars < 0) maxBars = 0;

      if(g_mtf_buy_active) g_mtf_buy_bars++;
      if(g_mtf_sell_active) g_mtf_sell_bars++;

      if(maxBars > 0 && g_mtf_buy_active && g_mtf_buy_bars > maxBars)
      {
         g_mtf_buy_active = false;
         g_mtf_buy_bars = 0;
         g_mtfA_buy_state = 0;
         g_mtfC_buy_state = 0;
      }
      if(maxBars > 0 && g_mtf_sell_active && g_mtf_sell_bars > maxBars)
      {
         g_mtf_sell_active = false;
         g_mtf_sell_bars = 0;
         g_mtfA_sell_state = 0;
         g_mtfC_sell_state = 0;
      }

      double cPrev = iClose(_Symbol, _Period, 2);
      if(cPrev <= 0.0) { g_last_bar_time = t0; return; }

      double buf = (double)InpMtfSweepBufferPoints * _Point;
      int look = InpMtfSweepLookbackBars;
      if(look < 1) look = 1;

      if(g_mtf_buy_active && !(InpMaxOneTradePerDayPerSide && g_buy_done) && !HasPosition(+1))
      {
         if(g_mtfC_buy_struct_low <= 0.0 || l < g_mtfC_buy_struct_low) g_mtfC_buy_struct_low = l;

         if(InpMtfUseSetupA_ReclaimBreak)
         {
            if(g_mtfA_buy_state == 0) g_mtfA_buy_state = 1;

            if(g_mtfA_buy_state == 1)
            {
               if(cPrev <= g_mtf_buy_level && c > g_mtf_buy_level)
               {
                  g_mtfA_buy_reclaim_high = h;
                  g_mtfA_buy_reclaim_low = l;
                  g_mtfA_buy_state = 2;
               }
            }
            else if(g_mtfA_buy_state == 2)
            {
               if(g_mtfA_buy_reclaim_high > 0.0 && cPrev <= g_mtfA_buy_reclaim_high && c > g_mtfA_buy_reclaim_high)
               {
                  if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
                  if(!HasPosition(+1))
                  {
                     if(SpreadOk() && TryEnterWithSLTag(true, tBarOpen, c, g_mtfA_buy_reclaim_low, "BUY MTF A")) g_buy_done = true;
                  }
                  g_mtf_buy_active = false;
                  g_mtf_buy_bars = 0;
                  g_mtfA_buy_state = 0;
               }
            }
         }

         if(g_mtf_buy_active && InpMtfUseSetupB_SweepSfp)
         {
            double lowestPrev = LowestPrevLow(look);
            if(lowestPrev > 0.0 && l < (lowestPrev - buf) && c > lowestPrev)
            {
               if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
               if(!HasPosition(+1))
               {
                  if(SpreadOk() && TryEnterWithSLTag(true, tBarOpen, c, l, "BUY MTF B")) g_buy_done = true;
               }
               g_mtf_buy_active = false;
               g_mtf_buy_bars = 0;
               g_mtfA_buy_state = 0;
               g_mtfC_buy_state = 0;
            }
         }

         if(g_mtf_buy_active && InpMtfUseSetupC_ChoChRetest)
         {
            int piv = MathMax(1, InpMtfChoChPivotLen);
            int centerShift = piv + 1;
            int needBars = centerShift + piv + 2;
            if(iBars(_Symbol, _Period) >= needBars)
            {
               if(g_mtfC_buy_state == 0)
               {
                  bool isPH = true;
                  double hC = iHigh(_Symbol, _Period, centerShift);
                  for(int k = 1; k <= piv; k++)
                  {
                     if(hC <= iHigh(_Symbol, _Period, centerShift - k)) { isPH = false; break; }
                     if(hC <= iHigh(_Symbol, _Period, centerShift + k)) { isPH = false; break; }
                  }
                  if(isPH) g_mtfC_buy_last_pivot_high = hC;

                  if(g_mtfC_buy_last_pivot_high > 0.0 && cPrev <= g_mtfC_buy_last_pivot_high && c > g_mtfC_buy_last_pivot_high)
                  {
                     int obLook = MathMax(1, InpMtfObLookbackBars);
                     double obH = 0.0, obL = 0.0;
                     for(int i = 2; i <= (obLook + 1); i++)
                     {
                        double oi = iOpen(_Symbol, _Period, i);
                        double ci = iClose(_Symbol, _Period, i);
                        if(oi <= 0.0 || ci <= 0.0) continue;
                        if(ci < oi)
                        {
                           obH = iHigh(_Symbol, _Period, i);
                           obL = iLow(_Symbol, _Period, i);
                           break;
                        }
                     }

                     double fvgL = 0.0, fvgH = 0.0;
                     double h2 = iHigh(_Symbol, _Period, 3);
                     if(h2 > 0.0 && l > h2)
                     {
                        fvgL = h2;
                        fvgH = l;
                     }

                     double zL = 0.0, zH = 0.0;
                     if(InpMtfRetestZoneType == MTF_ZONE_OB)
                     {
                        zL = obL; zH = obH;
                     }
                     else if(InpMtfRetestZoneType == MTF_ZONE_FVG)
                     {
                        zL = fvgL; zH = fvgH;
                     }
                     else
                     {
                        if(obL > 0.0 && obH > 0.0) { zL = obL; zH = obH; }
                        if(fvgL > 0.0 && fvgH > 0.0)
                        {
                           if(zL <= 0.0 || fvgL < zL) zL = fvgL;
                           if(zH <= 0.0 || fvgH > zH) zH = fvgH;
                        }
                     }

                     if(zL > 0.0 && zH > 0.0 && zL < zH)
                     {
                        g_mtfC_buy_zone_low = zL;
                        g_mtfC_buy_zone_high = zH;
                        g_mtfC_buy_state = 1;
                     }
                  }
               }
               else if(g_mtfC_buy_state == 1)
               {
                  if(g_mtfC_buy_zone_low > 0.0 && g_mtfC_buy_zone_high > 0.0 && l <= g_mtfC_buy_zone_high && h >= g_mtfC_buy_zone_low)
                  {
                     double slBuf = (double)InpMtfSlBufferPoints * _Point;
                     double slFixed = g_mtfC_buy_struct_low - slBuf;
                     if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
                     if(!HasPosition(+1))
                     {
                        if(SpreadOk() && TryEnterWithSLTag(true, tBarOpen, c, slFixed, "BUY MTF C")) g_buy_done = true;
                     }
                     g_mtf_buy_active = false;
                     g_mtf_buy_bars = 0;
                     g_mtfA_buy_state = 0;
                     g_mtfC_buy_state = 0;
                  }
               }
            }
         }
      }

      if(g_mtf_sell_active && !(InpMaxOneTradePerDayPerSide && g_sell_done) && !HasPosition(-1))
      {
         if(g_mtfC_sell_struct_high <= 0.0 || h > g_mtfC_sell_struct_high) g_mtfC_sell_struct_high = h;

         if(InpMtfUseSetupA_ReclaimBreak)
         {
            if(g_mtfA_sell_state == 0) g_mtfA_sell_state = 1;

            if(g_mtfA_sell_state == 1)
            {
               if(cPrev >= g_mtf_sell_level && c < g_mtf_sell_level)
               {
                  g_mtfA_sell_reclaim_high = h;
                  g_mtfA_sell_reclaim_low = l;
                  g_mtfA_sell_state = 2;
               }
            }
            else if(g_mtfA_sell_state == 2)
            {
               if(g_mtfA_sell_reclaim_low > 0.0 && cPrev >= g_mtfA_sell_reclaim_low && c < g_mtfA_sell_reclaim_low)
               {
                  if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
                  if(!HasPosition(-1))
                  {
                     if(SpreadOk() && TryEnterWithSLTag(false, tBarOpen, c, g_mtfA_sell_reclaim_high, "SELL MTF A")) g_sell_done = true;
                  }
                  g_mtf_sell_active = false;
                  g_mtf_sell_bars = 0;
                  g_mtfA_sell_state = 0;
               }
            }
         }

         if(g_mtf_sell_active && InpMtfUseSetupB_SweepSfp)
         {
            double highestPrev = HighestPrevHigh(look);
            if(highestPrev > 0.0 && h > (highestPrev + buf) && c < highestPrev)
            {
               if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
               if(!HasPosition(-1))
               {
                  if(SpreadOk() && TryEnterWithSLTag(false, tBarOpen, c, h, "SELL MTF B")) g_sell_done = true;
               }
               g_mtf_sell_active = false;
               g_mtf_sell_bars = 0;
               g_mtfA_sell_state = 0;
               g_mtfC_sell_state = 0;
            }
         }

         if(g_mtf_sell_active && InpMtfUseSetupC_ChoChRetest)
         {
            int piv = MathMax(1, InpMtfChoChPivotLen);
            int centerShift = piv + 1;
            int needBars = centerShift + piv + 2;
            if(iBars(_Symbol, _Period) >= needBars)
            {
               if(g_mtfC_sell_state == 0)
               {
                  bool isPL = true;
                  double lC = iLow(_Symbol, _Period, centerShift);
                  for(int k = 1; k <= piv; k++)
                  {
                     if(lC >= iLow(_Symbol, _Period, centerShift - k)) { isPL = false; break; }
                     if(lC >= iLow(_Symbol, _Period, centerShift + k)) { isPL = false; break; }
                  }
                  if(isPL) g_mtfC_sell_last_pivot_low = lC;

                  if(g_mtfC_sell_last_pivot_low > 0.0 && cPrev >= g_mtfC_sell_last_pivot_low && c < g_mtfC_sell_last_pivot_low)
                  {
                     int obLook = MathMax(1, InpMtfObLookbackBars);
                     double obH = 0.0, obL = 0.0;
                     for(int i = 2; i <= (obLook + 1); i++)
                     {
                        double oi = iOpen(_Symbol, _Period, i);
                        double ci = iClose(_Symbol, _Period, i);
                        if(oi <= 0.0 || ci <= 0.0) continue;
                        if(ci > oi)
                        {
                           obH = iHigh(_Symbol, _Period, i);
                           obL = iLow(_Symbol, _Period, i);
                           break;
                        }
                     }

                     double fvgL = 0.0, fvgH = 0.0;
                     double l2 = iLow(_Symbol, _Period, 3);
                     if(l2 > 0.0 && h < l2)
                     {
                        fvgL = h;
                        fvgH = l2;
                     }

                     double zL = 0.0, zH = 0.0;
                     if(InpMtfRetestZoneType == MTF_ZONE_OB)
                     {
                        zL = obL; zH = obH;
                     }
                     else if(InpMtfRetestZoneType == MTF_ZONE_FVG)
                     {
                        zL = fvgL; zH = fvgH;
                     }
                     else
                     {
                        if(obL > 0.0 && obH > 0.0) { zL = obL; zH = obH; }
                        if(fvgL > 0.0 && fvgH > 0.0)
                        {
                           if(zL <= 0.0 || fvgL < zL) zL = fvgL;
                           if(zH <= 0.0 || fvgH > zH) zH = fvgH;
                        }
                     }

                     if(zL > 0.0 && zH > 0.0 && zL < zH)
                     {
                        g_mtfC_sell_zone_low = zL;
                        g_mtfC_sell_zone_high = zH;
                        g_mtfC_sell_state = 1;
                     }
                  }
               }
               else if(g_mtfC_sell_state == 1)
               {
                  if(g_mtfC_sell_zone_low > 0.0 && g_mtfC_sell_zone_high > 0.0 && l <= g_mtfC_sell_zone_high && h >= g_mtfC_sell_zone_low)
                  {
                     double slBuf = (double)InpMtfSlBufferPoints * _Point;
                     double slFixed = g_mtfC_sell_struct_high + slBuf;
                     if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
                     if(!HasPosition(-1))
                     {
                        if(SpreadOk() && TryEnterWithSLTag(false, tBarOpen, c, slFixed, "SELL MTF C")) g_sell_done = true;
                     }
                     g_mtf_sell_active = false;
                     g_mtf_sell_bars = 0;
                     g_mtfA_sell_state = 0;
                     g_mtfC_sell_state = 0;
                  }
               }
            }
         }
      }

      g_last_bar_time = t0;
      return;
   }

   if(InpTradeOnlyInstitutionalSwing)
   {
      bool instBuyTouch = (g_inst_touch_buy_time == tBarOpen);
      bool instSellTouch = (g_inst_touch_sell_time == tBarOpen);

      if(instBuyTouch && g_inst_swing_low_has)
      {
         if(!(InpMaxOneTradePerDayPerSide && g_buy_done))
         {
            if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
            if(!HasPosition(+1))
            {
               if(SpreadOk() && TryEnterWithSLTag(true, tBarOpen, c, g_inst_swing_low, "BUY InstSwing")) g_buy_done = true;
            }
         }
      }
      if(instSellTouch && g_inst_swing_high_has)
      {
         if(!(InpMaxOneTradePerDayPerSide && g_sell_done))
         {
            if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
            if(!HasPosition(-1))
            {
               if(SpreadOk() && TryEnterWithSLTag(false, tBarOpen, c, g_inst_swing_high, "SELL InstSwing")) g_sell_done = true;
            }
         }
      }

      g_last_bar_time = t0;
      return;
   }

   if(InpTradeOnlySwingPattern)
   {
      if(InpSwingRequireReclaimAfterSweep && g_h13_has)
      {
         bool inKill = InWindowLocal(tBarOpen, 14, 30, 16, 30);
         if(inKill)
         {
            if(l < g_h13_low)
            {
               g_swing_last_sweep_low_level = g_h13_low;
               g_swing_allow_buy = false;
            }
            if(h > g_h13_high)
            {
               g_swing_last_sweep_high_level = g_h13_high;
               g_swing_allow_sell = false;
            }
         }

         double cPrev = iClose(_Symbol, _Period, 2);
         if(!g_swing_allow_buy && g_swing_last_sweep_low_level > 0.0 && cPrev <= g_swing_last_sweep_low_level && c > g_swing_last_sweep_low_level)
            g_swing_allow_buy = true;
         if(!g_swing_allow_sell && g_swing_last_sweep_high_level > 0.0 && cPrev >= g_swing_last_sweep_high_level && c < g_swing_last_sweep_high_level)
            g_swing_allow_sell = true;
      }

      bool isEntryTimeSwing = true;
      if(InpSwingUseEntryTimeFilter) isEntryTimeSwing = IsEntryTimeLocal(tBarOpen);
      if(isEntryTimeSwing)
      {
         int left = MathMax(1, InpSwingLeftBars);
         int right = MathMax(1, InpSwingRightBars);
         int centerShift = right + 1;
         int needBars = centerShift + left + 2;
         if(iBars(_Symbol, _Period) >= needBars)
         {
            double hC = iHigh(_Symbol, _Period, centerShift);
            double lC = iLow(_Symbol, _Period, centerShift);
            double oR = iOpen(_Symbol, _Period, right);
            double cR = iClose(_Symbol, _Period, right);
            double hR = iHigh(_Symbol, _Period, right);
            double lR = iLow(_Symbol, _Period, right);

            double minRange = (double)InpSwingMinSwingRangePoints * _Point;
            double sep = (double)InpSwingMinReactionSepPoints * _Point;
            bool rangeOk = ((hC - lC) >= minRange);

            bool sh = true;
            bool sl = true;
            for(int off = -right; off <= left; off++)
            {
               int s = centerShift + off;
               if(s == centerShift) continue;
               double hh = iHigh(_Symbol, _Period, s);
               if(hh >= hC) sh = false;
               double ll = iLow(_Symbol, _Period, s);
               if(ll <= lC) sl = false;
            }

            if(!InpSwingUseInstitutionalSwings)
            {
               for(int k = left; sh && k >= 1; k--)
               {
                  if(iHigh(_Symbol, _Period, centerShift + k) >= iHigh(_Symbol, _Period, centerShift + k - 1)) sh = false;
               }
               for(int k = 1; sh && k <= right; k++)
               {
                  if(iHigh(_Symbol, _Period, centerShift - k) >= iHigh(_Symbol, _Period, centerShift - k + 1)) sh = false;
               }

               for(int k = left; sl && k >= 1; k--)
               {
                  if(iLow(_Symbol, _Period, centerShift + k) <= iLow(_Symbol, _Period, centerShift + k - 1)) sl = false;
               }
               for(int k = 1; sl && k <= right; k++)
               {
                  if(iLow(_Symbol, _Period, centerShift - k) <= iLow(_Symbol, _Period, centerShift - k + 1)) sl = false;
               }
            }

            bool reactBearOk = (cR < oR && hR < (hC - sep) && oR < (hC - sep) && cR < (hC - sep));
            bool reactBullOk = (cR > oR && lR > (lC + sep) && oR > (lC + sep) && cR > (lC + sep));
            bool bosBearOk = (!InpSwingConfirmBos || c < lR);
            bool bosBullOk = (!InpSwingConfirmBos || c > hR);

            sh = sh && rangeOk && reactBearOk && bosBearOk;
            sl = sl && rangeOk && reactBullOk && bosBullOk;

            if(InpSwingRequireReclaimAfterSweep)
            {
               sh = sh && g_swing_allow_sell;
               sl = sl && g_swing_allow_buy;
            }

            if(sl && !sh)
            {
               if(!(InpMaxOneTradePerDayPerSide && g_buy_done))
               {
                  if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
                  if(!HasPosition(+1))
                  {
                     if(SpreadOk() && TryEnterWithSLTag(true, tBarOpen, c, lC, "BUY Swing")) g_buy_done = true;
                  }
               }
            }
            if(sh && !sl)
            {
               if(!(InpMaxOneTradePerDayPerSide && g_sell_done))
               {
                  if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
                  if(!HasPosition(-1))
                  {
                     if(SpreadOk() && TryEnterWithSLTag(false, tBarOpen, c, hC, "SELL Swing")) g_sell_done = true;
                  }
               }
            }
         }
      }

      g_last_bar_time = t0;
      return;
   }

   int entrySlot = EntrySlotLocal(tBarOpen);
   bool isEntryTime = (entrySlot != 0);
   bool c02AboveLondon = (g_h02_has && g_london_range_has && g_h02_high > g_london_high && g_h02_low > g_london_high);
   bool dirOkB = true;
   bool dirOkS = true;
   if(InpUseAsiaLondonSell13 && entrySlot == 13)
   {
      dirOkB = false;
      dirOkS = c02AboveLondon;
   }

   if(InpUseHammerSlots && (entrySlot == 13 || entrySlot == 16))
   {
      double candleSize = MathAbs(h - l);
      bool isHammer = (candleSize > 0.0 && (h - InpHammerFibLevel * candleSize) < MathMin(o, c));
      bool isShoot = (candleSize > 0.0 && (l + InpHammerFibLevel * candleSize) > MathMax(o, c));
      bool doBuy = (isHammer && !isShoot);
      bool doSell = (isShoot && !isHammer);

      if(doBuy && dirOkB)
      {
         if(!(InpMaxOneTradePerDayPerSide && g_buy_done))
         {
            if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
            if(!HasPosition(+1))
            {
               if(SpreadOk() && TryEnter(true, tBarOpen, c)) g_buy_done = true;
            }
         }
      }
      if(doSell && dirOkS)
      {
         if(!(InpMaxOneTradePerDayPerSide && g_sell_done))
         {
            if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
            if(!HasPosition(-1))
            {
               if(SpreadOk() && TryEnter(false, tBarOpen, c)) g_sell_done = true;
            }
         }
      }
   }

   if(InpHammerFibRetraceEnabled)
   {
      string dayPfx = g_prefix + IntegerToString(g_day_key) + "_";
      double candleSize = MathAbs(h - l);
      bool isGreen = (o < c);
      bool isRed = (o > c);
      bool isHammer = (candleSize > 0.0 && (h - InpHammerFibLevel * candleSize) < MathMin(o, c));
      bool isShoot = (candleSize > 0.0 && (l + InpHammerFibLevel * candleSize) > MathMax(o, c));

      bool createFib = false;
      int dir = 0;
      datetime pTime = 0;
      double pHigh = 0.0;
      double pLow = 0.0;
      datetime expiry = 0;

      if(!InpHammerFibConfirmNextCandle)
      {
         if(isHammer || isShoot)
         {
            createFib = true;
            dir = isHammer ? 1 : -1;
            pTime = tBarOpen;
            pHigh = h;
            pLow = l;
            expiry = tBarOpen + (datetime)PeriodSeconds(_Period);
         }
      }
      else
      {
         if(g_hs_prev_hammer && isGreen && g_hs_prev_time != 0)
         {
            createFib = true;
            dir = 1;
            pTime = g_hs_prev_time;
            pHigh = g_hs_prev_high;
            pLow = g_hs_prev_low;
            expiry = tBarOpen;
         }
         else if(g_hs_prev_shoot && isRed && g_hs_prev_time != 0)
         {
            createFib = true;
            dir = -1;
            pTime = g_hs_prev_time;
            pHigh = g_hs_prev_high;
            pLow = g_hs_prev_low;
            expiry = tBarOpen;
         }
      }

      if(createFib && pHigh > pLow && pTime != 0)
      {
         DeleteByPrefix(dayPfx + "HSFIB_");
         double rng = pHigh - pLow;
         double lv0 = pLow;
         double lv1 = pHigh;
         double lv0382 = pLow + 0.382 * rng;
         double lv05 = pLow + 0.5 * rng;

         string fp = dayPfx + "HSFIB_";
         CreateOrUpdateRay(fp + "0", pTime, lv0, clrSilver, 1);
         CreateOrUpdateRay(fp + "1", pTime, lv1, clrSilver, 1);
         if(InpHammerFibUse0382) CreateOrUpdateRay(fp + "0382", pTime, lv0382, clrOrange, 2);
         if(InpHammerFibUse05) CreateOrUpdateRay(fp + "05", pTime, lv05, clrLimeGreen, 2);
         CreateOrUpdateTrendSegment(fp + "D", pTime, pHigh, pTime + (datetime)PeriodSeconds(_Period) * 20, pLow, clrSilver, STYLE_DASH, 1);

         g_hsfib_pending = true;
         g_hsfib_dir = dir;
         g_hsfib_pattern_time = pTime;
         g_hsfib_high = pHigh;
         g_hsfib_low = pLow;
         g_hsfib_expiry = expiry;
      }

      if(g_hsfib_pending && g_hsfib_expiry != 0 && tBarOpen == g_hsfib_expiry && g_hsfib_high > g_hsfib_low)
      {
         double rng = g_hsfib_high - g_hsfib_low;
         double lv0382 = g_hsfib_low + 0.382 * rng;
         double lv05 = g_hsfib_low + 0.5 * rng;
         bool touched = (InpHammerFibUse05 && l <= lv05 && h >= lv05) || (InpHammerFibUse0382 && l <= lv0382 && h >= lv0382);
         if(touched)
         {
            bool isBuySig = (g_hsfib_dir > 0);
            string n = dayPfx + (isBuySig ? "SIG_FIB_BUY_" : "SIG_FIB_SELL_") + IntegerToString((long)tBarOpen);
            CreateOrUpdateArrow(n, tBarOpen, isBuySig ? (l - 12 * _Point) : (h + 12 * _Point), isBuySig);

            if(isBuySig)
            {
               if(!(InpMaxOneTradePerDayPerSide && g_buy_done))
               {
                  if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
                  if(!HasPosition(+1))
                  {
                     if(SpreadOk() && TryEnterWithSL(true, tBarOpen, c, g_hsfib_low)) g_buy_done = true;
                  }
               }
            }
            else
            {
               if(!(InpMaxOneTradePerDayPerSide && g_sell_done))
               {
                  if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
                  if(!HasPosition(-1))
                  {
                     if(SpreadOk() && TryEnterWithSL(false, tBarOpen, c, g_hsfib_high)) g_sell_done = true;
                  }
               }
            }

            g_hsfib_pending = false;
         }
         else
         {
            DeleteByPrefix(dayPfx + "HSFIB_");
            g_hsfib_pending = false;
            g_hsfib_dir = 0;
            g_hsfib_pattern_time = 0;
            g_hsfib_high = 0.0;
            g_hsfib_low = 0.0;
            g_hsfib_expiry = 0;
         }
      }
      else if(g_hsfib_pending && g_hsfib_expiry != 0 && tBarOpen > g_hsfib_expiry)
      {
         DeleteByPrefix(dayPfx + "HSFIB_");
         g_hsfib_pending = false;
         g_hsfib_dir = 0;
         g_hsfib_pattern_time = 0;
         g_hsfib_high = 0.0;
         g_hsfib_low = 0.0;
         g_hsfib_expiry = 0;
      }

      g_hs_prev_hammer = isHammer;
      g_hs_prev_shoot = isShoot;
      g_hs_prev_time = tBarOpen;
      g_hs_prev_high = h;
      g_hs_prev_low = l;
   }

   bool instBuyTouch = (g_inst_touch_buy_time == tBarOpen);
   bool instSellTouch = (g_inst_touch_sell_time == tBarOpen);
   if(instBuyTouch)
   {
      if(!(InpMaxOneTradePerDayPerSide && g_buy_done))
      {
         if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
         if(!HasPosition(+1))
         {
            if(SpreadOk() && TryEnter(true, tBarOpen, c)) g_buy_done = true;
         }
      }
   }
   if(instSellTouch)
   {
      if(!(InpMaxOneTradePerDayPerSide && g_sell_done))
      {
         if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
         if(!HasPosition(-1))
         {
            if(SpreadOk() && TryEnter(false, tBarOpen, c)) g_sell_done = true;
         }
      }
   }

   if(g_ib_has && g_h13_has)
   {
      double ibMid = (g_ib_high + g_ib_low) / 2.0;
      bool dailyOkB = (!InpUseDailyOpenFilter || (g_daily_has && c > g_daily_open));
      bool dailyOkS = (!InpUseDailyOpenFilter || (g_daily_has && c < g_daily_open));
      bool ibOkB = (!InpUseIbMidFilter || (c > ibMid));
      bool ibOkS = (!InpUseIbMidFilter || (c < ibMid));
      bool manipOkB = (!InpRequireManipulation || g_mid_sweep_down || g_ib_sweep_down);
      bool manipOkS = (!InpRequireManipulation || g_mid_sweep_up || g_ib_sweep_up);
      bool asiaOkB = (!InpUseAsiaTrendFilter || (g_asia_has && g_asia_open > 0.0 && g_asia_close < g_asia_open));
      bool asiaOkS = (!InpUseAsiaTrendFilter || (g_asia_has && g_asia_open > 0.0 && g_asia_close > g_asia_open));
      double buf = (double)InpBreakoutBufferPoints * _Point;
      double h13Rng = g_h13_high - g_h13_low;
      bool h13RangeOk = (InpMinH13RangePoints <= 0) || (h13Rng >= (double)InpMinH13RangePoints * _Point);
      bool validB = (dirOkB && h13RangeOk && c > (g_h13_high + buf) && isEntryTime && !g_buy_done && dailyOkB && ibOkB && manipOkB && asiaOkB);
      bool validS = (dirOkS && h13RangeOk && c < (g_h13_low - buf) && isEntryTime && !g_sell_done && dailyOkS && ibOkS && manipOkS && asiaOkS);

      if(validB)
      {
         if(InpMaxOneTradePerDayPerSide && g_buy_done) { g_last_bar_time = t0; return; }
         if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
         if(!HasPosition(+1))
         {
            if(SpreadOk() && TryEnter(true, tBarOpen, c)) g_buy_done = true;
         }
      }

      if(validS)
      {
         if(InpMaxOneTradePerDayPerSide && g_sell_done) { g_last_bar_time = t0; return; }
         if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
         if(!HasPosition(-1))
         {
            if(SpreadOk() && TryEnter(false, tBarOpen, c)) g_sell_done = true;
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
      bool asiaOkB = (!InpUseAsiaTrendFilter || (g_asia_has && g_asia_open > 0.0 && g_asia_close < g_asia_open));
      bool asiaOkS = (!InpUseAsiaTrendFilter || (g_asia_has && g_asia_open > 0.0 && g_asia_close > g_asia_open));

      bool canLong = g_mid_sweep_down && !g_mid_long_done;
      if(canLong && InpReclaimMaxBars > 0 && g_mid_sweep_down_bar >= 0)
      {
         int barsSince = g_update_calls - g_mid_sweep_down_bar;
         if(barsSince > InpReclaimMaxBars) canLong = false;
      }
      bool longSig = (dirOkB && canLong && c > g_mid_low && isEntryTime && dailyOkB && ibOkB && asiaOkB);

      bool canShort = g_mid_sweep_up && !g_mid_short_done;
      if(canShort && InpReclaimMaxBars > 0 && g_mid_sweep_up_bar >= 0)
      {
         int barsSince = g_update_calls - g_mid_sweep_up_bar;
         if(barsSince > InpReclaimMaxBars) canShort = false;
      }
      bool shortSig = (dirOkS && canShort && c < g_mid_high && isEntryTime && dailyOkS && ibOkS && asiaOkS);

      if(longSig)
      {
         if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
         if(!HasPosition(+1))
         {
            if(SpreadOk() && TryEnter(true, tBarOpen, c)) g_mid_long_done = true;
         }
      }
      if(shortSig)
      {
         if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
         if(!HasPosition(-1))
         {
            if(SpreadOk() && TryEnter(false, tBarOpen, c)) g_mid_short_done = true;
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
   if(g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   g_atr_handle = iATR(_Symbol, _Period, InpAtrPeriod);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   DeleteByPrefix(g_prefix);
   if(g_atr_handle != INVALID_HANDLE)
   {
      IndicatorRelease(g_atr_handle);
      g_atr_handle = INVALID_HANDLE;
   }
}

void OnTick()
{
   if(!InpEnabled) return;
   ProcessSignalOnNewBar();
   ManagePartialTp();
   ManageBreakEven();
}
