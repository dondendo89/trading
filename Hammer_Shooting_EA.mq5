#property copyright "Trae"
#property link      ""
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

input group "Trading Settings"
input double InpLotSize = 0.01;
input int InpStopLoss = 0;
input int InpTakeProfit = 0;
input ulong InpMagicNumber = 12345;

input group "Hammer / Shooting Settings"
input double InpFibLevel = 0.382;
input bool InpConfirmByNextCandle = false;
input bool InpConfirmWithDxy = true;
input string InpDxySymbol = "DXY.cash";
input bool InpRequireConfirmation = false;
input bool InpHsTrendFilterEnabled = true;
input int InpHsTrendEmaFast = 50;
input int InpHsTrendEmaSlow = 200;
input int InpHsTrendAtrPeriod = 14;
input double InpHsTrendAtrMult = 0.5;

input group "Session Filter"
input bool InpOnlyLondonNy = true;
input int InpSessionOffsetHours = 0;
input int InpLondonStartHour = 7;
input int InpLondonEndHour = 12;
input int InpNewYorkStartHour = 12;
input int InpNewYorkEndHour = 17;

input group "Partial Close"
input bool InpPartialCloseEnabled = false;
input double InpPartialClosePercent = 50.0;
input int InpPartialCloseTriggerPoints = 200;
input bool InpPartialMoveSlToBreakeven = false;

input group "Breakout Entry"
input bool InpEntryOnBreakout = false;
input int InpBreakoutBufferPoints = 0;

input group "Volume Profile Filter"
input bool InpVpFilterEnabled = true;
input bool InpVpAnchorAsia = true;
input int InpVpAsiaOpenHour = 0;
input int InpVpMaxBars = 600;
input int InpVpLookbackBars = 100;
input int InpVpRows = 30;
input int InpVpValueAreaPercent = 70;
input bool InpVpUsePocTarget = false;
input bool InpVpShowLines = true;
input color InpVpPocColor = clrDeepSkyBlue;
input color InpVpVahColor = clrMediumPurple;
input color InpVpValColor = clrOrange;
input bool InpVpBodyZoneFilter = true;

CTrade trade;
datetime last_bar_time = 0;
ulong last_partial_ticket = 0;
bool partial_done = false;
bool pending_long = false;
bool pending_short = false;
double pending_long_level = 0.0;
double pending_short_level = 0.0;
double pending_tp = 0.0;
datetime last_vp_update_bar_time = 0;
string vp_poc_line = "HS_EA_VP_POC";
string vp_vah_line = "HS_EA_VP_VAH";
string vp_val_line = "HS_EA_VP_VAL";
string vp_poc_text = "HS_EA_VP_POC_TXT";
string vp_vah_text = "HS_EA_VP_VAH_TXT";
string vp_val_text = "HS_EA_VP_VAL_TXT";
int g_ema_fast_handle = INVALID_HANDLE;
int g_ema_slow_handle = INVALID_HANDLE;
int g_atr_handle = INVALID_HANDLE;

bool HasOpenPositionForThisEA()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if((string)PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      return true;
   }
   return false;
}

datetime ShiftTime(datetime t, int hours);

