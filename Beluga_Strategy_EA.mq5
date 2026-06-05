#property strict
#property version "1.00"

#include <Trade/Trade.mqh>

input group "Beluga Strategy"
input bool InpEnabled = true;
input double InpLots = 0.10;
input int InpDeviationPoints = 50;

input bool InpUseStopLoss = true;
input bool InpUseTakeProfit = true;
input double InpRiskReward = 2.0;
input bool InpCloseOpposite = true;
input bool InpMaxOneTradePerDayPerSide = true;

input group "Beluga Swing (len)"
input bool InpBelugaUseTfLen = true;
input int InpBelugaLen = 50;
input int InpBelugaLen_M1 = 120;
input int InpBelugaLen_M15 = 50;
input int InpBelugaLen_H1 = 50;
input int InpBelugaLen_H4 = 50;
input int InpBelugaSlBufferPoints = 0;
input double InpBelugaSlBufferPrice = 1.5;

input group "Beluga Draw"
input bool InpBelugaDrawEnabled = true;
input color InpBelugaLowVwapColor = clrLimeGreen;
input color InpBelugaHighVwapColor = clrDodgerBlue;
input int InpBelugaWidth = 2;

input group "Spread Filter"
input bool InpSpreadFilterEnabled = true;
input int InpMaxSpreadPoints = 50;

CTrade trade;
string g_prefix = "BELUGA_EA_";
datetime g_last_bar_time = 0;
datetime g_last_swing_high_time = 0;
datetime g_last_swing_low_time = 0;
int g_day_key = 0;
bool g_buy_done = false;
bool g_sell_done = false;
bool g_bb_trend_has = false;
bool g_bb_trend = false;

int DayKeyServer(const datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return dt.year * 10000 + dt.mon * 100 + dt.day;
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

bool CanOpenTrade(const bool isBuy)
{
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) return false;
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) return false;
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)) return false;

   long mode = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
   if(mode == SYMBOL_TRADE_MODE_DISABLED) return false;
   if(mode == SYMBOL_TRADE_MODE_CLOSEONLY) return false;
   if(isBuy && mode == SYMBOL_TRADE_MODE_SHORTONLY) return false;
   if(!isBuy && mode == SYMBOL_TRADE_MODE_LONGONLY) return false;
   return true;
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

void BelugaDrawActive(const datetime tBarOpen, const datetime indexTime, const color vwapColor, const bool markerUp, const double markerPrice, const bool useLowForVwap)
{
   if(!InpBelugaDrawEnabled) return;
   if(indexTime <= 0) return;

   int shiftIdx = iBarShift(_Symbol, _Period, indexTime, true);
   int shiftCur = iBarShift(_Symbol, _Period, tBarOpen, true);
   if(shiftIdx < 0 || shiftCur < 0) return;
   if(shiftIdx <= shiftCur) return;

   int maxPts = 5000;
   if(shiftIdx - shiftCur > maxPts) shiftIdx = shiftCur + maxPts;

   int pts = (shiftIdx - shiftCur + 1);
   if(pts < 2) return;

   datetime times[];
   double prices[];
   ArrayResize(times, pts);
   ArrayResize(prices, pts);

   double sumPV = 0.0;
   double sumV = 0.0;
   int j = 0;
   for(int s = shiftIdx; s >= shiftCur; s--)
   {
      datetime t = iTime(_Symbol, _Period, s);
      double src = useLowForVwap ? iLow(_Symbol, _Period, s) : iHigh(_Symbol, _Period, s);
      long vL = iVolume(_Symbol, _Period, s);
      double v = (vL > 0 ? (double)vL : 0.0);
      if(src <= 0.0) continue;
      sumPV += src * v;
      sumV += v;
      double vwap = (sumV > 0.0 ? (sumPV / sumV) : src);
      times[j] = t;
      prices[j] = vwap;
      j++;
   }
   if(j < 2) return;
   ArrayResize(times, j);
   ArrayResize(prices, j);

   int w = InpBelugaWidth;
   if(w < 1) w = 1;
   if(w > 5) w = 5;

   string pfx = g_prefix + "BB_ACTIVE_";
   const int maxSeg = 200;
   int step = (j - 1 + maxSeg - 1) / maxSeg;
   if(step < 1) step = 1;

   int seg = 0;
   int prevIdx = 0;
   for(int idx = step; idx < j; idx += step)
   {
      string nm = pfx + "SEG_" + IntegerToString(seg);
      CreateOrUpdateTrendSegment(nm, times[prevIdx], prices[prevIdx], times[idx], prices[idx], vwapColor, STYLE_SOLID, w);
      prevIdx = idx;
      seg++;
      if(seg >= maxSeg) break;
   }
   if(seg < maxSeg && prevIdx < (j - 1))
   {
      string nm = pfx + "SEG_" + IntegerToString(seg);
      CreateOrUpdateTrendSegment(nm, times[prevIdx], prices[prevIdx], times[j - 1], prices[j - 1], vwapColor, STYLE_SOLID, w);
      seg++;
   }
   for(int i = seg; i < maxSeg; i++)
   {
      string nm = pfx + "SEG_" + IntegerToString(i);
      ObjectDelete(0, nm);
   }

   double markPx = markerPrice;
   if(markPx <= 0.0)
   {
      markPx = markerUp ? iLow(_Symbol, _Period, shiftIdx) : iHigh(_Symbol, _Period, shiftIdx);
   }
   CreateOrUpdateArrow(pfx + "MARK", indexTime, markPx, markerUp);
}

