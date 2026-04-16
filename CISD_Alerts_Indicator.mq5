#property indicator_chart_window
#property indicator_plots 0
#property version "1.00"

input group "Style"
input color InpPlusColor = clrLimeGreen;
input color InpMinusColor = clrRed;
input string InpPlusText = "+CISD";
input string InpMinusText = "-CISD";
input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID;
input int InpLineWidth = 1;
input int InpExtendBars = 5;
input bool InpKeepLevels = false;

input group "Alerts"
input bool InpSendAlert = true;
input bool InpSendPush = false;
input bool InpNotifyHistorical = false;
input bool InpSuppressAlertsOnLoad = true;

input group "Hammer / Shooting"
input bool InpEnableHs = true;
input double InpFibLevel = 0.382;
input bool InpConfirmByNextCandle = false;
input bool InpConfirmWithDxy = true;
input string InpDxySymbol = "DXY.cash";
input color InpHammerColor = clrLimeGreen;
input color InpShootingColor = clrRed;
input int InpHammerArrowCode = 233;
input int InpShootingArrowCode = 234;
input bool InpHsEntryOnBreakout = false;
input int InpHsBreakoutBufferPoints = 0;
input bool InpHsAlertOnBreakout = true;
input bool InpHsShowBreakoutLine = true;
input color InpHsBreakoutLineColor = clrDodgerBlue;

input group "Volume Profile Filter"
input bool InpVpFilterEnabled = true;
input bool InpVpAnchorAsia = true;
input int InpVpAsiaOpenHour = 0;
input int InpVpSessionOffsetHours = 0;
input int InpVpMaxBars = 600;
input int InpVpLookbackBars = 100;
input int InpVpRows = 30;
input int InpVpValueAreaPercent = 70;
input bool InpVpShowLines = true;
input color InpVpPocColor = clrDeepSkyBlue;
input color InpVpVahColor = clrMediumPurple;
input color InpVpValColor = clrOrange;

double g_top_price = 0.0;
double g_bottom_price = 0.0;
bool g_is_bullish = false;

bool g_is_bullish_pullback = false;
bool g_is_bearish_pullback = false;
double g_potential_top_price = 0.0;
double g_potential_bottom_price = 0.0;
int g_bullish_break_pos = -1;
int g_bearish_break_pos = -1;

double g_plus_level_price = 0.0;
datetime g_plus_level_time = 0;
bool g_plus_completed = true;
string g_plus_obj = "";
string g_plus_lbl = "";

double g_minus_level_price = 0.0;
datetime g_minus_level_time = 0;
bool g_minus_completed = true;
string g_minus_obj = "";
string g_minus_lbl = "";

datetime g_last_alert_time_plus = 0;
datetime g_last_alert_time_minus = 0;

string g_prefix = "CISD_";
bool g_alerts_armed = false;
datetime g_last_time0 = 0;

datetime g_last_hammer_alert_time = 0;
datetime g_last_shooting_alert_time = 0;
bool g_hs_pending_long = false;
bool g_hs_pending_short = false;
double g_hs_pending_long_level = 0.0;
double g_hs_pending_short_level = 0.0;
datetime g_hs_pending_long_time = 0;
datetime g_hs_pending_short_time = 0;
bool g_hs_breakout_long_fired = false;
bool g_hs_breakout_short_fired = false;
string g_hs_breakout_long_line = "";
string g_hs_breakout_long_text = "";
string g_hs_breakout_short_line = "";
string g_hs_breakout_short_text = "";

double g_vp_poc = 0.0;
double g_vp_vah = 0.0;
double g_vp_val = 0.0;
string g_vp_poc_line = "";
string g_vp_vah_line = "";
string g_vp_val_line = "";

void DeleteObjectSafe(const string name)
{
   if(name == "") return;
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);
}

datetime ExtendTime(datetime t, int bars)
{
   long sec = PeriodSeconds(_Period);
   if(sec <= 0) sec = 60;
   return (datetime)(t + (long)bars * sec);
}