bool ComputeVpLevels(const int startShift, const int lookbackBars, const int rows, const int valueAreaPercent, double &poc, double &vah, double &val)
{
   poc = 0.0;
   vah = 0.0;
   val = 0.0;

   if(lookbackBars < 10 || rows < 10) return false;

   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, _Period, startShift, lookbackBars, rates);
   if(copied < 10) return false;

   double highest = -DBL_MAX;
   double lowest = DBL_MAX;
   for(int i = 0; i < copied; i++)
   {
      if(rates[i].high > highest) highest = rates[i].high;
      if(rates[i].low < lowest) lowest = rates[i].low;
   }
   double range = highest - lowest;
   if(range <= 0.0) return false;

   double rowHeight = range / (double)rows;
   if(rowHeight <= 0.0) return false;

   double levelVol[];
   ArrayResize(levelVol, rows);
   for(int i = 0; i < rows; i++) levelVol[i] = 0.0;

   for(int i = 0; i < copied; i++)
   {
      double barHigh = rates[i].high;
      double barLow = rates[i].low;
      double barVol = (double)rates[i].tick_volume;
      if(barVol <= 0.0) barVol = 1.0;

      int startLevel = (int)MathFloor((barLow - lowest) / rowHeight);
      int endLevel = (int)MathFloor((barHigh - lowest) / rowHeight);
      if(startLevel < 0) startLevel = 0;
      if(endLevel > rows - 1) endLevel = rows - 1;
      int levelsInBar = endLevel - startLevel + 1;
      if(levelsInBar <= 0) continue;
      double volPerLevel = barVol / (double)levelsInBar;
      for(int j = startLevel; j <= endLevel; j++) levelVol[j] += volPerLevel;
   }

   double totalVol = 0.0;
   int pocIndex = 0;
   double maxVol = levelVol[0];
   for(int i = 0; i < rows; i++)
   {
      totalVol += levelVol[i];
      if(levelVol[i] > maxVol)
      {
         maxVol = levelVol[i];
         pocIndex = i;
      }
   }
   if(totalVol <= 0.0) return false;

   double targetVa = totalVol * ((double)valueAreaPercent / 100.0);
   double accumulated = levelVol[pocIndex];
   int vahIndex = pocIndex;
   int valIndex = pocIndex;
   while(accumulated < targetVa)
   {
      bool canUp = (vahIndex < rows - 1);
      bool canDown = (valIndex > 0);
      double upVol = canUp ? levelVol[vahIndex + 1] : 0.0;
      double downVol = canDown ? levelVol[valIndex - 1] : 0.0;
      if(canUp && (!canDown || upVol >= downVol))
      {
         accumulated += upVol;
         vahIndex++;
      }
      else if(canDown)
      {
         accumulated += downVol;
         valIndex--;
      }
      else
         break;
   }

   poc = lowest + ((double)pocIndex + 0.5) * rowHeight;
   vah = lowest + ((double)(vahIndex + 1)) * rowHeight;
   val = lowest + ((double)valIndex) * rowHeight;
   return true;
}

datetime AsiaOpenServerTime(datetime serverTime)
{
   datetime localTime = ShiftTime(serverTime, InpSessionOffsetHours);
   MqlDateTime dt;
   TimeToStruct(localTime, dt);
   dt.hour = InpVpAsiaOpenHour;
   dt.min = 0;
   dt.sec = 0;
   datetime openLocal = StructToTime(dt);
   if(localTime < openLocal)
      openLocal = openLocal - 86400;
   datetime openServer = ShiftTime(openLocal, -InpSessionOffsetHours);
   return openServer;
}

int GetVpLookbackBars(const int startShift)
{
   if(!InpVpAnchorAsia)
      return InpVpLookbackBars;

   datetime barTime = iTime(_Symbol, _Period, startShift);
   if(barTime == 0) return InpVpLookbackBars;
   datetime asiaOpen = AsiaOpenServerTime(barTime);

   datetime times[];
   ArraySetAsSeries(times, true);
   int copied = CopyTime(_Symbol, _Period, startShift, InpVpMaxBars, times);
   if(copied < 10) return InpVpLookbackBars;

   int count = 0;
   for(int i = 0; i < copied; i++)
   {
      if(times[i] < asiaOpen) break;
      count++;
   }
   if(count < 10) return InpVpLookbackBars;
   return count;
}

void CreateOrUpdateHLine(const string name, const double price, const color clr, const ENUM_LINE_STYLE style)
{
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price)) return;
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
}

void CreateOrUpdatePriceLabel(const string name, const string text, const double price, const color clr)
{
   datetime t = iTime(_Symbol, _Period, 0);
   if(t == 0) return;
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_TEXT, 0, t, price)) return;
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   }
   ObjectMove(0, name, 0, t, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text + " " + DoubleToString(price, _Digits));
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
}

