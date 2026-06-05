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
   input bool InpNotifyOnlyBelugaSwing = true;
   input bool InpNotifyOnlySHSL = false;
   input bool InpNotifyOnlyQmEntryTouch = false;
input bool InpNotifyDiv = false;
input bool InpNotifyLux = false;
input bool InpNotifyMtf = false;
input bool InpNotifyDailyTouch = false;
input bool InpNotifyRsiCross = false;
input bool InpNotifyQm = false;
input bool InpNotifyStAi = false;
input bool InpNotifyBelugaSwing = true;
   input bool InpDailyTouchOncePerDay = true;

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
   input bool InpKissSignalsEnabled = true;
   input bool InpBuySellSignalsEnabled = true;

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
input bool InpSwingOverHighH13Enabled = false;
input int InpSwingOverHighH13BufferPoints = 0;
input bool InpSwingShowDailyExtremeShSl = false;
input int InpSwingDailyExtremeBufferPoints = 0;
input bool InpSwingShowSessionExtremeShSl = false;
input bool InpSwingSessionUseAsia = true;
input bool InpSwingSessionUseLondon = true;
input bool InpSwingSessionUseNy = true;
input int InpSwingSessionExtremeBufferPoints = 0;
input int InpSwingMinSwingRangePoints = 0;
input int InpSwingMinReactionSepPoints = 1;
input bool InpSwingConfirmBos = true;
input bool InpSwingBullDivEnabled = true;
input int InpSwingRsiLen = 14;
enum ENUM_SWING_RSI_MODE
{
   SWING_RSI_AGGRESSIVE = 0,
   SWING_RSI_CONSERVATIVE = 1
};
input bool InpSwingRsiFilterEnabled = false;
input ENUM_SWING_RSI_MODE InpSwingRsiMode = SWING_RSI_CONSERVATIVE;
input int InpSwingRsiBuyAgg = 30;
input int InpSwingRsiBuyCons = 40;
input int InpSwingRsiSellAgg = 70;
input int InpSwingRsiSellCons = 60;
enum ENUM_RSI_MA_TYPE
{
   RSI_MA_SMA = 0,
   RSI_MA_EMA = 1
};
input bool InpSwingRsiMaCrossEnabled = false;
input ENUM_RSI_MA_TYPE InpSwingRsiMaType = RSI_MA_SMA;
input int InpSwingRsiMaLen = 14;
input bool InpSwingMacdConfirmEnabled = false;
input bool InpSwingShowDiv = true;
input bool InpSwingDivUseRsiThresholds = true;
input double InpSwingDivBullPrevRsiMax = 40.0;
input double InpSwingDivBearPrevRsiMin = 60.0;
input double InpSwingDivMinRsiDelta = 0.0;
input bool InpSwingDivShowDailyExtreme = true;
input int InpSwingDivDailyExtremeBufferPoints = 0;

input group "RSI Cross"
input bool InpRsiCrossEnabled = true;
input bool InpRsiCrossShowLabels = true;
input ENUM_RSI_MA_TYPE InpRsiCrossMaType = RSI_MA_SMA;
input int InpRsiCrossMaLen = 14;
input bool InpRsiCrossUseDailyExtreme = true;
input int InpRsiCrossDailyExtremeBufferPoints = 0;
input bool InpRsiCrossUseSessionExtreme = true;
input bool InpRsiCrossSessionUseAsia = true;
input bool InpRsiCrossSessionUseLondon = true;
input bool InpRsiCrossSessionUseNy = true;
input int InpRsiCrossSessionExtremeBufferPoints = 0;

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

input group "Quasimodo (QM)"
input bool InpQmEnabled = true;
input bool InpQmOnlyMode = false;
input bool InpQmShowShSl = false;
input bool InpQmShowDaily = true;
input bool InpQmShowSessions = false;
input bool InpQmUseTfPivots = true;
input int InpQmPivotFallback = 5;
input int InpQmPivot_M1 = 5;
input int InpQmPivot_M5 = 5;
input int InpQmPivot_M15 = 5;
input int InpQmPivot_H1 = 5;
input int InpQmPivot_H4 = 5;
input bool InpQmLiveEnabled = true;
input int InpQmLivePoints = 6;
input bool InpQmLiveToCurrent = true;
input color InpQmLiveColorW = clrLimeGreen;
input color InpQmLiveColorM = clrRed;
input int InpQmLiveWidth = 2;
input bool InpQmNotifyEntryTouch = true;
input bool InpQmNotifyOncePerSetup = true;

input group "SuperTrend AI (Clustering)"
input bool InpStAiEnabled = true;
input int InpStAiMinScore = 2;
input int InpStAiAtrLen = 10;
input int InpStAiMinMult = 1;
input int InpStAiMaxMult = 5;
input double InpStAiStep = 0.5;
input double InpStAiPerfAlpha = 10.0;
enum ENUM_STAI_CLUSTER { STAI_CLUSTER_BEST = 0, STAI_CLUSTER_AVERAGE = 1, STAI_CLUSTER_WORST = 2 };
input ENUM_STAI_CLUSTER InpStAiFromCluster = STAI_CLUSTER_BEST;
input int InpStAiMaxIter = 1000;