void BelugaDrawHistory(const datetime tBarOpen, const datetime indexTime, const bool useLowForVwap, const color baseColor, const bool markerUp)
{
   if(!InpBelugaDrawEnabled) return;
   if(indexTime <= 0) return;

   int shiftIdx = iBarShift(_Symbol, _Period, indexTime, true);
   int shiftCur = iBarShift(_Symbol, _Period, tBarOpen, true);
   if(shiftIdx < 0 || shiftCur < 0) return;
   if(shiftIdx <= shiftCur) return;

   int maxPts = 5000;
   if(shiftIdx - shiftCur > maxPts) shiftIdx = shiftCur + maxPts;

   int pts = (shiftIdx - shiftCur + 1);
   if(pts < 2) return;

   datetime times[];
   double prices[];
   ArrayResize(times, pts);
   ArrayResize(prices, pts);

   double sumPV = 0.0;
   double sumV = 0.0;
   int j = 0;
   for(int s = shiftIdx; s >= shiftCur; s--)
   {
      datetime t = iTime(_Symbol, _Period, s);
      double src = useLowForVwap ? iLow(_Symbol, _Period, s) : iHigh(_Symbol, _Period, s);
      long vL = iVolume(_Symbol, _Period, s);
      double v = (vL > 0 ? (double)vL : 0.0);
      if(src <= 0.0) continue;
      sumPV += src * v;
      sumV += v;
      double vwap = (sumV > 0.0 ? (sumPV / sumV) : src);
      times[j] = t;
      prices[j] = vwap;
      j++;
   }
   if(j < 2) return;
   ArrayResize(times, j);
   ArrayResize(prices, j);

   int w = InpBelugaWidth;
   if(w < 1) w = 1;
   if(w > 5) w = 5;

   string pfx = g_prefix + "BB_HIST_" + IntegerToString((long)indexTime) + "_";
   const int maxSeg = 200;
   int step = (j - 1 + maxSeg - 1) / maxSeg;
   if(step < 1) step = 1;

   int seg = 0;
   int prevIdx = 0;
   for(int idx = step; idx < j; idx += step)
   {
      string nm = pfx + "SEG_" + IntegerToString(seg);
      CreateOrUpdateTrendSegment(nm, times[prevIdx], prices[prevIdx], times[idx], prices[idx], baseColor, STYLE_SOLID, w);
      prevIdx = idx;
      seg++;
      if(seg >= maxSeg) break;
   }
   if(seg < maxSeg && prevIdx < (j - 1))
   {
      string nm = pfx + "SEG_" + IntegerToString(seg);
      CreateOrUpdateTrendSegment(nm, times[prevIdx], prices[prevIdx], times[j - 1], prices[j - 1], baseColor, STYLE_SOLID, w);
      seg++;
   }
   for(int i = seg; i < maxSeg; i++)
   {
      string nm = pfx + "SEG_" + IntegerToString(i);
      ObjectDelete(0, nm);
   }

   double markPx = markerUp ? iLow(_Symbol, _Period, shiftIdx) : iHigh(_Symbol, _Period, shiftIdx);
   CreateOrUpdateArrow(pfx + "MARK", indexTime, markPx, markerUp);
}

