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
input bool InpCisdShowLines = false;

input group "Alerts"
input bool InpSendAlert = true;
input bool InpSendPush = false;
input bool InpNotifyHistorical = false;
input bool InpSuppressAlertsOnLoad = true;

input group "Hammer / Shooting"
input bool InpEnableHs = true;
input double InpFibLevel = 0.382;
input bool InpProCandleFilterEnabled = true;
input double InpProWickBodyMinRatio = 2.0;
input double InpProOppWickMaxBodyRatio = 0.3;
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
input bool InpHsEnableM15 = true;
input bool InpHsEnableM30 = true;
input bool InpHsEnableH1  = true;
input bool InpHsEnableH4  = true;
input bool InpHsMultiTimeframe = true;
input bool InpHsTrendFilterEnabled = true;
input int InpHsTrendEmaFast = 50;
input int InpHsTrendEmaSlow = 200;
input int InpHsTrendAtrPeriod = 14;
input double InpHsTrendAtrMult = 0.5;
input group "EMA Touch Tag"
input bool InpEmaTouchTagEnabled = true;
input int InpEmaTouchTolerancePoints = 0;
input bool InpWyckSpikeFilterEnabled = true;
input int InpWyckSpikeMinPoints = 600;
input int InpWyckSpikeMinPointsCurrent = 0;
input int InpWyckSpikeMinPointsM15 = 0;
input int InpWyckSpikeMinPointsM30 = 0;
input int InpWyckSpikeMinPointsH1 = 0;
input int InpWyckSpikeMinPointsH4 = 0;

input group "SMT Filter"
input bool InpSmtFilterEnabled = true;
input string InpSmtXagSymbol = "XAGUSD";
input int InpSmtPivotLeft = 3;
input int InpSmtPivotRight = 3;
input int InpSmtMaxBars = 300;
input bool InpSmtInvertDxy = true;
input bool InpSmtShowOnChart = true;
input color InpSmtColor = clrSilver;
input int InpSmtLineWidth = 1;
input int InpSmtYOffsetPoints = 0;

input group "Volume Filter (VL)"
input bool InpVolFilterEnabled = false;
input int InpVolMaPeriod = 20;
input double InpVolMult = 1.5;

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
input bool InpVpBodyZoneFilter = true;

input group "Structure"
input bool InpShowStructure = true;
input int InpStLeftBars = 5;
input int InpStRightBars = 5;
input int InpStPivotLegs = 0;
input int InpStMaxBars = 1000;
input bool InpStShowHH = true;
input bool InpStShowHL = true;
input bool InpStShowLH = true;
input bool InpStShowLL = true;
input color InpStUpColor = clrLimeGreen;
input color InpStDownColor = clrRed;
input bool InpStShowLine = true;
input color InpStLineColor = clrGray;
input int InpStLineWidth = 2;
input double InpStDeviationPercent = 5.0;
input int InpStFontSize = 8;
input int InpStYOffsetPoints = 0;

input group "Live Candle"
input bool InpLiveHlEnabled = true;
input bool InpLiveHlShowPrice = true;
input color InpLiveHighColor = clrDeepSkyBlue;
input color InpLiveLowColor = clrOrange;
input int InpLiveHlFontSize = 9;
input int InpLiveHlYOffsetPoints = 0;

input group "Daily Levels"
input bool InpDailyEnabled = true;
input int InpDailyTzOffsetHours = 1;
input int InpDailyNyOpenHour = 5;
input int InpDailyClosingHour = 14;
input int InpDailyClosingMinute = 30;
input int InpDailyFinalHour = 17;
input int InpDailyMaxBars = 2000;
input bool InpDailyShowVerticalLines = true;
input color InpDailyLineColor = clrWhite;
input color InpDailyNyOpenColor = clrBlue;
input bool InpDailyAlertOnCreate = true;
input bool InpDailyAlertOnTouch = true;

input group "Sessions"
input bool InpShowSessions = true;
input int InpSessionsTzOffsetHours = 1;
input int InpAsiaStartHour = 1;
input int InpAsiaEndHour = 10;
input int InpLondonStartHour = 9;
input int InpLondonEndHour = 18;
input int InpNyStartHour = 14;
input int InpNyEndHour = 23;
input color InpAsiaColor = clrCadetBlue;
input color InpLondonColor = clrSteelBlue;
input color InpNyColor = clrThistle;
input int InpSessionBoxAlpha = 10;
input int InpSessionsMaxDays = 5;
input bool InpShowOHLC = true;
input color InpOhlcBullColor = clrLimeGreen;
input color InpOhlcBearColor = clrRed;

input group "OHCL HTF Trend Levels"
input bool InpOhclEnabled = true;
input ENUM_TIMEFRAMES InpOhclHtf = PERIOD_H4;
input int InpOhclExtendBars = 50;
input int InpOhclBreakoutBufferPoints = 0;
input bool InpOhclResetOnNewHtf = true;
input bool InpOhclKeepOld = false;
input bool InpOhclShowSignals = true;
input bool InpOhclShowTp = true;
input bool InpOhclConfirmOnClose = true;
input bool InpOhclSendNotifications = true;
input bool InpOhclPlotHistorySignals = true;
input bool InpOhclPlotHistoryLevels = true;
input int InpOhclMaxHistoryLevels = 50;
input int InpOhclHistoryBars = 500;
input int InpOhclEmaLen = 50;
input bool InpOhclShowEma = false;
input bool InpOhclShowLines = false;
input color InpOhclBullColor = clrLimeGreen;
input color InpOhclBearColor = clrRed;
input color InpOhclNeutralColor = clrGray;

input group "Matteo Capital"
input bool InpCapEnabled = true;
input int InpCapTzOffsetHours = 1;
input int InpCapIbHour = 9;
input ENUM_TIMEFRAMES InpCapSignalTf = PERIOD_M15;
input bool InpCapConfirmOnClose = true;
input int InpCapNyStartHour = 15;
input int InpCapNyStartMinute = 0;
input int InpCapNyEndHour = 16;
input int InpCapNyEndMinute = 30;
input bool InpCapVolFilterEnabled = true;
input int InpCapVolMaLen = 20;
input double InpCapVolMinMult = 0.7;
input bool InpCapShowMidLine = true;
input bool InpCapShowFibExt = true;
input bool InpCapSendNotifications = true;
input int InpCapHistoryBars = 2000;
input color InpCapMidColor = clrDodgerBlue;
input color InpCapFibColor = clrSilver;
input color InpCapBuyColor = clrLimeGreen;
input color InpCapSellColor = clrRed;
input color InpCapNyColor = clrMagenta;

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
int g_ema_fast_handle = INVALID_HANDLE;
int g_ema_slow_handle = INVALID_HANDLE;
int g_atr_handle = INVALID_HANDLE;
int g_ema_fast_m15 = INVALID_HANDLE;
int g_ema_slow_m15 = INVALID_HANDLE;
int g_atr_m15 = INVALID_HANDLE;
int g_ema_fast_m30 = INVALID_HANDLE;
int g_ema_slow_m30 = INVALID_HANDLE;
int g_atr_m30 = INVALID_HANDLE;
int g_ema_fast_h1 = INVALID_HANDLE;
int g_ema_slow_h1 = INVALID_HANDLE;
int g_atr_h1 = INVALID_HANDLE;
int g_ema_fast_h4 = INVALID_HANDLE;
int g_ema_slow_h4 = INVALID_HANDLE;
int g_atr_h4 = INVALID_HANDLE;
datetime g_tf_last_time0_m15 = 0;
datetime g_tf_last_time0_m30 = 0;
datetime g_tf_last_time0_h1 = 0;
datetime g_tf_last_time0_h4 = 0;
bool g_tf_armed_m15 = false;
bool g_tf_armed_m30 = false;
bool g_tf_armed_h1 = false;
bool g_tf_armed_h4 = false;
datetime g_last_hammer_time_m15 = 0;
datetime g_last_shooting_time_m15 = 0;
datetime g_last_hammer_time_m30 = 0;
datetime g_last_shooting_time_m30 = 0;
datetime g_last_hammer_time_h1 = 0;
datetime g_last_shooting_time_h1 = 0;
datetime g_last_hammer_time_h4 = 0;
datetime g_last_shooting_time_h4 = 0;

datetime g_struct_last_time0 = 0;
datetime g_daily_last_time0 = 0;
datetime g_daily_start_time = 0;
double g_daily_ny_open = 0.0;
double g_daily_high = 0.0;
double g_daily_low = 0.0;
bool g_daily_has = false;
bool g_daily_touched_open = false;
bool g_daily_touched_high = false;
bool g_daily_touched_low = false;

datetime g_sessions_last_time0 = 0;

int g_ohcl_trend = 0;
double g_ohcl_base = 0.0;
datetime g_ohcl_htf_time0 = 0;
datetime g_ohcl_last_calc_time0 = 0;
datetime g_ohcl_last_signal_time = 0;
int g_ohcl_ema_handle = INVALID_HANDLE;
datetime g_ohcl_hist_times[];

datetime g_cap_last_signal_time = 0;
int g_cap_last_day_key = 0;

void DeleteObjectSafe(const string name)
{
   if(name == "") return;
   if(ObjectFind(0, name) >= 0) ObjectDelete(0, name);
}

void DeleteObjectsByPrefix(const string prefix)
{
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string n = ObjectName(0, i);
      if(StringFind(n, prefix) == 0)
         ObjectDelete(0, n);
   }
}

void UpdateLiveHighLow(const datetime t0, const double hi, const double lo)
{
   string highName = g_prefix + "LIVE_HIGH";
   string lowName = g_prefix + "LIVE_LOW";

   if(!InpLiveHlEnabled)
   {
      DeleteObjectSafe(highName);
      DeleteObjectSafe(lowName);
      return;
   }

   double off = (double)InpLiveHlYOffsetPoints * _Point;
   double yHigh = hi + off;
   double yLow = lo - off;

   string tHigh = InpLiveHlShowPrice ? ("High " + DoubleToString(hi, _Digits)) : "High";
   string tLow = InpLiveHlShowPrice ? ("Low " + DoubleToString(lo, _Digits)) : "Low";

   if(ObjectFind(0, highName) < 0)
   {
      ObjectCreate(0, highName, OBJ_TEXT, 0, t0, yHigh);
      ObjectSetInteger(0, highName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, highName, OBJPROP_ANCHOR, ANCHOR_LEFT);
   }
   else
   {
      ObjectMove(0, highName, 0, t0, yHigh);
   }
   ObjectSetString(0, highName, OBJPROP_TEXT, tHigh);
   ObjectSetInteger(0, highName, OBJPROP_COLOR, InpLiveHighColor);
   ObjectSetInteger(0, highName, OBJPROP_FONTSIZE, InpLiveHlFontSize);

   if(ObjectFind(0, lowName) < 0)
   {
      ObjectCreate(0, lowName, OBJ_TEXT, 0, t0, yLow);
      ObjectSetInteger(0, lowName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lowName, OBJPROP_ANCHOR, ANCHOR_LEFT);
   }
   else
   {
      ObjectMove(0, lowName, 0, t0, yLow);
   }
   ObjectSetString(0, lowName, OBJPROP_TEXT, tLow);
   ObjectSetInteger(0, lowName, OBJPROP_COLOR, InpLiveLowColor);
   ObjectSetInteger(0, lowName, OBJPROP_FONTSIZE, InpLiveHlFontSize);
}

bool LocalTimeParts(const datetime serverTime, int &hh, int &mm)
{
   datetime t = serverTime + (datetime)InpDailyTzOffsetHours * 3600;
   MqlDateTime dt;
   TimeToStruct(t, dt);
   hh = dt.hour;
   mm = dt.min;
   return true;
}

bool IsDailyNyOpenBar(const datetime t)
{
   int hh = 0, mm = 0;
   LocalTimeParts(t, hh, mm);
   return (hh == InpDailyNyOpenHour && mm == 0);
}

bool IsDailyClosingBar(const datetime t)
{
   int hh = 0, mm = 0;
   LocalTimeParts(t, hh, mm);
   return (hh == InpDailyClosingHour && mm == InpDailyClosingMinute);
}

bool IsDailyFinalBar(const datetime t)
{
   int hh = 0, mm = 0;
   LocalTimeParts(t, hh, mm);
   return (hh == InpDailyFinalHour && mm == 0);
}

bool IsWithinDailyRange(const datetime t)
{
   int hh = 0, mm = 0;
   LocalTimeParts(t, hh, mm);
   bool afterOpen = (hh > InpDailyNyOpenHour);
   bool beforeClose = (hh < InpDailyClosingHour) || (hh == InpDailyClosingHour && mm < InpDailyClosingMinute);
   return afterOpen || beforeClose;
}

void CreateOrUpdateDailyLine(const string name, const datetime t1, const double price, const datetime t2, const color clr, const int width)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   else
   {
      ObjectMove(0, name, 0, t1, price);
      ObjectMove(0, name, 1, t2, price);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

void CreateOrUpdateDailyText(const string name, const datetime t, const double price, const string text, const color clr)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TEXT, 0, t, price);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   else
   {
      ObjectMove(0, name, 0, t, price);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
}

