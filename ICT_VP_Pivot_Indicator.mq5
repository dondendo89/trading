#property strict
#property indicator_chart_window
#property indicator_plots 3
#property indicator_buffers 3
#property indicator_label1 "POC"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "VAH"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrMagenta
#property indicator_style2 STYLE_DASH
#property indicator_width2 1
#property indicator_label3 "VAL"
#property indicator_type3 DRAW_LINE
#property indicator_color3 clrOrange
#property indicator_style3 STYLE_DASH
#property indicator_width3 1

input int InpDepth = 10;
input int InpLb = 2;
input int InpVpLookbackBars = 100;
input int InpVpRows = 30;
input int InpVpValueAreaPercent = 70;

input bool InpShowProfile = true;
input bool InpProfileRight = true;
input int InpProfileOffsetBars = 10;
input int InpProfileWidthBars = 20;
input int InpProfileAlpha = 170;

input bool InpShowLevels = true;
input bool InpShowPivots = true;
input bool InpShowSignals = true;
input bool InpScanHistoryPivots = true;
input bool InpDebugLog = false;

input bool InpAlertOnTouch = true;
input bool InpAlertOnDouble = true;
input bool InpAlertOnCrossAfterDouble = true;

input bool InpSendTerminalAlert = true;
input bool InpSendPushNotification = false;
input bool InpSendTelegram = false;
input string InpTelegramToken = "";
input string InpTelegramChatId = "";

datetime g_last_bar_time = 0;
datetime g_last_debug_bar_time = 0;

double g_pocBuffer[];
double g_vahBuffer[];
double g_valBuffer[];

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
bool g_pending_buy = false;
double g_pending_buy_level = 0.0;

datetime g_last_touch_vah_bar_time = 0;
datetime g_last_touch_val_bar_time = 0;
datetime g_last_double_hh_time = 0;
datetime g_last_double_ll_time = 0;
datetime g_last_cross_sell_time = 0;
datetime g_last_cross_buy_time = 0;

double PipSize()
{
   if(_Digits == 3 || _Digits == 5) return 10.0 * _Point;
   return _Point;
}

string ObjName(const string suffix)
{
   return "ICTVP_IND_" + _Symbol + "_" + IntegerToString((int)_Period) + "_" + suffix;
}

color WithAlpha(color c, int alpha)
{
   if(alpha < 0) alpha = 0;
   if(alpha > 255) alpha = 255;
   return (color)ColorToARGB(c, (uchar)alpha);
}

void UpsertHLine(const string name, double price, color clr, int width, ENUM_LINE_STYLE style)
{
   if(!InpShowLevels) return;
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
}

void UpsertCornerLabel(const string name, const string text, int corner, int x, int y, color clr)
{
   if(!InpShowLevels) return;
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
}

void DrawLevels(double poc, double vah, double val)
{
   if(!InpShowLevels) return;
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

void PlotPivotText(const string txt, datetime t, double price)
{
   if(!InpShowPivots) return;
   string name = ObjName("PIV_" + txt + "_" + IntegerToString((int)t));
   if(ObjectFind(0, name) >= 0) return;
   if(!ObjectCreate(0, name, OBJ_TEXT, 0, t, price)) return;
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, (txt == "HH") ? clrRed : clrLime);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
}

void PlotSignalArrow(const string side, datetime t, double price)
{
   if(!InpShowSignals) return;
   string name = ObjName("SIG_" + side + "_" + IntegerToString((int)t));
   if(ObjectFind(0, name) >= 0) return;
   bool isBuy = (StringFind(side, "BUY") >= 0);
   ENUM_OBJECT objType = isBuy ? OBJ_ARROW_BUY : OBJ_ARROW_SELL;
   if(!ObjectCreate(0, name, objType, 0, t, price)) return;
   ObjectSetInteger(0, name, OBJPROP_COLOR, isBuy ? clrLime : clrRed);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
}

void DeleteVolumeProfileObjects()
{
   for(int i=0; i<InpVpRows; i++)
   {
      string name = ObjName("VP_" + IntegerToString(i));
      if(ObjectFind(0, name) >= 0)
         ObjectDelete(0, name);
   }
}

