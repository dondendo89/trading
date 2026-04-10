#property strict

#include <Trade/Trade.mqh>

CTrade Trade;

input int InpDepth = 10;
input int InpLb = 2;
input int InpVpLookbackBars = 100;
input int InpVpRows = 30;
input int InpVpValueAreaPercent = 70;

input bool InpTradeOnTouch = false;
input bool InpTradeOnDouble = false;
input bool InpTradeOnCrossAfterDouble = true;

input bool InpDrawLevels = true;
input bool InpDrawPivots = true;

input bool InpOneTradeOnly = true;

input double InpLots = 0.10;
input int InpStopLossPips = 50;
input int InpTakeProfitPips = 100;
input ulong InpMagic = 20260331;

datetime g_last_bar_time = 0;
datetime g_last_touch_vah_bar_time = 0;
datetime g_last_touch_val_bar_time = 0;
datetime g_last_pivot_time = 0;
double g_last_pivot_price = 0.0;
bool g_has_last_pivot = false;

double g_prev_hh_price = 0.0;
datetime g_prev_hh_time = 0;
bool g_has_prev_hh = false;

double g_prev_ll_price = 0.0;
datetime g_prev_ll_time = 0;
bool g_has_prev_ll = false;

bool g_pending_sell = false;
double g_pending_sell_level = 0.0;
datetime g_pending_sell_from_time = 0;
bool g_pending_buy = false;
double g_pending_buy_level = 0.0;
datetime g_pending_buy_from_time = 0;
bool g_trade_done = false;

double PipSize()
{
   if(_Digits == 3 || _Digits == 5) return 10.0 * _Point;
   return _Point;
}

string ObjName(const string suffix)
{
   return "ICTVP_" + _Symbol + "_" + IntegerToString((int)_Period) + "_" + suffix;
}

void UpsertHLine(const string name, double price, color clr, int width, ENUM_LINE_STYLE style)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void UpsertCornerLabel(const string name, const string text, int corner, int x, int y, color clr)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void DrawLevels(double poc, double vah, double val)
{
   if(!InpDrawLevels) return;
   UpsertHLine(ObjName("POC"), poc, clrDodgerBlue, 2, STYLE_SOLID);
   UpsertHLine(ObjName("VAH"), vah, clrMagenta, 1, STYLE_DASH);
   UpsertHLine(ObjName("VAL"), val, clrOrange, 1, STYLE_DASH);
   string txt =
      "ICT VP" + "\n" +
      "POC: " + DoubleToString(poc, _Digits) + "\n" +
      "VAH: " + DoubleToString(vah, _Digits) + "\n" +
      "VAL: " + DoubleToString(val, _Digits);
   UpsertCornerLabel(ObjName("LBL"), txt, CORNER_RIGHT_UPPER, 10, 20, clrWhite);
}