void CreateDailyVerticalLine(const string name, const datetime t, const double y1, const double y2)
{
   if(ObjectFind(0, name) >= 0) return;
   if(ObjectCreate(0, name, OBJ_TREND, 0, t, y1, t, y2))
   {
      ObjectSetInteger(0, name, OBJPROP_COLOR, InpDailyLineColor);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
}

void ProcessDailyLevels(const datetime &time[], const double &open[], const double &high[], const double &low[])
{
   if(!InpDailyEnabled)
      return;

   datetime t0 = time[0];
   bool newBar = (g_daily_last_time0 == 0 || t0 != g_daily_last_time0);
   g_daily_last_time0 = t0;

   if(!g_daily_has)
   {
      int total = ArraySize(time);
      int maxBars = InpDailyMaxBars;
      if(maxBars < 100) maxBars = 100;
      if(maxBars > total - 1) maxBars = total - 1;
      int start = -1;
      for(int i = 0; i <= maxBars; i++)
      {
         if(IsDailyNyOpenBar(time[i]))
         {
            start = i;
            break;
         }
      }
      if(start >= 0)
      {
         g_daily_start_time = time[start];
         g_daily_ny_open = open[start];
         g_daily_high = high[start];
         g_daily_low = low[start];
         for(int i = start - 1; i >= 0; i--)
         {
            if(high[i] > g_daily_high) g_daily_high = high[i];
            if(low[i] < g_daily_low) g_daily_low = low[i];
         }
         g_daily_has = true;
         g_daily_touched_open = false;
         g_daily_touched_high = false;
         g_daily_touched_low = false;
      }
   }

   if(IsDailyNyOpenBar(t0))
   {
      g_daily_ny_open = open[0];
      g_daily_high = high[0];
      g_daily_low = low[0];
      g_daily_has = true;
      g_daily_start_time = t0;
      g_daily_touched_open = false;
      g_daily_touched_high = false;
      g_daily_touched_low = false;

      string lnOpen = g_prefix + "D_NY_OPEN";
      string lnHigh = g_prefix + "D_HIGH";
      string lnLow = g_prefix + "D_LOW";
      string lbOpen = g_prefix + "D_NY_OPEN_LBL";
      string lbHigh = g_prefix + "D_HIGH_LBL";
      string lbLow = g_prefix + "D_LOW_LBL";
      datetime t2 = ExtendTime(t0, InpExtendBars);
      CreateOrUpdateDailyLine(lnOpen, g_daily_start_time, g_daily_ny_open, t2, InpDailyNyOpenColor, 1);
      CreateOrUpdateDailyLine(lnHigh, g_daily_start_time, g_daily_high, t2, InpDailyLineColor, 1);
      CreateOrUpdateDailyLine(lnLow, g_daily_start_time, g_daily_low, t2, InpDailyLineColor, 1);
      CreateOrUpdateDailyText(lbOpen, t0, g_daily_ny_open, "NY Open", InpDailyNyOpenColor);
      CreateOrUpdateDailyText(lbHigh, t0, g_daily_high, "Daily High", InpDailyLineColor);
      CreateOrUpdateDailyText(lbLow, t0, g_daily_low, "Daily Low", InpDailyLineColor);

      if(g_alerts_armed && InpDailyAlertOnCreate)
      {
         string msg = "NY Open created on " + _Symbol + " TF=" + EnumToString(_Period);
         if(InpSendAlert) Alert(msg);
         if(InpSendPush) SendNotification(msg);
      }
   }

   if(!g_daily_has) return;

   if(InpDailyShowVerticalLines && (IsDailyNyOpenBar(t0) || IsDailyClosingBar(t0)))
   {
      string vname = g_prefix + "D_V_" + IntegerToString((long)t0);
      CreateDailyVerticalLine(vname, t0, low[0], high[0]);
   }

   if(newBar && IsWithinDailyRange(t0))
   {
      if(high[0] > g_daily_high)
      {
         g_daily_high = high[0];
         if(g_alerts_armed && InpDailyAlertOnCreate)
         {
            string msg = "Daily High updated on " + _Symbol + " TF=" + EnumToString(_Period);
            if(InpSendAlert) Alert(msg);
            if(InpSendPush) SendNotification(msg);
         }
      }
      if(low[0] < g_daily_low)
      {
         g_daily_low = low[0];
         if(g_alerts_armed && InpDailyAlertOnCreate)
         {
            string msg = "Daily Low updated on " + _Symbol + " TF=" + EnumToString(_Period);
            if(InpSendAlert) Alert(msg);
            if(InpSendPush) SendNotification(msg);
         }
      }
   }

   string lnOpen = g_prefix + "D_NY_OPEN";
   string lnHigh = g_prefix + "D_HIGH";
   string lnLow = g_prefix + "D_LOW";
   string lbOpen = g_prefix + "D_NY_OPEN_LBL";
   string lbHigh = g_prefix + "D_HIGH_LBL";
   string lbLow = g_prefix + "D_LOW_LBL";

   datetime t2 = ExtendTime(t0, InpExtendBars);
   if(g_daily_start_time == 0) g_daily_start_time = t0;
   CreateOrUpdateDailyLine(lnOpen, g_daily_start_time, g_daily_ny_open, t2, InpDailyNyOpenColor, 1);
   CreateOrUpdateDailyLine(lnHigh, g_daily_start_time, g_daily_high, t2, InpDailyLineColor, 1);
   CreateOrUpdateDailyLine(lnLow, g_daily_start_time, g_daily_low, t2, InpDailyLineColor, 1);
   CreateOrUpdateDailyText(lbOpen, t2, g_daily_ny_open, "NY Open", InpDailyNyOpenColor);
   CreateOrUpdateDailyText(lbHigh, t2, g_daily_high, "Daily High", InpDailyLineColor);
   CreateOrUpdateDailyText(lbLow, t2, g_daily_low, "Daily Low", InpDailyLineColor);

   if(g_alerts_armed && InpDailyAlertOnTouch)
   {
      if(!g_daily_touched_open && low[0] <= g_daily_ny_open && high[0] >= g_daily_ny_open)
      {
         g_daily_touched_open = true;
         string msg = "NY Open touched on " + _Symbol + " TF=" + EnumToString(_Period);
         if(InpSendAlert) Alert(msg);
         if(InpSendPush) SendNotification(msg);
      }
      if(!g_daily_touched_high && low[0] <= g_daily_high && high[0] >= g_daily_high)
      {
         g_daily_touched_high = true;
         string msg = "Daily High touched on " + _Symbol + " TF=" + EnumToString(_Period);
         if(InpSendAlert) Alert(msg);
         if(InpSendPush) SendNotification(msg);
      }
      if(!g_daily_touched_low && low[0] <= g_daily_low && high[0] >= g_daily_low)
      {
         g_daily_touched_low = true;
         string msg = "Daily Low touched on " + _Symbol + " TF=" + EnumToString(_Period);
         if(InpSendAlert) Alert(msg);
         if(InpSendPush) SendNotification(msg);
      }
   }
}

datetime DayStartLocal(const datetime serverTime, const int offsetHours)
{
   datetime t = serverTime + (datetime)offsetHours * 3600;
   MqlDateTime dt;
   TimeToStruct(t, dt);
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   datetime localStart = StructToTime(dt);
   return localStart - (datetime)offsetHours * 3600;
}

datetime MakeLocalTimeOnDay(const datetime dayStartServer, const int offsetHours, const int hour, const int minute)
{
   datetime localStart = dayStartServer + (datetime)offsetHours * 3600;
   MqlDateTime dt;
   TimeToStruct(localStart, dt);
   dt.hour = hour;
   dt.min = minute;
   dt.sec = 0;
   datetime localT = StructToTime(dt);
   return localT - (datetime)offsetHours * 3600;
}

void CreateOrUpdateSessionRect(const string name, const datetime t1, const datetime t2, const double top, const double bottom, const color c)
{
   color fill = (color)ColorToARGB(c, (uchar)InpSessionBoxAlpha);
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, top, t2, bottom);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
   }
   else
   {
      ObjectMove(0, name, 0, t1, top);
      ObjectMove(0, name, 1, t2, bottom);
   }
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, fill);
   ObjectSetInteger(0, name, OBJPROP_COLOR, (color)ColorToARGB(c, 0));
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
}

void CreateOrUpdateSessionText(const string name, const datetime t, const double y, const string txt, const color c)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TEXT, 0, t, y);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   else
   {
      ObjectMove(0, name, 0, t, y);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, c);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
}

void CreateOrUpdateSessionOhlc(const string name, const datetime t, const double y, const double o, const double h, const double l, const double c)
{
   if(!InpShowOHLC) return;
   double rng = h - l;
   bool openNearLow = false;
   bool closeNearHigh = false;
   bool openNearHigh = false;
   bool closeNearLow = false;
   if(rng > 0.0)
   {
      openNearLow = (o - l) <= rng * 0.2;
      closeNearHigh = (h - c) <= rng * 0.2;
      openNearHigh = (h - o) <= rng * 0.2;
      closeNearLow = (c - l) <= rng * 0.2;
   }
   bool strongBullish = (rng > 0.0 && openNearLow && closeNearHigh);
   bool strongBearish = (rng > 0.0 && openNearHigh && closeNearLow);

   string txt = "O: " + DoubleToString(o, _Digits) + "\n" +
                "H: " + DoubleToString(h, _Digits) + "\n" +
                "L: " + DoubleToString(l, _Digits) + "\n" +
                "C: " + DoubleToString(c, _Digits);
   color clr = clrGray;
   if(strongBullish)
   {
      txt += "\nStrong Bullish IB";
      clr = InpOhlcBullColor;
   }
   else if(strongBearish)
   {
      txt += "\nStrong Bearish IB";
      clr = InpOhlcBearColor;
   }

   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TEXT, 0, t, y);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   else
   {
      ObjectMove(0, name, 0, t, y);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
}

void DrawSessions(const int rates_total, const datetime &time[], const double &high[], const double &low[], const double &open[], const double &close[])
{
   if(!InpShowSessions && !InpShowOHLC) return;
   int maxDays = InpSessionsMaxDays;
   if(maxDays < 1) maxDays = 1;
   datetime now0 = time[0];
   datetime day0 = DayStartLocal(now0, InpSessionsTzOffsetHours);

   DeleteObjectsByPrefix(g_prefix + "SES_");

   for(int d = 0; d < maxDays; d++)
   {
      datetime dayStart = day0 - (datetime)d * 86400;

      datetime a1 = MakeLocalTimeOnDay(dayStart, InpSessionsTzOffsetHours, InpAsiaStartHour, 0);
      datetime a2 = MakeLocalTimeOnDay(dayStart, InpSessionsTzOffsetHours, InpAsiaEndHour, 0);
      if(InpAsiaEndHour <= InpAsiaStartHour) a2 += 86400;

      datetime l1 = MakeLocalTimeOnDay(dayStart, InpSessionsTzOffsetHours, InpLondonStartHour, 0);
      datetime l2 = MakeLocalTimeOnDay(dayStart, InpSessionsTzOffsetHours, InpLondonEndHour, 0);
      if(InpLondonEndHour <= InpLondonStartHour) l2 += 86400;

      datetime n1 = MakeLocalTimeOnDay(dayStart, InpSessionsTzOffsetHours, InpNyStartHour, 0);
      datetime n2 = MakeLocalTimeOnDay(dayStart, InpSessionsTzOffsetHours, InpNyEndHour, 0);
      if(InpNyEndHour <= InpNyStartHour) n2 += 86400;

      double aHi = -DBL_MAX, aLo = DBL_MAX;
      double lHi = -DBL_MAX, lLo = DBL_MAX;
      double nHi = -DBL_MAX, nLo = DBL_MAX;
      bool aOk = false, lOk = false, nOk = false;

      double aO = 0, aH = 0, aL = 0, aC = 0;
      double lO = 0, lH = 0, lL = 0, lC = 0;
      double nO = 0, nH = 0, nL = 0, nC = 0;
      datetime aT = 0, lT = 0, nT = 0;

      for(int i = rates_total - 1; i >= 0; i--)
      {
         datetime t = time[i];
         if(t < (dayStart - 86400)) continue;
         if(t >= a1 && t < a2)
         {
            if(!aOk) { aO = open[i]; aH = high[i]; aL = low[i]; aC = close[i]; aT = t; }
            aOk = true;
            if(high[i] > aHi) aHi = high[i];
            if(low[i] < aLo) aLo = low[i];
         }
         if(t >= l1 && t < l2)
         {
            if(!lOk) { lO = open[i]; lH = high[i]; lL = low[i]; lC = close[i]; lT = t; }
            lOk = true;
            if(high[i] > lHi) lHi = high[i];
            if(low[i] < lLo) lLo = low[i];
         }
         if(t >= n1 && t < n2)
         {
            if(!nOk) { nO = open[i]; nH = high[i]; nL = low[i]; nC = close[i]; nT = t; }
            nOk = true;
            if(high[i] > nHi) nHi = high[i];
            if(low[i] < nLo) nLo = low[i];
         }
      }

      string dayTag = IntegerToString((int)(dayStart / 86400));
      if(aOk)
      {
         if(InpShowSessions)
         {
            CreateOrUpdateSessionRect(g_prefix + "SES_ASIA_" + dayTag, a1, a2, aHi, aLo, InpAsiaColor);
            CreateOrUpdateSessionText(g_prefix + "SES_TXT_ASIA_" + dayTag, a1, aHi, "ASIA", InpAsiaColor);
         }
         CreateOrUpdateSessionOhlc(g_prefix + "SES_OHLC_ASIA_" + dayTag, aT, aL, aO, aH, aL, aC);
      }
      if(lOk)
      {
         if(InpShowSessions)
         {
            CreateOrUpdateSessionRect(g_prefix + "SES_LONDON_" + dayTag, l1, l2, lHi, lLo, InpLondonColor);
            CreateOrUpdateSessionText(g_prefix + "SES_TXT_LONDON_" + dayTag, l1, lHi, "LONDON", InpLondonColor);
         }
         CreateOrUpdateSessionOhlc(g_prefix + "SES_OHLC_LONDON_" + dayTag, lT, lL, lO, lH, lL, lC);
      }
      if(nOk)
      {
         if(InpShowSessions)
         {
            CreateOrUpdateSessionRect(g_prefix + "SES_NY_" + dayTag, n1, n2, nHi, nLo, InpNyColor);
            CreateOrUpdateSessionText(g_prefix + "SES_TXT_NY_" + dayTag, n1, nHi, "NY", InpNyColor);
         }
         CreateOrUpdateSessionOhlc(g_prefix + "SES_OHLC_NY_" + dayTag, nT, nL, nO, nH, nL, nC);
      }
   }
}