void UpsertRectLabel(const string name, int x, int y, int w, int h, color clr)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
}

void DrawVolumeProfile(
   const datetime &timeArr[],
   const double &levelPrices[],
   const double &levelVols[],
   int rows,
   double rowHeight,
   double vah,
   double val
)
{
   if(!InpShowProfile)
   {
      DeleteVolumeProfileObjects();
      return;
   }
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   if(chartW <= 0) chartW = 800;
   if(chartH <= 0) chartH = 600;
   int margin = 10;
   int offsetPx = InpProfileOffsetBars * 6;
   int anchorX = InpProfileRight ? (chartW - margin - offsetPx) : (margin + offsetPx);
   double maxVol = 0.0;
   for(int i=0; i<rows; i++)
      if(levelVols[i] > maxVol) maxVol = levelVols[i];
   if(maxVol <= 0.0)
      return;

   double priceTopAll = levelPrices[rows - 1] + rowHeight * 0.5;
   double priceBotAll = levelPrices[0] - rowHeight * 0.5;
   double priceRange = priceTopAll - priceBotAll;
   if(priceRange <= 0.0) return;
   for(int i=0; i<rows; i++)
   {
      double pTop = levelPrices[i] + rowHeight * 0.5;
      double pBot = levelPrices[i] - rowHeight * 0.5;
      int yTop = (int)MathRound((priceTopAll - pTop) / priceRange * (double)chartH);
      int yBot = (int)MathRound((priceTopAll - pBot) / priceRange * (double)chartH);
      int topY = MathMin(yTop, yBot);
      int heightPx = MathAbs(yBot - yTop);
      if(heightPx < 1) heightPx = 1;

      double wPxF = ((double)InpProfileWidthBars) * 6.0 * (levelVols[i] / maxVol);
      int wPx = (int)MathRound(wPxF);
      if(wPx < 1) wPx = 1;

      int x = InpProfileRight ? (anchorX - wPx) : anchorX;
      int y = topY;
      bool inVA = (levelPrices[i] >= val && levelPrices[i] <= vah);
      color c = inVA ? WithAlpha(clrDeepSkyBlue, InpProfileAlpha) : WithAlpha(clrSilver, InpProfileAlpha);
      UpsertRectLabel(ObjName("VP_" + IntegerToString(i)), x, y, wPx, heightPx, c);
   }
}

string UrlEncode(const string s)
{
   string out = "";
   for(int i=0; i<StringLen(s); i++)
   {
      ushort ch = (ushort)StringGetCharacter(s, i);
      bool ok =
         (ch >= 'a' && ch <= 'z') ||
         (ch >= 'A' && ch <= 'Z') ||
         (ch >= '0' && ch <= '9') ||
         ch == '-' || ch == '_' || ch == '.' || ch == '~';
      if(ok)
      {
         out += CharToString((uchar)ch);
      }
      else
      {
         if(ch <= 0xFF)
            out += StringFormat("%%%02X", (int)ch);
         else
            out += "%3F";
      }
   }
   return out;
}

bool SendTelegramMessage(const string text)
{
   if(!InpSendTelegram) return true;
   if(InpTelegramToken == "" || InpTelegramChatId == "") return false;
   string url = "https://api.telegram.org/bot" + InpTelegramToken + "/sendMessage";
   string body = "chat_id=" + UrlEncode(InpTelegramChatId) + "&text=" + UrlEncode(text) + "&disable_web_page_preview=true";
   uchar data[];
   int data_len = StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
   if(data_len <= 0) return false;
   uchar result[];
   string result_headers = "";
   string headers = "Content-Type: application/x-www-form-urlencoded; charset=utf-8\r\n";
   int timeout = 10000;
   ResetLastError();
   int code = WebRequest("POST", url, headers, timeout, data, result, result_headers);
   return (code == 200);
}

