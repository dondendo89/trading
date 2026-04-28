#property strict
#property indicator_chart_window
#property indicator_plots 0
#property version "1.00"

input group "Capital Indicator"
input bool InpEnabled = true;
input int InpItalyOffsetHours = 2;
input bool InpShowSessions = true;
input int InpBoxAlpha = 60;
input bool InpShowDailyHL = true;
input bool InpShowNYOpen = true;
input bool InpShowIB = true;
input bool InpShowH13 = true;
input bool InpShow02 = true;
input bool InpShowSignals = true;
input bool InpShowStatusLabel = true;
input bool InpShowChartComment = true;
input bool InpShowTestLines = true;
input int InpHistoryDays = 5;
input bool InpDebugOverlay = true;

input group "Alerts"
input bool InpSendAlert = true;
input bool InpSendPush = false;
input bool InpNotifyHistorical = false;
input bool InpNotifyCrossLevels = true;

input group "Logic"
input bool InpUseDailyOpenFilter = true;
input bool InpUseIbMidFilter = true;
input bool InpRequireManipulation = false;
input int InpSweepBufferPoints = 0;
input int InpReclaimMaxBars = 6;
input bool InpMidnightSignalsEnabled = true;

input group "Colors"
input color InpDailyOpenColor = clrPurple;
input color InpDailyHLColor = clrWhite;
input color InpNyOpenColor = clrBlue;
input color InpIbColor = clrBlue;
input color InpH13Color = clrOrange;
input color InpH02Color = clrGreen;
input color InpAsiaColor = clrGreen;
input color InpLondonColor = clrBlue;
input color InpNyColor = clrOrange;
input color InpBuyColor = clrLimeGreen;
input color InpSellColor = clrRed;

string g_prefix = "CAP_IND_";
datetime g_last_time0 = 0;
int g_day_key = 0;
int g_create_fails = 0;
int g_last_create_err = 0;
int g_update_calls = 0;

int CountObjectsByPrefix(const string pfx)
{
   int total = ObjectsTotal(0, -1, -1);
   int c = 0;
   for(int i = total - 1; i >= 0; i--)
   {
      string n = ObjectName(0, i);
      if(StringFind(n, pfx) == 0) c++;
   }
   return c;
}

double g_daily_open = 0.0, g_daily_high = 0.0, g_daily_low = 0.0;
bool g_daily_has = false;

double g_ny_open = 0.0;
bool g_ny_has = false;
datetime g_ny_time = 0;

double g_ib_high = 0.0, g_ib_low = 0.0;
bool g_ib_has = false;
datetime g_ib_time = 0;

double g_h13_high = 0.0, g_h13_low = 0.0;
bool g_h13_has = false;
datetime g_h13_time = 0;

double g_h02_high = 0.0, g_h02_low = 0.0;
bool g_h02_has = false;
datetime g_h02_time = 0;

datetime g_day_start_time = 0;
bool g_buy_done = false;
bool g_sell_done = false;

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

double g_asia_high = 0.0, g_asia_low = 0.0;
double g_london_high = 0.0, g_london_low = 0.0;
double g_ny_high = 0.0, g_ny_low = 0.0;
bool g_asia_has = false, g_london_has = false, g_ny_sess_has = false;
datetime g_asia_start = 0, g_london_start = 0, g_ny_start = 0;

datetime g_last_cross_h13_h = 0, g_last_cross_h13_l = 0;
datetime g_last_cross_h02_h = 0, g_last_cross_h02_l = 0;

datetime LocalTime(const datetime tServer) { return tServer + (datetime)InpItalyOffsetHours * 3600; }

void UpdateChartComment(const string txt)
{
   if(InpShowChartComment) Comment(txt);
   else Comment("");
}

int IndexByShift(const bool isSeries, const int rates_total, const int shiftFromCurrent)
{
   int i = isSeries ? shiftFromCurrent : (rates_total - 1 - shiftFromCurrent);
   if(i < 0) i = 0;
   if(i > rates_total - 1) i = rates_total - 1;
   return i;
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

bool IsLocalTime(const datetime tServer, const int h, const int m)
{
   MqlDateTime dt;
   TimeToStruct(LocalTime(tServer), dt);
   return (dt.hour == h && dt.min == m);
}

bool InWindowLocal(const datetime tServer, const int sh, const int sm, const int eh, const int em)
{
   int cur = MinuteOfDayLocal(tServer);
   int a = sh * 60 + sm;
   int b = eh * 60 + em;
   return (cur >= a && cur < b);
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

void CreateOrUpdateStatusLabel(const string txt)
{
   if(!InpShowStatusLabel) return;
   string name = g_prefix + "STATUS";
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
      {
         g_last_create_err = GetLastError();
         g_create_fails++;
         return;
      }
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 10);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, name, OBJPROP_ZORDER, 999);
   }
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
}