input group "Swing BigBeluga"
input bool InpBelugaEnabled = true;
input bool InpBelugaOnlyMode = true;
input bool InpBelugaUseTfLen = true;
enum ENUM_BELUGA_PRESET { BELUGA_PRESET_CUSTOM = 0, BELUGA_PRESET_BALANCED = 1, BELUGA_PRESET_FAST = 2, BELUGA_PRESET_CONSERVATIVE = 3 };
input ENUM_BELUGA_PRESET InpBelugaPreset = BELUGA_PRESET_CUSTOM;
input int InpBelugaLen = 50;
input int InpBelugaLen_M1 = 50;
input int InpBelugaLen_M15 = 50;
input int InpBelugaLen_H1 = 50;
input int InpBelugaLen_H4 = 50;
input color InpBelugaLowVwapColor = clrLimeGreen;
input color InpBelugaHighVwapColor = clrDodgerBlue;
input int InpBelugaWidth = 1;
input bool InpBelugaShowBB = true;

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
   bool g_daily_touch_high_done = false;
   bool g_daily_touch_low_done = false;

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

   string g_qm_types[];
   double g_qm_vals[];
   datetime g_qm_times[];
   int g_qm_baridx[];
   int g_qm_check_be = 0;
   int g_qm_check_bu = 0;
   double g_qm_bear_start = 0.0;
   double g_qm_bull_start = 0.0;
   datetime g_qm_last_setup_time = 0;
   bool g_qm_entry_active = false;
   double g_qm_entry_price = 0.0;
   int g_qm_entry_dir = 0;
   datetime g_qm_entry_setup_time = 0;
   bool g_qm_entry_notified = false;

   struct StAiSupertrend
   {
      double upper;
      double lower;
      double output;
      double perf;
      double factor;
      int trend;
   };

   StAiSupertrend g_st_holder[];
   double g_st_factors[];
   bool g_st_inited = false;
   double g_st_prev_close = 0.0;
   bool g_st_prev_close_has = false;
   double g_st_atr = 0.0;
   bool g_st_atr_has = false;
   double g_st_den = 0.0;
   bool g_st_den_has = false;
   int g_st_os = 0;
   double g_st_upper = 0.0;
   double g_st_lower = 0.0;
   uint g_st_last_params_hash = 0;
   datetime g_st_last_signal_time = 0;

   datetime g_bb_times[];
   double g_bb_highs[];
   double g_bb_lows[];
   datetime g_bb_last_swing_high_time = 0;
   datetime g_bb_last_swing_low_time = 0;
   bool g_bb_trend_has = false;
   bool g_bb_trend = false;

   int StAiCmpDoubleAsc(const double a, const double b) { return (a < b ? -1 : a > b ? 1 : 0); }

   double StAiPercentileLinear(const double &values[], const int n, const double pct01)
   {
      if(n <= 0) return 0.0;
      double tmp[];
      ArrayResize(tmp, n);
      for(int i = 0; i < n; i++) tmp[i] = values[i];
      ArraySort(tmp);

      double p = pct01;
      if(p < 0.0) p = 0.0;
      if(p > 1.0) p = 1.0;
      double rank = p * (double)(n - 1);
      int lo = (int)MathFloor(rank);
      int hi = (int)MathCeil(rank);
      if(lo < 0) lo = 0;
      if(hi > n - 1) hi = n - 1;
      if(lo == hi) return tmp[lo];
      double w = rank - (double)lo;
      return tmp[lo] + (tmp[hi] - tmp[lo]) * w;
   }

   uint StAiParamsHash()
   {
      uint h = 2166136261u;
      h = (h ^ (uint)InpStAiAtrLen) * 16777619u;
      h = (h ^ (uint)InpStAiMinMult) * 16777619u;
      h = (h ^ (uint)InpStAiMaxMult) * 16777619u;
      h = (h ^ (uint)MathRound(InpStAiStep * 1000.0)) * 16777619u;
      h = (h ^ (uint)MathRound(InpStAiPerfAlpha * 1000.0)) * 16777619u;
      h = (h ^ (uint)InpStAiFromCluster) * 16777619u;
      return h;
   }

   void StAiInitIfNeeded(const double hl2)
   {
      if(!InpStAiEnabled) return;
      if(InpStAiMinMult > InpStAiMaxMult) return;
      if(InpStAiStep <= 0.0) return;

      uint ph = StAiParamsHash();
      if(ph != g_st_last_params_hash)
      {
         ArrayResize(g_st_factors, 0);
         ArrayResize(g_st_holder, 0);
         g_st_inited = false;
         g_st_prev_close_has = false;
         g_st_atr_has = false;
         g_st_den_has = false;
         g_st_os = 0;
         g_st_upper = hl2;
         g_st_lower = hl2;
         g_st_last_params_hash = ph;
         g_st_last_signal_time = 0;
      }

      if(ArraySize(g_st_factors) == 0)
      {
         int steps = (int)MathFloor(((double)InpStAiMaxMult - (double)InpStAiMinMult) / InpStAiStep);
         if(steps < 0) steps = 0;
         for(int i = 0; i <= steps; i++)
         {
            double f = (double)InpStAiMinMult + (double)i * InpStAiStep;
            ArrayResize(g_st_factors, ArraySize(g_st_factors) + 1);
            g_st_factors[ArraySize(g_st_factors) - 1] = f;
            ArrayResize(g_st_holder, ArraySize(g_st_holder) + 1);
            int k = ArraySize(g_st_holder) - 1;
            g_st_holder[k].upper = hl2;
            g_st_holder[k].lower = hl2;
            g_st_holder[k].output = hl2;
            g_st_holder[k].perf = 0.0;
            g_st_holder[k].factor = f;
            g_st_holder[k].trend = 0;
         }
         g_st_inited = true;
      }
   }

   void StAiUpdate(const datetime tBarOpen, const double h, const double l, const double c)
   {
      if(!InpStAiEnabled || !InpNotifyStAi)
      {
         g_st_prev_close = c;
         g_st_prev_close_has = true;
         return;
      }
      if(InpStAiMinMult > InpStAiMaxMult) return;
      if(InpStAiStep <= 0.0) return;
      if(InpStAiMaxIter < 0) return;

      double hl2 = (h + l) * 0.5;
      StAiInitIfNeeded(hl2);
      int n = ArraySize(g_st_holder);
      if(n <= 0) return;

      if(!g_st_prev_close_has)
      {
         g_st_prev_close = c;
         g_st_prev_close_has = true;
         g_st_upper = hl2;
         g_st_lower = hl2;
         g_st_os = 0;
         return;
      }

      double prevClose = g_st_prev_close;

      int atrLen = InpStAiAtrLen;
      if(atrLen < 1) atrLen = 1;
      double tr = h - l;
      double a = MathAbs(h - prevClose);
      if(a > tr) tr = a;
      a = MathAbs(l - prevClose);
      if(a > tr) tr = a;
      if(!g_st_atr_has)
      {
         g_st_atr = tr;
         g_st_atr_has = true;
      }
      else
      {
         g_st_atr = (g_st_atr * (double)(atrLen - 1) + tr) / (double)atrLen;
      }

      int denLen = (int)InpStAiPerfAlpha;
      if(denLen < 1) denLen = 1;
      double x = MathAbs(c - prevClose);
      double emaA = 2.0 / ((double)denLen + 1.0);
      if(!g_st_den_has)
      {
         g_st_den = x;
         g_st_den_has = true;
      }
      else
      {
         g_st_den = emaA * x + (1.0 - emaA) * g_st_den;
      }
      if(g_st_den <= 0.0)
      {
         g_st_prev_close = c;
         g_st_prev_close_has = true;
         return;
      }

      double perfAlpha = InpStAiPerfAlpha;
      if(perfAlpha < 2.0) perfAlpha = 2.0;
      double perfK = 2.0 / (perfAlpha + 1.0);

      double perfVals[];
      ArrayResize(perfVals, n);

      for(int i = 0; i < n; i++)
      {
         double factor = g_st_holder[i].factor;
         double up = hl2 + g_st_atr * factor;
         double dn = hl2 - g_st_atr * factor;

         int trend = g_st_holder[i].trend;
         if(c > g_st_holder[i].upper) trend = 1;
         else if(c < g_st_holder[i].lower) trend = 0;

         double upper = (prevClose < g_st_holder[i].upper ? MathMin(up, g_st_holder[i].upper) : up);
         double lower = (prevClose > g_st_holder[i].lower ? MathMax(dn, g_st_holder[i].lower) : dn);

         double d = prevClose - g_st_holder[i].output;
         double diff = (d > 0.0 ? 1.0 : d < 0.0 ? -1.0 : 0.0);

         double perf = g_st_holder[i].perf + perfK * ((c - prevClose) * diff - g_st_holder[i].perf);
         double output = (trend == 1 ? lower : upper);

         g_st_holder[i].trend = trend;
         g_st_holder[i].upper = upper;
         g_st_holder[i].lower = lower;
         g_st_holder[i].perf = perf;
         g_st_holder[i].output = output;
         perfVals[i] = perf;
      }

      double centroids[3];
      centroids[0] = StAiPercentileLinear(perfVals, n, 0.25);
      centroids[1] = StAiPercentileLinear(perfVals, n, 0.50);
      centroids[2] = StAiPercentileLinear(perfVals, n, 0.75);

      double perfSum[3] = {0.0, 0.0, 0.0};
      double factSum[3] = {0.0, 0.0, 0.0};
      int cnt[3] = {0, 0, 0};

      int maxIter = InpStAiMaxIter;
      if(maxIter < 0) maxIter = 0;
      for(int it = 0; it <= maxIter; it++)
      {
         perfSum[0] = perfSum[1] = perfSum[2] = 0.0;
         factSum[0] = factSum[1] = factSum[2] = 0.0;
         cnt[0] = cnt[1] = cnt[2] = 0;

         for(int i = 0; i < n; i++)
         {
            double v = perfVals[i];
            double d0 = MathAbs(v - centroids[0]);
            double d1 = MathAbs(v - centroids[1]);
            double d2 = MathAbs(v - centroids[2]);
            int idx = 0;
            double best = d0;
            if(d1 < best) { best = d1; idx = 1; }
            if(d2 < best) { idx = 2; }

            perfSum[idx] += v;
            factSum[idx] += g_st_holder[i].factor;
            cnt[idx] += 1;
         }

         double newC[3] = {centroids[0], centroids[1], centroids[2]};
         for(int k = 0; k < 3; k++)
            if(cnt[k] > 0) newC[k] = perfSum[k] / (double)cnt[k];

         if(MathAbs(newC[0] - centroids[0]) < 1e-9 && MathAbs(newC[1] - centroids[1]) < 1e-9 && MathAbs(newC[2] - centroids[2]) < 1e-9)
            break;

         centroids[0] = newC[0];
         centroids[1] = newC[1];
         centroids[2] = newC[2];
      }

      int bestIdx = 0;
      int worstIdx = 0;
      if(centroids[1] > centroids[bestIdx]) bestIdx = 1;
      if(centroids[2] > centroids[bestIdx]) bestIdx = 2;
      if(centroids[1] < centroids[worstIdx]) worstIdx = 1;
      if(centroids[2] < centroids[worstIdx]) worstIdx = 2;
      int avgIdx = 3 - bestIdx - worstIdx;

      int pick = (InpStAiFromCluster == STAI_CLUSTER_BEST ? bestIdx : InpStAiFromCluster == STAI_CLUSTER_WORST ? worstIdx : avgIdx);
      if(cnt[pick] <= 0)
      {
         g_st_prev_close = c;
         g_st_prev_close_has = true;
         return;
      }

      double targetFactor = factSum[pick] / (double)cnt[pick];
      double perfAvg = perfSum[pick] / (double)cnt[pick];
      double perfIdx = MathMax(perfAvg, 0.0) / g_st_den;
      int score = (int)(perfIdx * 10.0);

      int prevOs = g_st_os;
      double up2 = hl2 + g_st_atr * targetFactor;
      double dn2 = hl2 - g_st_atr * targetFactor;
      g_st_upper = (prevClose < g_st_upper ? MathMin(up2, g_st_upper) : up2);
      g_st_lower = (prevClose > g_st_lower ? MathMax(dn2, g_st_lower) : dn2);
      if(c > g_st_upper) g_st_os = 1;
      else if(c < g_st_lower) g_st_os = 0;

      if(g_st_os != prevOs && tBarOpen != g_st_last_signal_time)
      {
         if(score >= InpStAiMinScore)
         {
            NotifySignal("ST AI " + string(g_st_os == 1 ? "BUY " : "SELL ") + IntegerToString(score), tBarOpen);
            g_st_last_signal_time = tBarOpen;
         }
      }

      g_st_prev_close = c;
      g_st_prev_close_has = true;
   }

   int BelugaLenForPeriod(const ENUM_TIMEFRAMES tf)
   {
      if(InpBelugaPreset == BELUGA_PRESET_BALANCED)
      {
         if(tf == PERIOD_M1) return 50;
         if(tf == PERIOD_M15) return 50;
         if(tf == PERIOD_H1) return 50;
         if(tf == PERIOD_H4) return 50;
      }
      else if(InpBelugaPreset == BELUGA_PRESET_FAST)
      {
         if(tf == PERIOD_M1) return 30;
         if(tf == PERIOD_M15) return 35;
         if(tf == PERIOD_H1) return 40;
         if(tf == PERIOD_H4) return 50;
      }
      else if(InpBelugaPreset == BELUGA_PRESET_CONSERVATIVE)
      {
         if(tf == PERIOD_M1) return 80;
         if(tf == PERIOD_M15) return 70;
         if(tf == PERIOD_H1) return 60;
         if(tf == PERIOD_H4) return 70;
      }

      if(!InpBelugaUseTfLen) return InpBelugaLen;
      if(tf == PERIOD_M1) return InpBelugaLen_M1;
      if(tf == PERIOD_M15) return InpBelugaLen_M15;
      if(tf == PERIOD_H1) return InpBelugaLen_H1;
      if(tf == PERIOD_H4) return InpBelugaLen_H4;
      return InpBelugaLen;
   }

   void BelugaPushBar(const datetime tBarOpen, const double h, const double l)
   {
      int len = BelugaLenForPeriod((ENUM_TIMEFRAMES)_Period);
      if(len < 1) len = 1;

      int cap = len + 2;
      if(cap < 5) cap = 5;
      int n = ArraySize(g_bb_times);
      if(n > 0)
      {
         datetime lastT = g_bb_times[n - 1];
         if(tBarOpen == lastT)
         {
            g_bb_highs[n - 1] = h;
            g_bb_lows[n - 1] = l;
            return;
         }
         if(tBarOpen < lastT)
         {
            return;
         }
      }
      if(n > cap)
      {
         int start = n - cap;
         for(int i = 0; i < cap; i++)
         {
            g_bb_times[i] = g_bb_times[i + start];
            g_bb_highs[i] = g_bb_highs[i + start];
            g_bb_lows[i] = g_bb_lows[i + start];
         }
         ArrayResize(g_bb_times, cap);
         ArrayResize(g_bb_highs, cap);
         ArrayResize(g_bb_lows, cap);
         n = cap;
      }
      if(n < cap)
      {
         ArrayResize(g_bb_times, n + 1);
         ArrayResize(g_bb_highs, n + 1);
         ArrayResize(g_bb_lows, n + 1);
         g_bb_times[n] = tBarOpen;
         g_bb_highs[n] = h;
         g_bb_lows[n] = l;
         return;
      }

      for(int i = 0; i < cap - 1; i++)
      {
         g_bb_times[i] = g_bb_times[i + 1];
         g_bb_highs[i] = g_bb_highs[i + 1];
         g_bb_lows[i] = g_bb_lows[i + 1];
      }
      g_bb_times[cap - 1] = tBarOpen;
      g_bb_highs[cap - 1] = h;
      g_bb_lows[cap - 1] = l;
   }

   void BelugaDrawActive(
      const datetime tBarOpen,
      const bool trend,
      const datetime indexTime,
      const color vwapColor,
      const bool markerUp,
      const double markerPrice,
      const bool useLowForVwap
   )
   {
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

      string pfx = g_prefix + "BB_ACTIVE_";
      string nameLine = pfx + "LINE";
      string namePrice = pfx + "PRICE";
      string nameMark = pfx + "MARK";

      const int maxSeg = 200;
      int step = (j - 1 + maxSeg - 1) / maxSeg;
      if(step < 1) step = 1;

      int seg = 0;
      int prevIdx = 0;
      for(int idx = step; idx < j; idx += step)
      {
         string nm = pfx + "SEG_" + IntegerToString(seg);
         CreateOrUpdateTrendSegment(nm, times[prevIdx], prices[prevIdx], times[idx], prices[idx], vwapColor, STYLE_SOLID, 2);
         prevIdx = idx;
         seg++;
         if(seg >= maxSeg) break;
      }
      if(seg < maxSeg && prevIdx < (j - 1))
      {
         string nm = pfx + "SEG_" + IntegerToString(seg);
         CreateOrUpdateTrendSegment(nm, times[prevIdx], prices[prevIdx], times[j - 1], prices[j - 1], vwapColor, STYLE_SOLID, 2);
         seg++;
      }
      for(int i = seg; i < maxSeg; i++)
      {
         string nm = pfx + "SEG_" + IntegerToString(i);
         ObjectDelete(0, nm);
      }

      datetime tNow = times[j - 1];
      double vNow = prices[j - 1];
      datetime tFuture = tNow + (datetime)PeriodSeconds(_Period) * 5;
      CreateOrUpdateTrendSegment(nameLine, tNow, vNow, tFuture, vNow, vwapColor, STYLE_SOLID, 2);
      CreateOrUpdateText(namePrice, tFuture, vNow, DoubleToString(vNow, _Digits), clrWhite, ANCHOR_LEFT);

      double markPx = markerPrice;
      if(markPx <= 0.0)
      {
         markPx = markerUp ? iHigh(_Symbol, _Period, shiftIdx) : iLow(_Symbol, _Period, shiftIdx);
      }

      if(!AllowObjInQmOnly(nameMark)) { ObjectDelete(0, nameMark); return; }
      if(ObjectFind(0, nameMark) < 0)
      {
         ResetLastError();
         if(!ObjectCreate(0, nameMark, OBJ_ARROW, 0, indexTime, markPx)) return;
         ObjectSetInteger(0, nameMark, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, nameMark, OBJPROP_BACK, false);
         ObjectSetInteger(0, nameMark, OBJPROP_HIDDEN, false);
      }
      ObjectMove(0, nameMark, 0, indexTime, markPx);
      ObjectSetInteger(0, nameMark, OBJPROP_COLOR, vwapColor);
      ObjectSetInteger(0, nameMark, OBJPROP_ARROWCODE, markerUp ? 233 : 234);
      ObjectSetInteger(0, nameMark, OBJPROP_WIDTH, 1);
   }

   void BelugaDrawHistory(
      const datetime tBarOpen,
      const datetime indexTime,
      const bool useLowForVwap,
      const color baseColor,
      const bool labelUp
   )
   {
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
      uchar histAlpha = (uchar)(useLowForVwap ? 153 : 178);
      color histColor = (color)ColorToARGB(baseColor, histAlpha);
      const int maxSeg = 200;
      int step = (j - 1 + maxSeg - 1) / maxSeg;
      if(step < 1) step = 1;

      int seg = 0;
      int prevIdx = 0;
      for(int idx = step; idx < j; idx += step)
      {
         string nm = pfx + "SEG_" + IntegerToString(seg);
         CreateOrUpdateTrendSegment(nm, times[prevIdx], prices[prevIdx], times[idx], prices[idx], histColor, STYLE_SOLID, w);
         prevIdx = idx;
         seg++;
         if(seg >= maxSeg) break;
      }
      if(seg < maxSeg && prevIdx < (j - 1))
      {
         string nm = pfx + "SEG_" + IntegerToString(seg);
         CreateOrUpdateTrendSegment(nm, times[prevIdx], prices[prevIdx], times[j - 1], prices[j - 1], histColor, STYLE_SOLID, w);
         seg++;
      }
      for(int i = seg; i < maxSeg; i++)
      {
         string nm = pfx + "SEG_" + IntegerToString(i);
         ObjectDelete(0, nm);
      }

      double px = labelUp ? iLow(_Symbol, _Period, shiftIdx) : iHigh(_Symbol, _Period, shiftIdx);
      string nameMark = pfx + "MARK";
      if(!AllowObjInQmOnly(nameMark)) { ObjectDelete(0, nameMark); return; }
      if(ObjectFind(0, nameMark) < 0)
      {
         ResetLastError();
         if(!ObjectCreate(0, nameMark, OBJ_ARROW, 0, indexTime, px)) return;
         ObjectSetInteger(0, nameMark, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, nameMark, OBJPROP_BACK, false);
         ObjectSetInteger(0, nameMark, OBJPROP_HIDDEN, false);
      }
      ObjectMove(0, nameMark, 0, indexTime, px);
      ObjectSetInteger(0, nameMark, OBJPROP_COLOR, (color)ColorToARGB(baseColor, (uchar)153));
      ObjectSetInteger(0, nameMark, OBJPROP_ARROWCODE, labelUp ? 233 : 234);
      ObjectSetInteger(0, nameMark, OBJPROP_WIDTH, 1);
   }

   void BelugaUpdate(const datetime tBarOpen, const double h, const double l)
   {
      if(!InpBelugaEnabled)
      {
         BelugaPushBar(tBarOpen, h, l);
         return;
      }

      BelugaPushBar(tBarOpen, h, l);

      int len = BelugaLenForPeriod((ENUM_TIMEFRAMES)_Period);
      if(len < 2) len = 2;
      int n = ArraySize(g_bb_times);
      if(n < len + 1) return;

      double prevH = g_bb_highs[n - 2];
      double prevL = g_bb_lows[n - 2];
      double curH = g_bb_highs[n - 1];
      double curL = g_bb_lows[n - 1];
      datetime prevT = g_bb_times[n - 2];

      int startPrev = n - 1 - len;
      int endPrev = n - 2;
      if(startPrev < 0) startPrev = 0;

      int startCur = n - len;
      int endCur = n - 1;
      if(startCur < 0) startCur = 0;

      double highestPrev = g_bb_highs[endPrev];
      for(int i = startPrev; i <= endPrev; i++)
         if(g_bb_highs[i] > highestPrev) highestPrev = g_bb_highs[i];

      double highestCur = g_bb_highs[endCur];
      for(int i = startCur; i <= endCur; i++)
         if(g_bb_highs[i] > highestCur) highestCur = g_bb_highs[i];

      double lowestPrev = g_bb_lows[endPrev];
      for(int i = startPrev; i <= endPrev; i++)
         if(g_bb_lows[i] < lowestPrev) lowestPrev = g_bb_lows[i];

      double lowestCur = g_bb_lows[endCur];
      for(int i = startCur; i <= endCur; i++)
         if(g_bb_lows[i] < lowestCur) lowestCur = g_bb_lows[i];

      bool swingHigh = (prevH == highestPrev && curH < highestCur);
      bool swingLow = (prevL == lowestPrev && curL > lowestCur);

      bool drawBeluga = (InpBelugaOnlyMode || InpBelugaShowBB);

      if(swingHigh && prevT != g_bb_last_swing_high_time)
      {
         g_bb_last_swing_high_time = prevT;
         if(InpNotifyBelugaSwing) NotifySignal("BB SWING HIGH", tBarOpen);
      }
      if(swingLow && prevT != g_bb_last_swing_low_time)
      {
         g_bb_last_swing_low_time = prevT;
         if(InpNotifyBelugaSwing) NotifySignal("BB SWING LOW", tBarOpen);
      }

      bool prevTrend = g_bb_trend;
      bool prevTrendHas = g_bb_trend_has;
      if(h == highestCur) { g_bb_trend = true; g_bb_trend_has = true; }
      if(l == lowestCur) { g_bb_trend = false; g_bb_trend_has = true; }

      static datetime lastDrawBar = 0;
      bool doDraw = (tBarOpen != lastDrawBar);
      if(doDraw) lastDrawBar = tBarOpen;

      if(doDraw && drawBeluga && g_bb_trend_has)
      {
         if(prevTrendHas && g_bb_trend != prevTrend)
         {
            if(g_bb_trend) BelugaDrawHistory(tBarOpen, g_bb_last_swing_high_time, false, InpBelugaHighVwapColor, false);
            else BelugaDrawHistory(tBarOpen, g_bb_last_swing_low_time, true, InpBelugaLowVwapColor, true);
         }

         if(g_bb_trend)
         {
            datetime idxT = g_bb_last_swing_low_time;
            int sIdx = iBarShift(_Symbol, _Period, idxT, true);
            double markPx = (sIdx >= 0 ? iHigh(_Symbol, _Period, sIdx) : 0.0);
            BelugaDrawActive(tBarOpen, true, idxT, InpBelugaLowVwapColor, true, markPx, true);
         }
         else
         {
            datetime idxT = g_bb_last_swing_high_time;
            int sIdx = iBarShift(_Symbol, _Period, idxT, true);
            double markPx = (sIdx >= 0 ? iLow(_Symbol, _Period, sIdx) : 0.0);
            BelugaDrawActive(tBarOpen, false, idxT, InpBelugaHighVwapColor, false, markPx, false);
         }
      }
   }

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
   double g_es_daily_high[ES_CAP];
   double g_es_daily_low[ES_CAP];
   double g_es_asia_high[ES_CAP];
   double g_es_asia_low[ES_CAP];
   double g_es_london_high[ES_CAP];
   double g_es_london_low[ES_CAP];
   double g_es_ny_high[ES_CAP];
   double g_es_ny_low[ES_CAP];
   int g_es_head = -1;
   int g_es_count = 0;
   datetime g_es_last_early_low_time = 0;
   datetime g_es_last_early_high_time = 0;
   datetime g_es_last_conf_low_time = 0;
   datetime g_es_last_conf_high_time = 0;
   datetime g_es_last_sp_sh_time = 0;
   datetime g_es_last_sp_sl_time = 0;
   int g_rsi_handle = INVALID_HANDLE;
   int g_macd_handle = INVALID_HANDLE;
   int g_atr_handle = INVALID_HANDLE;
   bool g_swing_last_sl_has = false;
   double g_swing_last_sl_price = 0.0;
   double g_swing_last_sl_rsi = 0.0;
   datetime g_swing_last_sl_time = 0;
   bool g_swing_last_sh_has = false;
   double g_swing_last_sh_price = 0.0;
   double g_swing_last_sh_rsi = 0.0;
   datetime g_swing_last_sh_time = 0;
   datetime g_swing_last_bull_div_time = 0;
   datetime g_swing_last_bear_div_time = 0;
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
   double g_prev_bar_high = 0.0;
   bool g_prev_bar_high_has = false;
   datetime g_last_over_low_time = 0;
   datetime g_last_over_high_time = 0;

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

   bool GetMacdAtTime(const datetime tBarOpen, double &mainVal, double &signalVal)
   {
      mainVal = 0.0;
      signalVal = 0.0;
      if(g_macd_handle == INVALID_HANDLE) return false;
      int shift = iBarShift(_Symbol, _Period, tBarOpen, true);
      if(shift < 0) return false;
      double m[1], s[1];
      if(CopyBuffer(g_macd_handle, 0, shift, 1, m) <= 0) return false;
      if(CopyBuffer(g_macd_handle, 1, shift, 1, s) <= 0) return false;
      mainVal = m[0];
      signalVal = s[0];
      return true;
   }

   double AtrCurrent()
   {
      if(g_atr_handle == INVALID_HANDLE) return 0.0;
      double b[1];
      if(CopyBuffer(g_atr_handle, 0, 0, 1, b) <= 0) return 0.0;
      return b[0];
   }

   bool MacdBullCrossAtTime(const datetime tBarOpen)
   {
      if(g_macd_handle == INVALID_HANDLE) return false;
      int shift = iBarShift(_Symbol, _Period, tBarOpen, true);
      if(shift < 0) return false;
      double m[2], s[2];
      if(CopyBuffer(g_macd_handle, 0, shift, 2, m) <= 0) return false;
      if(CopyBuffer(g_macd_handle, 1, shift, 2, s) <= 0) return false;
      return (m[0] > s[0] && m[1] <= s[1]);
   }

   bool MacdBearCrossAtTime(const datetime tBarOpen)
   {
      if(g_macd_handle == INVALID_HANDLE) return false;
      int shift = iBarShift(_Symbol, _Period, tBarOpen, true);
      if(shift < 0) return false;
      double m[2], s[2];
      if(CopyBuffer(g_macd_handle, 0, shift, 2, m) <= 0) return false;
      if(CopyBuffer(g_macd_handle, 1, shift, 2, s) <= 0) return false;
      return (m[0] < s[0] && m[1] >= s[1]);
   }

   bool GetRsiMaAtShift(const int shift, const int len, const ENUM_RSI_MA_TYPE maType, double &maValue)
   {
      maValue = 0.0;
      if(g_rsi_handle == INVALID_HANDLE) return false;
      int n = len;
      if(n < 1) n = 1;
      double rsiArr[];
      ArrayResize(rsiArr, n);
      ArraySetAsSeries(rsiArr, true);
      if(CopyBuffer(g_rsi_handle, 0, shift, n, rsiArr) <= 0) return false;

      if(maType == RSI_MA_SMA)
      {
         double sum = 0.0;
         for(int i = 0; i < n; i++) sum += rsiArr[i];
         maValue = sum / (double)n;
         return true;
      }

      double k = 2.0 / ((double)n + 1.0);
      double ema = rsiArr[n - 1];
      for(int i = n - 2; i >= 0; i--)
         ema = k * rsiArr[i] + (1.0 - k) * ema;
      maValue = ema;
      return true;
   }

   bool RsiCrossSignalAtTime(const datetime tPivot, const bool bullish)
   {
      if(!InpRsiCrossEnabled) return false;
      if(g_rsi_handle == INVALID_HANDLE) return false;
      int shift = iBarShift(_Symbol, _Period, tPivot, true);
      if(shift < 0) return false;
      int prevShift = shift + 1;

      double rsiNow = 0.0, rsiPrev = 0.0;
      double b0[1], b1[1];
      if(CopyBuffer(g_rsi_handle, 0, shift, 1, b0) <= 0) return false;
      if(CopyBuffer(g_rsi_handle, 0, prevShift, 1, b1) <= 0) return false;
      rsiNow = b0[0];
      rsiPrev = b1[0];

      double maNow = 0.0, maPrev = 0.0;
      if(!GetRsiMaAtShift(shift, InpRsiCrossMaLen, InpRsiCrossMaType, maNow)) return false;
      if(!GetRsiMaAtShift(prevShift, InpRsiCrossMaLen, InpRsiCrossMaType, maPrev)) return false;

      if(bullish) return (rsiNow > maNow && rsiPrev <= maPrev);
      return (rsiNow < maNow && rsiPrev >= maPrev);
   }

   bool RsiCrossAtTime(const datetime tPivot, const bool bullish)
   {
      if(!InpSwingRsiMaCrossEnabled) return true;
      int shift = iBarShift(_Symbol, _Period, tPivot, true);
      if(shift < 0) return false;
      int prevShift = shift + 1;

      double rsiNow = 0.0, rsiPrev = 0.0;
      double b0[1], b1[1];
      if(CopyBuffer(g_rsi_handle, 0, shift, 1, b0) <= 0) return false;
      if(CopyBuffer(g_rsi_handle, 0, prevShift, 1, b1) <= 0) return false;
      rsiNow = b0[0];
      rsiPrev = b1[0];

      double maNow = 0.0, maPrev = 0.0;
      if(!GetRsiMaAtShift(shift, InpSwingRsiMaLen, InpSwingRsiMaType, maNow)) return false;
      if(!GetRsiMaAtShift(prevShift, InpSwingRsiMaLen, InpSwingRsiMaType, maPrev)) return false;

      if(bullish) return (rsiNow > maNow && rsiPrev <= maPrev);
      return (rsiNow < maNow && rsiPrev >= maPrev);
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

   int QmGetPivotPeriod()
   {
      if(!InpQmUseTfPivots) return MathMax(1, InpQmPivotFallback);
      if(_Period == PERIOD_M1) return MathMax(1, InpQmPivot_M1);
      if(_Period == PERIOD_M5) return MathMax(1, InpQmPivot_M5);
      if(_Period == PERIOD_M15) return MathMax(1, InpQmPivot_M15);
      if(_Period == PERIOD_H1) return MathMax(1, InpQmPivot_H1);
      if(_Period == PERIOD_H4) return MathMax(1, InpQmPivot_H4);
      return MathMax(1, InpQmPivotFallback);
   }

   int QmSize()
   {
      return ArraySize(g_qm_types);
   }

   void QmRemoveAt(const int idx)
   {
      int n = QmSize();
      if(idx < 0 || idx >= n) return;
      for(int i = idx; i < n - 1; i++)
      {
         g_qm_types[i] = g_qm_types[i + 1];
         g_qm_vals[i] = g_qm_vals[i + 1];
         g_qm_times[i] = g_qm_times[i + 1];
         g_qm_baridx[i] = g_qm_baridx[i + 1];
      }
      ArrayResize(g_qm_types, n - 1);
      ArrayResize(g_qm_vals, n - 1);
      ArrayResize(g_qm_times, n - 1);
      ArrayResize(g_qm_baridx, n - 1);
   }

   void QmRemoveLast()
   {
      int n = QmSize();
      if(n <= 0) return;
      ArrayResize(g_qm_types, n - 1);
      ArrayResize(g_qm_vals, n - 1);
      ArrayResize(g_qm_times, n - 1);
      ArrayResize(g_qm_baridx, n - 1);
   }

   void QmPush(const string ty, const double val, const datetime t, const int barIdx)
   {
      int n = QmSize();
      ArrayResize(g_qm_types, n + 1);
      ArrayResize(g_qm_vals, n + 1);
      ArrayResize(g_qm_times, n + 1);
      ArrayResize(g_qm_baridx, n + 1);
      g_qm_types[n] = ty;
      g_qm_vals[n] = val;
      g_qm_times[n] = t;
      g_qm_baridx[n] = barIdx;
   }

   bool QmIsPivotHighAtShift(const int pivotShift, const int pp)
   {
      int bars = Bars(_Symbol, _Period);
      if(pp < 1) return false;
      if(pivotShift - pp < 0) return false;
      if(pivotShift + pp >= bars) return false;
      double v = iHigh(_Symbol, _Period, pivotShift);
      if(v <= 0.0) return false;
      for(int j = pivotShift - pp; j <= pivotShift + pp; j++)
      {
         if(j == pivotShift) continue;
         double hj = iHigh(_Symbol, _Period, j);
         if(hj >= v) return false;
      }
      return true;
   }

   bool QmIsPivotLowAtShift(const int pivotShift, const int pp)
   {
      int bars = Bars(_Symbol, _Period);
      if(pp < 1) return false;
      if(pivotShift - pp < 0) return false;
      if(pivotShift + pp >= bars) return false;
      double v = iLow(_Symbol, _Period, pivotShift);
      if(v <= 0.0) return false;
      for(int j = pivotShift - pp; j <= pivotShift + pp; j++)
      {
         if(j == pivotShift) continue;
         double lj = iLow(_Symbol, _Period, j);
         if(lj <= v) return false;
      }
      return true;
   }

   datetime TimeFromBarIndex(const int barIdx, const datetime baseTime)
   {
      int bars = Bars(_Symbol, _Period);
      int curBarIdx = bars - 1;
      if(barIdx <= curBarIdx)
      {
         int shift = curBarIdx - barIdx;
         return iTime(_Symbol, _Period, shift);
      }
      int delta = barIdx - curBarIdx;
      return baseTime + (datetime)PeriodSeconds(_Period) * delta;
   }

   void QmDrawLive(const datetime tNow, const double cNow)
   {
      if(!InpQmLiveEnabled)
      {
         DeleteByToken("QM_LIVE_");
         return;
      }
      int n = QmSize();
      int pts = InpQmLivePoints;
      if(pts < 2) pts = 2;
      if(pts > 10) pts = 10;
      if(n < 2)
      {
         DeleteByToken("QM_LIVE_");
         return;
      }
      int usePts = MathMin(pts, n);
      string lastTy = g_qm_types[n - 1];
      bool isW = (lastTy == "L" || lastTy == "LL" || lastTy == "HL");
      color col = (isW ? InpQmLiveColorW : InpQmLiveColorM);
      int width = InpQmLiveWidth;
      if(width < 1) width = 1;
      if(width > 5) width = 5;

      int seg = usePts - 1;
      for(int i = 0; i < seg; i++)
      {
         int idx1 = n - usePts + i;
         int idx2 = idx1 + 1;
         string nm = g_prefix + "QM_LIVE_" + IntegerToString(i);
         CreateOrUpdateTrendSegment(nm, g_qm_times[idx1], g_qm_vals[idx1], g_qm_times[idx2], g_qm_vals[idx2], col, STYLE_SOLID, width);
      }
      for(int i = seg; i < 20; i++)
      {
         string nm = g_prefix + "QM_LIVE_" + IntegerToString(i);
         ObjectDelete(0, nm);
      }
      if(InpQmLiveToCurrent)
      {
         string nm = g_prefix + "QM_LIVE_CUR";
         CreateOrUpdateTrendSegment(nm, g_qm_times[n - 1], g_qm_vals[n - 1], tNow, cNow, col, STYLE_SOLID, width);
      }
      else
      {
         ObjectDelete(0, g_prefix + "QM_LIVE_CUR");
      }
   }

   void QmDrawSetup(const bool bull, const datetime tBarOpen)
   {
      int n = QmSize();
      if(n <= 5) return;

      datetime t1 = g_qm_times[n - 1];
      double v1 = g_qm_vals[n - 1];
      datetime t2 = g_qm_times[n - 2];
      double v2 = g_qm_vals[n - 2];
      datetime t3 = g_qm_times[n - 3];
      double v3 = g_qm_vals[n - 3];
      datetime t4 = g_qm_times[n - 4];
      double v4 = g_qm_vals[n - 4];
      datetime t5 = g_qm_times[n - 5];
      double v5 = g_qm_vals[n - 5];

      int i1 = g_qm_baridx[n - 1];
      int i2 = g_qm_baridx[n - 2];
      int i3 = g_qm_baridx[n - 3];
      int i4 = g_qm_baridx[n - 4];
      int i5 = g_qm_baridx[n - 5];

      int moveBars = (i2 - i4) / 2;
      if(moveBars < 1) moveBars = 1;

      int endLegIdx = i1 + moveBars - 2;
      int endLineIdx = i1 + moveBars;
      datetime tLegEnd = TimeFromBarIndex(endLegIdx, tBarOpen);
      datetime tLineEnd = TimeFromBarIndex(endLineIdx, tBarOpen);
      datetime tLbl = TimeFromBarIndex(endLineIdx + 1, tBarOpen);

      string key = IntegerToString((long)t1);
      string pfx = g_prefix + "QM_SETUP_" + key + "_";

      color legCol = (bull ? clrGreen : clrMaroon);
      color arrowCol = (bull ? clrAqua : clrOrange);
      CreateOrUpdateTrendSegment(pfx + "LEG1", t5, v5, t4, v4, legCol, STYLE_SOLID, 2);
      CreateOrUpdateTrendSegment(pfx + "LEG2", t4, v4, t3, v3, legCol, STYLE_SOLID, 2);
      CreateOrUpdateTrendSegment(pfx + "LEG3", t3, v3, t2, v2, legCol, STYLE_SOLID, 2);
      CreateOrUpdateTrendSegment(pfx + "LEG4", t2, v2, t1, v1, legCol, STYLE_SOLID, 2);
      CreateOrUpdateTrendSegment(pfx + "LEG5", t1, v1, tLegEnd, v4, arrowCol, STYLE_SOLID, 2);

      double entry = v4;
      double atr = AtrCurrent();
      double sl = (bull ? (v2 - (atr / 2.0)) : (v2 + (atr / 2.0)));
      CreateOrUpdateTrendSegment(pfx + "ENTRY", t4, entry, tLineEnd, entry, clrBlack, STYLE_DOT, 1);
      CreateOrUpdateTrendSegment(pfx + "SL", t2, sl, tLineEnd, sl, clrMaroon, STYLE_DOT, 1);
      CreateOrUpdateTrendSegment(pfx + "TP1", t3, v3, tLineEnd, v3, clrGreen, STYLE_DOT, 1);
      CreateOrUpdateTrendSegment(pfx + "TP2", t1, v1, tLineEnd, v1, clrGreen, STYLE_DOT, 1);

      CreateOrUpdateText(pfx + "LBL_ENTRY", tLbl, entry, "Entry", clrWhite, ANCHOR_LEFT);
      CreateOrUpdateText(pfx + "LBL_SL", tLbl, sl, "SL", clrWhite, ANCHOR_LEFT);
      CreateOrUpdateText(pfx + "LBL_TP1", tLbl, v3, "TP1", clrWhite, ANCHOR_LEFT);
      CreateOrUpdateText(pfx + "LBL_TP2", tLbl, v1, "TP2", clrWhite, ANCHOR_LEFT);

      g_qm_entry_active = true;
      g_qm_entry_price = entry;
      g_qm_entry_dir = (bull ? 1 : -1);
      g_qm_entry_setup_time = t1;
      g_qm_entry_notified = false;
   }

   void QmCheckEntryTouchRealtime(const datetime tNow, const double hNow, const double lNow)
   {
      if(!InpQmEnabled || !InpQmNotifyEntryTouch) return;
      if(!g_qm_entry_active || g_qm_entry_price <= 0.0) return;
      if(InpQmNotifyOncePerSetup && g_qm_entry_notified) return;
      double eps = _Point * 0.1;
      bool touch = (hNow >= (g_qm_entry_price - eps) && lNow <= (g_qm_entry_price + eps));
      if(!touch) return;
      g_qm_entry_notified = true;
      NotifySignal("QM ENTRY TOUCH " + string(g_qm_entry_dir > 0 ? "W" : "M"), tNow);
   }

   void UpdateQm(const datetime tBarOpen, const double cNow)
   {
      if(!InpQmEnabled) { DeleteByToken("QM_"); return; }
      int pp = QmGetPivotPeriod();
      int curShift = iBarShift(_Symbol, _Period, tBarOpen, true);
      if(curShift < 0) return;
      int pivotShift = curShift + pp;
      int bars = Bars(_Symbol, _Period);
      if(pivotShift + pp >= bars) return;

      bool hasHigh = QmIsPivotHighAtShift(pivotShift, pp);
      bool hasLow = QmIsPivotLowAtShift(pivotShift, pp);
      if(!hasHigh && !hasLow)
      {
         QmDrawLive(tBarOpen, cNow);
         return;
      }

      datetime tPivot = iTime(_Symbol, _Period, pivotShift);
      double highVal = iHigh(_Symbol, _Period, pivotShift);
      double lowVal = iLow(_Symbol, _Period, pivotShift);
      int curBarIdx = bars - 1 - curShift;
      int pivBarIdx = bars - 1 - pivotShift;

      int n = QmSize();
      if(hasHigh && hasLow)
      {
         if(n == 0)
         {
            QmPush("H", highVal, tPivot, pivBarIdx);
         }
         else
         {
            string last = g_qm_types[n - 1];
            if(last == "L" || last == "LL")
            {
               if(lowVal < g_qm_vals[n - 1])
               {
                  QmRemoveLast();
                  int nn = QmSize();
                  string ty = (nn > 2 ? (g_qm_vals[nn - 2] < lowVal ? "HL" : "LL") : "L");
                  QmPush(ty, lowVal, tPivot, pivBarIdx);
               }
               else
               {
                  string ty = (n > 2 ? (g_qm_vals[n - 2] < highVal ? "HH" : "LH") : "H");
                  QmPush(ty, highVal, tPivot, pivBarIdx);
               }
            }
            else if(last == "H" || last == "HH")
            {
               if(highVal > g_qm_vals[n - 1])
               {
                  QmRemoveLast();
                  int nn = QmSize();
                  string ty = (nn > 2 ? (g_qm_vals[nn - 2] < highVal ? "HH" : "LH") : "H");
                  QmPush(ty, highVal, tPivot, pivBarIdx);
               }
               else
               {
                  string ty = (n > 2 ? (g_qm_vals[n - 2] < lowVal ? "HL" : "LL") : "L");
                  QmPush(ty, lowVal, tPivot, pivBarIdx);
               }
            }
         }
      }
      else if(hasHigh)
      {
         if(n == 0)
         {
            QmPush("H", highVal, tPivot, pivBarIdx);
         }
         else
         {
            string last = g_qm_types[n - 1];
            if(last == "L" || last == "HL" || last == "LL")
            {
               if(highVal > g_qm_vals[n - 1])
               {
                  string ty = (n > 2 ? (g_qm_vals[n - 2] < highVal ? "HH" : "LH") : "H");
                  QmPush(ty, highVal, tPivot, pivBarIdx);
               }
               else if(highVal < g_qm_vals[n - 1])
               {
                  QmRemoveLast();
                  int nn = QmSize();
                  string ty = (nn > 2 ? (g_qm_vals[nn - 2] < lowVal ? "HL" : "LL") : "L");
                  QmPush(ty, lowVal, tPivot, pivBarIdx);
               }
            }
            else if(last == "H" || last == "HH" || last == "LH")
            {
               if(g_qm_vals[n - 1] < highVal)
               {
                  QmRemoveLast();
                  int nn = QmSize();
                  string ty = (nn > 2 ? (g_qm_vals[nn - 2] < highVal ? "HH" : "LH") : "H");
                  QmPush(ty, highVal, tPivot, pivBarIdx);
               }
            }
         }
      }
      else if(hasLow)
      {
         if(n == 0)
         {
            QmPush("L", lowVal, tPivot, pivBarIdx);
         }
         else
         {
            string last = g_qm_types[n - 1];
            if(last == "H" || last == "HH" || last == "LH")
            {
               if(lowVal < g_qm_vals[n - 1])
               {
                  string ty = (n > 2 ? (g_qm_vals[n - 2] < lowVal ? "HL" : "LL") : "L");
                  QmPush(ty, lowVal, tPivot, pivBarIdx);
               }
               else if(lowVal > g_qm_vals[n - 1])
               {
                  QmRemoveLast();
                  int nn = QmSize();
                  string ty = (nn > 2 ? (g_qm_vals[nn - 2] < highVal ? "HH" : "LH") : "H");
                  QmPush(ty, highVal, tPivot, pivBarIdx);
               }
            }
            else if(last == "L" || last == "HL" || last == "LL")
            {
               if(g_qm_vals[n - 1] > lowVal)
               {
                  QmRemoveLast();
                  int nn = QmSize();
                  string ty = (nn > 2 ? (g_qm_vals[nn - 2] < lowVal ? "HL" : "LL") : "L");
                  QmPush(ty, lowVal, tPivot, pivBarIdx);
               }
            }
         }
      }

      QmDrawLive(tBarOpen, cNow);

      int s = QmSize();
      if(s <= 5) return;
      string th1 = g_qm_types[s - 1];
      string th2 = g_qm_types[s - 2];
      string th3 = g_qm_types[s - 3];
      string th4 = g_qm_types[s - 4];
      string th5 = g_qm_types[s - 5];

      int ih = g_qm_baridx[s - 1];
      int ih2 = g_qm_baridx[s - 2];
      int ih4 = g_qm_baridx[s - 4];

      double vh1 = g_qm_vals[s - 1];
      double vh2 = g_qm_vals[s - 2];
      double vh5 = g_qm_vals[s - 5];

      bool bearQM = (th1 == "LL" && th2 == "HH" && th3 == "HL" && th4 == "HH" && vh5 < vh1 && ih == (curBarIdx - pp) && g_qm_check_be == 0);
      if(bearQM)
      {
         g_qm_bear_start = vh2;
         g_qm_check_be = 1;
         if(g_qm_last_setup_time != g_qm_times[s - 1])
         {
            QmDrawSetup(false, tBarOpen);
            g_qm_last_setup_time = g_qm_times[s - 1];
         }
      }
      if(g_qm_bear_start != vh2) g_qm_check_be = 0;

      string tl1 = th1;
      string tl2 = th2;
      string tl3 = th3;
      string tl4 = th4;
      string tl5 = th5;

      int il = ih;
      double vl1 = vh1;
      double vl2 = vh2;
      double vl5 = vh5;

      bool bullQM = (tl1 == "HH" && tl2 == "LL" && tl3 == "LH" && tl4 == "LL" && vl5 > vl1 && il == (curBarIdx - pp) && g_qm_check_bu == 0);
      if(bullQM)
      {
         g_qm_bull_start = vl2;
         g_qm_check_bu = 1;
         if(g_qm_last_setup_time != g_qm_times[s - 1])
         {
            QmDrawSetup(true, tBarOpen);
            g_qm_last_setup_time = g_qm_times[s - 1];
         }
      }
      if(g_qm_bull_start != vl2) g_qm_check_bu = 0;
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
   g_swing_last_bull_div_time = 0;
   g_swing_last_bear_div_time = 0;
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
   g_es_daily_high[g_es_head] = (g_daily_has ? g_daily_high : 0.0);
   g_es_daily_low[g_es_head] = (g_daily_has ? g_daily_low : 0.0);
   g_es_asia_high[g_es_head] = (g_asia_has ? g_asia_high : 0.0);
   g_es_asia_low[g_es_head] = (g_asia_has ? g_asia_low : 0.0);
   g_es_london_high[g_es_head] = (g_london_has ? g_london_high : 0.0);
   g_es_london_low[g_es_head] = (g_london_has ? g_london_low : 0.0);
   g_es_ny_high[g_es_head] = (g_ny_sess_has ? g_ny_high : 0.0);
   g_es_ny_low[g_es_head] = (g_ny_sess_has ? g_ny_low : 0.0);
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

   bool AllowObjInQmOnly(const string name)
   {
      if(InpBelugaOnlyMode)
      {
         if(StringFind(name, "BB_") >= 0) return true;
         return false;
      }
      if(!InpQmOnlyMode) return true;
      if(StringFind(name, "QM_") >= 0) return true;
      if(StringFind(name, "STATUS") >= 0) return true;
      if(InpBelugaShowBB && StringFind(name, "BB_") >= 0) return true;
      if(InpQmShowShSl && (StringFind(name, "SP_SH_") >= 0 || StringFind(name, "SP_SL_") >= 0)) return true;
      return false;
   }

   void CreateOrUpdateHLine(const string name, const double price, const color clr, const ENUM_LINE_STYLE style, const int width)
   {
      if(!AllowObjInQmOnly(name)) { ObjectDelete(0, name); return; }
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
      if(!AllowObjInQmOnly(name)) { ObjectDelete(0, name); return; }
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
      if(!AllowObjInQmOnly(name)) { ObjectDelete(0, name); return; }
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
      if(!AllowObjInQmOnly(name)) { ObjectDelete(0, name); return; }
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
      if(!AllowObjInQmOnly(name)) { ObjectDelete(0, name); return; }
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
      if(!AllowObjInQmOnly(name)) { ObjectDelete(0, name); return; }
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
      if(InpNotifyOnlyBelugaSwing)
      {
         bool isBeluga = (StringFind(txt, "BB SWING") == 0);
         if(!(InpNotifyBelugaSwing && isBeluga)) return;
      }
      if(InpNotifyOnlyQmEntryTouch)
      {
         bool isQmEntryTouch = (StringFind(txt, "QM ENTRY TOUCH") == 0);
         bool isDailyTouch = (StringFind(txt, "DAILY TOUCH") == 0);
         bool isStAi = (StringFind(txt, "ST AI") == 0);
         bool isBeluga = (StringFind(txt, "BB SWING") == 0);
         if(!(isQmEntryTouch || (InpNotifyDailyTouch && isDailyTouch) || (InpNotifyStAi && isStAi) || (InpNotifyBelugaSwing && isBeluga))) return;
      }
      if(InpQmOnlyMode)
      {
         bool isQm = (StringFind(txt, "QM") == 0);
         bool isShSl = (txt == "SH" || txt == "SL");
         bool isDailyTouch = (StringFind(txt, "DAILY TOUCH") == 0);
         bool isStAi = (StringFind(txt, "ST AI") == 0);
         bool isBeluga = (StringFind(txt, "BB SWING") == 0);
         if(!(isQm || (InpQmShowShSl && isShSl) || (InpQmShowDaily && isDailyTouch) || (InpNotifyStAi && isStAi) || (InpNotifyBelugaSwing && isBeluga))) return;
      }
      if(InpNotifyOnlySHSL)
      {
         bool isShSl = (txt == "SH" || txt == "SL");
         bool isDiv = (StringFind(txt, "DIV") == 0);
         bool isLux = (StringFind(txt, "LUX") == 0);
         bool isMtf = (StringFind(txt, "BUY MTF") == 0 || StringFind(txt, "SELL MTF") == 0);
         bool isDailyTouch = (StringFind(txt, "DAILY TOUCH") == 0);
         bool isRsiCross = (StringFind(txt, "RSI CROSS") == 0);
         bool isQm = (StringFind(txt, "QM") == 0);
         bool isStAi = (StringFind(txt, "ST AI") == 0);
         bool isBeluga = (StringFind(txt, "BB SWING") == 0);
         if(!(isShSl || (InpNotifyDiv && isDiv) || (InpNotifyLux && isLux) || (InpNotifyMtf && isMtf) || (InpNotifyDailyTouch && isDailyTouch) || (InpNotifyRsiCross && isRsiCross) || (InpNotifyQm && isQm) || (InpNotifyStAi && isStAi) || (InpNotifyBelugaSwing && isBeluga))) return;
      }
      if(!InpNotifyHistorical)
      {
         datetime ref = iTime(_Symbol, _Period, 1);
         if(tBar != ref)
         {
            bool isQmEntryTouch = (StringFind(txt, "QM ENTRY TOUCH") == 0);
            datetime cur = iTime(_Symbol, _Period, 0);
            if(!(isQmEntryTouch && tBar == cur)) return;
         }
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
      bool beforeNyClose = (MinuteOfDayLocal(tLastBar) < 21 * 60);
      datetime tAnchor = tLastBar + (datetime)PeriodSeconds(_Period) * 2;
      string dayPfx = g_prefix + IntegerToString(g_day_key) + "_";

      if(beforeNyClose && InpShowDailyHL && g_daily_has)
      {
         CreateOrUpdateText(dayPfx + "LBL_D_HIGH", tAnchor, g_daily_high, "Daily High", clrRed, ANCHOR_RIGHT);
         CreateOrUpdateText(dayPfx + "LBL_D_LOW", tAnchor, g_daily_low, "Daily Low", clrRed, ANCHOR_RIGHT);
      }
      else
      {
         ObjectDelete(0, dayPfx + "LBL_D_HIGH");
         ObjectDelete(0, dayPfx + "LBL_D_LOW");
      }

      if(beforeNyClose && InpShowNYOpen && g_ny_has)
         CreateOrUpdateText(dayPfx + "LBL_NY_OPEN", tAnchor, g_ny_open, "NY Open", clrRed, ANCHOR_RIGHT);
      else
         ObjectDelete(0, dayPfx + "LBL_NY_OPEN");
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
      g_daily_touch_high_done = false;
      g_daily_touch_low_done = false;
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
      g_prev_bar_high = 0.0;
      g_prev_bar_high_has = false;
      g_last_over_high_time = 0;
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

      if(InpBelugaOnlyMode)
      {
         g_prev_bar_low = l;
         g_prev_bar_low_has = true;
         g_prev_bar_high = h;
         g_prev_bar_high_has = true;
         ObjectDelete(0, g_prefix + "STATUS");
         ObjectDelete(0, g_prefix + "PING");
         UpdateChartComment("");
         return;
      }

      double prevLow = g_prev_bar_low_has ? g_prev_bar_low : l;
      double prevHigh = g_prev_bar_high_has ? g_prev_bar_high : h;

      bool hadDaily = g_daily_has;
      double prevDailyHigh = g_daily_high;
      double prevDailyLow = g_daily_low;

      if(!g_daily_has) { g_day_start_time = tBarOpen; g_daily_open = o; g_daily_high = h; g_daily_low = l; g_daily_has = true; }
      else { if(h > g_daily_high) g_daily_high = h; if(l < g_daily_low) g_daily_low = l; }

      if(InpNotifyDailyTouch && hadDaily)
      {
         double eps = _Point * 0.1;
         bool touchHigh = (prevDailyHigh > 0.0 && h >= (prevDailyHigh - eps) && l <= (prevDailyHigh + eps));
         bool touchLow = (prevDailyLow > 0.0 && l <= (prevDailyLow + eps) && h >= (prevDailyLow - eps));
         if(touchHigh && (!InpDailyTouchOncePerDay || !g_daily_touch_high_done))
         {
            g_daily_touch_high_done = true;
            NotifySignal("DAILY TOUCH HIGH", tBarOpen);
         }
         if(touchLow && (!InpDailyTouchOncePerDay || !g_daily_touch_low_done))
         {
            g_daily_touch_low_done = true;
            NotifySignal("DAILY TOUCH LOW", tBarOpen);
         }
      }

      StAiUpdate(tBarOpen, h, l, c);

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
         g_daily_touch_high_done = false;
         g_daily_touch_low_done = false;
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
      bool showOther = !InpShowOnlySwingSignals && !InpQmOnlyMode;
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
         datetime tStart = (g_day_start_time == 0 ? tBarOpen : g_day_start_time);
         datetime tEnd = tBarOpen + (datetime)PeriodSeconds(_Period);
         MqlDateTime dtClose;
         TimeToStruct(LocalTime(tBarOpen), dtClose);
         dtClose.hour = 21; dtClose.min = 0; dtClose.sec = 0;
         datetime nyCloseServer = StructToTime(dtClose) - (datetime)InpItalyOffsetHours * 3600;
         if(tEnd > nyCloseServer) tEnd = nyCloseServer;

         if(showOther && InpShowDailyOpen)
         {
            if(beforeNyClose)
               CreateOrUpdateTrendSegment(dayPfx + "D_OPEN", tStart, g_daily_open, tEnd, g_daily_open, InpDailyOpenColor, STYLE_SOLID, 1);
         }
         else
            DeleteByToken("_D_OPEN");

         if(showOther && InpShowDailyHL)
         {
            if(beforeNyClose)
            {
               CreateOrUpdateTrendSegment(dayPfx + "D_HIGH", tStart, g_daily_high, tEnd, g_daily_high, InpDailyHLColor, STYLE_SOLID, 1);
               CreateOrUpdateTrendSegment(dayPfx + "D_LOW", tStart, g_daily_low, tEnd, g_daily_low, InpDailyHLColor, STYLE_SOLID, 1);
            }
         }
         else
         {
            DeleteByToken("_D_HIGH");
            DeleteByToken("_D_LOW");
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

      if(InpSwingOverHighH13Enabled && beforeNyClose && g_h13_has)
      {
         double buf = (double)InpSwingOverHighH13BufferPoints * _Point;
         double level = g_h13_high + buf;
         if(prevHigh <= level && h > level && g_last_over_high_time != tBarOpen)
         {
            string n = dayPfx + "SP_OVERHIGH_H13_" + IntegerToString((long)tBarOpen);
            CreateOrUpdateText(n, tBarOpen, h + 12 * _Point, "OVER\nHIGH", clrLimeGreen, ANCHOR_LEFT_UPPER);
            NotifySignal("OVER HIGH (H13)", tBarOpen);
            g_last_over_high_time = tBarOpen;
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
         bool validKissBuy = InpKissSignalsEnabled && allowKiss && (!InpRequireSweepBeforeKiss || g_kiss_swept_l) && !g_kiss_done_b && l <= (g_h13_low + tol) && c > g_h13_low;
         bool validKissSell = InpKissSignalsEnabled && allowKiss && (!InpRequireSweepBeforeKiss || g_kiss_swept_h) && !g_kiss_done_s && h >= (g_h13_high - tol) && c < g_h13_high;

         if(validKissBuy) g_kiss_done_b = true;
         if(validKissSell) g_kiss_done_s = true;

         if(showOther && InpShowSignals && InpKissSignalsEnabled)
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
         bool buy = (InpBuySellSignalsEnabled && c > g_h13_high && isKill && !g_buy_done && dailyOkB && ibOkB && manipOkB);
         bool sell = (InpBuySellSignalsEnabled && c < g_h13_low && isKill && !g_sell_done && dailyOkS && ibOkS && manipOkS);
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
                     if(centerOff == 1)
                     {
                        if(!(g_es_close[newest] < lC)) sh = false;
                     }
                     else
                     {
                        if(!(g_es_close[newest] < g_es_low[reactIdx])) sh = false;
                     }
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
                     if(centerOff == 1)
                     {
                        if(!(g_es_close[newest] > hC)) sl = false;
                     }
                     else
                     {
                        if(!(g_es_close[newest] > g_es_high[reactIdx])) sl = false;
                     }
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

               bool extremeOn = (InpSwingShowDailyExtremeShSl || InpSwingShowSessionExtremeShSl);
               bool nearDailyHigh = false;
               bool nearDailyLow = false;
               bool nearSessHigh = false;
               bool nearSessLow = false;
               if(InpSwingShowDailyExtremeShSl)
               {
                  double buf = (double)InpSwingDailyExtremeBufferPoints * _Point;
                  double dHi = g_es_daily_high[centerIdx];
                  double dLo = g_es_daily_low[centerIdx];
                  nearDailyHigh = (dHi > 0.0 && buf >= 0.0 && MathAbs(hC - dHi) <= buf);
                  nearDailyLow = (dLo > 0.0 && buf >= 0.0 && MathAbs(lC - dLo) <= buf);
               }
               if(InpSwingShowSessionExtremeShSl)
               {
                  double buf = (double)InpSwingSessionExtremeBufferPoints * _Point;
                  if(buf < 0.0) buf = 0.0;
                  if(InpSwingSessionUseAsia && g_es_asia_high[centerIdx] > 0.0)
                  {
                     nearSessHigh = nearSessHigh || (MathAbs(hC - g_es_asia_high[centerIdx]) <= buf);
                     nearSessLow = nearSessLow || (MathAbs(lC - g_es_asia_low[centerIdx]) <= buf);
                  }
                  if(InpSwingSessionUseLondon && g_es_london_high[centerIdx] > 0.0)
                  {
                     nearSessHigh = nearSessHigh || (MathAbs(hC - g_es_london_high[centerIdx]) <= buf);
                     nearSessLow = nearSessLow || (MathAbs(lC - g_es_london_low[centerIdx]) <= buf);
                  }
                  if(InpSwingSessionUseNy && g_es_ny_high[centerIdx] > 0.0)
                  {
                     nearSessHigh = nearSessHigh || (MathAbs(hC - g_es_ny_high[centerIdx]) <= buf);
                     nearSessLow = nearSessLow || (MathAbs(lC - g_es_ny_low[centerIdx]) <= buf);
                  }
               }
               bool passExtremeSh = (!extremeOn) || nearDailyHigh || nearSessHigh;
               bool passExtremeSl = (!extremeOn) || nearDailyLow || nearSessLow;

               double rsiPivot = 0.0;
               bool hasRsiPivot = ((InpSwingBullDivEnabled || InpSwingRsiFilterEnabled) && GetRsiAtTime(tPivot, rsiPivot));
               double buyThr = (InpSwingRsiMode == SWING_RSI_AGGRESSIVE ? (double)InpSwingRsiBuyAgg : (double)InpSwingRsiBuyCons);
               double sellThr = (InpSwingRsiMode == SWING_RSI_AGGRESSIVE ? (double)InpSwingRsiSellAgg : (double)InpSwingRsiSellCons);
               bool passMacdSh = (!InpSwingMacdConfirmEnabled) || MacdBearCrossAtTime(tBarOpen);
               bool passMacdSl = (!InpSwingMacdConfirmEnabled) || MacdBullCrossAtTime(tBarOpen);

               bool shCore = (sh && (!InpSwingRequireReclaimAfterSweep || g_swing_allow_sh));
               bool shNormal = (shCore && passOppForSh && passSessionSh && passExtremeSh && passMacdSh);
               bool shRsiOverride = (shCore && InpSwingRsiFilterEnabled && hasRsiPivot && rsiPivot >= sellThr && RsiCrossAtTime(tPivot, false) && passExtremeSh && passMacdSh);
               bool shFinal = (InpSwingRsiFilterEnabled ? shRsiOverride : shNormal);

               if(shFinal && g_es_last_sp_sh_time != tPivot)
               {
                  datetime prevShTime = g_swing_last_sh_time;
                  double prevShPrice = g_swing_last_sh_price;
                  double prevShRsi = g_swing_last_sh_rsi;
                  bool prevShHas = g_swing_last_sh_has;

                  bool hasRsi = (InpSwingBullDivEnabled && hasRsiPivot);
                  bool bearDiv = false;
                  bool divNearDailyHigh = true;
                  if(InpSwingDivShowDailyExtreme)
                  {
                     double buf = (double)InpSwingDivDailyExtremeBufferPoints * _Point;
                     double dHi = g_es_daily_high[centerIdx];
                     divNearDailyHigh = (dHi > 0.0 && buf >= 0.0 && MathAbs(hC - dHi) <= buf);
                  }
                  if(hasRsi && prevShHas && divNearDailyHigh && hC > prevShPrice && rsiPivot < (prevShRsi - InpSwingDivMinRsiDelta) && (!InpSwingDivUseRsiThresholds || prevShRsi >= InpSwingDivBearPrevRsiMin))
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
                     if(g_swing_last_bear_div_time != tPivot)
                     {
                        NotifySignal("DIV BEAR", tBarOpen);
                        g_swing_last_bear_div_time = tPivot;
                     }
                  }

                  if(InpSwingShowLabels && (!InpQmOnlyMode || InpQmShowShSl))
                  {
                     string n = dayPfx + "SP_SH_" + IntegerToString((long)tPivot);
                     CreateOrUpdateText(n, tPivot, hC + 10 * _Point, "SH", clrRed, ANCHOR_LEFT_UPPER);
                  }
                  if(InpRsiCrossEnabled)
                  {
                     double bufD = (double)InpRsiCrossDailyExtremeBufferPoints * _Point;
                     double bufS = (double)InpRsiCrossSessionExtremeBufferPoints * _Point;
                     bool crossNearD = (!InpRsiCrossUseDailyExtreme) || (g_es_daily_high[centerIdx] > 0.0 && MathAbs(hC - g_es_daily_high[centerIdx]) <= bufD);
                     bool crossNearS = true;
                     if(InpRsiCrossUseSessionExtreme)
                     {
                        crossNearS = false;
                        if(InpRsiCrossSessionUseAsia && g_es_asia_high[centerIdx] > 0.0) crossNearS = crossNearS || (MathAbs(hC - g_es_asia_high[centerIdx]) <= bufS);
                        if(InpRsiCrossSessionUseLondon && g_es_london_high[centerIdx] > 0.0) crossNearS = crossNearS || (MathAbs(hC - g_es_london_high[centerIdx]) <= bufS);
                        if(InpRsiCrossSessionUseNy && g_es_ny_high[centerIdx] > 0.0) crossNearS = crossNearS || (MathAbs(hC - g_es_ny_high[centerIdx]) <= bufS);
                     }
                     bool crossOk = crossNearD && crossNearS;
                     if(crossOk && RsiCrossSignalAtTime(tPivot, false))
                     {
                        if(InpRsiCrossShowLabels)
                        {
                           string n2 = dayPfx + "RSI_CROSS_DN_" + IntegerToString((long)tPivot);
                           CreateOrUpdateText(n2, tPivot, hC + 22 * _Point, "RSI↓", clrOrange, ANCHOR_LEFT_UPPER);
                        }
                        NotifySignal("RSI CROSS DOWN", tBarOpen);
                     }
                  }
                  if(!InpQmOnlyMode || InpQmShowShSl) NotifySignal("SH", tBarOpen);
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

               bool slCore = (sl && (!InpSwingRequireReclaimAfterSweep || g_swing_allow_sl));
               bool slNormal = (slCore && passOppForSl && passSessionSl && passExtremeSl && passMacdSl);
               bool slRsiOverride = (slCore && InpSwingRsiFilterEnabled && hasRsiPivot && rsiPivot <= buyThr && RsiCrossAtTime(tPivot, true) && passExtremeSl && passMacdSl);
               bool slFinal = (InpSwingRsiFilterEnabled ? slRsiOverride : slNormal);

               if(slFinal && g_es_last_sp_sl_time != tPivot)
               {
                  datetime prevSlTime = g_swing_last_sl_time;
                  double prevSlPrice = g_swing_last_sl_price;
                  double prevSlRsi = g_swing_last_sl_rsi;
                  bool prevSlHas = g_swing_last_sl_has;

                  bool hasRsi = (InpSwingBullDivEnabled && hasRsiPivot);
                  bool bullDiv = false;
                  bool divNearDailyLow = true;
                  if(InpSwingDivShowDailyExtreme)
                  {
                     double buf = (double)InpSwingDivDailyExtremeBufferPoints * _Point;
                     double dLo = g_es_daily_low[centerIdx];
                     divNearDailyLow = (dLo > 0.0 && buf >= 0.0 && MathAbs(lC - dLo) <= buf);
                  }
                  if(hasRsi && prevSlHas && divNearDailyLow && lC < prevSlPrice && rsiPivot > (prevSlRsi + InpSwingDivMinRsiDelta) && (!InpSwingDivUseRsiThresholds || prevSlRsi <= InpSwingDivBullPrevRsiMax))
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
                     if(g_swing_last_bull_div_time != tPivot)
                     {
                        NotifySignal("DIV BULL", tBarOpen);
                        g_swing_last_bull_div_time = tPivot;
                     }
                  }

                  if(InpSwingShowLabels && (!InpQmOnlyMode || InpQmShowShSl))
                  {
                     string n = dayPfx + "SP_SL_" + IntegerToString((long)tPivot);
                     CreateOrUpdateText(n, tPivot, lC - 10 * _Point, "SL", clrLimeGreen, ANCHOR_LEFT_LOWER);
                  }
                  if(InpRsiCrossEnabled)
                  {
                     double bufD = (double)InpRsiCrossDailyExtremeBufferPoints * _Point;
                     double bufS = (double)InpRsiCrossSessionExtremeBufferPoints * _Point;
                     bool crossNearD = (!InpRsiCrossUseDailyExtreme) || (g_es_daily_low[centerIdx] > 0.0 && MathAbs(lC - g_es_daily_low[centerIdx]) <= bufD);
                     bool crossNearS = true;
                     if(InpRsiCrossUseSessionExtreme)
                     {
                        crossNearS = false;
                        if(InpRsiCrossSessionUseAsia && g_es_asia_low[centerIdx] > 0.0) crossNearS = crossNearS || (MathAbs(lC - g_es_asia_low[centerIdx]) <= bufS);
                        if(InpRsiCrossSessionUseLondon && g_es_london_low[centerIdx] > 0.0) crossNearS = crossNearS || (MathAbs(lC - g_es_london_low[centerIdx]) <= bufS);
                        if(InpRsiCrossSessionUseNy && g_es_ny_low[centerIdx] > 0.0) crossNearS = crossNearS || (MathAbs(lC - g_es_ny_low[centerIdx]) <= bufS);
                     }
                     bool crossOk = crossNearD && crossNearS;
                     if(crossOk && RsiCrossSignalAtTime(tPivot, true))
                     {
                        if(InpRsiCrossShowLabels)
                        {
                           string n2 = dayPfx + "RSI_CROSS_UP_" + IntegerToString((long)tPivot);
                           CreateOrUpdateText(n2, tPivot, lC - 22 * _Point, "RSI↑", clrAqua, ANCHOR_LEFT_LOWER);
                        }
                        NotifySignal("RSI CROSS UP", tBarOpen);
                     }
                  }
                  if(!InpQmOnlyMode || InpQmShowShSl) NotifySignal("SL", tBarOpen);
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

      UpdateQm(tBarOpen, c);

      string st = "CAP_IND | it " + IntegerToString(MinuteOfDayLocal(tBarOpen) / 60) + ":" + IntegerToString(MinuteOfDayLocal(tBarOpen) % 60) +
                  " | daily " + (g_daily_has ? "Y" : "N") + " | h02 " + (g_h02_has ? "Y" : "N") + " | h13 " + (g_h13_has ? "Y" : "N");
      CreateOrUpdateStatusLabel(st);
      g_prev_bar_low = l;
      g_prev_bar_low_has = true;
      g_prev_bar_high = h;
      g_prev_bar_high_has = true;
   }

   int OnInit()
   {
      if(InpShowOnlySwingSignals) DeleteByPrefix(g_prefix);
      CreateOrUpdateStatusLabel("CAP_IND loaded");
      UpdateChartComment("CAP_IND loaded");
      if(g_rsi_handle != INVALID_HANDLE) IndicatorRelease(g_rsi_handle);
      g_rsi_handle = iRSI(_Symbol, _Period, InpSwingRsiLen, PRICE_CLOSE);
      if(g_macd_handle != INVALID_HANDLE) IndicatorRelease(g_macd_handle);
      g_macd_handle = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
      if(g_atr_handle != INVALID_HANDLE) IndicatorRelease(g_atr_handle);
      g_atr_handle = iATR(_Symbol, _Period, 21);
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
      if(g_macd_handle != INVALID_HANDLE)
      {
         IndicatorRelease(g_macd_handle);
         g_macd_handle = INVALID_HANDLE;
      }
      if(g_atr_handle != INVALID_HANDLE)
      {
         IndicatorRelease(g_atr_handle);
         g_atr_handle = INVALID_HANDLE;
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

      static bool qmWasOnly = false;
      if(InpQmOnlyMode && !qmWasOnly)
      {
         DeleteByPrefix(g_prefix);
         qmWasOnly = true;
      }
      if(!InpQmOnlyMode) qmWasOnly = false;

      static bool belugaWasOnly = false;
      if(InpBelugaOnlyMode && !belugaWasOnly)
      {
         DeleteByPrefix(g_prefix);
         belugaWasOnly = true;
      }
      if(!InpBelugaOnlyMode) belugaWasOnly = false;

      if(!InpBelugaOnlyMode)
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
      else
      {
         ObjectDelete(0, g_prefix + "STATUS");
         UpdateChartComment("");
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
         DeleteByToken("QM_");
         ArrayResize(g_qm_types, 0);
         ArrayResize(g_qm_vals, 0);
         ArrayResize(g_qm_times, 0);
         ArrayResize(g_qm_baridx, 0);
         g_qm_check_be = 0;
         g_qm_check_bu = 0;
         g_qm_bear_start = 0.0;
         g_qm_bull_start = 0.0;
         g_qm_last_setup_time = 0;
         g_qm_entry_active = false;
         g_qm_entry_price = 0.0;
         g_qm_entry_dir = 0;
         g_qm_entry_setup_time = 0;
         g_qm_entry_notified = false;

         ArrayResize(g_st_factors, 0);
         ArrayResize(g_st_holder, 0);
         g_st_inited = false;
         g_st_prev_close = 0.0;
         g_st_prev_close_has = false;
         g_st_atr = 0.0;
         g_st_atr_has = false;
         g_st_den = 0.0;
         g_st_den_has = false;
         g_st_os = 0;
         g_st_upper = 0.0;
         g_st_lower = 0.0;
         g_st_last_params_hash = 0;
         g_st_last_signal_time = 0;

         ArrayResize(g_bb_times, 0);
         ArrayResize(g_bb_highs, 0);
         ArrayResize(g_bb_lows, 0);
         g_bb_last_swing_high_time = 0;
         g_bb_last_swing_low_time = 0;
         g_bb_trend_has = false;
         g_bb_trend = false;
         DeleteByToken("BB_");

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
            if(InpBelugaEnabled && (InpBelugaOnlyMode || InpBelugaShowBB))
               BelugaUpdate(time[ii], high[ii], low[ii]);
         }

         if(!InpBelugaOnlyMode)
         {
            UpdateRightSideLabels(time[curIndex]);
            if(InpDebugOverlay && !InpShowOnlySwingSignals)
            {
               CreateOrUpdateText(g_prefix + "PING", time[curIndex], close[curIndex], "CAP_IND", clrYellow, ANCHOR_LEFT_UPPER);
            }
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

      if(!InpBelugaOnlyMode)
      {
         QmCheckEntryTouchRealtime(time[curIdx], high[curIdx], low[curIdx]);
         UpdateRightSideLabels(time[curIdx]);
         if(InpDebugOverlay && !InpShowOnlySwingSignals)
         {
            CreateOrUpdateText(g_prefix + "PING", time[curIdx], close[curIdx], "CAP_IND", clrYellow, ANCHOR_LEFT_UPPER);
         }
      }
      if(InpBelugaEnabled && (InpBelugaOnlyMode || InpBelugaShowBB))
         BelugaUpdate(time[curIdx], high[curIdx], low[curIdx]);
      return rates_total;
   }