void PlotSignal(const string side, datetime t, double price)
{
   string name = ObjName("SIG_" + side + "_" + IntegerToString((int)t));
   if(ObjectFind(0, name) >= 0) return;
   ENUM_OBJECT objType = (side == "BUY") ? OBJ_ARROW_BUY : OBJ_ARROW_SELL;
   if(!ObjectCreate(0, name, objType, 0, t, price)) return;
   ObjectSetInteger(0, name, OBJPROP_COLOR, (side == "BUY") ? clrLime : clrRed);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void PlotPivotText(const string txt, datetime t, double price)
{
   if(!InpDrawPivots) return;
   string name = ObjName("PIV_" + txt + "_" + IntegerToString((int)t));
   if(ObjectFind(0, name) >= 0) return;
   if(!ObjectCreate(0, name, OBJ_TEXT, 0, t, price)) return;
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, (txt == "HH") ? clrRed : clrLime);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

bool HasOpenPosition()
{
   for(int i=PositionsTotal()-1; i>=0; i--)
   {
      ulong ticket = (ulong)PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      string sym = PositionGetString(POSITION_SYMBOL);
      long magic = (long)PositionGetInteger(POSITION_MAGIC);
      if(sym == _Symbol && (ulong)magic == InpMagic) return true;
   }
   return false;
}

bool CalcVolumeProfile(int lookbackBars, int rows, int vaPercent, double &poc, double &vah, double &val)
{
   poc = 0.0;
   vah = 0.0;
   val = 0.0;
   if(lookbackBars < 5 || rows < 10) return false;

   MqlRates rates[];
   int need = lookbackBars + 10;
   int copied = CopyRates(_Symbol, _Period, 1, need, rates);
   if(copied < lookbackBars) return false;
   ArraySetAsSeries(rates, true);

   double highest = -DBL_MAX;
   double lowest = DBL_MAX;
   for(int i=1; i<=lookbackBars; i++)
   {
      if(rates[i].high > highest) highest = rates[i].high;
      if(rates[i].low < lowest) lowest = rates[i].low;
   }

   double range = highest - lowest;
   if(range <= 0.0) return false;

   double rowHeight = range / (double)rows;
   if(rowHeight <= 0.0) return false;

   double levelPrices[];
   double levelVols[];
   ArrayResize(levelPrices, rows);
   ArrayResize(levelVols, rows);
   for(int i=0; i<rows; i++)
   {
      levelPrices[i] = lowest + ((double)i + 0.5) * rowHeight;
      levelVols[i] = 0.0;
   }

   for(int i=1; i<=lookbackBars; i++)
   {
      double barHigh = rates[i].high;
      double barLow = rates[i].low;
      double barVol = (double)rates[i].tick_volume;

      if(barHigh < barLow) continue;
      int startLevel = (int)MathFloor((barLow - lowest) / rowHeight);
      int endLevel = (int)MathFloor((barHigh - lowest) / rowHeight);
      if(startLevel < 0) startLevel = 0;
      if(endLevel > rows - 1) endLevel = rows - 1;
      int levelsInBar = endLevel - startLevel + 1;
      if(levelsInBar <= 0) continue;

      double volPerLevel = barVol / (double)levelsInBar;
      for(int j=startLevel; j<=endLevel; j++)
         levelVols[j] += volPerLevel;
   }

   double totalVol = 0.0;
   int pocIdx = 0;
   double maxVol = -1.0;
   for(int i=0; i<rows; i++)
   {
      totalVol += levelVols[i];
      if(levelVols[i] > maxVol)
      {
         maxVol = levelVols[i];
         pocIdx = i;
      }
   }
   if(totalVol <= 0.0) return false;

   poc = levelPrices[pocIdx];
   double targetVa = totalVol * ((double)vaPercent / 100.0);
   double acc = levelVols[pocIdx];
   int vahIdx = pocIdx;
   int valIdx = pocIdx;

   while(acc < targetVa)
   {
      bool canUp = (vahIdx < rows - 1);
      bool canDown = (valIdx > 0);
      double upVol = canUp ? levelVols[vahIdx + 1] : 0.0;
      double downVol = canDown ? levelVols[valIdx - 1] : 0.0;
      if(canUp && (!canDown || upVol >= downVol))
      {
         acc += upVol;
         vahIdx++;
      }
      else if(canDown)
      {
         acc += downVol;
         valIdx--;
      }
      else
      {
         break;
      }
   }

   vah = levelPrices[vahIdx] + rowHeight / 2.0;
   val = levelPrices[valIdx] - rowHeight / 2.0;
   return true;
}

bool IsPivotHigh(const MqlRates &rates[], int shiftPivot, int depth, int lb, double &price, datetime &t)
{
   price = 0.0;
   t = 0;
   int bars = ArraySize(rates);
   int leftMaxShift = shiftPivot + depth;
   int rightMinShift = shiftPivot - lb;
   if(rightMinShift < 1) return false;
   if(leftMaxShift >= bars) return false;

   double p = rates[shiftPivot].high;
   double maxH = -DBL_MAX;
   for(int s=rightMinShift; s<=leftMaxShift; s++)
      if(rates[s].high > maxH) maxH = rates[s].high;
   if(p == maxH)
   {
      price = p;
      t = rates[shiftPivot].time;
      return true;
   }
   return false;
}

bool IsPivotLow(const MqlRates &rates[], int shiftPivot, int depth, int lb, double &price, datetime &t)
{
   price = 0.0;
   t = 0;
   int bars = ArraySize(rates);
   int leftMaxShift = shiftPivot + depth;
   int rightMinShift = shiftPivot - lb;
   if(rightMinShift < 1) return false;
   if(leftMaxShift >= bars) return false;

   double p = rates[shiftPivot].low;
   double minL = DBL_MAX;
   for(int s=rightMinShift; s<=leftMaxShift; s++)
      if(rates[s].low < minL) minL = rates[s].low;
   if(p == minL)
   {
      price = p;
      t = rates[shiftPivot].time;
      return true;
   }
   return false;
}

string StructureLabel(double pivotPrice, bool isHigh)
{
   if(!g_has_last_pivot) return isHigh ? "HH" : "LL";
   if(isHigh) return (pivotPrice > g_last_pivot_price) ? "HH" : "LH";
   return (pivotPrice < g_last_pivot_price) ? "LL" : "HL";
}

void SendTrade(string side, double price, double sl, double tp)
{
   if(InpOneTradeOnly && g_trade_done) return;
   if(HasOpenPosition()) return;

   Trade.SetExpertMagicNumber((long)InpMagic);
   Trade.SetTypeFillingBySymbol(_Symbol);

   bool ok = false;
   if(side == "BUY")
      ok = Trade.Buy(InpLots, _Symbol, price, sl, tp);
   else if(side == "SELL")
      ok = Trade.Sell(InpLots, _Symbol, price, sl, tp);

   if(ok)
   {
      g_trade_done = true;
      g_pending_sell = false;
      g_pending_sell_level = 0.0;
      g_pending_sell_from_time = 0;
      g_pending_buy = false;
      g_pending_buy_level = 0.0;
      g_pending_buy_from_time = 0;
      Print("ORDER_OK ", side, " price=", DoubleToString(price, _Digits), " sl=", DoubleToString(sl, _Digits), " tp=", DoubleToString(tp, _Digits));
   }
   else
      Print("ORDER_FAIL ", side, " err=", GetLastError());
}

bool TryFirePendingSell(const MqlRates &rates[], double level)
{
   if(!g_pending_sell || g_trade_done) return false;
   int bars = ArraySize(rates);
   if(bars < 5) return false;
   for(int s=bars-2; s>=1; s--)
   {
      if(g_pending_sell_from_time != 0 && rates[s].time < g_pending_sell_from_time)
         continue;
      if(rates[s+1].close > level && rates[s].low <= level)
      {
         datetime t = rates[s].time;
         Print("[YF->MT5] CROSS VAH after DOUBLE HH ", DoubleToString(level, _Digits), " at ", TimeToString(t, TIME_DATE|TIME_MINUTES));
         PlotSignal("SELL", t, level);
         if(InpTradeOnCrossAfterDouble)
         {
            double pip = PipSize();
            double sl = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (double)InpStopLossPips * pip, _Digits);
            double tp = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (double)InpTakeProfitPips * pip, _Digits);
            SendTrade("SELL", SymbolInfoDouble(_Symbol, SYMBOL_BID), sl, tp);
         }
         g_pending_sell = false;
         g_pending_sell_level = 0.0;
         g_pending_sell_from_time = 0;
         return true;
      }
   }
   return false;
}