void CreateOrUpdateHLine(const string name, const double price, const color clr, const ENUM_LINE_STYLE style, const int width)
{
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price))
      {
         g_last_create_err = GetLastError();
         g_create_fails++;
         return;
      }
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

void CreateOrUpdateRay(const string name, const datetime t1, const double price, const color clr, const ENUM_LINE_STYLE style, const int width)
{
   datetime t2 = t1 + (datetime)PeriodSeconds(_Period);
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_TREND, 0, t1, price, t2, price))
      {
         g_last_create_err = GetLastError();
         g_create_fails++;
         return;
      }
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
   }
   ObjectMove(0, name, 0, t1, price);
   ObjectMove(0, name, 1, t2, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

void CreateOrUpdateVLine(const string name, const datetime t, const color clr, const ENUM_LINE_STYLE style, const int width)
{
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_VLINE, 0, t, 0))
      {
         g_last_create_err = GetLastError();
         g_create_fails++;
         return;
      }
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
   ObjectMove(0, name, 0, t, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

void CreateOrUpdateText(const string name, const datetime t, const double price, const string txt, const color clr, const int anchor)
{
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_TEXT, 0, t, price))
      {
         g_last_create_err = GetLastError();
         g_create_fails++;
         return;
      }
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
   ObjectMove(0, name, 0, t, price);
   ObjectSetString(0, name, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
}

void CreateOrUpdateRect(const string name, const datetime t1, const double p1, const datetime t2, const double p2, const color c)
{
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2))
      {
         g_last_create_err = GetLastError();
         g_create_fails++;
         return;
      }
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
   ObjectMove(0, name, 0, t1, p1);
   ObjectMove(0, name, 1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, (color)ColorToARGB(c, (uchar)InpBoxAlpha));
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
}

void CreateOrUpdateRectAlpha(const string name, const datetime t1, const double p1, const datetime t2, const double p2, const color c, const uchar alpha)
{
   if(ObjectFind(0, name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2))
      {
         g_last_create_err = GetLastError();
         g_create_fails++;
         return;
      }
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_FILL, true);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   }
   ObjectMove(0, name, 0, t1, p1);
   ObjectMove(0, name, 1, t2, p2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, (color)ColorToARGB(c, alpha));
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
}

void NotifySignal(const string txt, const datetime tBar)
{
   if(!InpSendAlert && !InpSendPush) return;
   if(!InpNotifyHistorical)
   {
      datetime ref = iTime(_Symbol, _Period, 1);
      if(tBar != ref) return;
   }
   string msg = txt + " on " + _Symbol + " TF=" + EnumToString(_Period);
   if(InpSendAlert) Alert(msg);
   if(InpSendPush) SendNotification(msg);
}

void CheckCrossLevel(const string tag, const double level, const double prevClose, const double curClose, const datetime tBarOpen, datetime &lastAlertTime)
{
   if(!InpNotifyCrossLevels || level <= 0.0 || tBarOpen == lastAlertTime) return;
   bool up = (prevClose <= level && curClose > level);
   bool dn = (prevClose >= level && curClose < level);
   if(!up && !dn) return;
   lastAlertTime = tBarOpen;
   NotifySignal("CROSS " + string(up ? "UP " : "DOWN ") + tag, tBarOpen);
}