void FireMessage(const string msg)
{
   if(InpSendTerminalAlert) Alert(msg);
   if(InpSendPushNotification) SendNotification(msg);
   SendTelegramMessage(msg);
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

bool IsPivotHigh(const double &high[], int shiftPivot, int depth, int lb, double &price, datetime &t, const datetime &timeArr[])
{
   price = 0.0;
   t = 0;
   int bars = ArraySize(high);
   int leftMaxShift = shiftPivot + depth;
   int rightMinShift = shiftPivot - lb;
   if(rightMinShift < 1) return false;
   if(leftMaxShift >= bars) return false;
   double p = high[shiftPivot];
   double maxH = -DBL_MAX;
   for(int s=rightMinShift; s<=leftMaxShift; s++)
      if(high[s] > maxH) maxH = high[s];
   if(p == maxH)
   {
      price = p;
      t = timeArr[shiftPivot];
      return true;
   }
   return false;
}

bool IsPivotLow(const double &low[], int shiftPivot, int depth, int lb, double &price, datetime &t, const datetime &timeArr[])
{
   price = 0.0;
   t = 0;
   int bars = ArraySize(low);
   int leftMaxShift = shiftPivot + depth;
   int rightMinShift = shiftPivot - lb;
   if(rightMinShift < 1) return false;
   if(leftMaxShift >= bars) return false;
   double p = low[shiftPivot];
   double minL = DBL_MAX;
   for(int s=rightMinShift; s<=leftMaxShift; s++)
      if(low[s] < minL) minL = low[s];
   if(p == minL)
   {
      price = p;
      t = timeArr[shiftPivot];
      return true;
   }
   return false;
}

bool CalcVolumeProfileDetails(
   int lookbackBars,
   int rows,
   int vaPercent,
   double &poc,
   double &vah,
   double &val,
   double &rowHeight,
   double &levelPrices[],
   double &levelVols[]
)
{
   return false;
}

bool CalcVolumeProfileDetailsFromArrays(
   const int rates_total,
   const datetime &timeArr[],
   const double &high[],
   const double &low[],
   const long &tick_volume[],
   int lookbackBars,
   int rows,
   int vaPercent,
   double &poc,
   double &vah,
   double &val,
   double &rowHeight,
   double &levelPrices[],
   double &levelVols[]
)
{
   poc = 0.0;
   vah = 0.0;
   val = 0.0;
   rowHeight = 0.0;
   ArrayResize(levelPrices, 0);
   ArrayResize(levelVols, 0);
   if(lookbackBars < 5 || rows < 10) return false;
   if(rates_total < lookbackBars + 5) return false;

   int maxLb = MathMin(lookbackBars, rates_total - 3);
   double highest = -DBL_MAX;
   double lowest = DBL_MAX;
   for(int i=1; i<=maxLb; i++)
   {
      if(high[i] > highest) highest = high[i];
      if(low[i] < lowest) lowest = low[i];
   }

   double range = highest - lowest;
   if(range <= 0.0) return false;
   rowHeight = range / (double)rows;
   if(rowHeight <= 0.0) return false;

   ArrayResize(levelPrices, rows);
   ArrayResize(levelVols, rows);
   for(int i=0; i<rows; i++)
   {
      levelPrices[i] = lowest + ((double)i + 0.5) * rowHeight;
      levelVols[i] = 0.0;
   }

   for(int i=1; i<=maxLb; i++)
   {
      double barHigh = high[i];
      double barLow = low[i];
      double barVol = (double)tick_volume[i];
      if(barVol <= 0.0) barVol = 1.0;
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

string StructureLabel(double pivotPrice, bool isHigh)
{
   if(!g_has_last_pivot) return isHigh ? "HH" : "LL";
   if(isHigh) return (pivotPrice > g_last_pivot_price) ? "HH" : "LH";
   return (pivotPrice < g_last_pivot_price) ? "LL" : "HL";
}

void ScanHistoryAndDrawPivots(
   const int rates_total,
   const datetime &timeArr[],
   const double &high[],
   const double &low[]
)
{
   if(!InpShowPivots || !InpScanHistoryPivots) return;
   if(rates_total < InpDepth + InpLb + 50) return;

   g_last_pivot_time = 0;
   g_last_pivot_price = 0.0;
   g_has_last_pivot = false;
   g_prev_hh_price = 0.0;
   g_prev_hh_time = 0;
   g_has_prev_hh = false;
   g_prev_ll_price = 0.0;
   g_prev_ll_time = 0;
   g_has_prev_ll = false;

   int maxShiftPivot = rates_total - 1 - InpDepth;
   int minShiftPivot = InpLb + 1;
   for(int sp=maxShiftPivot; sp>=minShiftPivot; sp--)
   {
      double phPrice, plPrice;
      datetime phTime, plTime;
      bool hasPh = IsPivotHigh(high, sp, InpDepth, InpLb, phPrice, phTime, timeArr);
      bool hasPl = IsPivotLow(low, sp, InpDepth, InpLb, plPrice, plTime, timeArr);

      if(hasPh && (g_last_pivot_time == 0 || phTime > g_last_pivot_time))
      {
         string label = StructureLabel(phPrice, true);
         if(label == "HH")
         {
            PlotPivotText("HH", phTime, phPrice + 5.0 * PipSize());
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
            g_prev_ll_price = plPrice;
            g_prev_ll_time = plTime;
            g_has_prev_ll = true;
         }
         g_last_pivot_time = plTime;
         g_last_pivot_price = plPrice;
         g_has_last_pivot = true;
      }
   }
}

int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "ICT VP Pivot Indicator");
   SetIndexBuffer(0, g_pocBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, g_vahBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, g_valBuffer, INDICATOR_DATA);
   ArraySetAsSeries(g_pocBuffer, true);
   ArraySetAsSeries(g_vahBuffer, true);
   ArraySetAsSeries(g_valBuffer, true);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, 0);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, 0);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   DeleteVolumeProfileObjects();
}