bool IsPivotHighAt(const int p, const int leftBars, const int rightBars, const double &high[])
{
   int n = ArraySize(high);
   if(leftBars < 1 || rightBars < 1) return false;
   if(p < rightBars) return false;
   if(p + leftBars >= n) return false;
   double v = high[p];
   for(int k = 1; k <= rightBars; k++)
      if(v <= high[p - k]) return false;
   for(int k = 1; k <= leftBars; k++)
      if(v <= high[p + k]) return false;
   return true;
}

bool IsPivotLowAt(const int p, const int leftBars, const int rightBars, const double &low[])
{
   int n = ArraySize(low);
   if(leftBars < 1 || rightBars < 1) return false;
   if(p < rightBars) return false;
   if(p + leftBars >= n) return false;
   double v = low[p];
   for(int k = 1; k <= rightBars; k++)
      if(v >= low[p - k]) return false;
   for(int k = 1; k <= leftBars; k++)
      if(v >= low[p + k]) return false;
   return true;
}

string CreateStructureLabel(const string kind, const datetime t, const double price, const bool isHigh)
{
   string name = g_prefix + "ST_" + kind + "_" + IntegerToString((long)t);
   if(ObjectFind(0, name) >= 0) return name;

   double y = price;
   if(InpStYOffsetPoints != 0)
   {
      double off = (double)InpStYOffsetPoints * _Point;
      y = isHigh ? (price + off) : (price - off);
   }

   if(ObjectCreate(0, name, OBJ_TEXT, 0, t, y))
   {
      color clr = (kind == "HH" || kind == "HL") ? InpStUpColor : InpStDownColor;
      ObjectSetString(0, name, OBJPROP_TEXT, kind);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpStFontSize);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   return name;
}

void DrawStructure(const int rates_total, const datetime &time[], const double &high[], const double &low[])
{
   if(!InpShowStructure) return;

   int lb = InpStLeftBars;
   int rb = InpStRightBars;
   if(InpStPivotLegs > 0) { lb = InpStPivotLegs; rb = InpStPivotLegs; }
   if(lb < 1) lb = 1;
   if(rb < 1) rb = 1;

   int maxBars = InpStMaxBars;
   if(maxBars < (lb + rb + 5)) maxBars = lb + rb + 5;
   int scanEnd = maxBars - 1;
   if(scanEnd > rates_total - 1) scanEnd = rates_total - 1;
   if(scanEnd <= (lb + rb)) return;

   DeleteObjectsByPrefix(g_prefix + "ST_");
   DeleteObjectsByPrefix(g_prefix + "STL_");

   datetime pivTime[];
   double pivPrice[];
   int pivType[];
   int pivCount = 0;

   for(int p = scanEnd - lb; p >= rb; p--)
   {
      bool ph = IsPivotHighAt(p, lb, rb, high);
      bool pl = IsPivotLowAt(p, lb, rb, low);
      if(!ph && !pl) continue;

      int t = ph ? 1 : -1;
      double pr = ph ? high[p] : low[p];
      datetime tm = time[p];

      if(pivCount == 0)
      {
         ArrayResize(pivTime, 1);
         ArrayResize(pivPrice, 1);
         ArrayResize(pivType, 1);
         pivTime[0] = tm;
         pivPrice[0] = pr;
         pivType[0] = t;
         pivCount = 1;
         continue;
      }

      int last = pivCount - 1;
      if(pivType[last] == t)
      {
         bool stronger = (t == 1) ? (pr > pivPrice[last]) : (pr < pivPrice[last]);
         if(stronger)
         {
            pivTime[last] = tm;
            pivPrice[last] = pr;
         }
      }
      else
      {
         if(InpStDeviationPercent > 0.0 && pivPrice[last] != 0.0)
         {
            double pct = (MathAbs(pr - pivPrice[last]) / MathAbs(pivPrice[last])) * 100.0;
            if(pct < InpStDeviationPercent)
               continue;
         }
         ArrayResize(pivTime, pivCount + 1);
         ArrayResize(pivPrice, pivCount + 1);
         ArrayResize(pivType, pivCount + 1);
         pivTime[pivCount] = tm;
         pivPrice[pivCount] = pr;
         pivType[pivCount] = t;
         pivCount++;
      }
   }

   if(InpStShowLine && pivCount >= 2)
   {
      for(int i = 1; i < pivCount; i++)
      {
         string ln = g_prefix + "STL_" + IntegerToString(i);
         if(ObjectCreate(0, ln, OBJ_TREND, 0, pivTime[i - 1], pivPrice[i - 1], pivTime[i], pivPrice[i]))
         {
            ObjectSetInteger(0, ln, OBJPROP_COLOR, InpStLineColor);
            ObjectSetInteger(0, ln, OBJPROP_WIDTH, InpStLineWidth);
            ObjectSetInteger(0, ln, OBJPROP_RAY_RIGHT, false);
            ObjectSetInteger(0, ln, OBJPROP_SELECTABLE, false);
         }
      }
   }

   bool hasHigh = false;
   bool hasLow = false;
   double lastHigh = 0.0, lastLow = 0.0;
   for(int i = 0; i < pivCount; i++)
   {
      if(pivType[i] == 1)
      {
         if(hasHigh)
         {
            if(pivPrice[i] > lastHigh && InpStShowHH) CreateStructureLabel("HH", pivTime[i], pivPrice[i], true);
            else if(pivPrice[i] < lastHigh && InpStShowLH) CreateStructureLabel("LH", pivTime[i], pivPrice[i], true);
         }
         lastHigh = pivPrice[i];
         hasHigh = true;
      }
      else
      {
         if(hasLow)
         {
            if(pivPrice[i] > lastLow && InpStShowHL) CreateStructureLabel("HL", pivTime[i], pivPrice[i], false);
            else if(pivPrice[i] < lastLow && InpStShowLL) CreateStructureLabel("LL", pivTime[i], pivPrice[i], false);
         }
         lastLow = pivPrice[i];
         hasLow = true;
      }
   }
}

datetime ExtendTime(datetime t, int bars)
{
   long sec = PeriodSeconds(_Period);
   if(sec <= 0) sec = 60;
   return (datetime)(t + (long)bars * sec);
}

int DayKeyLocalFromServer(const datetime tServer, const int offsetHours)
{
   datetime tLocal = tServer + (datetime)offsetHours * 3600;
   MqlDateTime dt;
   TimeToStruct(tLocal, dt);
   return dt.year * 10000 + dt.mon * 100 + dt.day;
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

void CreateOrUpdateCapHLine(const string name, const double price, const color clr, const ENUM_LINE_STYLE style, const int width)
{
   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price)) return;
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