bool ComputeVpLevelsSeries(const int lookbackBars, const int rows, const int valueAreaPercent, const double &high[], const double &low[], const long &tick_volume[], double &poc, double &vah, double &val)
{
   poc = 0.0;
   vah = 0.0;
   val = 0.0;
   if(lookbackBars < 10 || rows < 10) return false;
   if(ArraySize(high) < lookbackBars || ArraySize(low) < lookbackBars) return false;

   double highest = -DBL_MAX;
   double lowest = DBL_MAX;
   for(int i = 0; i < lookbackBars; i++)
   {
      if(high[i] > highest) highest = high[i];
      if(low[i] < lowest) lowest = low[i];
   }
   double range = highest - lowest;
   if(range <= 0.0) return false;

   double rowHeight = range / (double)rows;
   if(rowHeight <= 0.0) return false;

   double levelVol[];
   ArrayResize(levelVol, rows);
   for(int i = 0; i < rows; i++) levelVol[i] = 0.0;

   for(int i = 0; i < lookbackBars; i++)
   {
      double barHigh = high[i];
      double barLow = low[i];
      double barVol = (double)tick_volume[i];
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
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
}

void CreateBreakoutLevel(const string side, datetime t1, datetime t2, double price, bool confirmed, string &outLine, string &outLbl)
{
   if(!InpHsShowBreakoutLine) return;
   string lineName = g_prefix + "HSB_" + side + "_L_" + IntegerToString((long)t1);
   string lblName = g_prefix + "HSB_" + side + "_T_" + IntegerToString((long)t1);

   DeleteObjectSafe(outLine);
   DeleteObjectSafe(outLbl);

   if(ObjectCreate(0, lineName, OBJ_TREND, 0, t1, price, t2, price))
   {
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpHsBreakoutLineColor);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
   }

   string txt = (side == "LONG") ? "BUY break" : "SELL break";
   if(confirmed) txt = txt + " confermato";
   if(ObjectCreate(0, lblName, OBJ_TEXT, 0, t2, price))
   {
      ObjectSetString(0, lblName, OBJPROP_TEXT, txt);
      ObjectSetInteger(0, lblName, OBJPROP_COLOR, InpHsBreakoutLineColor);
      ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, lblName, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, lblName, OBJPROP_SELECTABLE, false);
   }

   outLine = lineName;
   outLbl = lblName;
}

void UpdateBreakoutLevel(const string lineName, const string lblName, datetime t2, double price)
{
   if(lineName != "" && ObjectFind(0, lineName) >= 0)
      ObjectMove(0, lineName, 1, t2, price);
   if(lblName != "" && ObjectFind(0, lblName) >= 0)
      ObjectMove(0, lblName, 0, t2, price);
}

void CreateLevel(const string side, datetime t1, datetime t2, double price, color clr, const string text, string &outLine, string &outLbl)
{
   string lineName = g_prefix + side + "_L_" + IntegerToString((long)t1);
   string lblName = g_prefix + side + "_T_" + IntegerToString((long)t1);

   if(!InpKeepLevels)
   {
      if(side == "PLUS") { DeleteObjectSafe(g_plus_obj); DeleteObjectSafe(g_plus_lbl); }
      if(side == "MINUS") { DeleteObjectSafe(g_minus_obj); DeleteObjectSafe(g_minus_lbl); }
   }

   if(ObjectCreate(0, lineName, OBJ_TREND, 0, t1, price, t2, price))
   {
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, InpLineStyle);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, InpLineWidth);
      ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
   }

   if(ObjectCreate(0, lblName, OBJ_TEXT, 0, t2, price))
   {
      ObjectSetString(0, lblName, OBJPROP_TEXT, text);
      ObjectSetInteger(0, lblName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, lblName, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, lblName, OBJPROP_SELECTABLE, false);
   }

   outLine = lineName;
   outLbl = lblName;
}