int OnCalculate(
   const int rates_total,
   const int prev_calculated,
   const datetime &timeArr[],
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   const long &tick_volume[],
   const long &volume[],
   const int &spread[]
)
{
   if(rates_total < InpDepth + InpLb + 10) return rates_total;
   if(prev_calculated == 0)
      ScanHistoryAndDrawPivots(rates_total, timeArr, high, low);

   bool doUpdate = false;
   if(prev_calculated == 0) doUpdate = true;
   if(g_last_bar_time == 0) { g_last_bar_time = timeArr[0]; doUpdate = true; }
   if(timeArr[0] != g_last_bar_time) { g_last_bar_time = timeArr[0]; doUpdate = true; }
   if(!doUpdate) return rates_total;

   double poc, vah, val, rowH;
   double lvlPrices[];
   double lvlVols[];
   bool vpOk = CalcVolumeProfileDetailsFromArrays(rates_total, timeArr, high, low, tick_volume, InpVpLookbackBars, InpVpRows, InpVpValueAreaPercent, poc, vah, val, rowH, lvlPrices, lvlVols);
   if(!vpOk)
   {
      for(int i=0; i<rates_total; i++)
      {
         g_pocBuffer[i] = EMPTY_VALUE;
         g_vahBuffer[i] = EMPTY_VALUE;
         g_valBuffer[i] = EMPTY_VALUE;
      }
      if(InpDebugLog && g_last_debug_bar_time != timeArr[0])
      {
         g_last_debug_bar_time = timeArr[0];
         Print("ICTVP_IND VP_FAIL ", _Symbol, " TF=", EnumToString(_Period), " rates_total=", rates_total, " lookback=", InpVpLookbackBars);
      }
      return rates_total;
   }
   DrawLevels(poc, vah, val);
   DrawVolumeProfile(timeArr, lvlPrices, lvlVols, InpVpRows, rowH, vah, val);
   // also plot buffers for persistent visibility
   for(int i=0; i<rates_total; i++)
   {
      g_pocBuffer[i] = poc;
      g_vahBuffer[i] = vah;
      g_valBuffer[i] = val;
   }
   if(InpDebugLog && g_last_debug_bar_time != timeArr[0])
   {
      g_last_debug_bar_time = timeArr[0];
      Print("ICTVP_IND VP_OK ", _Symbol, " POC=", DoubleToString(poc, _Digits), " VAH=", DoubleToString(vah, _Digits), " VAL=", DoubleToString(val, _Digits));
   }

   datetime lastClosedTime = timeArr[1];
   double prevClose = close[2];
   double lastClose = close[1];
   double lastHigh = high[1];
   double lastLow = low[1];

   if(InpAlertOnTouch)
   {
      if(g_last_touch_vah_bar_time != lastClosedTime && prevClose > vah && lastLow <= vah)
      {
         g_last_touch_vah_bar_time = lastClosedTime;
         PlotSignalArrow("SELL_TOUCH_VAH", lastClosedTime, vah);
         FireMessage(StringFormat("[MT5][YF] SELL Touch VAH %s VAH=%.5f Close=%.5f", _Symbol, vah, lastClose));
      }
      if(g_last_touch_val_bar_time != lastClosedTime && prevClose < val && lastHigh >= val)
      {
         g_last_touch_val_bar_time = lastClosedTime;
         PlotSignalArrow("BUY_TOUCH_VAL", lastClosedTime, val);
         FireMessage(StringFormat("[MT5][YF] BUY Touch VAL %s VAL=%.5f Close=%.5f", _Symbol, val, lastClose));
      }
   }

   int pivotShift = InpLb + 1;
   double phPrice, plPrice;
   datetime phTime, plTime;
   bool hasPh = IsPivotHigh(high, pivotShift, InpDepth, InpLb, phPrice, phTime, timeArr);
   bool hasPl = IsPivotLow(low, pivotShift, InpDepth, InpLb, plPrice, plTime, timeArr);

   if(hasPh && (g_last_pivot_time == 0 || phTime > g_last_pivot_time))
   {
      string label = StructureLabel(phPrice, true);
      if(label == "HH")
      {
         PlotPivotText("HH", phTime, phPrice + 5.0 * PipSize());
         if(g_has_prev_hh && phPrice > g_prev_hh_price)
         {
            if(InpAlertOnDouble && g_last_double_hh_time != phTime)
            {
               g_last_double_hh_time = phTime;
               FireMessage(StringFormat("[MT5][YF] DOUBLE HH %s %.5f -> %.5f", _Symbol, g_prev_hh_price, phPrice));
            }
            if(InpAlertOnCrossAfterDouble)
            {
               g_pending_sell = true;
               g_pending_sell_level = vah;
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
            if(InpAlertOnDouble && g_last_double_ll_time != plTime)
            {
               g_last_double_ll_time = plTime;
               FireMessage(StringFormat("[MT5][YF] DOUBLE LL %s %.5f -> %.5f", _Symbol, g_prev_ll_price, plPrice));
            }
            if(InpAlertOnCrossAfterDouble)
            {
               g_pending_buy = true;
               g_pending_buy_level = val;
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

   if(InpAlertOnCrossAfterDouble)
   {
      if(g_pending_sell && prevClose > g_pending_sell_level && lastClose <= g_pending_sell_level)
      {
         if(g_last_cross_sell_time != lastClosedTime)
         {
            g_last_cross_sell_time = lastClosedTime;
            PlotSignalArrow("SELL_CROSS_VAH", lastClosedTime, g_pending_sell_level);
            FireMessage(StringFormat("[MT5][YF] SELL Cross VAH %s VAH=%.5f Close=%.5f", _Symbol, g_pending_sell_level, lastClose));
         }
         g_pending_sell = false;
         g_pending_sell_level = 0.0;
      }
      if(g_pending_buy && prevClose < g_pending_buy_level && lastClose >= g_pending_buy_level)
      {
         if(g_last_cross_buy_time != lastClosedTime)
         {
            g_last_cross_buy_time = lastClosedTime;
            PlotSignalArrow("BUY_CROSS_VAL", lastClosedTime, g_pending_buy_level);
            FireMessage(StringFormat("[MT5][YF] BUY Cross VAL %s VAL=%.5f Close=%.5f", _Symbol, g_pending_buy_level, lastClose));
         }
         g_pending_buy = false;
         g_pending_buy_level = 0.0;
      }
   }

   ChartRedraw(0);
   return rates_total;
}