double WindowHigh(const int shiftStart, const int count)
{
   int n = count;
   if(n < 1) n = 1;
   if(iBars(_Symbol, _Period) < (shiftStart + n + 1)) return 0.0;
   double v = 0.0;
   for(int sh = shiftStart; sh < shiftStart + n; sh++)
   {
      double x = iHigh(_Symbol, _Period, sh);
      if(x > 0.0 && (v <= 0.0 || x > v)) v = x;
   }
   return v;
}

double WindowLow(const int shiftStart, const int count)
{
   int n = count;
   if(n < 1) n = 1;
   if(iBars(_Symbol, _Period) < (shiftStart + n + 1)) return 0.0;
   double v = 0.0;
   for(int sh = shiftStart; sh < shiftStart + n; sh++)
   {
      double x = iLow(_Symbol, _Period, sh);
      if(x > 0.0 && (v <= 0.0 || x < v)) v = x;
   }
   return v;
}

int BelugaLenForPeriod(const ENUM_TIMEFRAMES tf)
{
   if(!InpBelugaUseTfLen) return InpBelugaLen;
   if(tf == PERIOD_M1) return InpBelugaLen_M1;
   if(tf == PERIOD_M15) return InpBelugaLen_M15;
   if(tf == PERIOD_H1) return InpBelugaLen_H1;
   if(tf == PERIOD_H4) return InpBelugaLen_H4;
   return InpBelugaLen;
}

bool HasPosition(const int dir)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      long type = PositionGetInteger(POSITION_TYPE);
      if(dir > 0 && type == POSITION_TYPE_BUY) return true;
      if(dir < 0 && type == POSITION_TYPE_SELL) return true;
   }
   return false;
}

void ClosePositions(const int dir)
{
   trade.SetDeviationInPoints(InpDeviationPoints);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      long type = PositionGetInteger(POSITION_TYPE);
      if(dir > 0 && type != POSITION_TYPE_BUY) continue;
      if(dir < 0 && type != POSITION_TYPE_SELL) continue;
      trade.PositionClose(ticket);
   }
}

