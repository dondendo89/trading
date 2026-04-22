#property strict
#property version   "1.00"

#include <Trade/Trade.mqh>

input group "Matteo Capital"
input bool InpEnabled = true;
input ulong InpMagic = 20260221;
input double InpLots = 0.10;
input int InpDeviationPoints = 50;

input ENUM_TIMEFRAMES InpSignalTf = PERIOD_M15;
input int InpIbHour = 9;
input int InpLocalOffsetHours = 0;

input int InpNyStartHour = 15;
input int InpNyStartMinute = 0;
input int InpNyEndHour = 16;
input int InpNyEndMinute = 30;
input bool InpTradeOnlyInNy = true;

input bool InpVolFilterEnabled = true;
input int InpVolMaLen = 20;
input double InpVolMinMult = 0.7;

input bool InpOnlyExpansion = false;
input bool InpMaxOneTradePerDay = false;
input bool InpSpreadFilterEnabled = false;
input int InpMaxSpreadPoints = 50;

input bool InpPartialEnabled = false;
input double InpPartialPercent = 50.0;
input double InpPartialTpMult = 0.5;
input bool InpMoveSlToBeAfterPartial = true;
input int InpBeOffsetPoints = 0;

input bool InpUseStopLoss = true;
input bool InpUseTakeProfit = true;
input double InpTakeProfitMult = 1.0;

input bool InpDebugDailyInfo = true;

CTrade trade;
datetime g_last_signal_bar_time = 0;
int g_last_trade_day_key = -1;
ulong g_managed_ticket = 0;
bool g_partial_done = false;
bool g_be_moved = false;
int g_last_ib_print_day_key = -1;

int DayKeyLocalFromServer(const datetime tServer, const int offsetHours)
{
   datetime tLocal = tServer + (datetime)offsetHours * 3600;
   MqlDateTime dt;
   TimeToStruct(tLocal, dt);
   return dt.year * 10000 + dt.mon * 100 + dt.day;
}

ENUM_TIMEFRAMES NormalizeTf(ENUM_TIMEFRAMES tf)
{
   int v = (int)tf;
   if(v >= 16384)
      v -= 16384;
   if(v <= 0)
      v = Period();
   return (ENUM_TIMEFRAMES)v;
}

int TfSeconds(ENUM_TIMEFRAMES tf)
{
   ENUM_TIMEFRAMES n = NormalizeTf(tf);
   int sec = PeriodSeconds(n);
   if(sec > 0) return sec;
   int v = (int)n;
   if(v <= 0) v = Period();
   return v * 60;
}

string TimeToStringLocal(const datetime tServer, const int offsetHours)
{
   datetime tLocal = tServer + (datetime)offsetHours * 3600;
   return TimeToString(tLocal, TIME_DATE|TIME_MINUTES);
}

bool InLocalWindow(const datetime tServer, const int offsetHours, const int h1, const int m1, const int h2, const int m2)
{
   datetime tLocal = tServer + (datetime)offsetHours * 3600;
   MqlDateTime dt;
   TimeToStruct(tLocal, dt);
   int cur = dt.hour * 60 + dt.min;
   int a = h1 * 60 + m1;
   int b = h2 * 60 + m2;
   return (cur >= a && cur < b);
}

bool FindH1BarShiftAtLocalHour(const datetime nowServer, const int offsetHours, const int targetHour, int &outShift, datetime &outOpenServer)
{
   outShift = -1;
   outOpenServer = 0;
   int dayKey = DayKeyLocalFromServer(nowServer, offsetHours);
   for(int s = 0; s < 96; s++)
   {
      datetime t = iTime(_Symbol, PERIOD_H1, s);
      if(t == 0) break;
      if(DayKeyLocalFromServer(t, offsetHours) != dayKey) continue;
      datetime tLocal = t + (datetime)offsetHours * 3600;
      MqlDateTime dt;
      TimeToStruct(tLocal, dt);
      if(dt.hour == targetHour && dt.min == 0)
      {
         outShift = s;
         outOpenServer = t;
         return true;
      }
   }
   return false;
}

bool GetIbFromH1(const datetime nowServer, double &ibh, double &ibl, datetime &ibOpenServer)
{
   ibh = 0.0;
   ibl = 0.0;
   ibOpenServer = 0;
   int shift = -1;
   datetime openServer = 0;
   if(!FindH1BarShiftAtLocalHour(nowServer, InpLocalOffsetHours, InpIbHour, shift, openServer)) return false;
   double hi = iHigh(_Symbol, PERIOD_H1, shift);
   double lo = iLow(_Symbol, PERIOD_H1, shift);
   if(hi == 0.0 && lo == 0.0) return false;
   ibh = hi;
   ibl = lo;
   ibOpenServer = openServer;
   return (ibh > ibl);
}

