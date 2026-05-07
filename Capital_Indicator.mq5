   #property strict
   #property indicator_chart_window
   #property indicator_plots 0
   #property version "1.00"

   input group "Capital Indicator"
   input bool InpEnabled = true;
   input int InpItalyOffsetHours = 2;
   input bool InpShowSessions = false;
   input bool InpShowSessionNames = true;
   input int InpBoxAlpha = 60;
   input bool InpShowDailyHL = true;
   input bool InpShowDailyOpen = false;
   input bool InpShowNYOpen = true;
   input bool InpShowA2NRange = true;
   input bool InpShowIB = true;
   input bool InpShowH13 = true; 
   input bool InpShow02 = true;
   input bool InpShowMidnightHL = true;
   input bool InpShowAsiaBiasArrow = true;
   input bool InpShowSignals = true;
   input bool InpShowOnlySwingSignals = false;
   input bool InpShowStatusLabel = true;
   input bool InpShowChartComment = true;
   input bool InpShowTestLines = false;
   input int InpHistoryDays = 5;
   input bool InpDebugOverlay = true;

   input group "Alerts"
   input bool InpSendAlert = true;
   input bool InpSendPush = true;
   input bool InpNotifyHistorical = false;
   input bool InpNotifyCrossLevels = false;
   input bool InpNotifyOnlySHSL = true;
   input bool InpNotifyDiv = true;
   input bool InpNotifyLux = true;
   input bool InpNotifyMtf = true;

   input group "Logic"
   input bool InpUseDailyOpenFilter = true;
   input bool InpUseIbMidFilter = true;
   input bool InpRequireManipulation = false;
   input bool InpUseAsiaLondonSell13 = true;
   input int InpSweepBufferPoints = 0;
   input int InpReclaimMaxBars = 6;
   input bool InpMidnightSignalsEnabled = true;

   input group "Logica Matteo Capital"
   input int InpRetestToleranceTicks = 5;
   input bool InpRequireSweepBeforeKiss = true;
   input bool InpSweepOutsideKillzone = false;
   input bool InpKissOutsideKillzone = false;

   input group "Hammer/Shooting"
   input bool InpHammerShootingEnabled = true;
   input double InpHammerFibLevel = 0.382;
   input bool InpHammerConfirmNextCandle = true;
   input bool InpHammerShowLabels = true;
   input bool InpHammerFibRetraceEnabled = true;
   input bool InpHammerFibUse05 = true;
   input bool InpHammerFibUse0382 = true;

   input group "Lux Swing"
   input bool InpLuxSwingEnabled = true;
   input int InpLuxSwingLength = 21;
   input bool InpLuxSwingShowLabels = true;
   input color InpLuxSwingHighColor = clrRed;
   input color InpLuxSwingLowColor = clrTeal;
   input bool InpLuxNotifySwings = true;
   input bool InpLuxNotifyPatterns = true;
   input bool InpLuxNotifyHammer = true;
   input bool InpLuxNotifyInvertedHammer = true;
   input bool InpLuxNotifyBullishEngulfing = true;
   input bool InpLuxNotifyHangingMan = true;
   input bool InpLuxNotifyShootingStar = true;
   input bool InpLuxNotifyBearishEngulfing = true;
   input bool InpLuxNotifyNone = true;

input group "Institutional Sweep"
input bool InpInstSweepEnabled = true;
input int InpInstCooldownPeriod = 10;
input color InpInstBullColor = clrTeal;
input color InpInstBearColor = clrMaroon;

input group "Early Swing"
input bool InpEarlySwingEnabled = true;
input int InpEarlyLeftBars = 2;
input int InpEarlyRightBars = 2;
input bool InpEarlyVolFilter = true;
input bool InpEarlyShowLabels = true;
input bool InpEarlyShowDailyExtremeShSl = false;
input int InpEarlyDailyExtremeBufferPoints = 0;

input group "Swing Pattern"
input bool InpSwingPatternEnabled = true;
input int InpSwingLeftBars = 2;
input int InpSwingRightBars = 2;
input bool InpSwingUseTfBars = true;
input int InpSwingLeftBars_M1 = 2;
input int InpSwingRightBars_M1 = 2;
input int InpSwingLeftBars_M15 = 2;
input int InpSwingRightBars_M15 = 2;
input int InpSwingLeftBars_H1 = 2;
input int InpSwingRightBars_H1 = 2;
input int InpSwingLeftBars_H4 = 2;
input int InpSwingRightBars_H4 = 2;
input bool InpSwingShowLabels = true;
input bool InpSwingUseInstitutionalSwings = false;
input bool InpSwingRequireReclaimAfterSweep = false;
input bool InpSwingRequireOppositeSwingSweep = false;
input int InpSwingOppositeSwingSweepBufferPoints = 0;
input bool InpSwingRequireH13L13Sweep = false;
input bool InpSwingRequireAsiaSweep = false;
input int InpSwingAsiaSweepStartHour = 8;
input int InpSwingAsiaSweepStartMinute = 0;
input int InpSwingAsiaSweepEndHour = 11;
input int InpSwingAsiaSweepEndMinute = 0;
input bool InpSwingRequireIBSweep = false;
input int InpSwingIBSweepStartHour = 10;
input int InpSwingIBSweepStartMinute = 0;
input int InpSwingIBSweepEndHour = 13;
input int InpSwingIBSweepEndMinute = 0;
input bool InpSwingOverLowL13Enabled = false;
input int InpSwingOverLowL13BufferPoints = 0;
input bool InpSwingShowDailyExtremeShSl = false;
input int InpSwingDailyExtremeBufferPoints = 0;
input int InpSwingMinSwingRangePoints = 0;
input int InpSwingMinReactionSepPoints = 1;
input bool InpSwingConfirmBos = true;
input bool InpSwingBullDivEnabled = true;
input int InpSwingRsiLen = 14;
input bool InpSwingShowDiv = true;
input bool InpSwingDivUseRsiThresholds = true;
input double InpSwingDivBullPrevRsiMax = 40.0;
input double InpSwingDivBearPrevRsiMin = 60.0;
input double InpSwingDivMinRsiDelta = 0.0;

enum ENUM_MTF_RETEST_ZONE_TYPE
{
   MTF_ZONE_OB = 0,
   MTF_ZONE_FVG = 1,
   MTF_ZONE_OB_FVG = 2
};