void UpdateVpLinesIfNeeded()
{
   if(!InpVpShowLines)
   {
      ObjectDelete(0, vp_poc_line);
      ObjectDelete(0, vp_vah_line);
      ObjectDelete(0, vp_val_line);
      ObjectDelete(0, vp_poc_text);
      ObjectDelete(0, vp_vah_text);
      ObjectDelete(0, vp_val_text);
      return;
   }
   datetime barTime = iTime(_Symbol, _Period, 0);
   if(barTime == 0) return;
   if(barTime == last_vp_update_bar_time) return;
   last_vp_update_bar_time = barTime;

   double poc = 0.0, vah = 0.0, val = 0.0;
   int lb = GetVpLookbackBars(1);
   if(!ComputeVpLevels(1, lb, InpVpRows, InpVpValueAreaPercent, poc, vah, val)) return;
   CreateOrUpdateHLine(vp_poc_line, poc, InpVpPocColor, STYLE_SOLID);
   CreateOrUpdateHLine(vp_vah_line, vah, InpVpVahColor, STYLE_DOT);
   CreateOrUpdateHLine(vp_val_line, val, InpVpValColor, STYLE_DOT);
   CreateOrUpdatePriceLabel(vp_poc_text, "POC", poc, InpVpPocColor);
   CreateOrUpdatePriceLabel(vp_vah_text, "VAH", vah, InpVpVahColor);
   CreateOrUpdatePriceLabel(vp_val_text, "VAL", val, InpVpValColor);
   ChartRedraw(0);
}

bool GetTrendFlagsEA(const int shift, bool &isUp, bool &isDown)
{
   isUp = false;
   isDown = false;
   if(!InpHsTrendFilterEnabled) return true;
   if(g_ema_fast_handle == INVALID_HANDLE || g_ema_slow_handle == INVALID_HANDLE || g_atr_handle == INVALID_HANDLE) return true;
   if(shift < 0) return false;

   double emaFast[1], emaSlow[1], atr[1], closeArr[1];
   if(CopyBuffer(g_ema_fast_handle, 0, shift, 1, emaFast) <= 0) return false;
   if(CopyBuffer(g_ema_slow_handle, 0, shift, 1, emaSlow) <= 0) return false;
   if(CopyBuffer(g_atr_handle, 0, shift, 1, atr) <= 0) return false;
   if(CopyClose(_Symbol, _Period, shift, 1, closeArr) <= 0) return false;

   double diff = emaFast[0] - emaSlow[0];
   double threshold = atr[0] * InpHsTrendAtrMult;
   if(diff >= threshold && closeArr[0] > emaFast[0]) isUp = true;
   if((-diff) >= threshold && closeArr[0] < emaFast[0]) isDown = true;
   return true;
}

bool TryBreakoutEntry()
{
   if(!InpEntryOnBreakout) return false;
   if(!pending_long && !pending_short) return false;

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0.0) return false;
   double buffer = (double)InpBreakoutBufferPoints * point;

   if(pending_long)
   {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(ask > 0.0 && ask >= (pending_long_level + buffer))
      {
         double sl = 0.0;
         double tp = pending_tp;
         if(InpStopLoss > 0) sl = ask - (InpStopLoss * point);
         if(InpTakeProfit > 0) tp = ask + (InpTakeProfit * point);
         if(trade.Buy(InpLotSize, _Symbol, ask, sl, tp, "Hammer Breakout Buy"))
         {
            pending_long = false;
            pending_short = false;
            pending_tp = 0.0;
            return true;
         }
      }
   }

   if(pending_short)
   {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(bid > 0.0 && bid <= (pending_short_level - buffer))
      {
         double sl = 0.0;
         double tp = pending_tp;
         if(InpStopLoss > 0) sl = bid + (InpStopLoss * point);
         if(InpTakeProfit > 0) tp = bid - (InpTakeProfit * point);
         if(trade.Sell(InpLotSize, _Symbol, bid, sl, tp, "Shooting Breakout Sell"))
         {
            pending_long = false;
            pending_short = false;
            pending_tp = 0.0;
            return true;
         }
      }
   }

   return false;
}

bool SelectPositionForThisEA(ulong &ticket)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(!PositionSelectByTicket(t)) continue;
      if((string)PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      ticket = t;
      return true;
   }
   ticket = 0;
   return false;
}

datetime ShiftTime(datetime t, int hours)
{
   if(hours == 0) return t;
   return (datetime)(t + (long)hours * 3600);
}