double AvgTickVolTf(const ENUM_TIMEFRAMES tf, const datetime tBarOpen, const int len)
{
   if(len <= 0) return 0.0;
   ENUM_TIMEFRAMES n = NormalizeTf(tf);
   int shift = iBarShift(_Symbol, n, tBarOpen, true);
   if(shift < 0) return 0.0;
   long vols[];
   ArrayResize(vols, len);
   ArraySetAsSeries(vols, true);
   int copied = CopyTickVolume(_Symbol, n, shift, len, vols);
   if(copied <= 0) return 0.0;
   double sum = 0.0;
   for(int i = 0; i < copied; i++) sum += (double)vols[i];
   return (copied > 0) ? (sum / (double)copied) : 0.0;
}

bool HasPosition(const int direction, ulong &ticketOut)
{
   ticketOut = 0;
   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      int type = (int)PositionGetInteger(POSITION_TYPE);
      if(direction > 0 && type == POSITION_TYPE_BUY) { ticketOut = ticket; return true; }
      if(direction < 0 && type == POSITION_TYPE_SELL) { ticketOut = ticket; return true; }
   }
   return false;
}

void CloseAllPositions()
{
   int total = PositionsTotal();
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      trade.PositionClose(ticket);
   }
}

bool GetOurSinglePosition(ulong &ticketOut)
{
   ticketOut = 0;
   int total = PositionsTotal();
   for(int i = 0; i < total; i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      ticketOut = ticket;
      return true;
   }
   return false;
}

double NormalizeVolumeDown(const double vol, const double step, const double minVol)
{
   if(step <= 0.0) return 0.0;
   double v = MathFloor(vol / step) * step;
   if(v < minVol) return 0.0;
   return v;
}

void ManageOpenPosition()
{
   if(!InpEnabled) return;
   if(!InpPartialEnabled && !InpMoveSlToBeAfterPartial) return;

   ulong ticket = 0;
   if(!GetOurSinglePosition(ticket))
   {
      g_managed_ticket = 0;
      g_partial_done = false;
      g_be_moved = false;
      return;
   }

   if(ticket != g_managed_ticket)
   {
      g_managed_ticket = ticket;
      g_partial_done = false;
      g_be_moved = false;
   }

   int type = (int)PositionGetInteger(POSITION_TYPE);
   double vol = PositionGetDouble(POSITION_VOLUME);
   double entry = PositionGetDouble(POSITION_PRICE_OPEN);
   double sl = PositionGetDouble(POSITION_SL);
   double tp = PositionGetDouble(POSITION_TP);

   double ibh = 0.0, ibl = 0.0;
   datetime ibOpen = 0;
   if(!GetIbFromH1(TimeCurrent(), ibh, ibl, ibOpen)) return;
   double rng = ibh - ibl;
   if(rng <= 0.0) return;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   if(bid <= 0.0 || ask <= 0.0) return;

   double tp1 = 0.0;
   if(type == POSITION_TYPE_BUY) tp1 = ibh + InpPartialTpMult * rng;
   if(type == POSITION_TYPE_SELL) tp1 = ibl - InpPartialTpMult * rng;

   bool reached = false;
   if(type == POSITION_TYPE_BUY) reached = (bid >= tp1);
   if(type == POSITION_TYPE_SELL) reached = (ask <= tp1);

   if(InpPartialEnabled && !g_partial_done && reached)
   {
      double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double closeVol = NormalizeVolumeDown(vol * (InpPartialPercent / 100.0), step, minVol);
      bool ok = false;
      if(closeVol > 0.0 && closeVol < vol)
         ok = trade.PositionClosePartial(ticket, closeVol);
      g_partial_done = ok || closeVol <= 0.0 || closeVol >= vol;
   }

   if(InpMoveSlToBeAfterPartial && !g_be_moved && (g_partial_done || !InpPartialEnabled) && reached)
   {
      double be = entry;
      if(type == POSITION_TYPE_BUY) be = entry + (double)InpBeOffsetPoints * _Point;
      if(type == POSITION_TYPE_SELL) be = entry - (double)InpBeOffsetPoints * _Point;

      bool shouldMove = false;
      if(type == POSITION_TYPE_BUY) shouldMove = (sl <= 0.0 || sl < be);
      if(type == POSITION_TYPE_SELL) shouldMove = (sl <= 0.0 || sl > be);

      if(shouldMove)
      {
         if(trade.PositionModify(_Symbol, be, tp))
            g_be_moved = true;
      }
      else
      {
         g_be_moved = true;
      }
   }
}