void CreateCapitalSignal(const datetime tBar, const double y, const string text, const color clr)
{
   string safe = text;
   StringReplace(safe, " ", "_");
   string name = g_prefix + "CAP_SIG_" + safe + "_" + IntegerToString((long)tBar);
   if(ObjectFind(0, name) >= 0) return;
   if(ObjectCreate(0, name, OBJ_TEXT, 0, tBar, y))
   {
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
}

void NotifyCapital(const string kind, const datetime t, const double levelPrice)
{
   if(!InpCapEnabled) return;
   if(!InpCapSendNotifications) return;
   if(!g_alerts_armed) return;
   if(!InpNotifyHistorical)
   {
      datetime ref = 0;
      if(InpCapConfirmOnClose)
         ref = iTime(_Symbol, InpCapSignalTf, 1);
      else
         ref = iTime(_Symbol, InpCapSignalTf, 0);
      if(t != ref) return;
   }
   string msg = kind + " on " + _Symbol + " TF=" + EnumToString(InpCapSignalTf) + " Level=" + DoubleToString(levelPrice, _Digits);
   if(InpSendAlert) Alert(msg);
   if(InpSendPush) SendNotification(msg);
}

bool FindH1BarShiftAtLocalHour(const datetime nowServer, const int offsetHours, const int targetHour, int &outShift, datetime &outOpenServer)
{
   outShift = -1;
   outOpenServer = 0;
   int dayKey = DayKeyLocalFromServer(nowServer, offsetHours);
   for(int s = 0; s < 72; s++)
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

bool GetIbFromH1(const datetime nowServer, double &ibh, double &ibl, datetime &ibOpenServer, int &usedOffsetHours)
{
   ibh = 0.0;
   ibl = 0.0;
   ibOpenServer = 0;
   int offsets[4];
   offsets[0] = InpCapTzOffsetHours;
   offsets[1] = InpSessionsTzOffsetHours;
   offsets[2] = InpDailyTzOffsetHours;
   offsets[3] = 0;

   for(int k = 0; k < 4; k++)
   {
      int off = offsets[k];
      bool dup = false;
      for(int j = 0; j < k; j++) if(offsets[j] == off) { dup = true; break; }
      if(dup) continue;

      int shift = -1;
      datetime tOpen = 0;
      if(!FindH1BarShiftAtLocalHour(nowServer, off, InpCapIbHour, shift, tOpen)) continue;
      double hi = iHigh(_Symbol, PERIOD_H1, shift);
      double lo = iLow(_Symbol, PERIOD_H1, shift);
      if(hi == 0.0 && lo == 0.0) continue;
      ibh = hi;
      ibl = lo;
      ibOpenServer = tOpen;
      usedOffsetHours = off;
      return true;
   }

   return false;
}

double AvgTickVolTf(const ENUM_TIMEFRAMES tf, const int startShift, const int len)
{
   if(len <= 0) return 0.0;
   long vols[];
   ArrayResize(vols, len);
   ArraySetAsSeries(vols, true);
   int copied = CopyTickVolume(_Symbol, tf, startShift, len, vols);
   if(copied <= 0) return 0.0;
   double sum = 0.0;
   for(int i = 0; i < copied; i++) sum += (double)vols[i];
   return (copied > 0) ? (sum / (double)copied) : 0.0;
}

void ProcessCapital(const datetime nowServer)
{
   if(!InpCapEnabled) { DeleteObjectsByPrefix(g_prefix + "CAP_"); return; }

   double ibh = 0.0, ibl = 0.0;
   datetime ibOpen = 0;
   int tzOff = InpCapTzOffsetHours;
   if(!GetIbFromH1(nowServer, ibh, ibl, ibOpen, tzOff)) return;
   if(ibh <= ibl) return;
   int dayKey = DayKeyLocalFromServer(nowServer, tzOff);
   if(g_cap_last_day_key == 0) g_cap_last_day_key = dayKey;
   if(dayKey != g_cap_last_day_key)
   {
      DeleteObjectsByPrefix(g_prefix + "CAP_");
      g_cap_last_signal_time = 0;
      g_cap_last_day_key = dayKey;
   }
   double mid = (ibh + ibl) / 2.0;
   double rng = ibh - ibl;

   if(InpCapShowMidLine)
      CreateOrUpdateCapHLine(g_prefix + "CAP_MID", mid, InpCapMidColor, STYLE_DASH, 1);
   CreateOrUpdateCapHLine(g_prefix + "CAP_IBH", ibh, InpCapFibColor, STYLE_DOT, 1);
   CreateOrUpdateCapHLine(g_prefix + "CAP_IBL", ibl, InpCapFibColor, STYLE_DOT, 1);

   if(InpCapShowFibExt)
   {
      CreateOrUpdateCapHLine(g_prefix + "CAP_TP1_UP", ibh + 0.5 * rng, InpCapFibColor, STYLE_DOT, 1);
      CreateOrUpdateCapHLine(g_prefix + "CAP_TP2_UP", ibh + 1.0 * rng, InpCapFibColor, STYLE_DOT, 1);
      CreateOrUpdateCapHLine(g_prefix + "CAP_TP1_DN", ibl - 0.5 * rng, InpCapFibColor, STYLE_DOT, 1);
      CreateOrUpdateCapHLine(g_prefix + "CAP_TP2_DN", ibl - 1.0 * rng, InpCapFibColor, STYLE_DOT, 1);
   }

   MqlRates rates[];
   ArrayResize(rates, 3);
   ArraySetAsSeries(rates, true);
   if(CopyRates(_Symbol, InpCapSignalTf, 0, 3, rates) < 3) return;

   int idx = InpCapConfirmOnClose ? 1 : 0;
   int prev = idx + 1;
   if(prev >= 3) return;

   datetime tBar = rates[idx].time;
   datetime tClose = tBar + (datetime)PeriodSeconds(InpCapSignalTf);

   int sigDayKey = DayKeyLocalFromServer(tClose, tzOff);
   if(sigDayKey != dayKey) return;
   if(tClose < (ibOpen + 3600)) return;

   if(InpCapConfirmOnClose && tBar == g_cap_last_signal_time) return;

   double volMa = AvgTickVolTf(InpCapSignalTf, idx, InpCapVolMaLen);
   bool volOk = true;
   if(InpCapVolFilterEnabled)
   {
      if(volMa > 0.0)
         volOk = ((double)rates[idx].tick_volume) >= (volMa * InpCapVolMinMult);
   }

   double bodyMin = MathMin(rates[idx].open, rates[idx].close);
   double bodyMax = MathMax(rates[idx].open, rates[idx].close);
   double prevBodyMin = MathMin(rates[prev].open, rates[prev].close);
   double prevBodyMax = MathMax(rates[prev].open, rates[prev].close);

   bool breakUp = (bodyMin > ibh && prevBodyMin <= ibh);
   bool breakDn = (bodyMax < ibl && prevBodyMax >= ibl);
   bool sweepIbl = (rates[idx].low < ibl && rates[idx].close > ibl);
   bool sweepIbh = (rates[idx].high > ibh && rates[idx].close < ibh);

   bool aboveMid = (rates[idx].close > mid);
   bool belowMid = (rates[idx].close < mid);

   bool buy = volOk && aboveMid && (breakUp || sweepIbl);
   bool sell = volOk && belowMid && (breakDn || sweepIbh);

   bool inNy = InLocalWindow(tClose, tzOff, InpCapNyStartHour, InpCapNyStartMinute, InpCapNyEndHour, InpCapNyEndMinute);
   bool buyNy = buy && inNy && breakUp;
   bool sellNy = sell && inNy && breakDn;

   if((buy || sell) && tBar != g_cap_last_signal_time)
   {
      string txt = buy ? (buyNy ? "BUY Capital NY" : "BUY Capital") : (sellNy ? "SELL Capital NY" : "SELL Capital");
      color clr = buy ? (buyNy ? InpCapNyColor : InpCapBuyColor) : (sellNy ? InpCapNyColor : InpCapSellColor);
      double y = buy ? (rates[idx].low - 10 * _Point) : (rates[idx].high + 10 * _Point);
      CreateCapitalSignal(tBar, y, txt, clr);
      NotifyCapital(txt, tBar, buy ? ibh : ibl);
      g_cap_last_signal_time = tBar;
   }
}

void BackfillCapital()
{
   if(!InpCapEnabled) return;
   int bars = InpCapHistoryBars;
   if(bars < 50) bars = 50;

   MqlRates rates[];
   ArrayResize(rates, bars + InpCapVolMaLen + 5);
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, InpCapSignalTf, 0, ArraySize(rates), rates);
   if(copied < (InpCapVolMaLen + 5)) return;

   int maxIdx = copied - 2;
   if(maxIdx < 2) return;

   int cacheDayKey = 0;
   double cacheIbh = 0.0;
   double cacheIbl = 0.0;
   double cacheMid = 0.0;
   datetime cacheIbOpen = 0;
   int cacheOff = InpCapTzOffsetHours;

   for(int i = maxIdx; i >= 1; i--)
   {
      datetime tBar = rates[i].time;
      datetime tClose = tBar + (datetime)PeriodSeconds(InpCapSignalTf);

      double ibh = 0.0, ibl = 0.0;
      datetime ibOpen = 0;
      int off = InpCapTzOffsetHours;
      if(!GetIbFromH1(tClose, ibh, ibl, ibOpen, off)) continue;
      if(ibh <= ibl) continue;

      int dayKey = DayKeyLocalFromServer(tClose, off);
      if(cacheDayKey != dayKey)
      {
         cacheDayKey = dayKey;
         cacheIbh = ibh;
         cacheIbl = ibl;
         cacheMid = (ibh + ibl) / 2.0;
         cacheIbOpen = ibOpen;
         cacheOff = off;
      }

      if(tClose < (cacheIbOpen + 3600)) continue;
      if(DayKeyLocalFromServer(tClose, cacheOff) != cacheDayKey) continue;

      double volMa = 0.0;
      if(InpCapVolMaLen > 0)
      {
         double sum = 0.0;
         int cnt = 0;
         for(int k = i; k < i + InpCapVolMaLen && k < copied; k++)
         {
            sum += (double)rates[k].tick_volume;
            cnt++;
         }
         if(cnt > 0) volMa = sum / (double)cnt;
      }
      bool volOk = true;
      if(InpCapVolFilterEnabled && volMa > 0.0)
         volOk = ((double)rates[i].tick_volume) >= (volMa * InpCapVolMinMult);

      double bodyMin = MathMin(rates[i].open, rates[i].close);
      double bodyMax = MathMax(rates[i].open, rates[i].close);
      double prevBodyMin = MathMin(rates[i + 1].open, rates[i + 1].close);
      double prevBodyMax = MathMax(rates[i + 1].open, rates[i + 1].close);

      bool breakUp = (bodyMin > cacheIbh && prevBodyMin <= cacheIbh);
      bool breakDn = (bodyMax < cacheIbl && prevBodyMax >= cacheIbl);
      bool sweepIbl = (rates[i].low < cacheIbl && rates[i].close > cacheIbl);
      bool sweepIbh = (rates[i].high > cacheIbh && rates[i].close < cacheIbh);

      bool aboveMid = (rates[i].close > cacheMid);
      bool belowMid = (rates[i].close < cacheMid);

      bool buy = volOk && aboveMid && (breakUp || sweepIbl);
      bool sell = volOk && belowMid && (breakDn || sweepIbh);
      if(!buy && !sell) continue;

      bool inNy = InLocalWindow(tClose, cacheOff, InpCapNyStartHour, InpCapNyStartMinute, InpCapNyEndHour, InpCapNyEndMinute);
      bool buyNy = buy && inNy && breakUp;
      bool sellNy = sell && inNy && breakDn;

      string txt = buy ? (buyNy ? "BUY Capital NY" : "BUY Capital") : (sellNy ? "SELL Capital NY" : "SELL Capital");
      color clr = buy ? (buyNy ? InpCapNyColor : InpCapBuyColor) : (sellNy ? InpCapNyColor : InpCapSellColor);
      double y = buy ? (rates[i].low - 10 * _Point) : (rates[i].high + 10 * _Point);
      CreateCapitalSignal(tBar, y, txt, clr);
   }
}

bool GetOhclEmaValue(const int shift, double &emaValue)
{
   emaValue = 0.0;
   if(!InpOhclEnabled) return false;
   if(g_ohcl_ema_handle == INVALID_HANDLE) return false;
   double buf[1];
   if(CopyBuffer(g_ohcl_ema_handle, 0, shift, 1, buf) <= 0) return false;
   emaValue = buf[0];
   return true;
}

bool GetOhclPrevLevelsAtTime(const datetime tServer, double &prevH, double &prevL, datetime &htfBarTime)
{
   prevH = 0.0;
   prevL = 0.0;
   htfBarTime = 0;
   int shift = iBarShift(_Symbol, InpOhclHtf, tServer, true);
   if(shift < 0) return false;
   htfBarTime = iTime(_Symbol, InpOhclHtf, shift);
   int prevShift = shift + 1;
   double h = iHigh(_Symbol, InpOhclHtf, prevShift);
   double l = iLow(_Symbol, InpOhclHtf, prevShift);
   if(h == 0.0 && l == 0.0) return false;
   prevH = h;
   prevL = l;
   return true;
}

void BackfillOhcl(const int rates_total, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
{
   if(!InpOhclEnabled) return;
   if(!InpOhclPlotHistorySignals && !InpOhclPlotHistoryLevels) return;

   int maxBars = InpOhclHistoryBars;
   if(maxBars < 10) maxBars = 10;
   int start = rates_total - 2;
   if(start > maxBars) start = maxBars;
   if(start < 2) return;

   int trend = 0;
   double base = 0.0;
   datetime lastHtf = 0;
   datetime lastSig = 0;
   double buf = (double)InpOhclBreakoutBufferPoints * _Point;

   for(int i = start; i >= 1; i--)
   {
      datetime tBar = time[i];
      double prevH = 0.0, prevL = 0.0;
      datetime htfT = 0;
      if(!GetOhclPrevLevelsAtTime(tBar, prevH, prevL, htfT)) continue;

      if(lastHtf != 0 && htfT != lastHtf && InpOhclResetOnNewHtf)
      {
         trend = 0;
         base = 0.0;
      }
      lastHtf = htfT;

      double emaVal = 0.0;
      if(!GetOhclEmaValue(i, emaVal)) emaVal = close[i];

      bool bullConfirm = close[i] > (prevH + buf) && close[i] > open[i] && close[i] > emaVal;
      bool bearConfirm = close[i] < (prevL - buf) && close[i] < open[i] && close[i] < emaVal;

      bool bullEvent = bullConfirm && trend != 1;
      bool bearEvent = bearConfirm && trend != -1;

      if(bullEvent && tBar != lastSig)
      {
         trend = 1;
         base = prevH;
         lastSig = tBar;
         CreateOhclSignalText("BUY", tBar, low[i] - 10 * _Point, InpOhclBullColor);
         if(InpOhclPlotHistoryLevels)
            CreateOrUpdateOhclLine(tBar, ExtendTime(tBar, InpOhclExtendBars), base, InpOhclBullColor, true);
      }
      else if(bearEvent && tBar != lastSig)
      {
         trend = -1;
         base = prevL;
         lastSig = tBar;
         CreateOhclSignalText("SELL", tBar, high[i] + 10 * _Point, InpOhclBearColor);
         if(InpOhclPlotHistoryLevels)
            CreateOrUpdateOhclLine(tBar, ExtendTime(tBar, InpOhclExtendBars), base, InpOhclBearColor, true);
      }

      bool neutralizeLong = (trend == 1 && base != 0.0 && close[i] < (base - buf));
      bool neutralizeShort = (trend == -1 && base != 0.0 && close[i] > (base + buf));
      if(neutralizeLong || neutralizeShort)
      {
         CreateOhclSignalText("TP", tBar, close[i], InpOhclNeutralColor);
         trend = 0;
         base = 0.0;
      }
   }

   g_ohcl_trend = trend;
   g_ohcl_base = base;
   g_ohcl_last_signal_time = lastSig;
}

void SendOhclSignalNotification(const string kind, const datetime t, const double levelPrice)
{
   if(!InpOhclEnabled) return;
   if(!InpOhclSendNotifications) return;
   if(!g_alerts_armed) return;
   if(!InpNotifyHistorical)
   {
      if(t != iTime(_Symbol, _Period, 1)) return;
   }
   string msg = kind + " on " + _Symbol + " TF=" + EnumToString(_Period) + " Level=" + DoubleToString(levelPrice, _Digits);
   if(InpSendAlert) Alert(msg);
   if(InpSendPush) SendNotification(msg);
}

void CreateOhclSignalText(const string kind, const datetime t, const double y, const color clr)
{
   if(!InpOhclEnabled) return;
   if(!InpOhclShowSignals && kind != "TP") return;
   if(kind == "TP" && !InpOhclShowTp) return;
   if(!InpOhclPlotHistorySignals) return;

   string name = g_prefix + "OHCL_SIG_" + kind + "_" + IntegerToString((long)t);
   if(ObjectFind(0, name) >= 0) return;

   if(ObjectCreate(0, name, OBJ_TEXT, 0, t, y))
   {
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, kind);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
}

void DeleteOhclLiveLine()
{
   string name = g_prefix + "OHCL_LIVE";
   DeleteObjectSafe(name);
}

void CreateOrUpdateOhclLine(const datetime t1, const datetime t2, const double price, const color clr, const bool history)
{
   if(!InpOhclEnabled) return;
   if(!InpOhclShowLines) return;

   string name = history ? (g_prefix + "OHCL_L_" + IntegerToString((long)t1)) : (g_prefix + "OHCL_LIVE");

   if(ObjectFind(0, name) < 0)
   {
      if(!ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price)) return;
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
   }
   else
   {
      ObjectMove(0, name, 0, t1, price);
      ObjectMove(0, name, 1, t2, price);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);

   if(history && InpOhclMaxHistoryLevels > 0)
   {
      int n = ArraySize(g_ohcl_hist_times);
      ArrayResize(g_ohcl_hist_times, n + 1);
      g_ohcl_hist_times[n] = t1;
      if(ArraySize(g_ohcl_hist_times) > InpOhclMaxHistoryLevels)
      {
         datetime oldT = g_ohcl_hist_times[0];
         string oldName = g_prefix + "OHCL_L_" + IntegerToString((long)oldT);
         DeleteObjectSafe(oldName);
         for(int i = 1; i < ArraySize(g_ohcl_hist_times); i++)
            g_ohcl_hist_times[i - 1] = g_ohcl_hist_times[i];
         ArrayResize(g_ohcl_hist_times, ArraySize(g_ohcl_hist_times) - 1);
      }
   }
}

void ProcessOhcl(const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[])
{
   if(!InpOhclEnabled) return;
   int idx = InpOhclConfirmOnClose ? 1 : 0;
   if(ArraySize(time) <= idx) return;

   if(InpOhclConfirmOnClose)
   {
      if(time[0] == g_ohcl_last_calc_time0) return;
      g_ohcl_last_calc_time0 = time[0];
   }

   datetime htfTimes[];
   ArrayResize(htfTimes, 1);
   ArraySetAsSeries(htfTimes, true);
   if(CopyTime(_Symbol, InpOhclHtf, 0, 1, htfTimes) <= 0) return;
   datetime htfT0 = htfTimes[0];
   bool newHtf = (g_ohcl_htf_time0 != 0 && htfT0 != g_ohcl_htf_time0);
   g_ohcl_htf_time0 = htfT0;

   if(newHtf && InpOhclResetOnNewHtf)
   {
      g_ohcl_trend = 0;
      g_ohcl_base = 0.0;
      if(!InpOhclKeepOld && !InpOhclPlotHistoryLevels)
         DeleteOhclLiveLine();
   }

   double htfHigh[];
   double htfLow[];
   ArrayResize(htfHigh, 2);
   ArrayResize(htfLow, 2);
   ArraySetAsSeries(htfHigh, true);
   ArraySetAsSeries(htfLow, true);
   if(CopyHigh(_Symbol, InpOhclHtf, 0, 2, htfHigh) < 2) return;
   if(CopyLow(_Symbol, InpOhclHtf, 0, 2, htfLow) < 2) return;
   double prevH = htfHigh[1];
   double prevL = htfLow[1];

   double emaVal = 0.0;
   if(!GetOhclEmaValue(idx, emaVal)) emaVal = close[idx];

   double buf = (double)InpOhclBreakoutBufferPoints * _Point;
   bool barOk = (!InpOhclConfirmOnClose) || (idx == 1);

   bool bullConfirm = barOk && close[idx] > (prevH + buf) && close[idx] > open[idx] && close[idx] > emaVal;
   bool bearConfirm = barOk && close[idx] < (prevL - buf) && close[idx] < open[idx] && close[idx] < emaVal;

   bool bullEvent = bullConfirm && g_ohcl_trend != 1;
   bool bearEvent = bearConfirm && g_ohcl_trend != -1;

   if(bullEvent && time[idx] != g_ohcl_last_signal_time)
   {
      if(!InpOhclKeepOld && !InpOhclPlotHistoryLevels)
         DeleteOhclLiveLine();

      g_ohcl_trend = 1;
      g_ohcl_base = prevH;
      g_ohcl_last_signal_time = time[idx];

      double y = low[idx] - 10 * _Point;
      CreateOhclSignalText("BUY", time[idx], y, InpOhclBullColor);
      SendOhclSignalNotification("OHCL BUY", time[idx], g_ohcl_base);

      datetime t2 = ExtendTime(time[idx], InpOhclExtendBars);
      CreateOrUpdateOhclLine(time[idx], t2, g_ohcl_base, InpOhclBullColor, InpOhclPlotHistoryLevels);
   }

   if(bearEvent && time[idx] != g_ohcl_last_signal_time)
   {
      if(!InpOhclKeepOld && !InpOhclPlotHistoryLevels)
         DeleteOhclLiveLine();

      g_ohcl_trend = -1;
      g_ohcl_base = prevL;
      g_ohcl_last_signal_time = time[idx];

      double y = high[idx] + 10 * _Point;
      CreateOhclSignalText("SELL", time[idx], y, InpOhclBearColor);
      SendOhclSignalNotification("OHCL SELL", time[idx], g_ohcl_base);

      datetime t2 = ExtendTime(time[idx], InpOhclExtendBars);
      CreateOrUpdateOhclLine(time[idx], t2, g_ohcl_base, InpOhclBearColor, InpOhclPlotHistoryLevels);
   }

   bool neutralizeLong = (g_ohcl_trend == 1 && g_ohcl_base != 0.0 && close[idx] < (g_ohcl_base - buf));
   bool neutralizeShort = (g_ohcl_trend == -1 && g_ohcl_base != 0.0 && close[idx] > (g_ohcl_base + buf));
   if(neutralizeLong || neutralizeShort)
   {
      CreateOhclSignalText("TP", time[idx], close[idx], InpOhclNeutralColor);
      g_ohcl_trend = 0;
      g_ohcl_base = 0.0;
      if(!InpOhclKeepOld && !InpOhclPlotHistoryLevels)
         DeleteOhclLiveLine();
   }

   if(InpOhclShowLines && !InpOhclPlotHistoryLevels && g_ohcl_trend != 0 && g_ohcl_base != 0.0)
   {
      datetime t2 = ExtendTime(time[0], InpOhclExtendBars);
      color clr = (g_ohcl_trend == 1) ? InpOhclBullColor : InpOhclBearColor;
      CreateOrUpdateOhclLine(time[0], t2, g_ohcl_base, clr, false);
   }
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

   color lineClr = InpCisdShowLines ? clr : (color)ColorToARGB(clr, 0);
   if(ObjectCreate(0, lineName, OBJ_TREND, 0, t1, price, t2, price))
   {
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineClr);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, InpLineStyle);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, InpLineWidth);
      ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, lineName, OBJPROP_HIDDEN, !InpCisdShowLines);
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
   double body = MathAbs(close[i] - open[i]);
   double bodyMin = MathMin(open[i], close[i]);
   double bodyMax = MathMax(open[i], close[i]);
   double lowerW = bodyMin - low[i];
   double upperW = high[i] - bodyMax;
   bool baseOk = (high[i] - InpFibLevel * candleSize) < bodyMin;
   if(!baseOk) return false;
   if(!InpProCandleFilterEnabled) return true;
   if(body <= 0.0) return false;
   if(lowerW < body * InpProWickBodyMinRatio) return false;
   if(upperW > body * InpProOppWickMaxBodyRatio) return false;
   return true;
}