bool InHourRange(int hour, int startHour, int endHour)
{
   if(startHour == endHour) return true;
   if(startHour < endHour) return (hour >= startHour && hour < endHour);
   return (hour >= startHour || hour < endHour);
}

bool IsLondonNySession(datetime serverTime)
{
   datetime localTime = ShiftTime(serverTime, InpSessionOffsetHours);
   MqlDateTime dt;
   TimeToStruct(localTime, dt);
   int h = dt.hour;
   if(InHourRange(h, InpLondonStartHour, InpLondonEndHour)) return true;
   if(InHourRange(h, InpNewYorkStartHour, InpNewYorkEndHour)) return true;
   return false;
}

double NormalizeVolume(double vol)
{
   double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double stepVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(stepVol <= 0.0) stepVol = minVol;
   if(vol < minVol) return 0.0;
   double steps = MathFloor(vol / stepVol);
   double out = steps * stepVol;
   if(out < minVol) return 0.0;
   return out;
}

void ManagePartialClose()
{
   if(!InpPartialCloseEnabled) return;

   ulong ticket = 0;
   if(!SelectPositionForThisEA(ticket))
   {
      last_partial_ticket = 0;
      partial_done = false;
      return;
   }

   if(ticket != last_partial_ticket)
   {
      last_partial_ticket = ticket;
      partial_done = false;
   }
   if(partial_done) return;

   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   double volume = PositionGetDouble(POSITION_VOLUME);
   long type = PositionGetInteger(POSITION_TYPE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0.0) return;

   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double movePoints = 0.0;
   if(type == POSITION_TYPE_BUY)
      movePoints = (bid - openPrice) / point;
   else if(type == POSITION_TYPE_SELL)
      movePoints = (openPrice - ask) / point;
   else
      return;

   if(movePoints < (double)InpPartialCloseTriggerPoints) return;

   double closeVolRaw = volume * (InpPartialClosePercent / 100.0);
   double closeVol = NormalizeVolume(closeVolRaw);
   if(closeVol <= 0.0) return;

   double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if((volume - closeVol) < minVol)
   {
      closeVol = NormalizeVolume(volume - minVol);
      if(closeVol <= 0.0) return;
   }

   if(trade.PositionClosePartial(_Symbol, closeVol))
   {
      partial_done = true;
      if(InpPartialMoveSlToBreakeven)
      {
         double tp = PositionGetDouble(POSITION_TP);
         trade.PositionModify(_Symbol, openPrice, tp);
      }
   }
}

string ToUpper(const string src)
{
   string s = src;
   StringToUpper(s);
   return s;
}

bool IsXauSymbol()
{
   string s = ToUpper(_Symbol);
   return (StringFind(s, "XAU") >= 0);
}

bool IsHammerCandle(double open, double high, double low, double close)
{
   double candleSize = MathAbs(high - low);
   if(candleSize <= 0.0) return false;
   double bodyMin = MathMin(open, close);
   return (high - InpFibLevel * candleSize) < bodyMin;
}

bool IsShootingCandle(double open, double high, double low, double close)
{
   double candleSize = MathAbs(high - low);
   if(candleSize <= 0.0) return false;
   double bodyMax = MathMax(open, close);
   return (low + InpFibLevel * candleSize) > bodyMax;
}

bool GetDxyDirection(datetime t, bool &isBullish, bool &isBearish)
{
   isBullish = false;
   isBearish = false;
   if(!InpConfirmWithDxy) return false;
   if(InpDxySymbol == "") return false;
   
   int shift = iBarShift(InpDxySymbol, _Period, t, true);
   if(shift < 0) return false;
   
   double o[1], c[1];
   if(CopyOpen(InpDxySymbol, _Period, shift, 1, o) <= 0) return false;
   if(CopyClose(InpDxySymbol, _Period, shift, 1, c) <= 0) return false;
   
   if(c[0] > o[0]) isBullish = true;
   if(c[0] < o[0]) isBearish = true;
   return true;
}