input group "MTF Entry (H1->M1)"
input bool InpMtfEntryEnabled = false;
input bool InpMtfUseSetupA = true;
input bool InpMtfUseSetupB = true;
input bool InpMtfUseSetupC = false;
input int InpMtfH1LeftBars = 2;
input int InpMtfH1RightBars = 2;
input bool InpMtfH1ConfirmBos = true;
input int InpMtfMaxM1BarsAfterH1Signal = 180;
input int InpMtfSweepLookbackBars = 5;
input int InpMtfSweepBufferPoints = 0;
input int InpMtfChoChPivotLen = 1;
input ENUM_MTF_RETEST_ZONE_TYPE InpMtfRetestZoneType = MTF_ZONE_OB_FVG;
input int InpMtfObLookbackBars = 5;
input int InpMtfSlBufferPoints = 0;

   input group "Colors"
   input color InpDailyOpenColor = clrPurple;
   input color InpDailyHLColor = clrWhite;
   input color InpNyOpenColor = clrBlue;
   input color InpIbColor = clrBlue;
   input color InpH13Color = clrOrange;
   input color InpH02Color = clrGreen;
   input color InpMidnightColor = clrGreen;
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
   double g_asia_open = 0.0;
   double g_asia_close = 0.0;
   bool g_asia_bias_has = false;

   datetime g_last_cross_h13_h = 0, g_last_cross_h13_l = 0;
   datetime g_last_cross_h02_h = 0, g_last_cross_h02_l = 0;

   bool g_prev_hammer = false;
   bool g_prev_shoot = false;
   datetime g_prev_hs_time = 0;
   double g_prev_hs_high = 0.0;
   double g_prev_hs_low = 0.0;

   bool g_kiss_swept_h = false;
   bool g_kiss_swept_l = false;
   bool g_kiss_done_b = false;
   bool g_kiss_done_s = false;

   bool g_hsfib_pending = false;
   int g_hsfib_dir = 0;
   datetime g_hsfib_pattern_time = 0;
   double g_hsfib_high = 0.0;
   double g_hsfib_low = 0.0;
   datetime g_hsfib_expiry = 0;

   enum { LUX_CAP = 450, INST_CAP = 300 };
   datetime g_lux_time[LUX_CAP];
   double g_lux_open[LUX_CAP];
   double g_lux_high[LUX_CAP];
   double g_lux_low[LUX_CAP];
   double g_lux_close[LUX_CAP];
   int g_lux_head = -1;
   int g_lux_count = 0;
   double g_lux_phy = 0.0;
   bool g_lux_phy_has = false;
   double g_lux_ply = 0.0;
   bool g_lux_ply_has = false;
   datetime g_lux_last_notified_ph = 0;
   datetime g_lux_last_notified_pl = 0;
   datetime g_inst_time[INST_CAP];
   double g_inst_open[INST_CAP];
   double g_inst_high[INST_CAP];
   double g_inst_low[INST_CAP];
   double g_inst_close[INST_CAP];
   int g_inst_head = -1;
   int g_inst_count = 0;
   double g_inst_pLowVal = 0.0;
   bool g_inst_pLowHas = false;
   double g_inst_pHighVal = 0.0;
   bool g_inst_pHighHas = false;
   int g_inst_last_bull_index = -1000000;
   int g_inst_last_bear_index = -1000000;
   double g_inst_swing_high = 0.0;
   bool g_inst_swing_high_has = false;
   double g_inst_swing_low = 0.0;
   bool g_inst_swing_low_has = false;
   datetime g_inst_last_touch_high_time = 0;
   datetime g_inst_last_touch_low_time = 0;

   enum { ES_CAP = 220 };
   datetime g_es_time[ES_CAP];
   double g_es_open[ES_CAP];
   double g_es_high[ES_CAP];
   double g_es_low[ES_CAP];
   double g_es_close[ES_CAP];
   long g_es_vol[ES_CAP];
   int g_es_head = -1;
   int g_es_count = 0;
   datetime g_es_last_early_low_time = 0;
   datetime g_es_last_early_high_time = 0;
   datetime g_es_last_conf_low_time = 0;
   datetime g_es_last_conf_high_time = 0;
   datetime g_es_last_sp_sh_time = 0;
   datetime g_es_last_sp_sl_time = 0;
   int g_rsi_handle = INVALID_HANDLE;
   bool g_swing_last_sl_has = false;
   double g_swing_last_sl_price = 0.0;
   double g_swing_last_sl_rsi = 0.0;
   datetime g_swing_last_sl_time = 0;
   bool g_swing_last_sh_has = false;
   double g_swing_last_sh_price = 0.0;
   double g_swing_last_sh_rsi = 0.0;
   datetime g_swing_last_sh_time = 0;
   double g_swing_last_bull_sweep_level = 0.0;
   double g_swing_last_bear_sweep_level = 0.0;
   bool g_swing_allow_sl = true;
   bool g_swing_allow_sh = true;

   bool g_liq_last_sl_has = false;
   double g_liq_last_sl_price = 0.0;
   datetime g_liq_last_sl_time = 0;
   bool g_liq_last_sh_has = false;
   double g_liq_last_sh_price = 0.0;
   datetime g_liq_last_sh_time = 0;
   bool g_liq_opp_swept_for_sh = false;
   bool g_liq_opp_swept_for_sl = false;

   bool g_swing_asia_swept_h = false;
   bool g_swing_asia_swept_l = false;
   bool g_swing_ib_swept_h = false;
   bool g_swing_ib_swept_l = false;
   double g_prev_bar_low = 0.0;
   bool g_prev_bar_low_has = false;
   datetime g_last_over_low_time = 0;

   datetime g_mtf_last_h1_sl_time = 0;
   double g_mtf_last_h1_sl_price = 0.0;
   datetime g_mtf_last_h1_sh_time = 0;
   double g_mtf_last_h1_sh_price = 0.0;

   bool g_mtf_buy_active = false;
   datetime g_mtf_buy_h1_time = 0;
   double g_mtf_buy_level = 0.0;
   int g_mtf_buy_bars = 0;
   int g_mtfA_buy_state = 0;
   double g_mtfA_buy_reclaim_high = 0.0;
   double g_mtfA_buy_reclaim_low = 0.0;
   int g_mtfC_buy_state = 0;
   double g_mtfC_buy_last_pivot_high = 0.0;
   double g_mtfC_buy_zone_low = 0.0;
   double g_mtfC_buy_zone_high = 0.0;
   double g_mtfC_buy_struct_low = 0.0;

   bool g_mtf_sell_active = false;
   datetime g_mtf_sell_h1_time = 0;
   double g_mtf_sell_level = 0.0;
   int g_mtf_sell_bars = 0;
   int g_mtfA_sell_state = 0;
   double g_mtfA_sell_reclaim_high = 0.0;
   double g_mtfA_sell_reclaim_low = 0.0;
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

   void UpdateChartComment(const string txt)
   {
      if(InpShowChartComment) Comment(txt);
      else Comment("");
   }

   bool GetRsiAtTime(const datetime tBarOpen, double &rsiVal)
   {
      rsiVal = 0.0;
      if(g_rsi_handle == INVALID_HANDLE) return false;
      int shift = iBarShift(_Symbol, _Period, tBarOpen, true);
      if(shift < 0) return false;
      double buf[1];
      if(CopyBuffer(g_rsi_handle, 0, shift, 1, buf) <= 0) return false;
      rsiVal = buf[0];
      return true;
   }

   double MtfLowestPrevLow(const int look)
   {
      double vMin = 0.0;
      int n = MathMax(1, look);
      for(int s = 2; s <= n + 1; s++)
      {
         double v = iLow(_Symbol, _Period, s);
         if(v <= 0.0) continue;
         if(vMin <= 0.0 || v < vMin) vMin = v;
      }
      return vMin;
   }

   double MtfHighestPrevHigh(const int look)
   {
      double vMax = 0.0;
      int n = MathMax(1, look);
      for(int s = 2; s <= n + 1; s++)
      {
         double v = iHigh(_Symbol, _Period, s);
         if(v <= 0.0) continue;
         if(v > vMax) vMax = v;
      }
      return vMax;
   }

   void UpdateMtfH1SwingSignals()
   {
      int left = MathMax(1, InpMtfH1LeftBars);
      int right = MathMax(1, InpMtfH1RightBars);
      int centerShift = right + 1;
      int needBars = centerShift + left + 3;
      if(iBars(_Symbol, PERIOD_H1) < needBars) return;

      double hC = iHigh(_Symbol, PERIOD_H1, centerShift);
      double lC = iLow(_Symbol, PERIOD_H1, centerShift);
      if(hC <= 0.0 || lC <= 0.0) return;

      bool sh = true;
      bool sl = true;
      for(int off = -right; off <= left; off++)
      {
         if(off == 0) continue;
         int s = centerShift + off;
         double hh = iHigh(_Symbol, PERIOD_H1, s);
         double ll = iLow(_Symbol, PERIOD_H1, s);
         if(hh <= 0.0 || ll <= 0.0) { sh = false; sl = false; break; }
         if(hh >= hC) sh = false;
         if(ll <= lC) sl = false;
         if(!sh && !sl) break;
      }

      double sep = (double)InpSwingMinReactionSepPoints * _Point;
      double minRange = (double)InpSwingMinSwingRangePoints * _Point;
      bool rangeOk = ((hC - lC) >= minRange);

      double cR = iClose(_Symbol, PERIOD_H1, right);
      double oR = iOpen(_Symbol, PERIOD_H1, right);
      double hR = iHigh(_Symbol, PERIOD_H1, right);
      double lR = iLow(_Symbol, PERIOD_H1, right);
      double cNow = iClose(_Symbol, PERIOD_H1, 1);
      if(cR <= 0.0 || oR <= 0.0 || hR <= 0.0 || lR <= 0.0 || cNow <= 0.0) return;

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

      bool shSig = (sh && rangeOk && reactBearOk && bosBearOk);
      bool slSig = (sl && rangeOk && reactBullOk && bosBullOk);

      datetime tPivot = iTime(_Symbol, PERIOD_H1, centerShift);
      if(tPivot == 0) return;

      if(slSig && tPivot != g_mtf_last_h1_sl_time)
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
      if(shSig && tPivot != g_mtf_last_h1_sh_time)
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

   void DeleteByToken(const string token)
   {
      int total = ObjectsTotal(0, -1, -1);
      for(int i = total - 1; i >= 0; i--)
      {
         string n = ObjectName(0, i);
         if(StringFind(n, g_prefix) == 0 && StringFind(n, token) >= 0) ObjectDelete(0, n);
      }
   }

   void LuxReset()
   {
      g_lux_head = -1;
      g_lux_count = 0;
      g_lux_phy = 0.0;
      g_lux_phy_has = false;
      g_lux_ply = 0.0;
      g_lux_ply_has = false;
      g_lux_last_notified_ph = 0;
      g_lux_last_notified_pl = 0;
   }

   int LuxIdx(const int offsetFromNewest)
   {
      int idx = g_lux_head - offsetFromNewest;
      while(idx < 0) idx += LUX_CAP;
      return (idx % LUX_CAP);
   }

   void LuxPushBar(const datetime t, const double o, const double h, const double l, const double c)
   {
      g_lux_head = (g_lux_head + 1) % LUX_CAP;
      g_lux_time[g_lux_head] = t;
      g_lux_open[g_lux_head] = o;
      g_lux_high[g_lux_head] = h;
      g_lux_low[g_lux_head] = l;
      g_lux_close[g_lux_head] = c;
      if(g_lux_count < LUX_CAP) g_lux_count++;
   }

void InstReset()
{
   g_inst_head = -1;
   g_inst_count = 0;
   g_inst_pLowVal = 0.0;
   g_inst_pLowHas = false;
   g_inst_pHighVal = 0.0;
   g_inst_pHighHas = false;
   g_inst_last_bull_index = -1000000;
   g_inst_last_bear_index = -1000000;
   g_inst_swing_high = 0.0;
   g_inst_swing_high_has = false;
   g_inst_swing_low = 0.0;
   g_inst_swing_low_has = false;
   g_inst_last_touch_high_time = 0;
   g_inst_last_touch_low_time = 0;
}

void EsReset()
{
   g_es_head = -1;
   g_es_count = 0;
   g_es_last_early_low_time = 0;
   g_es_last_early_high_time = 0;
   g_es_last_conf_low_time = 0;
   g_es_last_conf_high_time = 0;
   g_es_last_sp_sh_time = 0;
   g_es_last_sp_sl_time = 0;
   g_swing_last_sl_has = false;
   g_swing_last_sl_price = 0.0;
   g_swing_last_sl_rsi = 0.0;
   g_swing_last_sl_time = 0;
   g_swing_last_sh_has = false;
   g_swing_last_sh_price = 0.0;
   g_swing_last_sh_rsi = 0.0;
   g_swing_last_sh_time = 0;
   g_swing_last_bull_sweep_level = 0.0;
   g_swing_last_bear_sweep_level = 0.0;
   g_swing_allow_sl = true;
   g_swing_allow_sh = true;

   g_liq_last_sl_has = false;
   g_liq_last_sl_price = 0.0;
   g_liq_last_sl_time = 0;
   g_liq_last_sh_has = false;
   g_liq_last_sh_price = 0.0;
   g_liq_last_sh_time = 0;
   g_liq_opp_swept_for_sh = false;
   g_liq_opp_swept_for_sl = false;
}

int EsIdx(const int offsetFromNewest)
{
   int idx = g_es_head - offsetFromNewest;
   while(idx < 0) idx += ES_CAP;
   return (idx % ES_CAP);
}

void EsPushBar(const datetime t, const double o, const double h, const double l, const double c, const long v)
{
   g_es_head = (g_es_head + 1) % ES_CAP;
   g_es_time[g_es_head] = t;
   g_es_open[g_es_head] = o;
   g_es_high[g_es_head] = h;
   g_es_low[g_es_head] = l;
   g_es_close[g_es_head] = c;
   g_es_vol[g_es_head] = v;
   if(g_es_count < ES_CAP) g_es_count++;
}

int InstIdx(const int offsetFromNewest)
{
   int idx = g_inst_head - offsetFromNewest;
   while(idx < 0) idx += INST_CAP;
   return (idx % INST_CAP);
}

void InstPushBar(const datetime t, const double o, const double h, const double l, const double c)
{
   g_inst_head = (g_inst_head + 1) % INST_CAP;
   g_inst_time[g_inst_head] = t;
   g_inst_open[g_inst_head] = o;
   g_inst_high[g_inst_head] = h;
   g_inst_low[g_inst_head] = l;
   g_inst_close[g_inst_head] = c;
   if(g_inst_count < INST_CAP) g_inst_count++;
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
      datetime t2 = NextLocalMidnightServer(t1);
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
      }
      ObjectMove(0, name, 0, t1, price);
      ObjectMove(0, name, 1, t2, price);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, style);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   }

   void CreateOrUpdateTrendSegment(const string name, const datetime t1, const double p1, const datetime t2, const double p2, const color clr, const ENUM_LINE_STYLE style, const int width)
   {
      if(ObjectFind(0, name) < 0)
      {
         ResetLastError();
         if(!ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2))
         {
            g_last_create_err = GetLastError();
            g_create_fails++;
            return;
         }
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
      if(InpNotifyOnlySHSL)
      {
         bool isShSl = (txt == "SH" || txt == "SL");
         bool isDiv = (txt == "DIV");
         bool isLux = (StringFind(txt, "LUX") == 0);
         bool isMtf = (StringFind(txt, "BUY MTF") == 0 || StringFind(txt, "SELL MTF") == 0);
         if(!(isShSl || (InpNotifyDiv && isDiv) || (InpNotifyLux && isLux) || (InpNotifyMtf && isMtf))) return;
      }
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
      if(InpShowOnlySwingSignals)
      {
         DeleteByToken("LBL_");
         return;
      }
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
      g_asia_open = 0.0; g_asia_close = 0.0; g_asia_bias_has = false;
      g_last_cross_h13_h = 0; g_last_cross_h13_l = 0; g_last_cross_h02_h = 0; g_last_cross_h02_l = 0;
      g_buy_done = false;
      g_sell_done = false;
      g_prev_hammer = false;
      g_prev_shoot = false;
      g_prev_hs_time = 0;
      g_prev_hs_high = 0.0;
      g_prev_hs_low = 0.0;
      g_kiss_swept_h = false;
      g_kiss_swept_l = false;
      g_kiss_done_b = false;
      g_kiss_done_s = false;
      g_hsfib_pending = false;
      g_hsfib_dir = 0;
      g_hsfib_pattern_time = 0;
      g_hsfib_high = 0.0;
      g_hsfib_low = 0.0;
      g_hsfib_expiry = 0;
      g_swing_asia_swept_h = false;
      g_swing_asia_swept_l = false;
      g_swing_ib_swept_h = false;
      g_swing_ib_swept_l = false;
      g_prev_bar_low = 0.0;
      g_prev_bar_low_has = false;
      g_last_over_low_time = 0;
      g_mtf_last_h1_sl_time = 0;
      g_mtf_last_h1_sl_price = 0.0;
      g_mtf_last_h1_sh_time = 0;
      g_mtf_last_h1_sh_price = 0.0;
      g_mtf_buy_active = false;
      g_mtf_buy_h1_time = 0;
      g_mtf_buy_level = 0.0;
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
      g_mtf_sell_h1_time = 0;
      g_mtf_sell_level = 0.0;
      g_mtf_sell_bars = 0;
      g_mtfA_sell_state = 0;
      g_mtfA_sell_reclaim_high = 0.0;
      g_mtfA_sell_reclaim_low = 0.0;
      g_mtfC_sell_state = 0;
      g_mtfC_sell_last_pivot_low = 0.0;
      g_mtfC_sell_zone_low = 0.0;
      g_mtfC_sell_zone_high = 0.0;
      g_mtfC_sell_struct_high = 0.0;
      DeleteByToken("HSFIB_");
      DeleteByPrefix(g_prefix + IntegerToString(dayKey) + "_");
      EsReset();
   }

   void UpdateWithBar(const datetime tBarOpen, const double o, const double h, const double l, const double c)
   {
      g_update_calls++;
      int dk = DayKeyLocal(tBarOpen);
      if(dk != g_day_key) ResetDay(dk);

      double prevLow = g_prev_bar_low_has ? g_prev_bar_low : l;

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
         g_kiss_swept_h = false;
         g_kiss_swept_l = false;
         g_kiss_done_b = false;
         g_kiss_done_s = false;
      }

      if(IsLocalTime(tBarOpen, 14, 30)) { g_ny_time = tBarOpen; g_ny_open = o; g_ny_has = true; }
      if(IsLocalTime(tBarOpen, 2, 0)) { g_h02_time = tBarOpen; g_h02_high = h; g_h02_low = l; g_h02_has = true; }

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
      bool showOther = !InpShowOnlySwingSignals;
      bool inAsia = InWindowLocal(tBarOpen, 0, 0, 8, 0);
      bool inLondon = InWindowLocal(tBarOpen, 9, 0, 17, 30);
      bool inNy = InWindowLocal(tBarOpen, 14, 30, 21, 0);
      bool beforeNyClose = (MinuteOfDayLocal(tBarOpen) < 21 * 60);

      bool inAsiaSweepWin = InWindowLocal(tBarOpen, InpSwingAsiaSweepStartHour, InpSwingAsiaSweepStartMinute, InpSwingAsiaSweepEndHour, InpSwingAsiaSweepEndMinute);
      if(inAsiaSweepWin && g_asia_has)
      {
         if(h > g_asia_high) g_swing_asia_swept_h = true;
         if(l < g_asia_low) g_swing_asia_swept_l = true;
      }

      bool inIbSweepWin = InWindowLocal(tBarOpen, InpSwingIBSweepStartHour, InpSwingIBSweepStartMinute, InpSwingIBSweepEndHour, InpSwingIBSweepEndMinute);
      if(inIbSweepWin && g_ib_has)
      {
         if(h > g_ib_high) g_swing_ib_swept_h = true;
         if(l < g_ib_low) g_swing_ib_swept_l = true;
      }

      if(inAsia)
      {
         if(!g_asia_has)
         {
            g_asia_high = h; g_asia_low = l; g_asia_has = true; g_asia_start = tBarOpen;
            g_asia_open = o;
            g_asia_close = c;
            g_asia_bias_has = true;
         }
         else { if(h > g_asia_high) g_asia_high = h; if(l < g_asia_low) g_asia_low = l; }
         g_asia_close = c;
      }
      else { g_asia_start = 0; }

      if(inLondon)
      {
         if(!g_london_has) { g_london_high = h; g_london_low = l; g_london_has = true; g_london_start = tBarOpen; }
         else { if(h > g_london_high) g_london_high = h; if(l < g_london_low) g_london_low = l; }
      }
      else { g_london_has = false; g_london_start = 0; }

      if(inNy)
      {
         if(!g_ny_sess_has) { g_ny_high = h; g_ny_low = l; g_ny_sess_has = true; g_ny_start = tBarOpen; }
         else { if(h > g_ny_high) g_ny_high = h; if(l < g_ny_low) g_ny_low = l; }
      }
      else { g_ny_sess_has = false; g_ny_start = 0; }

      if(showOther && InpShowSessions)
      {
         if(!InpShowSessionNames) DeleteByToken("_TAG_");
         if(inAsia)
         {
            CreateOrUpdateRect(dayPfx + "ASIA_BOX", g_asia_start, g_asia_high, tBarOpen + PeriodSeconds(_Period), g_asia_low, InpAsiaColor);
            if(InpShowSessionNames) UpdateSessionTag(dayPfx, "ASIA", "ASIA", InpAsiaColor, tBarOpen, g_asia_high);
         }
         if(inLondon)
         {
            CreateOrUpdateRect(dayPfx + "LONDON_BOX", g_london_start, g_london_high, tBarOpen + PeriodSeconds(_Period), g_london_low, InpLondonColor);
            if(InpShowSessionNames) UpdateSessionTag(dayPfx, "LONDON", "LONDON", InpLondonColor, tBarOpen, g_london_high);
         }
         if(inNy)
         {
            CreateOrUpdateRect(dayPfx + "NY_BOX", g_ny_start, g_ny_high, tBarOpen + PeriodSeconds(_Period), g_ny_low, InpNyColor);
            if(InpShowSessionNames) UpdateSessionTag(dayPfx, "NY", "NY", InpNyColor, tBarOpen, g_ny_high);
         }
      }

      if(g_daily_has)
      {
         if(showOther && InpShowDailyOpen)
            CreateOrUpdateRay(dayPfx + "D_OPEN", g_day_start_time == 0 ? tBarOpen : g_day_start_time, g_daily_open, InpDailyOpenColor, STYLE_SOLID, 1);
         else
            DeleteByToken("_D_OPEN");
         if(showOther && InpShowDailyHL)
         {
            datetime tStart = (g_day_start_time == 0 ? tBarOpen : g_day_start_time);
            CreateOrUpdateRay(dayPfx + "D_HIGH", tStart, g_daily_high, InpDailyHLColor, STYLE_SOLID, 1);
            CreateOrUpdateRay(dayPfx + "D_LOW", tStart, g_daily_low, InpDailyHLColor, STYLE_SOLID, 1);
         }
      }

      if(showOther && InpShowNYOpen && g_ny_has)
      {
         CreateOrUpdateRay(dayPfx + "NY_OPEN", g_ny_time == 0 ? tBarOpen : g_ny_time, g_ny_open, InpNyOpenColor, STYLE_SOLID, 2);
      }

      if(showOther && InpShowIB && g_ib_has)
      {
         datetime tStart = (g_ib_time == 0 ? tBarOpen : g_ib_time);
         CreateOrUpdateRay(dayPfx + "IB_H", tStart, g_ib_high, InpIbColor, STYLE_DOT, 1);
         CreateOrUpdateRay(dayPfx + "IB_L", tStart, g_ib_low, InpIbColor, STYLE_DOT, 1);
      }

      if(showOther && InpShowH13 && g_h13_has && MinuteOfDayLocal(tBarOpen) >= 13 * 60)
      {
         datetime tStart = (g_h13_time == 0 ? tBarOpen : g_h13_time);
         CreateOrUpdateRay(dayPfx + "H13_H", tStart, g_h13_high, InpH13Color, STYLE_SOLID, 2);
         CreateOrUpdateRay(dayPfx + "H13_L", tStart, g_h13_low, InpH13Color, STYLE_SOLID, 2);
      }

      if(showOther && InpShow02 && g_h02_has && MinuteOfDayLocal(tBarOpen) >= 2 * 60)
      {
         datetime tStart = (g_h02_time == 0 ? tBarOpen : g_h02_time);
         CreateOrUpdateRay(dayPfx + "H02_H", tStart, g_h02_high, InpH02Color, STYLE_SOLID, 2);
         CreateOrUpdateRay(dayPfx + "H02_L", tStart, g_h02_low, InpH02Color, STYLE_SOLID, 2);
      }

      if(showOther && InpShowMidnightHL && g_mid_has)
      {
         datetime tStart = (g_mid_time == 0 ? tBarOpen : g_mid_time);
         CreateOrUpdateRay(dayPfx + "MID_H", tStart, g_mid_high, InpMidnightColor, STYLE_SOLID, 2);
         CreateOrUpdateRay(dayPfx + "MID_L", tStart, g_mid_low, InpMidnightColor, STYLE_SOLID, 2);
      }

      if(showOther && InpShowA2NRange && g_mid_has)
      {
         datetime tStart = (g_mid_time == 0 ? tBarOpen : g_mid_time);
         if(beforeNyClose)
         {
            datetime tEnd = tBarOpen + (datetime)PeriodSeconds(_Period);
            CreateOrUpdateTrendSegment(dayPfx + "A2N_H", tStart, g_mid_high, tEnd, g_mid_high, InpMidnightColor, STYLE_SOLID, 2);
            CreateOrUpdateTrendSegment(dayPfx + "A2N_L", tStart, g_mid_low, tEnd, g_mid_low, InpMidnightColor, STYLE_SOLID, 2);
         }
      }
      else
      {
         DeleteByToken("A2N_");
      }

      if(showOther && InpShowAsiaBiasArrow && IsLocalTime(tBarOpen, 9, 0) && g_asia_has)
      {
         bool buyBias = (g_asia_high > 0.0 && l > g_asia_high);
         bool sellBias = (g_asia_low > 0.0 && h < g_asia_low);
         if(buyBias || sellBias)
         {
            string n1 = (g_prefix + IntegerToString(g_day_key) + "_") + "ASIA_BIAS_" + IntegerToString((long)tBarOpen);
            if(ObjectFind(0, n1) < 0)
            {
               ObjectCreate(0, n1, buyBias ? OBJ_ARROW_BUY : OBJ_ARROW_SELL, 0, tBarOpen, buyBias ? (l - 12 * _Point) : (h + 12 * _Point));
               ObjectSetInteger(0, n1, OBJPROP_COLOR, buyBias ? InpBuyColor : InpSellColor);
               ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
               ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
               NotifySignal("ASIA BIAS " + string(buyBias ? "BUY" : "SELL"), tBarOpen);
            }
         }
      }

      if(showOther && InpUseAsiaLondonSell13 && IsLocalTime(tBarOpen, 13, 0) && g_london_has && g_h02_has && g_h02_high > g_london_high && g_h02_low > g_london_high)
      {
         string n1 = (g_prefix + IntegerToString(g_day_key) + "_") + "ASIA_LONDON_SELL13_" + IntegerToString((long)tBarOpen);
         if(ObjectFind(0, n1) < 0)
         {
            ObjectCreate(0, n1, OBJ_ARROW_SELL, 0, tBarOpen, h + 12 * _Point);
            ObjectSetInteger(0, n1, OBJPROP_COLOR, InpSellColor);
            ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
            NotifySignal("SELL 13 (02>London)", tBarOpen);
         }
      }

      if(InpSwingOverLowL13Enabled && beforeNyClose && g_h13_has)
      {
         double buf = (double)InpSwingOverLowL13BufferPoints * _Point;
         double level = g_h13_low - buf;
         if(prevLow >= level && l < level && g_last_over_low_time != tBarOpen)
         {
            string n = dayPfx + "SP_OVERLOW_L13_" + IntegerToString((long)tBarOpen);
            CreateOrUpdateText(n, tBarOpen, l - 12 * _Point, "OVER\nLOW", clrRed, ANCHOR_LEFT_LOWER);
            NotifySignal("OVER LOW (L13)", tBarOpen);
            g_last_over_low_time = tBarOpen;
         }
      }

      if(g_h13_has)
      {
         bool isKill = InWindowLocal(tBarOpen, 14, 30, 16, 30);
         bool allowSweep = (isKill || InpSweepOutsideKillzone);
         if(allowSweep)
         {
            if(!g_kiss_swept_h && h > g_h13_high)
            {
               g_kiss_swept_h = true;
               if(InpSwingRequireReclaimAfterSweep)
               {
                  g_swing_last_bear_sweep_level = g_h13_high;
                  g_swing_allow_sh = false;
               }
               if(showOther && InpShowSignals)
               {
                  string n = dayPfx + "KISS_SWEEP_H_" + IntegerToString((long)tBarOpen);
                  CreateOrUpdateText(n, tBarOpen, h + 12 * _Point, "Swept", clrRed, ANCHOR_LEFT_UPPER);
                  NotifySignal("SWEEP HIGH (H13)", tBarOpen);
               }
            }
            if(!g_kiss_swept_l && l < g_h13_low)
            {
               g_kiss_swept_l = true;
               if(InpSwingRequireReclaimAfterSweep)
               {
                  g_swing_last_bull_sweep_level = g_h13_low;
                  g_swing_allow_sl = false;
               }
               if(showOther && InpShowSignals)
               {
                  string n = dayPfx + "KISS_SWEEP_L_" + IntegerToString((long)tBarOpen);
                  CreateOrUpdateText(n, tBarOpen, l - 12 * _Point, "Swept", clrRed, ANCHOR_LEFT_LOWER);
                  NotifySignal("SWEEP LOW (H13)", tBarOpen);
               }
            }
         }

         double tol = (double)InpRetestToleranceTicks * _Point;
         bool allowKiss = (isKill || InpKissOutsideKillzone);
         bool validKissBuy = allowKiss && (!InpRequireSweepBeforeKiss || g_kiss_swept_l) && !g_kiss_done_b && l <= (g_h13_low + tol) && c > g_h13_low;
         bool validKissSell = allowKiss && (!InpRequireSweepBeforeKiss || g_kiss_swept_h) && !g_kiss_done_s && h >= (g_h13_high - tol) && c < g_h13_high;

         if(validKissBuy) g_kiss_done_b = true;
         if(validKissSell) g_kiss_done_s = true;

         if(showOther && InpShowSignals)
         {
            if(validKissBuy)
            {
               string n1 = dayPfx + "KISS_BUY_" + IntegerToString((long)tBarOpen);
               string n2 = n1 + "_T";
               if(ObjectFind(0, n1) < 0)
               {
                  ObjectCreate(0, n1, OBJ_ARROW_BUY, 0, tBarOpen, l - 12 * _Point);
                  ObjectSetInteger(0, n1, OBJPROP_COLOR, InpBuyColor);
                  ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
                  ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
                  ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
               }
               CreateOrUpdateText(n2, tBarOpen, l - 12 * _Point, "KISS BUY", InpBuyColor, ANCHOR_LEFT_LOWER);
               NotifySignal("KISS BUY", tBarOpen);
            }
            if(validKissSell)
            {
               string n1 = dayPfx + "KISS_SELL_" + IntegerToString((long)tBarOpen);
               string n2 = n1 + "_T";
               if(ObjectFind(0, n1) < 0)
               {
                  ObjectCreate(0, n1, OBJ_ARROW_SELL, 0, tBarOpen, h + 12 * _Point);
                  ObjectSetInteger(0, n1, OBJPROP_COLOR, InpSellColor);
                  ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
                  ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
                  ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
               }
               CreateOrUpdateText(n2, tBarOpen, h + 12 * _Point, "KISS SELL", InpSellColor, ANCHOR_LEFT_UPPER);
               NotifySignal("KISS SELL", tBarOpen);
            }
         }
      }

      if(showOther && InpHammerShootingEnabled)
      {
         double candleSize = MathAbs(h - l);
         bool isGreen = (o < c);
         bool isRed = (o > c);
         bool isHammer = (candleSize > 0.0 && (h - InpHammerFibLevel * candleSize) < MathMin(o, c));
         bool isShoot = (candleSize > 0.0 && (l + InpHammerFibLevel * candleSize) > MathMax(o, c));

         if(!InpHammerConfirmNextCandle)
         {
            if(isHammer)
            {
               string n1 = dayPfx + "HAMMER_" + IntegerToString((long)tBarOpen);
               string n2 = n1 + "_T";
               if(ObjectFind(0, n1) < 0)
               {
                  ObjectCreate(0, n1, OBJ_ARROW_BUY, 0, tBarOpen, l - 10 * _Point);
                  ObjectSetInteger(0, n1, OBJPROP_COLOR, clrGreen);
                  ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
                  ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
                  ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
                  NotifySignal("HAMMER", tBarOpen);
               }
               if(InpHammerShowLabels) CreateOrUpdateText(n2, tBarOpen, l - 10 * _Point, "Hammer", clrGreen, ANCHOR_LEFT_LOWER);
            }
            if(isShoot)
            {
               string n1 = dayPfx + "SHOOT_" + IntegerToString((long)tBarOpen);
               string n2 = n1 + "_T";
               if(ObjectFind(0, n1) < 0)
               {
                  ObjectCreate(0, n1, OBJ_ARROW_SELL, 0, tBarOpen, h + 10 * _Point);
                  ObjectSetInteger(0, n1, OBJPROP_COLOR, clrRed);
                  ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
                  ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
                  ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
                  NotifySignal("SHOOTING", tBarOpen);
               }
               if(InpHammerShowLabels) CreateOrUpdateText(n2, tBarOpen, h + 10 * _Point, "Shooting", clrRed, ANCHOR_LEFT_UPPER);
            }
         }
         else
         {
            if(g_prev_hammer && isGreen && g_prev_hs_time != 0)
            {
               string n1 = dayPfx + "HAMMER_" + IntegerToString((long)g_prev_hs_time);
               string n2 = n1 + "_T";
               if(ObjectFind(0, n1) < 0)
               {
                  ObjectCreate(0, n1, OBJ_ARROW_BUY, 0, g_prev_hs_time, g_prev_hs_low - 10 * _Point);
                  ObjectSetInteger(0, n1, OBJPROP_COLOR, clrGreen);
                  ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
                  ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
                  ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
                  NotifySignal("HAMMER (confirmed)", tBarOpen);
               }
               if(InpHammerShowLabels) CreateOrUpdateText(n2, g_prev_hs_time, g_prev_hs_low - 10 * _Point, "Hammer", clrGreen, ANCHOR_LEFT_LOWER);
            }
            if(g_prev_shoot && isRed && g_prev_hs_time != 0)
            {
               string n1 = dayPfx + "SHOOT_" + IntegerToString((long)g_prev_hs_time);
               string n2 = n1 + "_T";
               if(ObjectFind(0, n1) < 0)
               {
                  ObjectCreate(0, n1, OBJ_ARROW_SELL, 0, g_prev_hs_time, g_prev_hs_high + 10 * _Point);
                  ObjectSetInteger(0, n1, OBJPROP_COLOR, clrRed);
                  ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
                  ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
                  ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
                  NotifySignal("SHOOTING (confirmed)", tBarOpen);
               }
               if(InpHammerShowLabels) CreateOrUpdateText(n2, g_prev_hs_time, g_prev_hs_high + 10 * _Point, "Shooting", clrRed, ANCHOR_LEFT_UPPER);
            }
         }

         if(InpHammerFibRetraceEnabled)
         {
            bool createFib = false;
            int dir = 0;
            datetime pTime = 0;
            double pHigh = 0.0;
            double pLow = 0.0;
            datetime expiry = 0;

            if(!InpHammerConfirmNextCandle)
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
               if(g_prev_hammer && isGreen && g_prev_hs_time != 0)
               {
                  createFib = true;
                  dir = 1;
                  pTime = g_prev_hs_time;
                  pHigh = g_prev_hs_high;
                  pLow = g_prev_hs_low;
                  expiry = tBarOpen;
               }
               else if(g_prev_shoot && isRed && g_prev_hs_time != 0)
               {
                  createFib = true;
                  dir = -1;
                  pTime = g_prev_hs_time;
                  pHigh = g_prev_hs_high;
                  pLow = g_prev_hs_low;
                  expiry = tBarOpen;
               }
            }

            if(createFib && pHigh > pLow && pTime != 0)
            {
               DeleteByToken("HSFIB_");
               double rng = pHigh - pLow;
               double lv0 = pLow;
               double lv1 = pHigh;
               double lv0382 = pLow + 0.382 * rng;
               double lv05 = pLow + 0.5 * rng;

               string fp = dayPfx + "HSFIB_";
               CreateOrUpdateRay(fp + "0", pTime, lv0, clrSilver, STYLE_SOLID, 1);
               CreateOrUpdateRay(fp + "1", pTime, lv1, clrSilver, STYLE_SOLID, 1);
               if(InpHammerFibUse0382) CreateOrUpdateRay(fp + "0382", pTime, lv0382, clrOrange, STYLE_SOLID, 2);
               if(InpHammerFibUse05) CreateOrUpdateRay(fp + "05", pTime, lv05, clrLimeGreen, STYLE_SOLID, 2);
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
                  string n1 = dayPfx + (isBuySig ? "SIG_FIB_BUY_" : "SIG_FIB_SELL_") + IntegerToString((long)tBarOpen);
                  string n2 = n1 + "_T";
                  if(ObjectFind(0, n1) < 0)
                  {
                     ObjectCreate(0, n1, isBuySig ? OBJ_ARROW_BUY : OBJ_ARROW_SELL, 0, tBarOpen, isBuySig ? (l - 12 * _Point) : (h + 12 * _Point));
                     ObjectSetInteger(0, n1, OBJPROP_COLOR, isBuySig ? InpBuyColor : InpSellColor);
                     ObjectSetInteger(0, n1, OBJPROP_WIDTH, 1);
                     ObjectSetInteger(0, n1, OBJPROP_SELECTABLE, false);
                     ObjectSetInteger(0, n1, OBJPROP_HIDDEN, false);
                  }
                  CreateOrUpdateText(n2, tBarOpen, isBuySig ? (l - 12 * _Point) : (h + 12 * _Point), isBuySig ? "BUY" : "SELL", isBuySig ? InpBuyColor : InpSellColor, isBuySig ? ANCHOR_LEFT_LOWER : ANCHOR_LEFT_UPPER);
                  NotifySignal(isBuySig ? "FIB BUY (Hammer)" : "FIB SELL (Shooting)", tBarOpen);
                  g_hsfib_pending = false;
               }
               else
               {
                  DeleteByToken("HSFIB_");
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
               DeleteByToken("HSFIB_");
               g_hsfib_pending = false;
               g_hsfib_dir = 0;
               g_hsfib_pattern_time = 0;
               g_hsfib_high = 0.0;
               g_hsfib_low = 0.0;
               g_hsfib_expiry = 0;
            }
         }

         g_prev_hammer = isHammer;
         g_prev_shoot = isShoot;
         g_prev_hs_time = tBarOpen;
         g_prev_hs_high = h;
         g_prev_hs_low = l;
      }

      if(showOther && InpShowSignals && g_ib_has && g_h13_has)
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

      if(showOther && InpShowSignals && InpMidnightSignalsEnabled && g_mid_has && g_ib_has)
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
      if(showOther && isStar13)
      {
         string n = (g_prefix + IntegerToString(g_day_key) + "_") + "STAR_13_" + IntegerToString((long)tBarOpen);
         CreateOrUpdateText(n, tBarOpen, l - 14 * _Point, "★", clrYellow, ANCHOR_LEFT_LOWER);
      }
      if(showOther && isStar16)
      {
         string n = (g_prefix + IntegerToString(g_day_key) + "_") + "STAR_16_" + IntegerToString((long)tBarOpen);
         CreateOrUpdateText(n, tBarOpen, l - 14 * _Point, "★", clrYellow, ANCHOR_LEFT_LOWER);
      }

      bool runLux = InpLuxSwingEnabled && (showOther || InpLuxNotifySwings || InpLuxNotifyPatterns);
      if(runLux)
      {
         int len = InpLuxSwingLength;
         if(len < 1) len = 1;
         if((2 * len + 1) < LUX_CAP)
         {
            LuxPushBar(tBarOpen, o, h, l, c);
            if(g_lux_count >= (2 * len + 1))
            {
               int centerOff = len;
               int centerIdx = LuxIdx(centerOff);
               double oC = g_lux_open[centerIdx];
               double hC = g_lux_high[centerIdx];
               double lC = g_lux_low[centerIdx];
               double cC = g_lux_close[centerIdx];

               bool ph = true;
               for(int off = 0; off <= 2 * len; off++)
               {
                  if(off == centerOff) continue;
                  if(g_lux_high[LuxIdx(off)] >= hC) { ph = false; break; }
               }
               bool pl = true;
               for(int off = 0; off <= 2 * len; off++)
               {
                  if(off == centerOff) continue;
                  if(g_lux_low[LuxIdx(off)] <= lC) { pl = false; break; }
               }

               if(ph || pl)
               {
                  int prevIdx = LuxIdx(centerOff + 1);
                  double oP = g_lux_open[prevIdx];
                  double cP = g_lux_close[prevIdx];
                  double d = MathAbs(cC - oC);

                  bool hammer = (pl && (MathMin(oC, cC) - lC > d) && (hC - MathMax(cC, oC) < d));
                  bool ihammer = (pl && (hC - MathMax(cC, oC) > d) && (MathMin(cC, oC) - lC < d));
                  bool bulleng = (cC > oC && cP < oP && cC > oP && oC < cP);
                  bool hanging = (ph && (MathMin(cC, oC) - lC > d) && (hC - MathMax(oC, cC) < d));
                  bool shooting = (ph && (hC - MathMax(oC, cC) > d) && (MathMin(cC, oC) - lC < d));
                  bool beareng = (cC > oC && cP < oP && cC > oP && oC < cP);

                  int pattCode = 0;
                  string patt = "None";
                  if(hammer) { patt = "Hammer"; pattCode = 1; }
                  else if(ihammer) { patt = "Inverted Hammer"; pattCode = 2; }
                  else if(bulleng) { patt = "Bullish Engulfing"; pattCode = 3; }
                  else if(hanging) { patt = "Hanging Man"; pattCode = 4; }
                  else if(shooting) { patt = "Shooting Star"; pattCode = 5; }
                  else if(beareng) { patt = "Bearish Engulfing"; pattCode = 6; }

                  bool pattAllowed = true;
                  if(pattCode == 0) pattAllowed = InpLuxNotifyNone;
                  else if(pattCode == 1) pattAllowed = InpLuxNotifyHammer;
                  else if(pattCode == 2) pattAllowed = InpLuxNotifyInvertedHammer;
                  else if(pattCode == 3) pattAllowed = InpLuxNotifyBullishEngulfing;
                  else if(pattCode == 4) pattAllowed = InpLuxNotifyHangingMan;
                  else if(pattCode == 5) pattAllowed = InpLuxNotifyShootingStar;
                  else if(pattCode == 6) pattAllowed = InpLuxNotifyBearishEngulfing;

                  datetime tPivot = g_lux_time[centerIdx];
                  int dk = DayKeyLocal(tPivot);

                  if(ph && tPivot != g_lux_last_notified_ph)
                  {
                     string hh = (!g_lux_phy_has || hC > g_lux_phy) ? "HH" : "LH";
                     g_lux_phy = hC;
                     g_lux_phy_has = true;
                     string pattLbl = (InpLuxNotifyPatterns && pattAllowed) ? patt : "";
                     string txt = (pattLbl == "" ? hh : (hh + "\n" + pattLbl));
                     string name = g_prefix + IntegerToString(dk) + "_LUX_PH_" + IntegerToString((long)tPivot);
                     if(showOther && InpLuxSwingShowLabels) CreateOrUpdateText(name, tPivot, hC, txt, InpLuxSwingHighColor, ANCHOR_LEFT_UPPER);
                     if(InpLuxNotifySwings) NotifySignal("LUX SWING " + hh, tBarOpen);
                     if(InpLuxNotifyPatterns && pattAllowed) NotifySignal("LUX " + hh + " " + patt, tBarOpen);
                     g_lux_last_notified_ph = tPivot;
                  }
                  else if(pl && tPivot != g_lux_last_notified_pl)
                  {
                     string ll = (!g_lux_ply_has || lC < g_lux_ply) ? "LL" : "HL";
                     g_lux_ply = lC;
                     g_lux_ply_has = true;
                     string pattLbl = (InpLuxNotifyPatterns && pattAllowed) ? patt : "";
                     string txt = (pattLbl == "" ? ll : (ll + "\n" + pattLbl));
                     string name = g_prefix + IntegerToString(dk) + "_LUX_PL_" + IntegerToString((long)tPivot);
                     if(showOther && InpLuxSwingShowLabels) CreateOrUpdateText(name, tPivot, lC, txt, InpLuxSwingLowColor, ANCHOR_LEFT_LOWER);
                     if(InpLuxNotifySwings) NotifySignal("LUX SWING " + ll, tBarOpen);
                     if(InpLuxNotifyPatterns && pattAllowed) NotifySignal("LUX " + ll + " " + patt, tBarOpen);
                     g_lux_last_notified_pl = tPivot;
                  }
               }
            }
         }
      }
      else
      {
         LuxReset();
      }

      if(showOther && InpInstSweepEnabled)
      {
         const int lbLeft = 20;
         const int lbRight = 20;
         const int win = lbLeft + lbRight + 1;
         if(win < INST_CAP)
         {
            InstPushBar(tBarOpen, o, h, l, c);
            if(g_inst_count >= win)
            {
               int centerOff = lbRight;
               int centerIdx = InstIdx(centerOff);
               double lowC = g_inst_low[centerIdx];
               double highC = g_inst_high[centerIdx];

               bool pLow = true;
               for(int off = 0; off < win; off++)
               {
                  if(off == centerOff) continue;
                  if(g_inst_low[InstIdx(off)] <= lowC) { pLow = false; break; }
               }
               bool pHigh = true;
               for(int off = 0; off < win; off++)
               {
                  if(off == centerOff) continue;
                  if(g_inst_high[InstIdx(off)] >= highC) { pHigh = false; break; }
               }

               if(pLow) { g_inst_pLowVal = lowC; g_inst_pLowHas = true; }
               if(pHigh) { g_inst_pHighVal = highC; g_inst_pHighHas = true; }
               if(pLow) { g_inst_swing_low = lowC; g_inst_swing_low_has = true; }
               if(pHigh) { g_inst_swing_high = highC; g_inst_swing_high_has = true; }
            }

            if(g_inst_swing_high_has || g_inst_swing_low_has)
            {
               double epsTouch = _Point * 0.1;
               double prevH = h;
               double prevL = l;
               if(g_inst_count >= 2)
               {
                  prevH = g_inst_high[InstIdx(1)];
                  prevL = g_inst_low[InstIdx(1)];
               }

               if(g_inst_swing_high_has && prevH < (g_inst_swing_high - epsTouch) && h >= (g_inst_swing_high - epsTouch) && g_inst_last_touch_high_time != tBarOpen)
               {
                  NotifySignal("INST TOUCH Swing H", tBarOpen);
                  g_inst_last_touch_high_time = tBarOpen;
               }
               if(g_inst_swing_low_has && prevL > (g_inst_swing_low + epsTouch) && l <= (g_inst_swing_low + epsTouch) && g_inst_last_touch_low_time != tBarOpen)
               {
                  NotifySignal("INST TOUCH Swing L", tBarOpen);
                  g_inst_last_touch_low_time = tBarOpen;
               }
            }

            if(g_inst_pLowHas || g_inst_pHighHas)
            {
               double lp = g_inst_low[InstIdx(0)];
               double hp = g_inst_high[InstIdx(0)];
               double lowestClose = g_inst_close[InstIdx(0)];
               double highestClose = g_inst_close[InstIdx(0)];
               for(int off = 1; off < lbLeft && off < g_inst_count; off++)
               {
                  double lo2 = g_inst_low[InstIdx(off)];
                  double hi2 = g_inst_high[InstIdx(off)];
                  double c2 = g_inst_close[InstIdx(off)];
                  if(lo2 < lp) lp = lo2;
                  if(hi2 > hp) hp = hi2;
                  if(c2 < lowestClose) lowestClose = c2;
                  if(c2 > highestClose) highestClose = c2;
               }

               double eps = _Point * 0.1;
               bool lowIsLp = (MathAbs(l - lp) <= eps);
               bool highIsHp = (MathAbs(h - hp) <= eps);

               bool bullishSfp = g_inst_pLowHas && (l < g_inst_pLowVal) && (c > g_inst_pLowVal) && (o > g_inst_pLowVal) && lowIsLp && (lowestClose >= g_inst_pLowVal);
               bool bearishSfp = g_inst_pHighHas && (h > g_inst_pHighVal) && (c < g_inst_pHighVal) && (o < g_inst_pHighVal) && highIsHp && (highestClose <= g_inst_pHighVal);

               int cd = InpInstCooldownPeriod;
               if(cd < 0) cd = 0;

               if(bullishSfp && g_update_calls >= (g_inst_last_bull_index + cd))
               {
                  string name = (g_prefix + IntegerToString(g_day_key) + "_") + "INST_SWEEP_L_" + IntegerToString((long)tBarOpen);
                  CreateOrUpdateText(name, tBarOpen, l - 10 * _Point, "Sweep", InpInstBullColor, ANCHOR_LEFT_LOWER);
                  NotifySignal("Bullish Sweep", tBarOpen);
                  g_inst_last_bull_index = g_update_calls;
               }
               if(bearishSfp && g_update_calls >= (g_inst_last_bear_index + cd))
               {
                  string name = (g_prefix + IntegerToString(g_day_key) + "_") + "INST_SWEEP_H_" + IntegerToString((long)tBarOpen);
                  CreateOrUpdateText(name, tBarOpen, h + 10 * _Point, "Sweep", InpInstBearColor, ANCHOR_LEFT_UPPER);
                  NotifySignal("Bearish Sweep", tBarOpen);
                  g_inst_last_bear_index = g_update_calls;
               }
            }
         }
      }
      else
      {
         InstReset();
      }

      if(InpEarlySwingEnabled || InpSwingPatternEnabled)
      {
         int shift = iBarShift(_Symbol, _Period, tBarOpen, true);
         long vCur = 0;
         if(shift >= 0) vCur = (long)iVolume(_Symbol, _Period, shift);
         EsPushBar(tBarOpen, o, h, l, c, vCur);

         if(InpSwingRequireReclaimAfterSweep && g_es_count >= 2)
         {
            double prevC = g_es_close[EsIdx(1)];
            double curC = g_es_close[EsIdx(0)];
            if(!g_swing_allow_sl && g_swing_last_bull_sweep_level > 0.0 && prevC <= g_swing_last_bull_sweep_level && curC > g_swing_last_bull_sweep_level)
               g_swing_allow_sl = true;
            if(!g_swing_allow_sh && g_swing_last_bear_sweep_level > 0.0 && prevC >= g_swing_last_bear_sweep_level && curC < g_swing_last_bear_sweep_level)
               g_swing_allow_sh = true;
         }

         if(InpSwingPatternEnabled && InpSwingRequireOppositeSwingSweep)
         {
            double buf = (double)InpSwingOppositeSwingSweepBufferPoints * _Point;
            if(g_liq_last_sl_has && !g_liq_opp_swept_for_sh && l < (g_liq_last_sl_price - buf))
               g_liq_opp_swept_for_sh = true;
            if(g_liq_last_sh_has && !g_liq_opp_swept_for_sl && h > (g_liq_last_sh_price + buf))
               g_liq_opp_swept_for_sl = true;
         }

         int dk = DayKeyLocal(tBarOpen);
         string dayPfx = g_prefix + IntegerToString(dk) + "_";

         if(showOther && InpEarlySwingEnabled)
         {
            int lbLeft = InpEarlyLeftBars;
            int lbRight = InpEarlyRightBars;
            if(lbLeft < 1) lbLeft = 1;
            if(lbRight < 1) lbRight = 1;

            int volLen = 20;
            int nVol = MathMin(volLen, g_es_count);
            double avgVol = 0.0;
            for(int i = 0; i < nVol; i++) avgVol += (double)g_es_vol[EsIdx(i)];
            if(nVol > 0) avgVol /= (double)nVol;
            bool strongVol = ((double)vCur > avgVol);

            double eps = _Point * 0.1;
            double prevLow = (g_es_count >= 2 ? g_es_low[EsIdx(1)] : l);
            double prevHigh = (g_es_count >= 2 ? g_es_high[EsIdx(1)] : h);

            int look = MathMin(lbLeft + 1, g_es_count);
            double minLow = l;
            double maxHigh = h;
            for(int i = 0; i < look; i++)
            {
               double lo2 = g_es_low[EsIdx(i)];
               double hi2 = g_es_high[EsIdx(i)];
               if(lo2 < minLow) minLow = lo2;
               if(hi2 > maxHigh) maxHigh = hi2;
            }

            bool potentialLow = (l <= (minLow + eps));
            bool liquiditySweepLow = (l < prevLow && c > prevLow);
            bool bullReaction = (c > o);
            bool passEarlyLow = true;
            if(InpEarlyShowDailyExtremeShSl)
            {
               double bufDaily = (double)InpEarlyDailyExtremeBufferPoints * _Point;
               passEarlyLow = (g_daily_has && bufDaily >= 0.0 && MathAbs(l - g_daily_low) <= bufDaily);
            }
            bool earlyLow = (potentialLow && liquiditySweepLow && bullReaction && (!InpEarlyVolFilter || strongVol) && passEarlyLow);

            bool potentialHigh = (h >= (maxHigh - eps));
            bool liquiditySweepHigh = (h > prevHigh && c < prevHigh);
            bool bearReaction = (c < o);
            bool passEarlyHigh = true;
            if(InpEarlyShowDailyExtremeShSl)
            {
               double bufDaily = (double)InpEarlyDailyExtremeBufferPoints * _Point;
               passEarlyHigh = (g_daily_has && bufDaily >= 0.0 && MathAbs(h - g_daily_high) <= bufDaily);
            }
            bool earlyHigh = (potentialHigh && liquiditySweepHigh && bearReaction && (!InpEarlyVolFilter || strongVol) && passEarlyHigh);

            if(earlyLow && g_es_last_early_low_time != tBarOpen)
            {
               string n = dayPfx + "ES_EARLY_SWL_" + IntegerToString((long)tBarOpen);
               CreateOrUpdateText(n, tBarOpen, l - 10 * _Point, "Possible SWL", clrYellow, ANCHOR_LEFT_LOWER);
               NotifySignal("Early Swing Low", tBarOpen);
               g_es_last_early_low_time = tBarOpen;
            }
            if(earlyHigh && g_es_last_early_high_time != tBarOpen)
            {
               string n = dayPfx + "ES_EARLY_SWH_" + IntegerToString((long)tBarOpen);
               CreateOrUpdateText(n, tBarOpen, h + 10 * _Point, "Possible SWH", clrYellow, ANCHOR_LEFT_UPPER);
               NotifySignal("Early Swing High", tBarOpen);
               g_es_last_early_high_time = tBarOpen;
            }
         }

         if(InpSwingPatternEnabled)
         {
            int left = InpSwingLeftBars;
            int right = InpSwingRightBars;
            if(InpSwingUseTfBars)
            {
               if(_Period == PERIOD_M1) { left = InpSwingLeftBars_M1; right = InpSwingRightBars_M1; }
               else if(_Period == PERIOD_M15) { left = InpSwingLeftBars_M15; right = InpSwingRightBars_M15; }
               else if(_Period == PERIOD_H1) { left = InpSwingLeftBars_H1; right = InpSwingRightBars_H1; }
               else if(_Period == PERIOD_H4) { left = InpSwingLeftBars_H4; right = InpSwingRightBars_H4; }
            }
            if(left < 1) left = 1;
            if(right < 1) right = 1;

            int win = left + right + 1;
            if(win < ES_CAP && g_es_count >= win)
            {
               double epsSwing = _Point * 0.1;
               double sepSwing = (double)InpSwingMinReactionSepPoints * _Point;
               double minSwingRange = (double)InpSwingMinSwingRangePoints * _Point;
               int centerOff = right;
               int centerIdx = EsIdx(centerOff);
               double hC = g_es_high[centerIdx];
               double lC = g_es_low[centerIdx];

               bool sh = true;
               for(int off = 0; off < win; off++)
               {
                  if(off == centerOff) continue;
                  if(g_es_high[EsIdx(off)] >= hC) { sh = false; break; }
               }
               if(!InpSwingUseInstitutionalSwings)
               {
                  for(int k = left; sh && k >= 1; k--)
                  {
                     if(g_es_high[EsIdx(centerOff + k)] >= g_es_high[EsIdx(centerOff + k - 1)]) { sh = false; break; }
                  }
                  for(int k = 1; sh && k <= right; k++)
                  {
                     if(g_es_high[EsIdx(centerOff - k)] >= g_es_high[EsIdx(centerOff - k + 1)]) { sh = false; break; }
                  }
               }
               if(sh)
               {
                  int reactIdx = EsIdx(centerOff - 1);
                  if(!(g_es_close[reactIdx] < g_es_open[reactIdx])) sh = false;
                  if(sh && !(g_es_high[reactIdx] < (hC - sepSwing))) sh = false;
                  if(sh && !(g_es_open[reactIdx] < (hC - sepSwing))) sh = false;
                  if(sh && !(g_es_close[reactIdx] < (hC - sepSwing))) sh = false;
                  if(sh && minSwingRange > 0.0 && !((hC - lC) >= minSwingRange)) sh = false;
                  if(sh && InpSwingConfirmBos)
                  {
                     int newest = EsIdx(0);
                     if(!(g_es_close[newest] < g_es_low[reactIdx])) sh = false;
                  }
               }

               bool sl = true;
               for(int off = 0; off < win; off++)
               {
                  if(off == centerOff) continue;
                  if(g_es_low[EsIdx(off)] <= lC) { sl = false; break; }
               }
               if(!InpSwingUseInstitutionalSwings)
               {
                  for(int k = left; sl && k >= 1; k--)
                  {
                     if(g_es_low[EsIdx(centerOff + k)] <= g_es_low[EsIdx(centerOff + k - 1)]) { sl = false; break; }
                  }
                  for(int k = 1; sl && k <= right; k++)
                  {
                     if(g_es_low[EsIdx(centerOff - k)] <= g_es_low[EsIdx(centerOff - k + 1)]) { sl = false; break; }
                  }
               }
               if(sl)
               {
                  int reactIdx = EsIdx(centerOff - 1);
                  if(!(g_es_close[reactIdx] > g_es_open[reactIdx])) sl = false;
                  if(sl && !(g_es_low[reactIdx] > (lC + sepSwing))) sl = false;
                  if(sl && !(g_es_open[reactIdx] > (lC + sepSwing))) sl = false;
                  if(sl && !(g_es_close[reactIdx] > (lC + sepSwing))) sl = false;
                  if(sl && minSwingRange > 0.0 && !((hC - lC) >= minSwingRange)) sl = false;
                  if(sl && InpSwingConfirmBos)
                  {
                     int newest = EsIdx(0);
                     if(!(g_es_close[newest] > g_es_high[reactIdx])) sl = false;
                  }
               }

               datetime tPivot = g_es_time[centerIdx];
               bool passOppForSh = true;
               if(InpSwingRequireOppositeSwingSweep)
                  passOppForSh = (g_liq_last_sl_has && g_liq_opp_swept_for_sh);
               bool requireAnySessionSweep = (InpSwingRequireH13L13Sweep || InpSwingRequireAsiaSweep || InpSwingRequireIBSweep);
               bool passSessionSh = (!requireAnySessionSweep) ||
                  (InpSwingRequireH13L13Sweep && g_h13_has && g_kiss_swept_l) ||
                  (InpSwingRequireAsiaSweep && g_swing_asia_swept_h) ||
                  (InpSwingRequireIBSweep && g_swing_ib_swept_h);

               bool passDailySh = true;
               if(InpSwingShowDailyExtremeShSl)
               {
                  double buf = (double)InpSwingDailyExtremeBufferPoints * _Point;
                  passDailySh = (g_daily_has && buf >= 0.0 && MathAbs(hC - g_daily_high) <= buf);
               }

               if(sh && passOppForSh && passSessionSh && passDailySh && (!InpSwingRequireReclaimAfterSweep || g_swing_allow_sh) && g_es_last_sp_sh_time != tPivot)
               {
                  datetime prevShTime = g_swing_last_sh_time;
                  double prevShPrice = g_swing_last_sh_price;
                  double prevShRsi = g_swing_last_sh_rsi;
                  bool prevShHas = g_swing_last_sh_has;

                  double rsiPivot = 0.0;
                  bool hasRsi = (InpSwingBullDivEnabled && GetRsiAtTime(tPivot, rsiPivot));
                  bool bearDiv = false;
                  if(hasRsi && prevShHas && hC > prevShPrice && rsiPivot < (prevShRsi - InpSwingDivMinRsiDelta) && (!InpSwingDivUseRsiThresholds || prevShRsi >= InpSwingDivBearPrevRsiMin))
                     bearDiv = true;

                  if(hasRsi)
                  {
                     g_swing_last_sh_has = true;
                     g_swing_last_sh_price = hC;
                     g_swing_last_sh_rsi = rsiPivot;
                     g_swing_last_sh_time = tPivot;
                  }

                  if(bearDiv && InpSwingShowDiv)
                  {
                     string nDiv = dayPfx + "SP_DIVH_" + IntegerToString((long)tPivot);
                     CreateOrUpdateText(nDiv, tPivot, hC + 20 * _Point, "DIV", clrFuchsia, ANCHOR_LEFT_UPPER);
                  }
                  if(bearDiv && prevShHas && prevShTime != 0)
                  {
                     string nLn = dayPfx + "SP_DIVH_LN_" + IntegerToString((long)tPivot);
                     CreateOrUpdateTrendSegment(nLn, prevShTime, prevShPrice, tPivot, hC, clrFuchsia, STYLE_SOLID, 2);
                     NotifySignal("DIV", tBarOpen);
                  }

                  if(InpSwingShowLabels)
                  {
                     string n = dayPfx + "SP_SH_" + IntegerToString((long)tPivot);
                     CreateOrUpdateText(n, tPivot, hC + 10 * _Point, "SH", clrRed, ANCHOR_LEFT_UPPER);
                  }
                  NotifySignal("SH", tBarOpen);
                  g_es_last_sp_sh_time = tPivot;

                  g_liq_last_sh_has = true;
                  g_liq_last_sh_price = hC;
                  g_liq_last_sh_time = tPivot;
                  g_liq_opp_swept_for_sl = false;
               }
               bool passOppForSl = true;
               if(InpSwingRequireOppositeSwingSweep)
                  passOppForSl = (g_liq_last_sh_has && g_liq_opp_swept_for_sl);
               bool passSessionSl = (!requireAnySessionSweep) ||
                  (InpSwingRequireH13L13Sweep && g_h13_has && g_kiss_swept_h) ||
                  (InpSwingRequireAsiaSweep && g_swing_asia_swept_l) ||
                  (InpSwingRequireIBSweep && g_swing_ib_swept_l);

               bool passDailySl = true;
               if(InpSwingShowDailyExtremeShSl)
               {
                  double buf = (double)InpSwingDailyExtremeBufferPoints * _Point;
                  passDailySl = (g_daily_has && buf >= 0.0 && MathAbs(lC - g_daily_low) <= buf);
               }

               if(sl && passOppForSl && passSessionSl && passDailySl && (!InpSwingRequireReclaimAfterSweep || g_swing_allow_sl) && g_es_last_sp_sl_time != tPivot)
               {
                  datetime prevSlTime = g_swing_last_sl_time;
                  double prevSlPrice = g_swing_last_sl_price;
                  double prevSlRsi = g_swing_last_sl_rsi;
                  bool prevSlHas = g_swing_last_sl_has;

                  double rsiPivot = 0.0;
                  bool hasRsi = (InpSwingBullDivEnabled && GetRsiAtTime(tPivot, rsiPivot));
                  bool bullDiv = false;
                  if(hasRsi && prevSlHas && lC < prevSlPrice && rsiPivot > (prevSlRsi + InpSwingDivMinRsiDelta) && (!InpSwingDivUseRsiThresholds || prevSlRsi <= InpSwingDivBullPrevRsiMax))
                     bullDiv = true;

                  if(hasRsi)
                  {
                     g_swing_last_sl_has = true;
                     g_swing_last_sl_price = lC;
                     g_swing_last_sl_rsi = rsiPivot;
                     g_swing_last_sl_time = tPivot;
                  }

                  if(bullDiv && InpSwingShowDiv)
                  {
                     string nDiv = dayPfx + "SP_DIV_" + IntegerToString((long)tPivot);
                     CreateOrUpdateText(nDiv, tPivot, lC - 20 * _Point, "DIV", clrAqua, ANCHOR_LEFT_LOWER);
                  }
                  if(bullDiv && prevSlHas && prevSlTime != 0)
                  {
                     string nLn = dayPfx + "SP_DIV_LN_" + IntegerToString((long)tPivot);
                     CreateOrUpdateTrendSegment(nLn, prevSlTime, prevSlPrice, tPivot, lC, clrAqua, STYLE_SOLID, 2);
                     NotifySignal("DIV", tBarOpen);
                  }

                  if(InpSwingShowLabels)
                  {
                     string n = dayPfx + "SP_SL_" + IntegerToString((long)tPivot);
                     CreateOrUpdateText(n, tPivot, lC - 10 * _Point, "SL", clrLimeGreen, ANCHOR_LEFT_LOWER);
                  }
                  NotifySignal("SL", tBarOpen);
                  g_es_last_sp_sl_time = tPivot;

                  g_liq_last_sl_has = true;
                  g_liq_last_sl_price = lC;
                  g_liq_last_sl_time = tPivot;
                  g_liq_opp_swept_for_sh = false;
               }
            }
         }
      }
      else
      {
         EsReset();
      }

      if(InpMtfEntryEnabled && _Period == PERIOD_M1)
      {
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
         if(cPrev <= 0.0) cPrev = c;

         double buf = (double)InpMtfSweepBufferPoints * _Point;
         int look = MathMax(1, InpMtfSweepLookbackBars);

         if(g_mtf_buy_active)
         {
            if(g_mtfC_buy_struct_low <= 0.0 || l < g_mtfC_buy_struct_low) g_mtfC_buy_struct_low = l;

            if(InpMtfUseSetupA)
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
                     if(InpShowSignals)
                     {
                        string n = dayPfx + "MTF_BUY_A_" + IntegerToString((long)tBarOpen);
                        CreateOrUpdateText(n, tBarOpen, l - 12 * _Point, "BUY\nA", InpBuyColor, ANCHOR_LEFT_LOWER);
                     }
                     NotifySignal("BUY MTF A", tBarOpen);
                     g_mtf_buy_active = false;
                     g_mtf_buy_bars = 0;
                     g_mtfA_buy_state = 0;
                     g_mtfC_buy_state = 0;
                  }
               }
            }

            if(g_mtf_buy_active && InpMtfUseSetupB)
            {
               double lowestPrev = MtfLowestPrevLow(look);
               if(lowestPrev > 0.0 && l < (lowestPrev - buf) && c > lowestPrev)
               {
                  if(InpShowSignals)
                  {
                     string n = dayPfx + "MTF_BUY_B_" + IntegerToString((long)tBarOpen);
                     CreateOrUpdateText(n, tBarOpen, l - 12 * _Point, "BUY\nB", InpBuyColor, ANCHOR_LEFT_LOWER);
                  }
                  NotifySignal("BUY MTF B", tBarOpen);
                  g_mtf_buy_active = false;
                  g_mtf_buy_bars = 0;
                  g_mtfA_buy_state = 0;
                  g_mtfC_buy_state = 0;
               }
            }

            if(g_mtf_buy_active && InpMtfUseSetupC)
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
                        if(InpShowSignals)
                        {
                           string n = dayPfx + "MTF_BUY_C_" + IntegerToString((long)tBarOpen);
                           CreateOrUpdateText(n, tBarOpen, l - 12 * _Point, "BUY\nC", InpBuyColor, ANCHOR_LEFT_LOWER);
                        }
                        NotifySignal("BUY MTF C", tBarOpen);
                        g_mtf_buy_active = false;
                        g_mtf_buy_bars = 0;
                        g_mtfA_buy_state = 0;
                        g_mtfC_buy_state = 0;
                     }
                  }
               }
            }
         }

         if(g_mtf_sell_active)
         {
            if(g_mtfC_sell_struct_high <= 0.0 || h > g_mtfC_sell_struct_high) g_mtfC_sell_struct_high = h;

            if(InpMtfUseSetupA)
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
                     if(InpShowSignals)
                     {
                        string n = dayPfx + "MTF_SELL_A_" + IntegerToString((long)tBarOpen);
                        CreateOrUpdateText(n, tBarOpen, h + 12 * _Point, "SELL\nA", InpSellColor, ANCHOR_LEFT_UPPER);
                     }
                     NotifySignal("SELL MTF A", tBarOpen);
                     g_mtf_sell_active = false;
                     g_mtf_sell_bars = 0;
                     g_mtfA_sell_state = 0;
                     g_mtfC_sell_state = 0;
                  }
               }
            }

            if(g_mtf_sell_active && InpMtfUseSetupB)
            {
               double highestPrev = MtfHighestPrevHigh(look);
               if(highestPrev > 0.0 && h > (highestPrev + buf) && c < highestPrev)
               {
                  if(InpShowSignals)
                  {
                     string n = dayPfx + "MTF_SELL_B_" + IntegerToString((long)tBarOpen);
                     CreateOrUpdateText(n, tBarOpen, h + 12 * _Point, "SELL\nB", InpSellColor, ANCHOR_LEFT_UPPER);
                  }
                  NotifySignal("SELL MTF B", tBarOpen);
                  g_mtf_sell_active = false;
                  g_mtf_sell_bars = 0;
                  g_mtfA_sell_state = 0;
                  g_mtfC_sell_state = 0;
               }
            }

            if(g_mtf_sell_active && InpMtfUseSetupC)
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
                        if(InpShowSignals)
                        {
                           string n = dayPfx + "MTF_SELL_C_" + IntegerToString((long)tBarOpen);
                           CreateOrUpdateText(n, tBarOpen, h + 12 * _Point, "SELL\nC", InpSellColor, ANCHOR_LEFT_UPPER);
                        }
                        NotifySignal("SELL MTF C", tBarOpen);
                        g_mtf_sell_active = false;
                        g_mtf_sell_bars = 0;
                        g_mtfA_sell_state = 0;
                        g_mtfC_sell_state = 0;
                     }
                  }
               }
            }
         }
      }

      string st = "CAP_IND | it " + IntegerToString(MinuteOfDayLocal(tBarOpen) / 60) + ":" + IntegerToString(MinuteOfDayLocal(tBarOpen) % 60) +
                  " | daily " + (g_daily_has ? "Y" : "N") + " | h02 " + (g_h02_has ? "Y" : "N") + " | h13 " + (g_h13_has ? "Y" : "N");
      CreateOrUpdateStatusLabel(st);
      g_prev_bar_low = l;
      g_prev_bar_low_has = true;
   }

   int OnInit()
   {
      if(InpShowOnlySwingSignals) DeleteByPrefix(g_prefix);
      CreateOrUpdateStatusLabel("CAP_IND loaded");
      UpdateChartComment("CAP_IND loaded");
      if(g_rsi_handle != INVALID_HANDLE) IndicatorRelease(g_rsi_handle);
      g_rsi_handle = iRSI(_Symbol, _Period, InpSwingRsiLen, PRICE_CLOSE);
      DeleteByToken("TEST_");
      DeleteByToken("LUX_");
      LuxReset();
   DeleteByToken("INST_");
   InstReset();
      DeleteByToken("ES_");
      EsReset();
      if(InpDebugOverlay && !InpShowOnlySwingSignals)
      {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(bid > 0.0) CreateOrUpdateText(g_prefix + "PING", TimeCurrent(), bid, "CAP_IND", clrYellow, ANCHOR_LEFT_UPPER);
      }
      ChartRedraw(0);
      return(INIT_SUCCEEDED);
   }

   void OnDeinit(const int reason)
   {
      if(g_rsi_handle != INVALID_HANDLE)
      {
         IndicatorRelease(g_rsi_handle);
         g_rsi_handle = INVALID_HANDLE;
      }
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
      DeleteByToken("TEST_");

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
         DeleteByToken("LUX_");
         LuxReset();
        DeleteByToken("INST_");
        InstReset();
         DeleteByToken("ES_");
         EsReset();

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
         if(InpDebugOverlay && !InpShowOnlySwingSignals)
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
         }
         if(IsLocalTime(time[curIdx], 2, 0))
         {
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
      if(InpDebugOverlay && !InpShowOnlySwingSignals)
      {
         CreateOrUpdateText(g_prefix + "PING", time[curIdx], close[curIdx], "CAP_IND", clrYellow, ANCHOR_LEFT_UPPER);
      }
      return rates_total;
   }