void UpdateLevel(const string lineName, const string lblName, datetime t2, double price)
{
   if(ObjectFind(0, lineName) >= 0)
   {
      ObjectMove(0, lineName, 1, t2, price);
   }
   if(ObjectFind(0, lblName) >= 0)
   {
      ObjectMove(0, lblName, 0, t2, price);
   }
}

void NotifyCisd(const string kind, datetime t, double levelPrice)
{
   if(!g_alerts_armed) return;
   if(!InpNotifyHistorical)
   {
      if(t != iTime(_Symbol, _Period, 1)) return;
   }

   string msg = kind + " on " + _Symbol + " TF=" + EnumToString(_Period) + " Level=" + DoubleToString(levelPrice, _Digits);
   if(InpSendAlert) Alert(msg);
   if(InpSendPush) SendNotification(msg);
}

bool IsHammerCandle(const int i, const double &open[], const double &high[], const double &low[], const double &close[])
{
   double candleSize = MathAbs(high[i] - low[i]);
   if(candleSize <= 0.0) return false;
   double bodyMin = MathMin(open[i], close[i]);
   return (high[i] - InpFibLevel * candleSize) < bodyMin;
}

bool IsShootingCandle(const int i, const double &open[], const double &high[], const double &low[], const double &close[])
{
   double candleSize = MathAbs(high[i] - low[i]);
   if(candleSize <= 0.0) return false;
   double bodyMax = MathMax(open[i], close[i]);
   return (low[i] + InpFibLevel * candleSize) > bodyMax;
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

void CreateHsSignal(const string kind, datetime t, double price, color clr, int arrowCode, bool confirmed)
{
   string base = g_prefix + kind + "_" + IntegerToString((long)t);
   string arrowName = base + "_A";
   string textName = base + "_T";
   if(ObjectFind(0, arrowName) >= 0 || ObjectFind(0, textName) >= 0) return;

   if(ObjectCreate(0, arrowName, OBJ_ARROW, 0, t, price))
   {
      ObjectSetInteger(0, arrowName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, arrowCode);
      ObjectSetInteger(0, arrowName, OBJPROP_SELECTABLE, false);
   }

   string label = kind;
   if(confirmed) label = label + " confermato";
   if(ObjectCreate(0, textName, OBJ_TEXT, 0, t, price))
   {
      ObjectSetString(0, textName, OBJPROP_TEXT, label);
      ObjectSetInteger(0, textName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, textName, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
   }

   if(InpSendAlert || InpSendPush)
   {
      if(!g_alerts_armed) return;
      if(!InpNotifyHistorical)
      {
         if(t != iTime(_Symbol, _Period, 1)) return;
      }
      string msg = kind + (confirmed ? " confermato" : "") + " on " + _Symbol + " TF=" + EnumToString(_Period) + " Price=" + DoubleToString(price, _Digits);
      if(InpSendAlert) Alert(msg);
      if(InpSendPush) SendNotification(msg);
   }
}

void ProcessHammerShooting(const int i, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
{
   if(!InpEnableHs) return;
   if(i + 1 >= ArraySize(time)) return;

   int confirmIndex = i;
   int signalIndex = InpConfirmByNextCandle ? (i + 1) : i;

   bool isGreen = (close[confirmIndex] > open[confirmIndex]);
   bool isRed = (close[confirmIndex] < open[confirmIndex]);

   bool hammer = false;
   bool shoot = false;

   if(!InpConfirmByNextCandle)
   {
      hammer = IsHammerCandle(signalIndex, open, high, low, close);
      shoot = IsShootingCandle(signalIndex, open, high, low, close);
   }
   else
   {
      double sigBodyHigh = MathMax(open[signalIndex], close[signalIndex]);
      double sigBodyLow = MathMin(open[signalIndex], close[signalIndex]);
      hammer = IsHammerCandle(signalIndex, open, high, low, close) && isGreen && (close[confirmIndex] > sigBodyHigh);
      shoot = IsShootingCandle(signalIndex, open, high, low, close) && isRed && (close[confirmIndex] < sigBodyLow);
   }

   if(!hammer && !shoot) return;

   bool dxyBull = false;
   bool dxyBear = false;
   bool haveDxy = false;
   if(InpConfirmWithDxy && IsXauSymbol())
      haveDxy = GetDxyDirection(time[signalIndex], dxyBull, dxyBear);

   if(hammer)
   {
      bool confirmed = (haveDxy && dxyBear);
      CreateHsSignal("Hammer", time[signalIndex], low[signalIndex], InpHammerColor, InpHammerArrowCode, confirmed);
      if(InpHsEntryOnBreakout)
      {
         bool vpOk = true;
         if(InpVpFilterEnabled)
            vpOk = (low[signalIndex] < g_vp_val) && (close[signalIndex] > g_vp_val) && (close[signalIndex] < g_vp_vah);
         if(!vpOk) return;
         g_hs_pending_long = true;
         g_hs_pending_short = false;
         g_hs_pending_long_level = high[signalIndex];
         g_hs_pending_long_time = time[signalIndex];
         g_hs_breakout_long_fired = false;
         datetime t2 = ExtendTime(time[i], InpExtendBars);
         CreateBreakoutLevel("LONG", time[signalIndex], t2, g_hs_pending_long_level, confirmed, g_hs_breakout_long_line, g_hs_breakout_long_text);
         DeleteObjectSafe(g_hs_breakout_short_line);
         DeleteObjectSafe(g_hs_breakout_short_text);
         g_hs_breakout_short_line = "";
         g_hs_breakout_short_text = "";
      }
      g_last_hammer_alert_time = time[signalIndex];
   }

   if(shoot)
   {
      bool confirmed = (haveDxy && dxyBull);
      CreateHsSignal("Shooting", time[signalIndex], high[signalIndex], InpShootingColor, InpShootingArrowCode, confirmed);
      if(InpHsEntryOnBreakout)
      {
         bool vpOk = true;
         if(InpVpFilterEnabled)
            vpOk = (high[signalIndex] > g_vp_vah) && (close[signalIndex] < g_vp_vah) && (close[signalIndex] > g_vp_val);
         if(!vpOk) return;
         g_hs_pending_short = true;
         g_hs_pending_long = false;
         g_hs_pending_short_level = low[signalIndex];
         g_hs_pending_short_time = time[signalIndex];
         g_hs_breakout_short_fired = false;
         datetime t2 = ExtendTime(time[i], InpExtendBars);
         CreateBreakoutLevel("SHORT", time[signalIndex], t2, g_hs_pending_short_level, confirmed, g_hs_breakout_short_line, g_hs_breakout_short_text);
         DeleteObjectSafe(g_hs_breakout_long_line);
         DeleteObjectSafe(g_hs_breakout_long_text);
         g_hs_breakout_long_line = "";
         g_hs_breakout_long_text = "";
      }
      g_last_shooting_alert_time = time[signalIndex];
   }
}

void ProcessBar(const int i, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
{
   ProcessHammerShooting(i, time, open, high, low, close);

   bool bearish_pullback_detected = (close[i+1] > open[i+1]);
   bool bullish_pullback_detected = (close[i+1] < open[i+1]);

   if(bearish_pullback_detected && !g_is_bearish_pullback)
   {
      g_is_bearish_pullback = true;
      g_potential_top_price = open[i+1];
      g_bullish_break_pos = i+1;
   }

   if(bullish_pullback_detected && !g_is_bullish_pullback)
   {
      g_is_bullish_pullback = true;
      g_potential_bottom_price = open[i+1];
      g_bearish_break_pos = i+1;
   }

   if(g_is_bullish_pullback)
   {
      if(open[i] < g_potential_bottom_price)
      {
         g_potential_bottom_price = open[i];
         g_bearish_break_pos = i;
      }
      if(close[i] < open[i] && open[i] > g_potential_bottom_price)
      {
         g_potential_bottom_price = open[i];
         g_bearish_break_pos = i;
      }
   }

   if(g_is_bearish_pullback)
   {
      if(open[i] > g_potential_top_price)
      {
         g_potential_top_price = open[i];
         g_bullish_break_pos = i;
      }
      if(close[i] > open[i] && open[i] < g_potential_top_price)
      {
         g_potential_top_price = open[i];
         g_bullish_break_pos = i;
      }
   }

   if(low[i] < g_bottom_price)
   {
      g_bottom_price = low[i];
      g_is_bullish = false;

      bool created = false;
      if(g_is_bearish_pullback && g_bullish_break_pos >= 0 && (g_bullish_break_pos - i) != 0)
      {
         int bp = g_bullish_break_pos;
         double h1 = high[bp];
         double h2 = (bp + 1 < ArraySize(high)) ? high[bp + 1] : high[bp];
         g_top_price = MathMax(h1, h2);
         g_is_bearish_pullback = false;

         datetime t1 = time[bp];
         datetime t2 = ExtendTime(time[i], InpExtendBars);
         CreateLevel("PLUS", t1, t2, g_potential_top_price, InpPlusColor, InpPlusText, g_plus_obj, g_plus_lbl);
         g_plus_level_price = g_potential_top_price;
         g_plus_level_time = time[i];
         g_plus_completed = false;
         created = true;
      }
      else if(close[i+1] > open[i+1] && close[i] < open[i])
      {
         g_top_price = high[i+1];
         g_is_bearish_pullback = false;
         if(g_bullish_break_pos >= 0)
         {
            datetime t1 = time[g_bullish_break_pos];
            datetime t2 = ExtendTime(time[i], InpExtendBars);
            CreateLevel("PLUS", t1, t2, g_potential_top_price, InpPlusColor, InpPlusText, g_plus_obj, g_plus_lbl);
            g_plus_level_price = g_potential_top_price;
            g_plus_level_time = time[i];
            g_plus_completed = false;
            created = true;
         }
      }
      if(created) {}
   }

   if(high[i] > g_top_price)
   {
      g_is_bullish = true;
      g_top_price = high[i];

      bool created = false;
      if(g_is_bullish_pullback && g_bearish_break_pos >= 0 && (g_bearish_break_pos - i) != 0)
      {
         int bp = g_bearish_break_pos;
         double l1 = low[bp];
         double l2 = (bp + 1 < ArraySize(low)) ? low[bp + 1] : low[bp];
         g_bottom_price = MathMin(l1, l2);
         g_is_bullish_pullback = false;

         datetime t1 = time[bp];
         datetime t2 = ExtendTime(time[i], InpExtendBars);
         CreateLevel("MINUS", t1, t2, g_potential_bottom_price, InpMinusColor, InpMinusText, g_minus_obj, g_minus_lbl);
         g_minus_level_price = g_potential_bottom_price;
         g_minus_level_time = time[i];
         g_minus_completed = false;
         created = true;
      }
      else if(close[i+1] < open[i+1] && close[i] > open[i])
      {
         g_bottom_price = low[i+1];
         g_is_bullish_pullback = false;
         if(g_bearish_break_pos >= 0)
         {
            datetime t1 = time[g_bearish_break_pos];
            datetime t2 = ExtendTime(time[i], InpExtendBars);
            CreateLevel("MINUS", t1, t2, g_potential_bottom_price, InpMinusColor, InpMinusText, g_minus_obj, g_minus_lbl);
            g_minus_level_price = g_potential_bottom_price;
            g_minus_level_time = time[i];
            g_minus_completed = false;
            created = true;
         }
      }
      if(created) {}
   }

   bool fired = false;
   if(!g_minus_completed && close[i] < g_minus_level_price)
   {
      g_minus_completed = true;
      if(time[i] != g_last_alert_time_minus)
      {
         NotifyCisd("Bearish CISD Formed", time[i], g_minus_level_price);
         g_last_alert_time_minus = time[i];
      }
      fired = true;

      if(g_bullish_break_pos >= 0)
      {
         datetime t1 = time[g_bullish_break_pos];
         datetime t2 = ExtendTime(time[i], InpExtendBars);
         CreateLevel("PLUS", t1, t2, g_potential_top_price, InpPlusColor, InpPlusText, g_plus_obj, g_plus_lbl);
         g_plus_level_price = g_potential_top_price;
         g_plus_level_time = time[i];
         g_plus_completed = false;
      }
      g_is_bullish = false;
   }

   if((!fired) && !g_plus_completed && close[i] > g_plus_level_price)
   {
      g_plus_completed = true;
      if(time[i] != g_last_alert_time_plus)
      {
         NotifyCisd("Bullish CISD Formed", time[i], g_plus_level_price);
         g_last_alert_time_plus = time[i];
      }

      if(g_bearish_break_pos >= 0)
      {
         datetime t1 = time[g_bearish_break_pos];
         datetime t2 = ExtendTime(time[i], InpExtendBars);
         CreateLevel("MINUS", t1, t2, g_potential_bottom_price, InpMinusColor, InpMinusText, g_minus_obj, g_minus_lbl);
         g_minus_level_price = g_potential_bottom_price;
         g_minus_level_time = time[i];
         g_minus_completed = false;
      }
      g_is_bullish = true;
   }
}

int OnInit()
{
   if(InpConfirmWithDxy && InpDxySymbol != "")
      SymbolSelect(InpDxySymbol, true);
   g_alerts_armed = !InpSuppressAlertsOnLoad;
   g_last_time0 = 0;
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, g_prefix);
}

datetime VpAsiaOpenLocal(datetime nowLocal)
{
   MqlDateTime dt;
   TimeToStruct(nowLocal, dt);
   dt.hour = InpVpAsiaOpenHour;
   dt.min = 0;
   dt.sec = 0;
   datetime openLocal = StructToTime(dt);
   if(nowLocal < openLocal)
      openLocal = openLocal - 86400;
   return openLocal;
}

int VpLookbackBarsFromAsia(const datetime &time[])
{
   if(!InpVpAnchorAsia) return InpVpLookbackBars;
   int total = ArraySize(time);
   if(total < 2) return InpVpLookbackBars;

   datetime nowServer = time[0];
   datetime nowLocal = nowServer + (datetime)InpVpSessionOffsetHours * 3600;
   datetime openLocal = VpAsiaOpenLocal(nowLocal);
   datetime openServer = openLocal - (datetime)InpVpSessionOffsetHours * 3600;

   int count = 0;
   for(int i = 0; i < total && i < InpVpMaxBars; i++)
   {
      if(time[i] < openServer) break;
      count++;
   }
   if(count < 10) return InpVpLookbackBars;
   return count;
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[])
{
   if(rates_total < 50) return 0;

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   if(InpSuppressAlertsOnLoad)
   {
      if(g_last_time0 == 0)
         g_last_time0 = time[0];
      else if(!g_alerts_armed && time[0] != g_last_time0)
         g_alerts_armed = true;
      g_last_time0 = time[0];
   }
   else
   {
      g_alerts_armed = true;
   }

   if(prev_calculated == 0)
   {
      ObjectsDeleteAll(0, g_prefix);
      int oldest = rates_total - 1;
      g_top_price = high[oldest];
      g_bottom_price = low[oldest];
      g_is_bullish = false;
      g_is_bullish_pullback = false;
      g_is_bearish_pullback = false;
      g_potential_top_price = open[oldest];
      g_potential_bottom_price = open[oldest];
      g_bullish_break_pos = oldest;
      g_bearish_break_pos = oldest;
      g_plus_completed = true;
      g_minus_completed = true;
      g_plus_obj = "";
      g_plus_lbl = "";
      g_minus_obj = "";
      g_minus_lbl = "";
      g_last_alert_time_plus = 0;
      g_last_alert_time_minus = 0;
      g_hs_pending_long = false;
      g_hs_pending_short = false;
      g_hs_breakout_long_fired = false;
      g_hs_breakout_short_fired = false;
      g_hs_breakout_long_line = "";
      g_hs_breakout_long_text = "";
      g_hs_breakout_short_line = "";
      g_hs_breakout_short_text = "";
      g_vp_poc = 0.0;
      g_vp_vah = 0.0;
      g_vp_val = 0.0;
      g_vp_poc_line = "";
      g_vp_vah_line = "";
      g_vp_val_line = "";
   }

   if(InpVpShowLines || InpVpFilterEnabled)
   {
      int lb = VpLookbackBarsFromAsia(time);
      if(lb > rates_total - 1) lb = rates_total - 1;
      double poc = 0.0, vah = 0.0, val = 0.0;
      if(ComputeVpLevelsSeries(lb, InpVpRows, InpVpValueAreaPercent, high, low, tick_volume, poc, vah, val))
      {
         g_vp_poc = poc;
         g_vp_vah = vah;
         g_vp_val = val;
         if(InpVpShowLines)
         {
            g_vp_poc_line = g_prefix + "VP_POC";
            g_vp_vah_line = g_prefix + "VP_VAH";
            g_vp_val_line = g_prefix + "VP_VAL";
            CreateOrUpdateHLine(g_vp_poc_line, g_vp_poc, InpVpPocColor, STYLE_SOLID);
            CreateOrUpdateHLine(g_vp_vah_line, g_vp_vah, InpVpVahColor, STYLE_DOT);
            CreateOrUpdateHLine(g_vp_val_line, g_vp_val, InpVpValColor, STYLE_DOT);
         }
      }
   }

   int limit = (prev_calculated == 0) ? rates_total - 2 : 2;
   if(limit > rates_total - 2) limit = rates_total - 2;

   for(int i = limit; i >= 1; i--)
   {
      ProcessBar(i, time, open, high, low, close);
   }

   datetime t2 = ExtendTime(time[1], InpExtendBars);
   if(!g_plus_completed && g_plus_obj != "")
      UpdateLevel(g_plus_obj, g_plus_lbl, t2, g_plus_level_price);
   if(!g_minus_completed && g_minus_obj != "")
      UpdateLevel(g_minus_obj, g_minus_lbl, t2, g_minus_level_price);

   if(InpEnableHs && InpHsEntryOnBreakout)
   {
      datetime t2b = ExtendTime(time[0], InpExtendBars);
      if(g_hs_pending_long && !g_hs_breakout_long_fired)
      {
         UpdateBreakoutLevel(g_hs_breakout_long_line, g_hs_breakout_long_text, t2b, g_hs_pending_long_level);
         double buffer = (double)InpHsBreakoutBufferPoints * _Point;
         if(high[0] >= (g_hs_pending_long_level + buffer))
         {
            g_hs_breakout_long_fired = true;
            if(g_alerts_armed && InpHsAlertOnBreakout)
            {
               string msg = "Hammer breakout BUY on " + _Symbol + " TF=" + EnumToString(_Period) + " Level=" + DoubleToString(g_hs_pending_long_level, _Digits);
               if(InpSendAlert) Alert(msg);
               if(InpSendPush) SendNotification(msg);
            }
         }
      }
      if(g_hs_pending_short && !g_hs_breakout_short_fired)
      {
         UpdateBreakoutLevel(g_hs_breakout_short_line, g_hs_breakout_short_text, t2b, g_hs_pending_short_level);
         double buffer = (double)InpHsBreakoutBufferPoints * _Point;
         if(low[0] <= (g_hs_pending_short_level - buffer))
         {
            g_hs_breakout_short_fired = true;
            if(g_alerts_armed && InpHsAlertOnBreakout)
            {
               string msg = "Shooting breakout SELL on " + _Symbol + " TF=" + EnumToString(_Period) + " Level=" + DoubleToString(g_hs_pending_short_level, _Digits);
               if(InpSendAlert) Alert(msg);
               if(InpSendPush) SendNotification(msg);
            }
         }
      }
   }

   return(rates_total);
}