void UpdateRightSideLabels(const datetime tLastBar)
{
   if(g_day_key == 0) return;
   datetime tAnchor = tLastBar + (datetime)PeriodSeconds(_Period) * 2;
   string dayPfx = g_prefix + IntegerToString(g_day_key) + "_";

   if(InpShowDailyHL && g_daily_has)
   {
      CreateOrUpdateText(dayPfx + "LBL_D_HIGH", tAnchor, g_daily_high, "Daily High", clrRed, ANCHOR_RIGHT);
      CreateOrUpdateText(dayPfx + "LBL_D_LOW", tAnchor, g_daily_low, "Daily Low", clrRed, ANCHOR_RIGHT);
   }

   if(InpShowNYOpen && g_ny_has)
      CreateOrUpdateText(dayPfx + "LBL_NY_OPEN", tAnchor, g_ny_open, "NY Open", clrRed, ANCHOR_RIGHT);
}

void UpdateSessionTag(
   const string dayPfx,
   const string key,
   const string txt,
   const color c,
   const datetime t,
   const double yTop
)
{
   datetime t1 = t;
   datetime t2 = t + (datetime)PeriodSeconds(_Period) * 4;
   double y1 = yTop;
   double y2 = yTop - 60.0 * _Point;
   CreateOrUpdateRectAlpha(dayPfx + key + "_TAG_BG", t1, y1, t2, y2, c, 220);
   CreateOrUpdateText(dayPfx + key + "_TAG_TXT", t2, y1, txt, clrWhite, ANCHOR_RIGHT);
}

void ResetDay(const int dayKey)
{
   g_day_key = dayKey;
   g_day_start_time = 0;
   g_daily_open = 0.0; g_daily_high = 0.0; g_daily_low = 0.0; g_daily_has = false;
   g_ny_open = 0.0; g_ny_has = false; g_ny_time = 0;
   g_ib_high = 0.0; g_ib_low = 0.0; g_ib_has = false; g_ib_time = 0;
   g_h13_high = 0.0; g_h13_low = 0.0; g_h13_has = false; g_h13_time = 0;
   g_h02_high = 0.0; g_h02_low = 0.0; g_h02_has = false; g_h02_time = 0;
   g_mid_high = 0.0; g_mid_low = 0.0; g_mid_has = false; g_mid_time = 0;
   g_mid_sweep_down = false; g_mid_sweep_up = false; g_mid_sweep_down_bar = -1; g_mid_sweep_up_bar = -1;
   g_mid_long_done = false; g_mid_short_done = false;
   g_ib_sweep_down = false; g_ib_sweep_up = false; g_ib_sweep_down_bar = -1; g_ib_sweep_up_bar = -1;
   g_asia_high = 0.0; g_asia_low = 0.0; g_asia_has = false; g_asia_start = 0;
   g_london_high = 0.0; g_london_low = 0.0; g_london_has = false; g_london_start = 0;
   g_ny_high = 0.0; g_ny_low = 0.0; g_ny_sess_has = false; g_ny_start = 0;
   g_last_cross_h13_h = 0; g_last_cross_h13_l = 0; g_last_cross_h02_h = 0; g_last_cross_h02_l = 0;
   g_buy_done = false;
   g_sell_done = false;
   DeleteByPrefix(g_prefix + IntegerToString(dayKey) + "_");
}