bool IsShootingCandle(const int i, const double &open[], const double &high[], const double &low[], const double &close[])
{
   double candleSize = MathAbs(high[i] - low[i]);
   if(candleSize <= 0.0) return false;
   double body = MathAbs(close[i] - open[i]);
   double bodyMin = MathMin(open[i], close[i]);
   double bodyMax = MathMax(open[i], close[i]);
   double lowerW = bodyMin - low[i];
   double upperW = high[i] - bodyMax;
   bool baseOk = (low[i] + InpFibLevel * candleSize) > bodyMax;
   if(!baseOk) return false;
   if(!InpProCandleFilterEnabled) return true;
   if(body <= 0.0) return false;
   if(upperW < body * InpProWickBodyMinRatio) return false;
   if(lowerW > body * InpProOppWickMaxBodyRatio) return false;
   return true;
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

bool HsTimeframeEnabled()
{
   switch(_Period)
   {
      case PERIOD_M15:  return InpHsEnableM15;
      case PERIOD_M30:  return InpHsEnableM30;
      case PERIOD_H1:   return InpHsEnableH1;
      case PERIOD_H4:   return InpHsEnableH4;
      default:          return true;
   }
}

string TfLabelFromTf(const ENUM_TIMEFRAMES tf)
{
   switch(tf)
   {
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      default:         return EnumToString(tf);
   }
}

bool GetTrendFlags(const int shift, const double &close[], bool &isUp, bool &isDown)
{
   isUp = false;
   isDown = false;
   if(!InpHsTrendFilterEnabled) return true;
   if(g_ema_fast_handle == INVALID_HANDLE || g_ema_slow_handle == INVALID_HANDLE || g_atr_handle == INVALID_HANDLE) return true;
   if(shift < 0) return false;
   double emaFast[1], emaSlow[1], atr[1];
   if(CopyBuffer(g_ema_fast_handle, 0, shift, 1, emaFast) <= 0) return false;
   if(CopyBuffer(g_ema_slow_handle, 0, shift, 1, emaSlow) <= 0) return false;
   if(CopyBuffer(g_atr_handle, 0, shift, 1, atr) <= 0) return false;
   double diff = emaFast[0] - emaSlow[0];
   double threshold = atr[0] * InpHsTrendAtrMult;
   if(diff >= threshold && close[shift] > emaFast[0]) isUp = true;
   if((-diff) >= threshold && close[shift] < emaFast[0]) isDown = true;
   return true;
}

string TfLabel()
{
   switch(_Period)
   {
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      default:         return EnumToString(_Period);
   }
}

bool GetDxyDirectionTf(const ENUM_TIMEFRAMES tf, datetime t, bool &isBullish, bool &isBearish)
{
   isBullish = false;
   isBearish = false;
   if(!InpConfirmWithDxy) return false;
   if(InpDxySymbol == "") return false;
   int shift = iBarShift(InpDxySymbol, tf, t, true);
   if(shift < 0) return false;
   double o[1], c[1];
   if(CopyOpen(InpDxySymbol, tf, shift, 1, o) <= 0) return false;
   if(CopyClose(InpDxySymbol, tf, shift, 1, c) <= 0) return false;
   if(c[0] > o[0]) isBullish = true;
   if(c[0] < o[0]) isBearish = true;
   return true;
}

bool ComputeVpLevelsRates(const MqlRates &rates[], const int bars, const int rows, const int valueAreaPercent, double &poc, double &vah, double &val)
{
   poc = 0.0;
   vah = 0.0;
   val = 0.0;
   if(bars < 10 || rows < 10) return false;
   double highest = -DBL_MAX;
   double lowest = DBL_MAX;
   for(int i = 0; i < bars; i++)
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
   for(int i = 0; i < bars; i++)
   {
      double barVol = (double)rates[i].tick_volume;
      if(barVol <= 0.0) barVol = 1.0;
      int startLevel = (int)MathFloor((rates[i].low - lowest) / rowHeight);
      int endLevel = (int)MathFloor((rates[i].high - lowest) / rowHeight);
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

datetime VpAsiaOpenLocalTf(const datetime nowLocal)
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

int VpLookbackBarsFromAsiaTf(const ENUM_TIMEFRAMES tf, const datetime nowServer)
{
   if(!InpVpAnchorAsia) return InpVpLookbackBars;
   datetime nowLocal = nowServer + (datetime)InpVpSessionOffsetHours * 3600;
   datetime openLocal = VpAsiaOpenLocalTf(nowLocal);
   datetime openServer = openLocal - (datetime)InpVpSessionOffsetHours * 3600;
   datetime times[];
   ArraySetAsSeries(times, true);
   int copied = CopyTime(_Symbol, tf, 0, InpVpMaxBars, times);
   if(copied < 10) return InpVpLookbackBars;
   int count = 0;
   for(int i = 0; i < copied; i++)
   {
      if(times[i] < openServer) break;
      count++;
   }
   if(count < 10) return InpVpLookbackBars;
   return count;
}

bool GetTrendFlagsTf(const ENUM_TIMEFRAMES tf, const int shift, const double closePrice, bool &isUp, bool &isDown)
{
   isUp = false;
   isDown = false;
   if(!InpHsTrendFilterEnabled) return true;
   int hFast = INVALID_HANDLE;
   int hSlow = INVALID_HANDLE;
   int hAtr = INVALID_HANDLE;
   if(tf == PERIOD_M15) { hFast = g_ema_fast_m15; hSlow = g_ema_slow_m15; hAtr = g_atr_m15; }
   if(tf == PERIOD_M30) { hFast = g_ema_fast_m30; hSlow = g_ema_slow_m30; hAtr = g_atr_m30; }
   if(tf == PERIOD_H1) { hFast = g_ema_fast_h1; hSlow = g_ema_slow_h1; hAtr = g_atr_h1; }
   if(tf == PERIOD_H4) { hFast = g_ema_fast_h4; hSlow = g_ema_slow_h4; hAtr = g_atr_h4; }
   if(hFast == INVALID_HANDLE || hSlow == INVALID_HANDLE || hAtr == INVALID_HANDLE) return true;
   double emaFast[1], emaSlow[1], atr[1];
   if(CopyBuffer(hFast, 0, shift, 1, emaFast) <= 0) return false;
   if(CopyBuffer(hSlow, 0, shift, 1, emaSlow) <= 0) return false;
   if(CopyBuffer(hAtr, 0, shift, 1, atr) <= 0) return false;
   double diff = emaFast[0] - emaSlow[0];
   double threshold = atr[0] * InpHsTrendAtrMult;
   if(diff >= threshold && closePrice > emaFast[0]) isUp = true;
   if((-diff) >= threshold && closePrice < emaFast[0]) isDown = true;
   return true;
}

bool GetEmaValuesTf(const ENUM_TIMEFRAMES tf, const int shift, double &emaFast, double &emaSlow)
{
   emaFast = 0.0;
   emaSlow = 0.0;
   int hFast = INVALID_HANDLE;
   int hSlow = INVALID_HANDLE;
   if(tf == _Period) { hFast = g_ema_fast_handle; hSlow = g_ema_slow_handle; }
   if(tf == PERIOD_M15) { hFast = g_ema_fast_m15; hSlow = g_ema_slow_m15; }
   if(tf == PERIOD_M30) { hFast = g_ema_fast_m30; hSlow = g_ema_slow_m30; }
   if(tf == PERIOD_H1) { hFast = g_ema_fast_h1; hSlow = g_ema_slow_h1; }
   if(tf == PERIOD_H4) { hFast = g_ema_fast_h4; hSlow = g_ema_slow_h4; }
   if(hFast == INVALID_HANDLE || hSlow == INVALID_HANDLE) return false;
   double ef[1], es[1];
   if(CopyBuffer(hFast, 0, shift, 1, ef) <= 0) return false;
   if(CopyBuffer(hSlow, 0, shift, 1, es) <= 0) return false;
   emaFast = ef[0];
   emaSlow = es[0];
   return true;
}

bool BodyTouchesEma(const double bodyMin, const double bodyMax, const double emaFast, const double emaSlow)
{
   double tol = (double)InpEmaTouchTolerancePoints * _Point;
   double lo = bodyMin - tol;
   double hi = bodyMax + tol;
   if(emaFast >= lo && emaFast <= hi) return true;
   if(emaSlow >= lo && emaSlow <= hi) return true;
   return false;
}

void CreateHsSignalTf(const string kind, const string tfTag, datetime t, double price, color clr, int arrowCode, bool confirmed, bool canAlert, bool volFlag, bool emaTouchFlag)
{
   string base = g_prefix + kind + "_" + tfTag + "_" + IntegerToString((long)t);
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

   string label = kind + " " + tfTag + (volFlag ? " VL" : "") + (emaTouchFlag ? " EMA" : "");
   if(confirmed) label = label + " confermato";
   if(ObjectCreate(0, textName, OBJ_TEXT, 0, t, price))
   {
      ObjectSetString(0, textName, OBJPROP_TEXT, label);
      ObjectSetInteger(0, textName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, textName, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
   }

   if((InpSendAlert || InpSendPush) && canAlert)
   {
      if(!g_alerts_armed) return;
      if(!InpNotifyHistorical) return;
      string msg = kind + " " + tfTag + (volFlag ? " VL" : "") + (emaTouchFlag ? " EMA" : "") + (confirmed ? " confermato" : "") + " on " + _Symbol + " Price=" + DoubleToString(price, _Digits);
      if(InpSendAlert) Alert(msg);
      if(InpSendPush) SendNotification(msg);
   }
}

bool IsHammerRates(const int i, const MqlRates &rates[])
{
   if(i < 0 || i >= ArraySize(rates)) return false;
   double candleSize = MathAbs(rates[i].high - rates[i].low);
   if(candleSize <= 0.0) return false;
   double body = MathAbs(rates[i].close - rates[i].open);
   double bodyMin = MathMin(rates[i].open, rates[i].close);
   double bodyMax = MathMax(rates[i].open, rates[i].close);
   double lowerW = bodyMin - rates[i].low;
   double upperW = rates[i].high - bodyMax;
   bool baseOk = (rates[i].high - InpFibLevel * candleSize) < bodyMin;
   if(!baseOk) return false;
   if(!InpProCandleFilterEnabled) return true;
   if(body <= 0.0) return false;
   if(lowerW < body * InpProWickBodyMinRatio) return false;
   if(upperW > body * InpProOppWickMaxBodyRatio) return false;
   return true;
}

bool IsShootingRates(const int i, const MqlRates &rates[])
{
   if(i < 0 || i >= ArraySize(rates)) return false;
   double candleSize = MathAbs(rates[i].high - rates[i].low);
   if(candleSize <= 0.0) return false;
   double body = MathAbs(rates[i].close - rates[i].open);
   double bodyMin = MathMin(rates[i].open, rates[i].close);
   double bodyMax = MathMax(rates[i].open, rates[i].close);
   double lowerW = bodyMin - rates[i].low;
   double upperW = rates[i].high - bodyMax;
   bool baseOk = (rates[i].low + InpFibLevel * candleSize) > bodyMax;
   if(!baseOk) return false;
   if(!InpProCandleFilterEnabled) return true;
   if(body <= 0.0) return false;
   if(upperW < body * InpProWickBodyMinRatio) return false;
   if(lowerW > body * InpProOppWickMaxBodyRatio) return false;
   return true;
}

int WyckMinPointsForTf(const ENUM_TIMEFRAMES tf)
{
   int v = 0;
   switch(tf)
   {
      case PERIOD_M15: v = InpWyckSpikeMinPointsM15; break;
      case PERIOD_M30: v = InpWyckSpikeMinPointsM30; break;
      case PERIOD_H1:  v = InpWyckSpikeMinPointsH1;  break;
      case PERIOD_H4:  v = InpWyckSpikeMinPointsH4;  break;
      default:         v = InpWyckSpikeMinPointsCurrent; break;
   }
   if(v <= 0) v = InpWyckSpikeMinPoints;
   return v;
}

double AvgTickVolumeRates(const MqlRates &rates[], const int startIndex, const int period)
{
   int n = ArraySize(rates);
   if(period <= 0) return 0.0;
   if(startIndex < 0) return 0.0;
   if(startIndex + period > n) return 0.0;
   double sum = 0.0;
   for(int i = startIndex; i < startIndex + period; i++)
      sum += (double)rates[i].tick_volume;
   return sum / (double)period;
}

double AvgTickVolumeArr(const long &tick_volume[], const int startIndex, const int period)
{
   int n = ArraySize(tick_volume);
   if(period <= 0) return 0.0;
   if(startIndex < 0) return 0.0;
   if(startIndex + period > n) return 0.0;
   double sum = 0.0;
   for(int i = startIndex; i < startIndex + period; i++)
      sum += (double)tick_volume[i];
   return sum / (double)period;
}

bool IsPivotLowRates(const int i, const MqlRates &rates[], const int left, const int right)
{
   int n = ArraySize(rates);
   if(left < 1 || right < 1) return false;
   if(i < right) return false;
   if(i + left >= n) return false;
   double v = rates[i].low;
   for(int k = 1; k <= left; k++)
      if(v >= rates[i + k].low) return false;
   for(int k = 1; k <= right; k++)
      if(v >= rates[i - k].low) return false;
   return true;
}

bool IsPivotHighRates(const int i, const MqlRates &rates[], const int left, const int right)
{
   int n = ArraySize(rates);
   if(left < 1 || right < 1) return false;
   if(i < right) return false;
   if(i + left >= n) return false;
   double v = rates[i].high;
   for(int k = 1; k <= left; k++)
      if(v <= rates[i + k].high) return false;
   for(int k = 1; k <= right; k++)
      if(v <= rates[i - k].high) return false;
   return true;
}

bool FindPivotLowBeforeTimeRates(const MqlRates &rates[], const int left, const int right, const datetime tMax, int &idx, datetime &tFound, double &val)
{
   int n = ArraySize(rates);
   for(int i = right; i + left < n; i++)
   {
      if(rates[i].time > tMax) continue;
      if(IsPivotLowRates(i, rates, left, right))
      {
         idx = i;
         tFound = rates[i].time;
         val = rates[i].low;
         return true;
      }
   }
   return false;
}

bool FindPivotHighBeforeTimeRates(const MqlRates &rates[], const int left, const int right, const datetime tMax, int &idx, datetime &tFound, double &val)
{
   int n = ArraySize(rates);
   for(int i = right; i + left < n; i++)
   {
      if(rates[i].time > tMax) continue;
      if(IsPivotHighRates(i, rates, left, right))
      {
         idx = i;
         tFound = rates[i].time;
         val = rates[i].high;
         return true;
      }
   }
   return false;
}

bool FindTwoPivotLowsBeforeTimeRates(const MqlRates &rates[], const int left, const int right, const datetime tMax, datetime &t1, double &v1, datetime &t2, double &v2)
{
   int idx = -1;
   if(!FindPivotLowBeforeTimeRates(rates, left, right, tMax, idx, t1, v1)) return false;
   if(!FindPivotLowBeforeTimeRates(rates, left, right, (datetime)(t1 - 1), idx, t2, v2)) return false;
   return true;
}

bool FindTwoPivotHighsBeforeTimeRates(const MqlRates &rates[], const int left, const int right, const datetime tMax, datetime &t1, double &v1, datetime &t2, double &v2)
{
   int idx = -1;
   if(!FindPivotHighBeforeTimeRates(rates, left, right, tMax, idx, t1, v1)) return false;
   if(!FindPivotHighBeforeTimeRates(rates, left, right, (datetime)(t1 - 1), idx, t2, v2)) return false;
   return true;
}

bool IsPivotLowArr(const int i, const datetime &time[], const double &low[], const int left, const int right)
{
   int n = ArraySize(time);
   if(left < 1 || right < 1) return false;
   if(i < right) return false;
   if(i + left >= n) return false;
   double v = low[i];
   for(int k = 1; k <= left; k++)
      if(v >= low[i + k]) return false;
   for(int k = 1; k <= right; k++)
      if(v >= low[i - k]) return false;
   return true;
}

bool IsPivotHighArr(const int i, const datetime &time[], const double &high[], const int left, const int right)
{
   int n = ArraySize(time);
   if(left < 1 || right < 1) return false;
   if(i < right) return false;
   if(i + left >= n) return false;
   double v = high[i];
   for(int k = 1; k <= left; k++)
      if(v <= high[i + k]) return false;
   for(int k = 1; k <= right; k++)
      if(v <= high[i - k]) return false;
   return true;
}

bool FindPivotLowBeforeTimeArr(const datetime &time[], const double &low[], const int left, const int right, const datetime tMax, int &idx, datetime &tFound, double &val)
{
   int n = ArraySize(time);
   for(int i = right; i + left < n; i++)
   {
      if(time[i] > tMax) continue;
      if(IsPivotLowArr(i, time, low, left, right))
      {
         idx = i;
         tFound = time[i];
         val = low[i];
         return true;
      }
   }
   return false;
}

bool FindPivotHighBeforeTimeArr(const datetime &time[], const double &high[], const int left, const int right, const datetime tMax, int &idx, datetime &tFound, double &val)
{
   int n = ArraySize(time);
   for(int i = right; i + left < n; i++)
   {
      if(time[i] > tMax) continue;
      if(IsPivotHighArr(i, time, high, left, right))
      {
         idx = i;
         tFound = time[i];
         val = high[i];
         return true;
      }
   }
   return false;
}

bool FindTwoPivotLowsBeforeTimeArr(const datetime &time[], const double &low[], const int left, const int right, const datetime tMax, datetime &t1, double &v1, datetime &t2, double &v2)
{
   int idx = -1;
   if(!FindPivotLowBeforeTimeArr(time, low, left, right, tMax, idx, t1, v1)) return false;
   if(!FindPivotLowBeforeTimeArr(time, low, left, right, (datetime)(t1 - 1), idx, t2, v2)) return false;
   return true;
}

bool FindTwoPivotHighsBeforeTimeArr(const datetime &time[], const double &high[], const int left, const int right, const datetime tMax, datetime &t1, double &v1, datetime &t2, double &v2)
{
   int idx = -1;
   if(!FindPivotHighBeforeTimeArr(time, high, left, right, tMax, idx, t1, v1)) return false;
   if(!FindPivotHighBeforeTimeArr(time, high, left, right, (datetime)(t1 - 1), idx, t2, v2)) return false;
   return true;
}

void DrawSmtMarker(const string kind, const string tfTag, const datetime t1, const double v1, const datetime t2, const double v2, const bool isHammer)
{
   if(!InpSmtShowOnChart) return;
   string base = g_prefix + "SMT_" + kind + "_" + tfTag + "_" + IntegerToString((long)t1);
   string lineName = base + "_L";
   string textName = base + "_T";
   if(ObjectFind(0, lineName) >= 0 || ObjectFind(0, textName) >= 0) return;

   if(ObjectCreate(0, lineName, OBJ_TREND, 0, t2, v2, t1, v1))
   {
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, InpSmtColor);
      ObjectSetInteger(0, lineName, OBJPROP_WIDTH, InpSmtLineWidth);
      ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
   }

   double y = v1;
   if(InpSmtYOffsetPoints != 0)
   {
      double off = (double)InpSmtYOffsetPoints * _Point;
      y = isHammer ? (v1 - off) : (v1 + off);
   }
   if(ObjectCreate(0, textName, OBJ_TEXT, 0, t1, y))
   {
      ObjectSetString(0, textName, OBJPROP_TEXT, "+ SMT");
      ObjectSetInteger(0, textName, OBJPROP_COLOR, InpSmtColor);
      ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, textName, OBJPROP_ANCHOR, ANCHOR_LEFT);
      ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
   }
}

bool SmtOkRates(const ENUM_TIMEFRAMES tf, const MqlRates &xauRates[], const datetime tSig, const bool isHammer, const bool isShooting, datetime &outT1, double &outV1, datetime &outT2, double &outV2)
{
   if(!InpSmtFilterEnabled) return true;
   if(!IsXauSymbol()) return true;
   if(!isHammer && !isShooting) return true;

   int left = InpSmtPivotLeft;
   int right = InpSmtPivotRight;
   if(left < 1) left = 1;
   if(right < 1) right = 1;

   datetime xT1 = 0, xT2 = 0;
   double xV1 = 0.0, xV2 = 0.0;

   string xag = InpSmtXagSymbol;
   if(xag == "" || xag == _Symbol) return true;

   MqlRates xagRates[];
   ArraySetAsSeries(xagRates, true);
   int copiedXag = CopyRates(xag, tf, 0, InpSmtMaxBars, xagRates);
   if(copiedXag < 20) return true;

   string dxy = InpDxySymbol;
   if(dxy == "" || dxy == _Symbol) return true;

   MqlRates dxyRates[];
   ArraySetAsSeries(dxyRates, true);
   int copiedDxy = CopyRates(dxy, tf, 0, InpSmtMaxBars, dxyRates);
   if(copiedDxy < 20) return true;

   if(isHammer)
   {
      if(!FindTwoPivotLowsBeforeTimeRates(xauRates, left, right, tSig, xT1, xV1, xT2, xV2)) return true;
      int idx = -1;
      datetime tA1 = 0, tA2 = 0;
      double a1 = 0.0, a2 = 0.0;
      if(!FindPivotLowBeforeTimeRates(xagRates, left, right, xT1, idx, tA1, a1)) return true;
      if(!FindPivotLowBeforeTimeRates(xagRates, left, right, xT2, idx, tA2, a2)) return true;

      datetime tD1 = 0, tD2 = 0;
      double d1 = 0.0, d2 = 0.0;
      bool okD = false;
      if(InpSmtInvertDxy)
         okD = FindPivotHighBeforeTimeRates(dxyRates, left, right, xT1, idx, tD1, d1) && FindPivotHighBeforeTimeRates(dxyRates, left, right, xT2, idx, tD2, d2);
      else
         okD = FindPivotLowBeforeTimeRates(dxyRates, left, right, xT1, idx, tD1, d1) && FindPivotLowBeforeTimeRates(dxyRates, left, right, xT2, idx, tD2, d2);
      if(!okD) return true;

      bool xauLL = (xV1 < xV2);
      bool xagNoLL = (a1 >= a2);
      bool dxyOk = InpSmtInvertDxy ? (d1 <= d2) : (d1 >= d2);
      bool ok = (xauLL && xagNoLL && dxyOk);
      outT1 = xT1; outV1 = xV1; outT2 = xT2; outV2 = xV2;
      return ok;
   }

   if(isShooting)
   {
      if(!FindTwoPivotHighsBeforeTimeRates(xauRates, left, right, tSig, xT1, xV1, xT2, xV2)) return true;
      int idx = -1;
      datetime tA1 = 0, tA2 = 0;
      double a1 = 0.0, a2 = 0.0;
      if(!FindPivotHighBeforeTimeRates(xagRates, left, right, xT1, idx, tA1, a1)) return true;
      if(!FindPivotHighBeforeTimeRates(xagRates, left, right, xT2, idx, tA2, a2)) return true;

      datetime tD1 = 0, tD2 = 0;
      double d1 = 0.0, d2 = 0.0;
      bool okD = false;
      if(InpSmtInvertDxy)
         okD = FindPivotLowBeforeTimeRates(dxyRates, left, right, xT1, idx, tD1, d1) && FindPivotLowBeforeTimeRates(dxyRates, left, right, xT2, idx, tD2, d2);
      else
         okD = FindPivotHighBeforeTimeRates(dxyRates, left, right, xT1, idx, tD1, d1) && FindPivotHighBeforeTimeRates(dxyRates, left, right, xT2, idx, tD2, d2);
      if(!okD) return true;

      bool xauHH = (xV1 > xV2);
      bool xagNoHH = (a1 <= a2);
      bool dxyOk = InpSmtInvertDxy ? (d1 >= d2) : (d1 <= d2);
      bool ok = (xauHH && xagNoHH && dxyOk);
      outT1 = xT1; outV1 = xV1; outT2 = xT2; outV2 = xV2;
      return ok;
   }
   return true;
}

bool SmtOkArr(const datetime &time[], const double &high[], const double &low[], const datetime tSig, const bool isHammer, const bool isShooting, datetime &outT1, double &outV1, datetime &outT2, double &outV2)
{
   if(!InpSmtFilterEnabled) return true;
   if(!IsXauSymbol()) return true;
   if(!isHammer && !isShooting) return true;

   int left = InpSmtPivotLeft;
   int right = InpSmtPivotRight;
   if(left < 1) left = 1;
   if(right < 1) right = 1;

   datetime xT1 = 0, xT2 = 0;
   double xV1 = 0.0, xV2 = 0.0;

   string xag = InpSmtXagSymbol;
   if(xag == "" || xag == _Symbol) return true;

   MqlRates xagRates[];
   ArraySetAsSeries(xagRates, true);
   int copiedXag = CopyRates(xag, _Period, 0, InpSmtMaxBars, xagRates);
   if(copiedXag < 20) return true;

   string dxy = InpDxySymbol;
   if(dxy == "" || dxy == _Symbol) return true;

   MqlRates dxyRates[];
   ArraySetAsSeries(dxyRates, true);
   int copiedDxy = CopyRates(dxy, _Period, 0, InpSmtMaxBars, dxyRates);
   if(copiedDxy < 20) return true;

   if(isHammer)
   {
      if(!FindTwoPivotLowsBeforeTimeArr(time, low, left, right, tSig, xT1, xV1, xT2, xV2)) return true;
      int idx = -1;
      datetime tA1 = 0, tA2 = 0;
      double a1 = 0.0, a2 = 0.0;
      if(!FindPivotLowBeforeTimeRates(xagRates, left, right, xT1, idx, tA1, a1)) return true;
      if(!FindPivotLowBeforeTimeRates(xagRates, left, right, xT2, idx, tA2, a2)) return true;

      datetime tD1 = 0, tD2 = 0;
      double d1 = 0.0, d2 = 0.0;
      bool okD = false;
      if(InpSmtInvertDxy)
         okD = FindPivotHighBeforeTimeRates(dxyRates, left, right, xT1, idx, tD1, d1) && FindPivotHighBeforeTimeRates(dxyRates, left, right, xT2, idx, tD2, d2);
      else
         okD = FindPivotLowBeforeTimeRates(dxyRates, left, right, xT1, idx, tD1, d1) && FindPivotLowBeforeTimeRates(dxyRates, left, right, xT2, idx, tD2, d2);
      if(!okD) return true;

      bool xauLL = (xV1 < xV2);
      bool xagNoLL = (a1 >= a2);
      bool dxyOk = InpSmtInvertDxy ? (d1 <= d2) : (d1 >= d2);
      bool ok = (xauLL && xagNoLL && dxyOk);
      outT1 = xT1; outV1 = xV1; outT2 = xT2; outV2 = xV2;
      return ok;
   }

   if(isShooting)
   {
      if(!FindTwoPivotHighsBeforeTimeArr(time, high, left, right, tSig, xT1, xV1, xT2, xV2)) return true;
      int idx = -1;
      datetime tA1 = 0, tA2 = 0;
      double a1 = 0.0, a2 = 0.0;
      if(!FindPivotHighBeforeTimeRates(xagRates, left, right, xT1, idx, tA1, a1)) return true;
      if(!FindPivotHighBeforeTimeRates(xagRates, left, right, xT2, idx, tA2, a2)) return true;

      datetime tD1 = 0, tD2 = 0;
      double d1 = 0.0, d2 = 0.0;
      bool okD = false;
      if(InpSmtInvertDxy)
         okD = FindPivotLowBeforeTimeRates(dxyRates, left, right, xT1, idx, tD1, d1) && FindPivotLowBeforeTimeRates(dxyRates, left, right, xT2, idx, tD2, d2);
      else
         okD = FindPivotHighBeforeTimeRates(dxyRates, left, right, xT1, idx, tD1, d1) && FindPivotHighBeforeTimeRates(dxyRates, left, right, xT2, idx, tD2, d2);
      if(!okD) return true;

      bool xauHH = (xV1 > xV2);
      bool xagNoHH = (a1 <= a2);
      bool dxyOk = InpSmtInvertDxy ? (d1 >= d2) : (d1 <= d2);
      bool ok = (xauHH && xagNoHH && dxyOk);
      outT1 = xT1; outV1 = xV1; outT2 = xT2; outV2 = xV2;
      return ok;
   }
   return true;
}

void CreateHsSignal(const string kind, datetime t, double price, color clr, int arrowCode, bool confirmed, bool volFlag, bool emaTouchFlag)
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

   string label = kind + " " + TfLabel() + (volFlag ? " VL" : "") + (emaTouchFlag ? " EMA" : "");
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
      string msg = kind + " " + TfLabel() + (volFlag ? " VL" : "") + (emaTouchFlag ? " EMA" : "") + (confirmed ? " confermato" : "") + " on " + _Symbol + " Price=" + DoubleToString(price, _Digits);
      if(InpSendAlert) Alert(msg);
      if(InpSendPush) SendNotification(msg);
   }
}