bool EnterWithFixedSL(const bool isBuy, const datetime tSignal, const double barClose, const double slFixed)
{
   if(!CanOpenTrade(isBuy)) return false;
   if(!SpreadOk()) return false;

   double entry = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(entry <= 0.0) entry = barClose;

   double sl = 0.0, tp = 0.0;
   if(InpUseStopLoss)
   {
      if(slFixed <= 0.0) return false;
      sl = slFixed;

      int stopsLevelPts = (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double minDist = (stopsLevelPts > 0 ? (double)stopsLevelPts * _Point : 0.0);
      if(minDist > 0.0)
      {
         if(isBuy && (entry - sl) < minDist) sl = entry - minDist;
         if(!isBuy && (sl - entry) < minDist) sl = entry + minDist;
      }

      double risk = isBuy ? (entry - sl) : (sl - entry);
      if(risk <= 0.0) return false;
      if(InpUseTakeProfit && InpRiskReward > 0.0)
      {
         tp = isBuy ? (entry + InpRiskReward * risk) : (entry - InpRiskReward * risk);
         if(minDist > 0.0)
         {
            if(isBuy && (tp - entry) < minDist) tp = entry + minDist;
            if(!isBuy && (entry - tp) < minDist) tp = entry - minDist;
         }
      }
   }

   trade.SetDeviationInPoints(InpDeviationPoints);
   return isBuy ? trade.Buy(InpLots, _Symbol, 0.0, sl, tp) : trade.Sell(InpLots, _Symbol, 0.0, sl, tp);
}

void ResetDay(const int dayKey)
{
   g_day_key = dayKey;
   g_buy_done = false;
   g_sell_done = false;
}

void ProcessBelugaOnNewBar()
{
   datetime t0 = iTime(_Symbol, _Period, 0);
   if(t0 == 0) return;
   if(t0 == g_last_bar_time) return;

   int dk = DayKeyServer(t0);
   if(dk != g_day_key) ResetDay(dk);

   datetime tPrevBarOpen = iTime(_Symbol, _Period, 1);
   if(tPrevBarOpen == 0) { g_last_bar_time = t0; return; }

   int len = BelugaLenForPeriod((ENUM_TIMEFRAMES)_Period);
   if(len < 1) len = 1;
   if(iBars(_Symbol, _Period) < (len + 3)) { g_last_bar_time = t0; return; }

   double high0 = iHigh(_Symbol, _Period, 0);
   double low0 = iLow(_Symbol, _Period, 0);
   double high1 = iHigh(_Symbol, _Period, 1);
   double low1 = iLow(_Symbol, _Period, 1);
   double close1 = iClose(_Symbol, _Period, 1);
   if(high0 <= 0.0 || low0 <= 0.0 || high1 <= 0.0 || low1 <= 0.0 || close1 <= 0.0) { g_last_bar_time = t0; return; }

   double highestPrev = WindowHigh(1, len);
   double highestCur = WindowHigh(0, len);
   double lowestPrev = WindowLow(1, len);
   double lowestCur = WindowLow(0, len);
   if(highestPrev <= 0.0 || highestCur <= 0.0 || lowestPrev <= 0.0 || lowestCur <= 0.0) { g_last_bar_time = t0; return; }

   bool swingHigh = (high1 == highestPrev) && (high0 < highestCur);
   bool swingLow = (low1 == lowestPrev) && (low0 > lowestCur);
   if(swingHigh && swingLow) { swingHigh = false; swingLow = false; }

   int slBufPts = InpBelugaSlBufferPoints;
   if(slBufPts < 0) slBufPts = 0;
   double slBuf = MathMax((double)slBufPts * _Point, MathMax(0.0, InpBelugaSlBufferPrice));

   bool prevTrendHas = g_bb_trend_has;
   bool prevTrend = g_bb_trend;
   bool anySwing = false;

   if(swingLow && tPrevBarOpen != g_last_swing_low_time)
   {
      g_last_swing_low_time = tPrevBarOpen;
      anySwing = true;
      g_bb_trend_has = true;
      g_bb_trend = true;
      CreateOrUpdateArrow(g_prefix + "SL_" + IntegerToString((long)tPrevBarOpen), tPrevBarOpen, low1 - 12 * _Point, true);

      if(!(InpMaxOneTradePerDayPerSide && g_buy_done))
      {
         if(InpCloseOpposite && HasPosition(-1)) ClosePositions(-1);
         if(!HasPosition(+1))
         {
            double slFixed = low1 - slBuf;
            if(EnterWithFixedSL(true, tPrevBarOpen, close1, slFixed)) g_buy_done = true;
         }
      }
   }

   if(swingHigh && tPrevBarOpen != g_last_swing_high_time)
   {
      g_last_swing_high_time = tPrevBarOpen;
      anySwing = true;
      g_bb_trend_has = true;
      g_bb_trend = false;
      CreateOrUpdateArrow(g_prefix + "SH_" + IntegerToString((long)tPrevBarOpen), tPrevBarOpen, high1 + 12 * _Point, false);

      if(!(InpMaxOneTradePerDayPerSide && g_sell_done))
      {
         if(InpCloseOpposite && HasPosition(+1)) ClosePositions(+1);
         if(!HasPosition(-1))
         {
            double slFixed = high1 + slBuf;
            if(EnterWithFixedSL(false, tPrevBarOpen, close1, slFixed)) g_sell_done = true;
         }
      }
   }

   if(anySwing && prevTrendHas && g_bb_trend_has && g_bb_trend != prevTrend)
   {
      if(g_bb_trend) BelugaDrawHistory(tPrevBarOpen, g_last_swing_high_time, false, InpBelugaHighVwapColor, false);
      else BelugaDrawHistory(tPrevBarOpen, g_last_swing_low_time, true, InpBelugaLowVwapColor, true);
   }

   if(InpBelugaDrawEnabled && g_bb_trend_has)
   {
      if(g_bb_trend)
      {
         datetime idxT = g_last_swing_low_time;
         int sIdx = iBarShift(_Symbol, _Period, idxT, true);
         double markPx = (sIdx >= 0 ? iLow(_Symbol, _Period, sIdx) : 0.0);
         BelugaDrawActive(tPrevBarOpen, idxT, InpBelugaLowVwapColor, true, markPx, true);
      }
      else
      {
         datetime idxT = g_last_swing_high_time;
         int sIdx = iBarShift(_Symbol, _Period, idxT, true);
         double markPx = (sIdx >= 0 ? iHigh(_Symbol, _Period, sIdx) : 0.0);
         BelugaDrawActive(tPrevBarOpen, idxT, InpBelugaHighVwapColor, false, markPx, false);
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
   ProcessBelugaOnNewBar();
}