bool TryFirePendingBuy(const MqlRates &rates[], double level)
{
   if(!g_pending_buy || g_trade_done) return false;
   int bars = ArraySize(rates);
   if(bars < 5) return false;
   for(int s=bars-2; s>=1; s--)
   {
      if(g_pending_buy_from_time != 0 && rates[s].time < g_pending_buy_from_time)
         continue;
      if(rates[s+1].close < level && rates[s].high >= level)
      {
         datetime t = rates[s].time;
         Print("[YF->MT5] CROSS VAL after DOUBLE LL ", DoubleToString(level, _Digits), " at ", TimeToString(t, TIME_DATE|TIME_MINUTES));
         PlotSignal("BUY", t, level);
         if(InpTradeOnCrossAfterDouble)
         {
            double pip = PipSize();
            double sl = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - (double)InpStopLossPips * pip, _Digits);
            double tp = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) + (double)InpTakeProfitPips * pip, _Digits);
            SendTrade("BUY", SymbolInfoDouble(_Symbol, SYMBOL_ASK), sl, tp);
         }
         g_pending_buy = false;
         g_pending_buy_level = 0.0;
         g_pending_buy_from_time = 0;
         return true;
      }
   }
   return false;
}

void OnNewBar()
{
   double poc, vah, val;
   bool vpOk = CalcVolumeProfile(InpVpLookbackBars, InpVpRows, InpVpValueAreaPercent, poc, vah, val);
   if(!vpOk) return;
   DrawLevels(poc, vah, val);
   if(g_pending_sell) g_pending_sell_level = vah;
   if(g_pending_buy) g_pending_buy_level = val;

   MqlRates rates[];
   int need = MathMax(InpVpLookbackBars + 20, InpDepth + InpLb + 30);
   int copied = CopyRates(_Symbol, _Period, 0, need, rates);
   if(copied < need/2) return;
   ArraySetAsSeries(rates, true);

   datetime lastClosedTime = rates[1].time;
   double lastClosedHigh = rates[1].high;
   double lastClosedLow = rates[1].low;
   double prevClose = rates[2].close;
   double lastClose = rates[1].close;

   if(g_last_touch_vah_bar_time != lastClosedTime && prevClose > vah && lastClosedLow <= vah)
   {
      g_last_touch_vah_bar_time = lastClosedTime;
      Print("[YF->MT5] SELL touch VAH ", DoubleToString(vah, _Digits));
      PlotSignal("SELL", lastClosedTime, vah);
      if(!g_trade_done && InpTradeOnCrossAfterDouble && g_pending_sell)
      {
         double pip = PipSize();
         double sl = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (double)InpStopLossPips * pip, _Digits);
         double tp = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - (double)InpTakeProfitPips * pip, _Digits);
         SendTrade("SELL", SymbolInfoDouble(_Symbol, SYMBOL_BID), sl, tp);
         g_pending_sell = false;
         g_pending_sell_level = 0.0;
         g_pending_sell_from_time = 0;
      }
   }

   if(g_last_touch_val_bar_time != lastClosedTime && prevClose < val && lastClosedHigh >= val)
   {
      g_last_touch_val_bar_time = lastClosedTime;
      Print("[YF->MT5] BUY touch VAL ", DoubleToString(val, _Digits));
      PlotSignal("BUY", lastClosedTime, val);
      if(!g_trade_done && InpTradeOnCrossAfterDouble && g_pending_buy)
      {
         double pip = PipSize();
         double sl = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - (double)InpStopLossPips * pip, _Digits);
         double tp = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) + (double)InpTakeProfitPips * pip, _Digits);
         SendTrade("BUY", SymbolInfoDouble(_Symbol, SYMBOL_ASK), sl, tp);
         g_pending_buy = false;
         g_pending_buy_level = 0.0;
         g_pending_buy_from_time = 0;
      }
   }

   int pivotShift = InpLb + 1;
   double phPrice, plPrice;
   datetime phTime, plTime;
   bool hasPh = IsPivotHigh(rates, pivotShift, InpDepth, InpLb, phPrice, phTime);
   bool hasPl = IsPivotLow(rates, pivotShift, InpDepth, InpLb, plPrice, plTime);

   if(hasPh && (g_last_pivot_time == 0 || phTime > g_last_pivot_time))
   {
      string label = StructureLabel(phPrice, true);
      if(label == "HH")
      {
         PlotPivotText("HH", phTime, phPrice + 5.0 * PipSize());
         if(g_has_prev_hh && phPrice > g_prev_hh_price)
         {
            Print("[YF->MT5] DOUBLE HH ", DoubleToString(g_prev_hh_price, _Digits), " -> ", DoubleToString(phPrice, _Digits));
            if(InpTradeOnCrossAfterDouble)
            {
               g_pending_sell = true;
               g_pending_sell_level = vah;
               g_pending_sell_from_time = phTime;
            }
         }
         g_prev_hh_price = phPrice;
         g_prev_hh_time = phTime;
         g_has_prev_hh = true;
      }
      g_last_pivot_time = phTime;
      g_last_pivot_price = phPrice;
      g_has_last_pivot = true;
   }

   if(hasPl && (g_last_pivot_time == 0 || plTime > g_last_pivot_time))
   {
      string label = StructureLabel(plPrice, false);
      if(label == "LL")
      {
         PlotPivotText("LL", plTime, plPrice - 5.0 * PipSize());
         if(g_has_prev_ll && plPrice < g_prev_ll_price)
         {
            Print("[YF->MT5] DOUBLE LL ", DoubleToString(g_prev_ll_price, _Digits), " -> ", DoubleToString(plPrice, _Digits));
            if(InpTradeOnCrossAfterDouble)
            {
               g_pending_buy = true;
               g_pending_buy_level = val;
               g_pending_buy_from_time = plTime;
            }
         }
         g_prev_ll_price = plPrice;
         g_prev_ll_time = plTime;
         g_has_prev_ll = true;
      }
      g_last_pivot_time = plTime;
      g_last_pivot_price = plPrice;
      g_has_last_pivot = true;
   }

   if(!g_trade_done)
   {
      if(g_pending_sell)
         TryFirePendingSell(rates, g_pending_sell_level);
      if(g_pending_buy && !g_trade_done)
         TryFirePendingBuy(rates, g_pending_buy_level);
   }
}

int OnInit()
{
   Trade.SetExpertMagicNumber((long)InpMagic);
   Print("ICT_VP_Pivot_Strategy AVVIATA su ", _Symbol, " TF=", EnumToString(_Period));
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   datetime t = iTime(_Symbol, _Period, 0);
   if(t == 0) return;
   if(g_last_bar_time == 0)
   {
      g_last_bar_time = t;
      return;
   }
   if(t != g_last_bar_time)
   {
      g_last_bar_time = t;
      OnNewBar();
   }
}