void ProcessHsTimeframe(const ENUM_TIMEFRAMES tf, const bool enabled, datetime &lastTime0, bool &armed, datetime &lastHammerTime, datetime &lastShootingTime)
{
   if(!InpHsMultiTimeframe) return;
   if(!enabled) return;
   if(tf == _Period) return;
   if(!InpEnableHs) return;

   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, tf, 0, InpVpMaxBars, rates);
   if(copied < 5) return;

   datetime time0 = rates[0].time;
   if(InpSuppressAlertsOnLoad)
   {
      if(lastTime0 == 0) { lastTime0 = time0; armed = false; return; }
      if(!armed && time0 != lastTime0) armed = true;
      lastTime0 = time0;
   }
   else
   {
      armed = true;
   }

   int confirmIndex = 1;
   int signalIndex = InpConfirmByNextCandle ? 2 : 1;
   if(copied <= signalIndex) return;

   bool isGreen = (rates[confirmIndex].close > rates[confirmIndex].open);
   bool isRed = (rates[confirmIndex].close < rates[confirmIndex].open);

   bool hammer = false;
   bool shoot = false;
   if(!InpConfirmByNextCandle)
   {
      hammer = IsHammerRates(signalIndex, rates);
      shoot = IsShootingRates(signalIndex, rates);
   }
   else
   {
      double sigBodyHigh = MathMax(rates[signalIndex].open, rates[signalIndex].close);
      double sigBodyLow = MathMin(rates[signalIndex].open, rates[signalIndex].close);
      hammer = IsHammerRates(signalIndex, rates) && isGreen && (rates[confirmIndex].close > sigBodyHigh);
      shoot = IsShootingRates(signalIndex, rates) && isRed && (rates[confirmIndex].close < sigBodyLow);
   }
   if(!hammer && !shoot) return;

   if(InpWyckSpikeFilterEnabled)
   {
      double pt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(pt <= 0.0) pt = _Point;
      double rangePts = (rates[signalIndex].high - rates[signalIndex].low) / pt;
      int minPts = WyckMinPointsForTf(tf);
      if(hammer && rangePts < (double)minPts) hammer = false;
      if(shoot && rangePts < (double)minPts) shoot = false;
   }
   if(!hammer && !shoot) return;

   if(InpSmtFilterEnabled && IsXauSymbol())
   {
      datetime tSig = rates[signalIndex].time;
      datetime t1 = 0, t2 = 0;
      double v1 = 0.0, v2 = 0.0;
      if(hammer)
      {
         bool ok = SmtOkRates(tf, rates, tSig, true, false, t1, v1, t2, v2);
         if(ok) DrawSmtMarker("Hammer", TfLabelFromTf(tf), t1, v1, t2, v2, true);
         hammer = ok;
      }
      if(shoot)
      {
         bool ok = SmtOkRates(tf, rates, tSig, false, true, t1, v1, t2, v2);
         if(ok) DrawSmtMarker("Shooting", TfLabelFromTf(tf), t1, v1, t2, v2, false);
         shoot = ok;
      }
   }
   if(!hammer && !shoot) return;

   bool hammerVl = false;
   bool shootVl = false;
   if(InpVolFilterEnabled)
   {
      int p = InpVolMaPeriod;
      if(p < 1) p = 1;
      double avg = AvgTickVolumeRates(rates, signalIndex + 1, p);
      double v = (double)rates[signalIndex].tick_volume;
      bool volOk = (avg > 0.0) && (v >= (avg * InpVolMult));
      if(hammer)
      {
         hammerVl = volOk;
         hammer = hammer && volOk;
      }
      if(shoot)
      {
         bool buyVol = (rates[signalIndex].close > rates[signalIndex].open);
         shootVl = volOk && buyVol;
         shoot = shoot && shootVl;
      }
   }
   if(!hammer && !shoot) return;

   bool trendUp = false;
   bool trendDown = false;
   if(InpHsTrendFilterEnabled)
   {
      if(GetTrendFlagsTf(tf, signalIndex, rates[signalIndex].close, trendUp, trendDown))
      {
         if(hammer && !trendDown) hammer = false;
         if(shoot && !trendUp) shoot = false;
      }
   }
   if(!hammer && !shoot) return;

   bool dxyBull = false;
   bool dxyBear = false;
   bool haveDxy = false;
   if(InpConfirmWithDxy && IsXauSymbol())
      haveDxy = GetDxyDirectionTf(tf, rates[signalIndex].time, dxyBull, dxyBear);

   double poc = 0.0, vah = 0.0, val = 0.0;
   bool vpOk = true;
   if(InpVpFilterEnabled)
   {
      int lb = VpLookbackBarsFromAsiaTf(tf, rates[confirmIndex].time);
      if(lb > copied) lb = copied;
      vpOk = ComputeVpLevelsRates(rates, lb, InpVpRows, InpVpValueAreaPercent, poc, vah, val);
   }

   string tfTag = TfLabelFromTf(tf);

   if(hammer)
   {
      bool confirmed = (haveDxy && dxyBear);
      if(InpVpFilterEnabled && vpOk)
      {
         hammer = (rates[signalIndex].low < val) && (rates[signalIndex].close > val) && (rates[signalIndex].close < vah);
         if(hammer && InpVpBodyZoneFilter)
         {
            double bodyMin = MathMin(rates[signalIndex].open, rates[signalIndex].close);
            double bodyMax = MathMax(rates[signalIndex].open, rates[signalIndex].close);
            hammer = (bodyMin >= val) && (bodyMax <= poc);
         }
      }
      if(hammer && rates[signalIndex].time != lastHammerTime)
      {
         bool emaTouchFlag = false;
         if(InpEmaTouchTagEnabled)
         {
            double ef = 0.0, es = 0.0;
            double bodyMin = MathMin(rates[signalIndex].open, rates[signalIndex].close);
            double bodyMax = MathMax(rates[signalIndex].open, rates[signalIndex].close);
            if(GetEmaValuesTf(tf, signalIndex, ef, es))
               emaTouchFlag = BodyTouchesEma(bodyMin, bodyMax, ef, es);
         }
         lastHammerTime = rates[signalIndex].time;
         CreateHsSignalTf("Hammer", tfTag, rates[signalIndex].time, rates[signalIndex].low, InpHammerColor, InpHammerArrowCode, confirmed, armed, hammerVl, emaTouchFlag);
      }
   }

   if(shoot)
   {
      bool confirmed = (haveDxy && dxyBull);
      if(InpVpFilterEnabled && vpOk)
      {
         shoot = (rates[signalIndex].high > vah) && (rates[signalIndex].close < vah) && (rates[signalIndex].close > val);
         if(shoot && InpVpBodyZoneFilter)
         {
            double bodyMin = MathMin(rates[signalIndex].open, rates[signalIndex].close);
            double bodyMax = MathMax(rates[signalIndex].open, rates[signalIndex].close);
            shoot = (bodyMin >= poc) && (bodyMax <= vah);
         }
      }
      if(shoot && rates[signalIndex].time != lastShootingTime)
      {
         bool emaTouchFlag = false;
         if(InpEmaTouchTagEnabled)
         {
            double ef = 0.0, es = 0.0;
            double bodyMin = MathMin(rates[signalIndex].open, rates[signalIndex].close);
            double bodyMax = MathMax(rates[signalIndex].open, rates[signalIndex].close);
            if(GetEmaValuesTf(tf, signalIndex, ef, es))
               emaTouchFlag = BodyTouchesEma(bodyMin, bodyMax, ef, es);
         }
         lastShootingTime = rates[signalIndex].time;
         CreateHsSignalTf("Shooting", tfTag, rates[signalIndex].time, rates[signalIndex].high, InpShootingColor, InpShootingArrowCode, confirmed, armed, shootVl, emaTouchFlag);
      }
   }
}