int OnInit()
{
   trade.SetExpertMagicNumber(InpMagicNumber);
   
   if(InpConfirmWithDxy && InpDxySymbol != "")
      SymbolSelect(InpDxySymbol, true);

   g_ema_fast_handle = iMA(_Symbol, _Period, InpHsTrendEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   g_ema_slow_handle = iMA(_Symbol, _Period, InpHsTrendEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   g_atr_handle = iATR(_Symbol, _Period, InpHsTrendAtrPeriod);
      
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectDelete(0, vp_poc_line);
   ObjectDelete(0, vp_vah_line);
   ObjectDelete(0, vp_val_line);
   ObjectDelete(0, vp_poc_text);
   ObjectDelete(0, vp_vah_text);
   ObjectDelete(0, vp_val_text);
   if(g_ema_fast_handle != INVALID_HANDLE) IndicatorRelease(g_ema_fast_handle);
   if(g_ema_slow_handle != INVALID_HANDLE) IndicatorRelease(g_ema_slow_handle);
   if(g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   g_ema_fast_handle = INVALID_HANDLE;
   g_ema_slow_handle = INVALID_HANDLE;
   g_atr_handle = INVALID_HANDLE;
}

void OnTick()
{
   UpdateVpLinesIfNeeded();

   ManagePartialClose();

   if(HasOpenPositionForThisEA()) return;
   
   if(InpOnlyLondonNy && !IsLondonNySession(TimeTradeServer()))
   {
      return;
   }

   if(TryBreakoutEntry()) return;

   datetime current_time = iTime(_Symbol, _Period, 0);
   if(current_time == last_bar_time) return; // Lavora solo su candela chiusa
   
   double o[3], h[3], l[3], c[3];
   datetime t[3];
   ArraySetAsSeries(o, true);
   ArraySetAsSeries(h, true);
   ArraySetAsSeries(l, true);
   ArraySetAsSeries(c, true);
   ArraySetAsSeries(t, true);
   if(CopyOpen(_Symbol, _Period, 1, 3, o) <= 0) return;
   if(CopyHigh(_Symbol, _Period, 1, 3, h) <= 0) return;
   if(CopyLow(_Symbol, _Period, 1, 3, l) <= 0) return;
   if(CopyClose(_Symbol, _Period, 1, 3, c) <= 0) return;
   if(CopyTime(_Symbol, _Period, 1, 3, t) <= 0) return;
   
   int confirmIndex = 0;
   int signalIndex = InpConfirmByNextCandle ? 1 : 0;
   bool isGreen = (c[confirmIndex] > o[confirmIndex]);
   bool isRed = (c[confirmIndex] < o[confirmIndex]);
   
   bool hammer = false;
   bool shoot = false;
   datetime sigTime = t[signalIndex];
   
   if(!InpConfirmByNextCandle)
   {
      hammer = IsHammerCandle(o[signalIndex], h[signalIndex], l[signalIndex], c[signalIndex]);
      shoot = IsShootingCandle(o[signalIndex], h[signalIndex], l[signalIndex], c[signalIndex]);
   }
   else
   {
      double sigBodyHigh = MathMax(o[signalIndex], c[signalIndex]);
      double sigBodyLow = MathMin(o[signalIndex], c[signalIndex]);
      hammer = IsHammerCandle(o[signalIndex], h[signalIndex], l[signalIndex], c[signalIndex]) && isGreen && (c[confirmIndex] > sigBodyHigh);
      shoot = IsShootingCandle(o[signalIndex], h[signalIndex], l[signalIndex], c[signalIndex]) && isRed && (c[confirmIndex] < sigBodyLow);
   }
   
   if(!hammer && !shoot)
   {
      last_bar_time = current_time;
      return;
   }

   int trendShift = InpConfirmByNextCandle ? 2 : 1;
   bool trendUp = false;
   bool trendDown = false;
   if(InpHsTrendFilterEnabled)
   {
      if(GetTrendFlagsEA(trendShift, trendUp, trendDown))
      {
         if(hammer && !trendDown) hammer = false;
         if(shoot && !trendUp) shoot = false;
      }
   }
   if(!hammer && !shoot)
   {
      last_bar_time = current_time;
      return;
   }
   
   bool dxyBull = false;
   bool dxyBear = false;
   bool haveDxy = false;
   
   if(InpConfirmWithDxy && IsXauSymbol())
   {
      haveDxy = GetDxyDirection(sigTime, dxyBull, dxyBear);
   }
   
   double sl = 0.0;
   double tp = 0.0;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(hammer)
   {
      bool confirmed = (!InpConfirmWithDxy || !IsXauSymbol() || (haveDxy && dxyBear));
      if(!InpRequireConfirmation || confirmed)
      {
         int sigIndex = signalIndex;
         int sigShift = InpConfirmByNextCandle ? 2 : 1;
         bool vpOk = true;
         double poc = 0.0, vah = 0.0, val = 0.0;
         if(InpVpFilterEnabled)
         {
            int lb = GetVpLookbackBars(sigShift);
            vpOk = ComputeVpLevels(sigShift, lb, InpVpRows, InpVpValueAreaPercent, poc, vah, val);
            if(vpOk)
            {
               vpOk = (l[sigIndex] < val) && (c[sigIndex] > val) && (c[sigIndex] < vah);
               if(vpOk && InpVpBodyZoneFilter)
               {
                  double bodyMin = MathMin(o[sigIndex], c[sigIndex]);
                  double bodyMax = MathMax(o[sigIndex], c[sigIndex]);
                  vpOk = (bodyMin >= val) && (bodyMax <= poc);
               }
            }
         }
         if(!vpOk)
         {
         }
         else
         {
         if(InpEntryOnBreakout)
         {
            pending_long = true;
            pending_short = false;
            pending_long_level = h[sigIndex];
            pending_tp = 0.0;
            if(InpVpFilterEnabled && InpVpUsePocTarget && InpTakeProfit <= 0 && poc > 0.0)
               pending_tp = poc;
         }
         else
         {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            if(InpStopLoss > 0) sl = ask - (InpStopLoss * point);
            if(InpTakeProfit > 0)
               tp = ask + (InpTakeProfit * point);
            else if(InpVpFilterEnabled && InpVpUsePocTarget && poc > 0.0)
               tp = poc;
            trade.Buy(InpLotSize, _Symbol, ask, sl, tp, "Hammer Buy");
         }
         }
      }
   }
   
   if(shoot)
   {
      bool confirmed = (!InpConfirmWithDxy || !IsXauSymbol() || (haveDxy && dxyBull));
      if(!InpRequireConfirmation || confirmed)
      {
         int sigIndex = signalIndex;
         int sigShift = InpConfirmByNextCandle ? 2 : 1;
         bool vpOk = true;
         double poc = 0.0, vah = 0.0, val = 0.0;
         if(InpVpFilterEnabled)
         {
            int lb = GetVpLookbackBars(sigShift);
            vpOk = ComputeVpLevels(sigShift, lb, InpVpRows, InpVpValueAreaPercent, poc, vah, val);
            if(vpOk)
            {
               vpOk = (h[sigIndex] > vah) && (c[sigIndex] < vah) && (c[sigIndex] > val);
               if(vpOk && InpVpBodyZoneFilter)
               {
                  double bodyMin = MathMin(o[sigIndex], c[sigIndex]);
                  double bodyMax = MathMax(o[sigIndex], c[sigIndex]);
                  vpOk = (bodyMin >= poc) && (bodyMax <= vah);
               }
            }
         }
         if(!vpOk)
         {
         }
         else
         {
         if(InpEntryOnBreakout)
         {
            pending_short = true;
            pending_long = false;
            pending_short_level = l[sigIndex];
            pending_tp = 0.0;
            if(InpVpFilterEnabled && InpVpUsePocTarget && InpTakeProfit <= 0 && poc > 0.0)
               pending_tp = poc;
         }
         else
         {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if(InpStopLoss > 0) sl = bid + (InpStopLoss * point);
            if(InpTakeProfit > 0)
               tp = bid - (InpTakeProfit * point);
            else if(InpVpFilterEnabled && InpVpUsePocTarget && poc > 0.0)
               tp = poc;
            trade.Sell(InpLotSize, _Symbol, bid, sl, tp, "Shooting Sell");
         }
         }
      }
   }
   
   last_bar_time = current_time;
}