void UpdateWithBar(const datetime tBarOpen, const double o, const double h, const double l, const double c)
{
   g_update_calls++;
   int dk = DayKeyLocal(tBarOpen);
   if(dk != g_day_key) ResetDay(dk);

   if(!g_daily_has) { g_day_start_time = tBarOpen; g_daily_open = o; g_daily_high = h; g_daily_low = l; g_daily_has = true; }
   else { if(h > g_daily_high) g_daily_high = h; if(l < g_daily_low) g_daily_low = l; }

   if(IsLocalTime(tBarOpen, 0, 0))
   {
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

   if(IsLocalTime(tBarOpen, 14, 30)) { g_ny_time = tBarOpen; g_ny_open = o; g_ny_has = true; }
   if(IsLocalTime(tBarOpen, 0, 0)) { g_h02_time = tBarOpen; g_h02_high = h; g_h02_low = l; g_h02_has = true; }

   if(InWindowLocal(tBarOpen, 9, 0, 10, 0))
   {
      if(!g_ib_has) { g_ib_time = tBarOpen; g_ib_high = h; g_ib_low = l; g_ib_has = true; }
      else { if(h > g_ib_high) g_ib_high = h; if(l < g_ib_low) g_ib_low = l; }
   }

   if(InWindowLocal(tBarOpen, 13, 0, 14, 0))
   {
      if(!g_h13_has) { g_h13_time = tBarOpen; g_h13_high = h; g_h13_low = l; g_h13_has = true; }
      else { if(h > g_h13_high) g_h13_high = h; if(l < g_h13_low) g_h13_low = l; }
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

   string dayPfx = g_prefix + IntegerToString(g_day_key) + "_";
   if(InpShowSessions)
   {
      bool inAsia = InWindowLocal(tBarOpen, 0, 0, 8, 0);
      bool inLondon = InWindowLocal(tBarOpen, 9, 0, 17, 30);
      bool inNy = InWindowLocal(tBarOpen, 14, 30, 21, 0);

      if(inAsia)
      {
         if(!g_asia_has) { g_asia_high = h; g_asia_low = l; g_asia_has = true; g_asia_start = tBarOpen; }
         else { if(h > g_asia_high) g_asia_high = h; if(l < g_asia_low) g_asia_low = l; }
         CreateOrUpdateRect(dayPfx + "ASIA_BOX", g_asia_start, g_asia_high, tBarOpen + PeriodSeconds(_Period), g_asia_low, InpAsiaColor);
         UpdateSessionTag(dayPfx, "ASIA", "ASIA", InpAsiaColor, tBarOpen, g_asia_high);
      }
      else { g_asia_has = false; g_asia_start = 0; }

      if(inLondon)
      {
         if(!g_london_has) { g_london_high = h; g_london_low = l; g_london_has = true; g_london_start = tBarOpen; }
         else { if(h > g_london_high) g_london_high = h; if(l < g_london_low) g_london_low = l; }
         CreateOrUpdateRect(dayPfx + "LONDON_BOX", g_london_start, g_london_high, tBarOpen + PeriodSeconds(_Period), g_london_low, InpLondonColor);
         UpdateSessionTag(dayPfx, "LONDON", "LONDON", InpLondonColor, tBarOpen, g_london_high);
      }
      else { g_london_has = false; g_london_start = 0; }

      if(inNy)
      {
         if(!g_ny_sess_has) { g_ny_high = h; g_ny_low = l; g_ny_sess_has = true; g_ny_start = tBarOpen; }
         else { if(h > g_ny_high) g_ny_high = h; if(l < g_ny_low) g_ny_low = l; }
         CreateOrUpdateRect(dayPfx + "NY_BOX", g_ny_start, g_ny_high, tBarOpen + PeriodSeconds(_Period), g_ny_low, InpNyColor);
         UpdateSessionTag(dayPfx, "NY", "NY", InpNyColor, tBarOpen, g_ny_high);
      }
      else { g_ny_sess_has = false; g_ny_start = 0; }
   }

   if(g_daily_has)
   {
      CreateOrUpdateRay(dayPfx + "D_OPEN", g_day_start_time == 0 ? tBarOpen : g_day_start_time, g_daily_open, InpDailyOpenColor, STYLE_SOLID, 1);
      if(InpShowDailyHL)
      {
         datetime tStart = (g_day_start_time == 0 ? tBarOpen : g_day_start_time);
         CreateOrUpdateRay(dayPfx + "D_HIGH", tStart, g_daily_high, InpDailyHLColor, STYLE_SOLID, 1);
         CreateOrUpdateRay(dayPfx + "D_LOW", tStart, g_daily_low, InpDailyHLColor, STYLE_SOLID, 1);
      }
   }

   if(InpShowNYOpen && g_ny_has)
   {
      CreateOrUpdateRay(dayPfx + "NY_OPEN", g_ny_time == 0 ? tBarOpen : g_ny_time, g_ny_open, InpNyOpenColor, STYLE_SOLID, 2);
   }

   if(InpShowIB && g_ib_has)
   {
      datetime tStart = (g_ib_time == 0 ? tBarOpen : g_ib_time);
      CreateOrUpdateRay(dayPfx + "IB_H", tStart, g_ib_high, InpIbColor, STYLE_DOT, 1);
      CreateOrUpdateRay(dayPfx + "IB_L", tStart, g_ib_low, InpIbColor, STYLE_DOT, 1);
   }

   if(InpShowH13 && g_h13_has && MinuteOfDayLocal(tBarOpen) >= 13 * 60)
   {
      datetime tStart = (g_h13_time == 0 ? tBarOpen : g_h13_time);
      CreateOrUpdateRay(dayPfx + "H13_H", tStart, g_h13_high, InpH13Color, STYLE_SOLID, 2);
      CreateOrUpdateRay(dayPfx + "H13_L", tStart, g_h13_low, InpH13Color, STYLE_SOLID, 2);
   }

   if(InpShow02 && g_h02_has)
   {
      datetime tStart = (g_h02_time == 0 ? tBarOpen : g_h02_time);
      CreateOrUpdateRay(dayPfx + "H02_H", tStart, g_h02_high, InpH02Color, STYLE_SOLID, 2);
      CreateOrUpdateRay(dayPfx + "H02_L", tStart, g_h02_low, InpH02Color, STYLE_SOLID, 2);
   }

   if(InpShowSignals && g_ib_has && g_h13_has)
   {
      double mid = (g_ib_high + g_ib_low) / 2.0;
      bool isKill = InWindowLocal(tBarOpen, 14, 30, 16, 30);
      bool dailyOkB = (!InpUseDailyOpenFilter || (g_daily_has && c > g_daily_open));
      bool dailyOkS = (!InpUseDailyOpenFilter || (g_daily_has && c < g_daily_open));
      bool ibOkB = (!InpUseIbMidFilter || (c > mid));
      bool ibOkS = (!InpUseIbMidFilter || (c < mid));
      bool manipOkB = (!InpRequireManipulation || g_mid_sweep_down || g_ib_sweep_down);
      bool manipOkS = (!InpRequireManipulation || g_mid_sweep_up || g_ib_sweep_up);
      bool buy = (c > g_h13_high && isKill && !g_buy_done && dailyOkB && ibOkB && manipOkB);
      bool sell = (c < g_h13_low && isKill && !g_sell_done && dailyOkS && ibOkS && manipOkS);
      if(buy)
      {
         g_buy_done = true;
         string n1 = dayPfx + "SIG_BUY_" + IntegerToString((long)tBarOpen);
         string n2 = n1 + "_T";
         if(ObjectFind(0, n1) < 0)
         {
            ObjectCreate(0, n1, OBJ_ARROW_BUY, 0, tBarOpen, l - 10 * _Point);
            ObjectSetInteger(0, n1, OBJPROP_COLOR, InpBuyColor);
            ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
         }
         CreateOrUpdateText(n2, tBarOpen, l - 10 * _Point, "BUY", InpBuyColor, ANCHOR_LEFT_LOWER);
         NotifySignal("BUY", tBarOpen);
      }
      if(sell)
      {
         g_sell_done = true;
         string n1 = dayPfx + "SIG_SELL_" + IntegerToString((long)tBarOpen);
         string n2 = n1 + "_T";
         if(ObjectFind(0, n1) < 0)
         {
            ObjectCreate(0, n1, OBJ_ARROW_SELL, 0, tBarOpen, h + 10 * _Point);
            ObjectSetInteger(0, n1, OBJPROP_COLOR, InpSellColor);
            ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
         }
         CreateOrUpdateText(n2, tBarOpen, h + 10 * _Point, "SELL", InpSellColor, ANCHOR_LEFT_UPPER);
         NotifySignal("SELL", tBarOpen);
      }
   }

   if(InpShowSignals && InpMidnightSignalsEnabled && g_mid_has && g_ib_has)
   {
      double ibMid = (g_ib_high + g_ib_low) / 2.0;
      bool isKill = InWindowLocal(tBarOpen, 14, 30, 16, 30);
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
      bool longSig = (canLong && c > g_mid_low && isKill && dailyOkB && ibOkB);

      bool canShort = g_mid_sweep_up && !g_mid_short_done;
      if(canShort && InpReclaimMaxBars > 0 && g_mid_sweep_up_bar >= 0)
      {
         int barsSince = g_update_calls - g_mid_sweep_up_bar;
         if(barsSince > InpReclaimMaxBars) canShort = false;
      }
      bool shortSig = (canShort && c < g_mid_high && isKill && dailyOkS && ibOkS);

      if(longSig)
      {
         g_mid_long_done = true;
         string n1 = (g_prefix + IntegerToString(g_day_key) + "_") + "SIG_MID_BUY_" + IntegerToString((long)tBarOpen);
         if(ObjectFind(0, n1) < 0)
         {
            ObjectCreate(0, n1, OBJ_ARROW_BUY, 0, tBarOpen, l - 12 * _Point);
            ObjectSetInteger(0, n1, OBJPROP_COLOR, clrAqua);
            ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
         }
         CreateOrUpdateText(n1 + "_T", tBarOpen, l - 12 * _Point, "BUY Mid", clrAqua, ANCHOR_LEFT_LOWER);
         NotifySignal("BUY Midnight", tBarOpen);
      }
      if(shortSig)
      {
         g_mid_short_done = true;
         string n1 = (g_prefix + IntegerToString(g_day_key) + "_") + "SIG_MID_SELL_" + IntegerToString((long)tBarOpen);
         if(ObjectFind(0, n1) < 0)
         {
            ObjectCreate(0, n1, OBJ_ARROW_SELL, 0, tBarOpen, h + 12 * _Point);
            ObjectSetInteger(0, n1, OBJPROP_COLOR, clrMagenta);
            ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
         }
         CreateOrUpdateText(n1 + "_T", tBarOpen, h + 12 * _Point, "SELL Mid", clrMagenta, ANCHOR_LEFT_UPPER);
         NotifySignal("SELL Midnight", tBarOpen);
      }
   }

   bool isStar13 = (_Period == PERIOD_M1) ? IsLocalTime(tBarOpen, 12, 59) : IsLocalTime(tBarOpen, 13, 0);
   bool isStar16 = (_Period == PERIOD_M1) ? IsLocalTime(tBarOpen, 15, 59) : IsLocalTime(tBarOpen, 16, 0);
   if(isStar13)
   {
      string n = (g_prefix + IntegerToString(g_day_key) + "_") + "STAR_13_" + IntegerToString((long)tBarOpen);
      CreateOrUpdateText(n, tBarOpen, l - 14 * _Point, "★", clrYellow, ANCHOR_LEFT_LOWER);
   }
   if(isStar16)
   {
      string n = (g_prefix + IntegerToString(g_day_key) + "_") + "STAR_16_" + IntegerToString((long)tBarOpen);
      CreateOrUpdateText(n, tBarOpen, l - 14 * _Point, "★", clrYellow, ANCHOR_LEFT_LOWER);
   }

   string st = "CAP_IND | it " + IntegerToString(MinuteOfDayLocal(tBarOpen) / 60) + ":" + IntegerToString(MinuteOfDayLocal(tBarOpen) % 60) +
               " | daily " + (g_daily_has ? "Y" : "N") + " | h02 " + (g_h02_has ? "Y" : "N") + " | h13 " + (g_h13_has ? "Y" : "N");
   CreateOrUpdateStatusLabel(st);
}

int OnInit()
{
   CreateOrUpdateStatusLabel("CAP_IND loaded");
   UpdateChartComment("CAP_IND loaded");
   if(InpShowTestLines)
   {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(bid > 0.0) CreateOrUpdateHLine(g_prefix + "TEST_HLINE", bid, clrMagenta, STYLE_SOLID, 2);
      CreateOrUpdateVLine(g_prefix + "TEST_VLINE", TimeCurrent(), clrMagenta, STYLE_SOLID, 2);
   }
   if(InpDebugOverlay)
   {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(bid > 0.0) CreateOrUpdateText(g_prefix + "PING", TimeCurrent(), bid, "CAP_IND", clrYellow, ANCHOR_LEFT_UPPER);
   }
   ChartRedraw(0);
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(!InpEnabled || rates_total < 10) return rates_total;

   bool isSeries = (time[0] > time[rates_total - 1]);

   {
      datetime now = TimeCurrent();
      MqlDateTime s, it;
      TimeToStruct(now, s);
      TimeToStruct(LocalTime(now), it);
      int objTotal = ObjectsTotal(0, -1, -1);
      int objOurs = CountObjectsByPrefix(g_prefix);
      string st = "CAP_IND | srv " + IntegerToString(s.hour) + ":" + IntegerToString(s.min) +
                  " | it " + IntegerToString(it.hour) + ":" + IntegerToString(it.min) +
                  " | bars " + IntegerToString(rates_total) +
                  " | obj " + IntegerToString(objTotal) + "/" + IntegerToString(objOurs) +
                  " | dayKey " + IntegerToString(DayKeyLocal(now)) +
                  " | fails " + IntegerToString(g_create_fails) +
                  " | err " + IntegerToString(g_last_create_err) +
                  " | series " + (isSeries ? "Y" : "N") +
                  " | upd " + IntegerToString(g_update_calls) +
                  " | daily " + (g_daily_has ? "Y" : "N") +
                  " | ib " + (g_ib_has ? "Y" : "N") +
                  " | h13 " + (g_h13_has ? "Y" : "N") +
                  " | h02 " + (g_h02_has ? "Y" : "N");
      CreateOrUpdateStatusLabel(st);
      UpdateChartComment(st);
   }

   if(prev_calculated == 0)
   {
      g_last_time0 = 0;
      g_day_key = 0;
      int curIndex = IndexByShift(isSeries, rates_total, 0);
      int todayKey = DayKeyLocal(time[curIndex]);
      ResetDay(todayKey);

      int histDays = InpHistoryDays;
      if(histDays < 1) histDays = 1;
      if(histDays > 60) histDays = 60;

      int startShift = 0;
      int dayCount = 1;
      int lastDay = todayKey;
      for(int sh = 1; sh < rates_total; sh++)
      {
         int ii = IndexByShift(isSeries, rates_total, sh);
         int dk = DayKeyLocal(time[ii]);
         if(dk != lastDay)
         {
            dayCount++;
            lastDay = dk;
            if(dayCount > histDays)
            {
               startShift = sh - 1;
               break;
            }
         }
         startShift = sh;
      }

      for(int sh = startShift; sh >= 0; sh--)
      {
         int ii = IndexByShift(isSeries, rates_total, sh);
         UpdateWithBar(time[ii], open[ii], high[ii], low[ii], close[ii]);
      }

      UpdateRightSideLabels(time[curIndex]);
      if(InpDebugOverlay)
      {
         CreateOrUpdateText(g_prefix + "PING", time[curIndex], close[curIndex], "CAP_IND", clrYellow, ANCHOR_LEFT_UPPER);
      }
      g_last_time0 = time[curIndex];
      return rates_total;
   }

   int curIdx = IndexByShift(isSeries, rates_total, 0);
   int prevIdx = IndexByShift(isSeries, rates_total, 1);
   int prevPrevIdx = IndexByShift(isSeries, rates_total, 2);

   if(_Period == PERIOD_M1)
   {
      int dkCur = DayKeyLocal(time[curIdx]);
      if(dkCur != g_day_key) ResetDay(dkCur);
      if(IsLocalTime(time[curIdx], 0, 0))
      {
         g_day_start_time = time[curIdx];
         g_daily_open = open[curIdx];
         g_daily_high = high[curIdx];
         g_daily_low = low[curIdx];
         g_daily_has = (g_daily_open > 0.0);

         g_mid_time = time[curIdx];
         g_mid_high = high[curIdx];
         g_mid_low = low[curIdx];
         g_mid_has = true;

         g_h02_time = time[curIdx];
         g_h02_high = high[curIdx];
         g_h02_low = low[curIdx];
         g_h02_has = true;
      }
   }

   if(time[curIdx] != g_last_time0)
   {
      UpdateWithBar(time[prevIdx], open[prevIdx], high[prevIdx], low[prevIdx], close[prevIdx]);
      if(rates_total >= 3)
      {
         double prevC = close[prevPrevIdx];
         double curC = close[prevIdx];
         datetime t = time[prevIdx];
         if(g_h13_has)
         {
            CheckCrossLevel("H13 HIGH", g_h13_high, prevC, curC, t, g_last_cross_h13_h);
            CheckCrossLevel("H13 LOW", g_h13_low, prevC, curC, t, g_last_cross_h13_l);
         }
         if(g_h02_has)
         {
            CheckCrossLevel("02 HIGH", g_h02_high, prevC, curC, t, g_last_cross_h02_h);
            CheckCrossLevel("02 LOW", g_h02_low, prevC, curC, t, g_last_cross_h02_l);
         }
      }
      g_last_time0 = time[curIdx];
   }

   UpdateRightSideLabels(time[curIdx]);
   if(InpDebugOverlay)
   {
      CreateOrUpdateText(g_prefix + "PING", time[curIdx], close[curIdx], "CAP_IND", clrYellow, ANCHOR_LEFT_UPPER);
   }
   return rates_total;
}