void DrawHsStatusOnChart()
{
   string name = g_prefix + "HS_TF_STATUS";
   string txt = "HS TF: ";
   txt = txt + (InpHsEnableM15 ? "M15 " : "");
   txt = txt + (InpHsEnableM30 ? "M30 " : "");
   txt = txt + (InpHsEnableH1 ? "H1 " : "");
   txt = txt + (InpHsEnableH4 ? "H4 " : "");
   if(txt == "HS TF: ") txt = "HS TF: OFF";

   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 20);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
}

void ProcessHammerShooting(const int i, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[])
{
   if(!InpEnableHs) return;
   if(!HsTimeframeEnabled()) return;
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

   if(InpWyckSpikeFilterEnabled)
   {
      double pt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(pt <= 0.0) pt = _Point;
      double rangePts = (high[signalIndex] - low[signalIndex]) / pt;
      int minPts = WyckMinPointsForTf(_Period);
      if(hammer && rangePts < (double)minPts) hammer = false;
      if(shoot && rangePts < (double)minPts) shoot = false;
   }
   if(!hammer && !shoot) return;

   if(InpSmtFilterEnabled && IsXauSymbol())
   {
      datetime tSig = time[signalIndex];
      datetime t1 = 0, t2 = 0;
      double v1 = 0.0, v2 = 0.0;
      if(hammer)
      {
         bool ok = SmtOkArr(time, high, low, tSig, true, false, t1, v1, t2, v2);
         if(ok) DrawSmtMarker("Hammer", TfLabel(), t1, v1, t2, v2, true);
         hammer = ok;
      }
      if(shoot)
      {
         bool ok = SmtOkArr(time, high, low, tSig, false, true, t1, v1, t2, v2);
         if(ok) DrawSmtMarker("Shooting", TfLabel(), t1, v1, t2, v2, false);
         shoot = ok;
      }
   }
   if(!hammer && !shoot) return;

   bool hammerVl = false;
   bool shootVl = false;
   if(InpVolFilterEnabled)
   {
      int p = InpVolMaPeriod;
      if(p < 1) p = 1;
      double avg = AvgTickVolumeArr(tick_volume, signalIndex + 1, p);
      double v = (double)tick_volume[signalIndex];
      bool volOk = (avg > 0.0) && (v >= (avg * InpVolMult));
      if(hammer)
      {
         hammerVl = volOk;
         hammer = hammer && volOk;
      }
      if(shoot)
      {
         bool buyVol = (close[signalIndex] > open[signalIndex]);
         shootVl = volOk && buyVol;
         shoot = shoot && shootVl;
      }
   }
   if(!hammer && !shoot) return;

   if(InpHsTrendFilterEnabled)
   {
      bool trendUp = false;
      bool trendDown = false;
      if(GetTrendFlags(signalIndex, close, trendUp, trendDown))
      {
         if(hammer && !trendDown) hammer = false;
         if(shoot && !trendUp) shoot = false;
      }
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
      bool emaTouchFlag = false;
      if(InpEmaTouchTagEnabled)
      {
         double ef = 0.0, es = 0.0;
         double bodyMin = MathMin(open[signalIndex], close[signalIndex]);
         double bodyMax = MathMax(open[signalIndex], close[signalIndex]);
         if(GetEmaValuesTf(_Period, signalIndex, ef, es))
            emaTouchFlag = BodyTouchesEma(bodyMin, bodyMax, ef, es);
      }
      CreateHsSignal("Hammer", time[signalIndex], low[signalIndex], InpHammerColor, InpHammerArrowCode, confirmed, hammerVl, emaTouchFlag);
      if(InpHsEntryOnBreakout)
      {
         bool vpOk = true;
         if(InpVpFilterEnabled)
            vpOk = (low[signalIndex] < g_vp_val) && (close[signalIndex] > g_vp_val) && (close[signalIndex] < g_vp_vah);
         if(vpOk && InpVpBodyZoneFilter)
         {
            double bodyMin = MathMin(open[signalIndex], close[signalIndex]);
            double bodyMax = MathMax(open[signalIndex], close[signalIndex]);
            vpOk = (bodyMin >= g_vp_val) && (bodyMax <= g_vp_poc);
         }
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
      bool emaTouchFlag = false;
      if(InpEmaTouchTagEnabled)
      {
         double ef = 0.0, es = 0.0;
         double bodyMin = MathMin(open[signalIndex], close[signalIndex]);
         double bodyMax = MathMax(open[signalIndex], close[signalIndex]);
         if(GetEmaValuesTf(_Period, signalIndex, ef, es))
            emaTouchFlag = BodyTouchesEma(bodyMin, bodyMax, ef, es);
      }
      CreateHsSignal("Shooting", time[signalIndex], high[signalIndex], InpShootingColor, InpShootingArrowCode, confirmed, shootVl, emaTouchFlag);
      if(InpHsEntryOnBreakout)
      {
         bool vpOk = true;
         if(InpVpFilterEnabled)
            vpOk = (high[signalIndex] > g_vp_vah) && (close[signalIndex] < g_vp_vah) && (close[signalIndex] > g_vp_val);
         if(vpOk && InpVpBodyZoneFilter)
         {
            double bodyMin = MathMin(open[signalIndex], close[signalIndex]);
            double bodyMax = MathMax(open[signalIndex], close[signalIndex]);
            vpOk = (bodyMin >= g_vp_poc) && (bodyMax <= g_vp_vah);
         }
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

void ProcessBar(const int i, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[])
{
   ProcessHammerShooting(i, time, open, high, low, close, tick_volume);

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
   g_ema_fast_handle = iMA(_Symbol, _Period, InpHsTrendEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   g_ema_slow_handle = iMA(_Symbol, _Period, InpHsTrendEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   g_atr_handle = iATR(_Symbol, _Period, InpHsTrendAtrPeriod);
   g_ema_fast_m15 = iMA(_Symbol, PERIOD_M15, InpHsTrendEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   g_ema_slow_m15 = iMA(_Symbol, PERIOD_M15, InpHsTrendEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   g_atr_m15 = iATR(_Symbol, PERIOD_M15, InpHsTrendAtrPeriod);
   g_ema_fast_m30 = iMA(_Symbol, PERIOD_M30, InpHsTrendEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   g_ema_slow_m30 = iMA(_Symbol, PERIOD_M30, InpHsTrendEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   g_atr_m30 = iATR(_Symbol, PERIOD_M30, InpHsTrendAtrPeriod);
   g_ema_fast_h1 = iMA(_Symbol, PERIOD_H1, InpHsTrendEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   g_ema_slow_h1 = iMA(_Symbol, PERIOD_H1, InpHsTrendEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   g_atr_h1 = iATR(_Symbol, PERIOD_H1, InpHsTrendAtrPeriod);
   g_ema_fast_h4 = iMA(_Symbol, PERIOD_H4, InpHsTrendEmaFast, 0, MODE_EMA, PRICE_CLOSE);
   g_ema_slow_h4 = iMA(_Symbol, PERIOD_H4, InpHsTrendEmaSlow, 0, MODE_EMA, PRICE_CLOSE);
   g_atr_h4 = iATR(_Symbol, PERIOD_H4, InpHsTrendAtrPeriod);
   g_ohcl_ema_handle = iMA(_Symbol, _Period, InpOhclEmaLen, 0, MODE_EMA, PRICE_CLOSE);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, g_prefix);
   if(g_ema_fast_handle != INVALID_HANDLE) IndicatorRelease(g_ema_fast_handle);
   if(g_ema_slow_handle != INVALID_HANDLE) IndicatorRelease(g_ema_slow_handle);
   if(g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
   g_ema_fast_handle = INVALID_HANDLE;
   g_ema_slow_handle = INVALID_HANDLE;
   g_atr_handle = INVALID_HANDLE;
   if(g_ema_fast_m15 != INVALID_HANDLE) IndicatorRelease(g_ema_fast_m15);
   if(g_ema_slow_m15 != INVALID_HANDLE) IndicatorRelease(g_ema_slow_m15);
   if(g_atr_m15 != INVALID_HANDLE) IndicatorRelease(g_atr_m15);
   if(g_ema_fast_m30 != INVALID_HANDLE) IndicatorRelease(g_ema_fast_m30);
   if(g_ema_slow_m30 != INVALID_HANDLE) IndicatorRelease(g_ema_slow_m30);
   if(g_atr_m30 != INVALID_HANDLE) IndicatorRelease(g_atr_m30);
   if(g_ema_fast_h1 != INVALID_HANDLE) IndicatorRelease(g_ema_fast_h1);
   if(g_ema_slow_h1 != INVALID_HANDLE) IndicatorRelease(g_ema_slow_h1);
   if(g_atr_h1 != INVALID_HANDLE) IndicatorRelease(g_atr_h1);
   if(g_ema_fast_h4 != INVALID_HANDLE) IndicatorRelease(g_ema_fast_h4);
   if(g_ema_slow_h4 != INVALID_HANDLE) IndicatorRelease(g_ema_slow_h4);
   if(g_atr_h4 != INVALID_HANDLE) IndicatorRelease(g_atr_h4);
   if(g_ohcl_ema_handle != INVALID_HANDLE) IndicatorRelease(g_ohcl_ema_handle);
   g_ema_fast_m15 = INVALID_HANDLE;
   g_ema_slow_m15 = INVALID_HANDLE;
   g_atr_m15 = INVALID_HANDLE;
   g_ema_fast_m30 = INVALID_HANDLE;
   g_ema_slow_m30 = INVALID_HANDLE;
   g_atr_m30 = INVALID_HANDLE;
   g_ema_fast_h1 = INVALID_HANDLE;
   g_ema_slow_h1 = INVALID_HANDLE;
   g_atr_h1 = INVALID_HANDLE;
   g_ema_fast_h4 = INVALID_HANDLE;
   g_ema_slow_h4 = INVALID_HANDLE;
   g_atr_h4 = INVALID_HANDLE;
   g_ohcl_ema_handle = INVALID_HANDLE;
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

   UpdateLiveHighLow(time[0], high[0], low[0]);
   ProcessDailyLevels(time, open, high, low);
   if(!InpShowSessions)
   {
      if(g_sessions_last_time0 != 0)
      {
         DeleteObjectsByPrefix(g_prefix + "SES_");
         g_sessions_last_time0 = 0;
      }
   }
   else
   {
      if(time[0] != g_sessions_last_time0)
      {
         DrawSessions(rates_total, time, high, low, open, close);
         g_sessions_last_time0 = time[0];
      }
   }

   DrawHsStatusOnChart();
   ProcessHsTimeframe(PERIOD_M15, InpHsEnableM15, g_tf_last_time0_m15, g_tf_armed_m15, g_last_hammer_time_m15, g_last_shooting_time_m15);
   ProcessHsTimeframe(PERIOD_M30, InpHsEnableM30, g_tf_last_time0_m30, g_tf_armed_m30, g_last_hammer_time_m30, g_last_shooting_time_m30);
   ProcessHsTimeframe(PERIOD_H1, InpHsEnableH1, g_tf_last_time0_h1, g_tf_armed_h1, g_last_hammer_time_h1, g_last_shooting_time_h1);
   ProcessHsTimeframe(PERIOD_H4, InpHsEnableH4, g_tf_last_time0_h4, g_tf_armed_h4, g_last_hammer_time_h4, g_last_shooting_time_h4);

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
      g_struct_last_time0 = 0;
      g_daily_last_time0 = 0;
      g_daily_start_time = 0;
      g_daily_has = false;
      g_daily_touched_open = false;
      g_daily_touched_high = false;
      g_daily_touched_low = false;
      g_sessions_last_time0 = 0;
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
      g_ohcl_trend = 0;
      g_ohcl_base = 0.0;
      g_ohcl_htf_time0 = 0;
      g_ohcl_last_calc_time0 = 0;
      g_ohcl_last_signal_time = 0;
      ArrayResize(g_ohcl_hist_times, 0);
      g_cap_last_signal_time = 0;
      g_cap_last_day_key = 0;
   }

   if(prev_calculated == 0)
      BackfillOhcl(rates_total, time, open, high, low, close);
   if(prev_calculated == 0)
      BackfillCapital();

   ProcessOhcl(time, open, high, low, close);
   ProcessCapital(time[0]);

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

   if(!InpShowStructure)
   {
      if(g_struct_last_time0 != 0)
      {
         DeleteObjectsByPrefix(g_prefix + "ST_");
         g_struct_last_time0 = 0;
      }
   }
   else
   {
      if(time[0] != g_struct_last_time0)
      {
         DrawStructure(rates_total, time, high, low);
         g_struct_last_time0 = time[0];
      }
   }

   int limit = (prev_calculated == 0) ? rates_total - 2 : 2;
   if(limit > rates_total - 2) limit = rates_total - 2;

   for(int i = limit; i >= 1; i--)
   {
      ProcessBar(i, time, open, high, low, close, tick_volume);
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