int OnInit()
{
   trade.SetExpertMagicNumber((long)InpMagic);
   trade.SetDeviationInPoints(InpDeviationPoints);
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   ManageOpenPosition();

   if(!InpEnabled) return;

   ENUM_TIMEFRAMES sigTf = NormalizeTf(InpSignalTf);
   MqlRates sigRates[3];
   ArraySetAsSeries(sigRates, true);
   if(CopyRates(_Symbol, sigTf, 0, 3, sigRates) < 3) return;

   datetime curBarOpen = sigRates[0].time;
   datetime prevBarOpen = sigRates[1].time;
   if(prevBarOpen == 0) return;

   if(prevBarOpen == g_last_signal_bar_time) return;

   double ibh = 0.0, ibl = 0.0;
   datetime ibOpen = 0;
   if(!GetIbFromH1(TimeCurrent(), ibh, ibl, ibOpen)) { g_last_signal_bar_time = prevBarOpen; return; }

   datetime prevClose = prevBarOpen + (datetime)TfSeconds(sigTf);
   if(prevClose < (ibOpen + 3600)) { g_last_signal_bar_time = prevBarOpen; return; }

   int dayKey = DayKeyLocalFromServer(prevClose, InpLocalOffsetHours);
   if(InpDebugDailyInfo && dayKey != g_last_ib_print_day_key)
   {
      double midDbg = (ibh + ibl) / 2.0;
      Print("Capital IB day=", dayKey,
            " sigTf=", (int)sigTf, " rawTf=", (int)InpSignalTf,
            " offsetHours=", InpLocalOffsetHours,
            " IBopen(server)=", TimeToString(ibOpen, TIME_DATE|TIME_MINUTES),
            " IBopen(local)=", TimeToStringLocal(ibOpen, InpLocalOffsetHours),
            " IBH=", DoubleToString(ibh, _Digits),
            " IBL=", DoubleToString(ibl, _Digits),
            " MID=", DoubleToString(midDbg, _Digits),
            " NY=", StringFormat("%02d:%02d-%02d:%02d", InpNyStartHour, InpNyStartMinute, InpNyEndHour, InpNyEndMinute),
            " onlyNY=", (InpTradeOnlyInNy ? "true" : "false"));
      if(InpPartialEnabled && InpUseTakeProfit && InpTakeProfitMult <= InpPartialTpMult)
         Print("Capital note: TakeProfitMult <= PartialTpMult (TP finale coincide/sta prima del parziale). TPmult=", InpTakeProfitMult, " PartialMult=", InpPartialTpMult);
      g_last_ib_print_day_key = dayKey;
   }

   if(InpTradeOnlyInNy)
   {
      if(!InLocalWindow(prevClose, InpLocalOffsetHours, InpNyStartHour, InpNyStartMinute, InpNyEndHour, InpNyEndMinute))
      {
         g_last_signal_bar_time = prevBarOpen;
         return;
      }
   }

   if(InpSpreadFilterEnabled)
   {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(ask > 0.0 && bid > 0.0 && _Point > 0.0)
      {
         int spreadPts = (int)MathRound((ask - bid) / _Point);
         if(spreadPts > InpMaxSpreadPoints)
         {
            g_last_signal_bar_time = prevBarOpen;
            return;
         }
      }
   }

   double mid = (ibh + ibl) / 2.0;
   double rng = ibh - ibl;
   if(rng <= 0.0) { g_last_signal_bar_time = prevBarOpen; return; }

   double volMa = AvgTickVolTf(sigTf, prevBarOpen, InpVolMaLen);
   bool volOk = true;
   if(InpVolFilterEnabled && volMa > 0.0)
      volOk = ((double)sigRates[1].tick_volume) >= (volMa * InpVolMinMult);

   double bodyMin = MathMin(sigRates[1].open, sigRates[1].close);
   double bodyMax = MathMax(sigRates[1].open, sigRates[1].close);
   double prevBodyMin = MathMin(sigRates[2].open, sigRates[2].close);
   double prevBodyMax = MathMax(sigRates[2].open, sigRates[2].close);

   bool breakUp = (bodyMin > ibh && prevBodyMin <= ibh);
   bool breakDn = (bodyMax < ibl && prevBodyMax >= ibl);
   bool sweepIbl = (sigRates[1].low < ibl && sigRates[1].close > ibl);
   bool sweepIbh = (sigRates[1].high > ibh && sigRates[1].close < ibh);

   bool aboveMid = (sigRates[1].close > mid);
   bool belowMid = (sigRates[1].close < mid);

   bool buy = volOk && aboveMid && (breakUp || (!InpOnlyExpansion && sweepIbl));
   bool sell = volOk && belowMid && (breakDn || (!InpOnlyExpansion && sweepIbh));

   if(!buy && !sell) { g_last_signal_bar_time = prevBarOpen; return; }

   if(InpMaxOneTradePerDay && dayKey == g_last_trade_day_key)
   {
      g_last_signal_bar_time = prevBarOpen;
      return;
   }

   trade.SetExpertMagicNumber((long)InpMagic);
   trade.SetDeviationInPoints(InpDeviationPoints);

   double sl = 0.0;
   double tp = 0.0;
   if(InpUseStopLoss)
      sl = buy ? ibl : ibh;
   if(InpUseTakeProfit)
      tp = buy ? (ibh + InpTakeProfitMult * rng) : (ibl - InpTakeProfitMult * rng);

   ulong tSame = 0;
   if(buy)
   {
      if(HasPosition(+1, tSame)) { g_last_signal_bar_time = prevBarOpen; return; }
      CloseAllPositions();
      if(trade.Buy(InpLots, _Symbol, 0.0, sl, tp))
         g_last_trade_day_key = dayKey;
   }
   else if(sell)
   {
      if(HasPosition(-1, tSame)) { g_last_signal_bar_time = prevBarOpen; return; }
      CloseAllPositions();
      if(trade.Sell(InpLots, _Symbol, 0.0, sl, tp))
         g_last_trade_day_key = dayKey;
   }

   g_last_signal_bar_time = prevBarOpen;
}
