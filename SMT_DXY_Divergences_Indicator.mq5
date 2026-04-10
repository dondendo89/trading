//+------------------------------------------------------------------+
//|                                                      SMT_MT5.mq5 |
//|                                        Copyright 2024, Gemini AI |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Gemini AI"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

// --- INPUT PARAMETERS ---
input group "Logic Setting"
input bool InpShowHistorical = true;       // Show Historical SMT
input int  InpMaxBarsBack    = 1000;       // Max Bars to scan (Performance)

input group "Symbol 1 Settings"
input bool   InpUseSym1      = true;       // Use Symbol 1
input string InpSym1         = "DXY";      // Symbol 1 Name (es. DXY o USDX)
input bool   InpInvertSym1   = true;       // Invert Symbol 1 (Price -> 1/Price)

input group "Symbol 2 Settings"
input bool   InpUseSym2      = false;      // Use Symbol 2
input string InpSym2         = "GBPUSD";   // Symbol 2 Name
input bool   InpInvertSym2   = false;      // Invert Symbol 2

input group "Style Options"
input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID; // Line Style
input color InpBullColor     = clrLimeGreen;      // Bullish SMT Color
input color InpBearColor     = clrRed;            // Bearish SMT Color
input int   InpLineWidth     = 2;                 // Line Width

input group "Alerts"
input bool InpSendAlert      = true;       // Enable Terminal Alerts
input bool InpSendPush       = false;      // Enable Push Notifications
input bool InpNotifyHistorical = false;    // Notify also during history scan

// --- GLOBAL VARIABLES ---
string g_keys[];
datetime g_last_alert_time = 0;

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+

// Verifica se la linea esiste già per evitare duplicati
bool IsNewLine(datetime t1, double p1, datetime t2, double p2) {
   string key = IntegerToString((long)t1) + DoubleToString(p1, 5) + 
                IntegerToString((long)t2) + DoubleToString(p2, 5);
   int size = ArraySize(g_keys);
   for(int i=0; i<size; i++) if(g_keys[i] == key) return false;
   ArrayResize(g_keys, size + 1);
   g_keys[size] = key;
   return true;
}

// Calcola la pendenza tra due punti
double GetSlope(double p1, double p2, int b1, int b2) {
   if(b1 == b2) return 0;
   return (p2 - p1) / (double)(b2 - b1);
}

// Identificazione Pivot High
bool IsPivotHigh(const double &high[], int i, int n) {
   if(i < n || i >= ArraySize(high) - n) return false;
   for(int j=1; j<=n; j++) if(high[i-j] > high[i] || high[i+j] > high[i]) return false;
   return true;
}

// Identificazione Pivot Low
bool IsPivotLow(const double &low[], int i, int n) {
   if(i < n || i >= ArraySize(low) - n) return false;
   for(int j=1; j<=n; j++) if(low[i-j] < low[i] || low[i+j] < low[i]) return false;
   return true;
}

// Recupera il prezzo del simbolo esterno gestendo l'inversione
double GetExtPrice(string symbol, datetime t, bool isHigh, bool invert) {
   double p[1];
   int shift = iBarShift(symbol, _Period, t, true);
   if(shift < 0) return 0;
   
   if(isHigh) {
      if(invert) { if(CopyLow(symbol, _Period, shift, 1, p) > 0 && p[0] != 0) return 1.0/p[0]; }
      else { if(CopyHigh(symbol, _Period, shift, 1, p) > 0) return p[0]; }
   } else {
      if(invert) { if(CopyHigh(symbol, _Period, shift, 1, p) > 0 && p[0] != 0) return 1.0/p[0]; }
      else { if(CopyLow(symbol, _Period, shift, 1, p) > 0) return p[0]; }
   }
   return 0;
}

// Disegna linea e label sul grafico
void CreateSMT(string name, datetime t1, double p1, datetime t2, double p2, color clr, string labelText) {
   name = "SMT_" + name;
   if(ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2)) {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, InpLineStyle);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, InpLineWidth);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      
      string lblName = name + "_LBL";
      ObjectCreate(0, lblName, OBJ_TEXT, 0, (t1+t2)/2, (p1+p2)/2);
      ObjectSetString(0, lblName, OBJPROP_TEXT, labelText);
      ObjectSetInteger(0, lblName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, lblName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, lblName, OBJPROP_ANCHOR, ANCHOR_CENTER);
      ObjectSetInteger(0, lblName, OBJPROP_SELECTABLE, false);
   }
}

void NotifySmt(const string side, const string symExt, datetime t)
{
   string msg = "SMT " + side + " detected on " + _Symbol + " vs " + symExt + " TF=" + EnumToString(_Period);
   if(InpSendAlert) Alert(msg);
   if(InpSendPush) SendNotification(msg);
   g_last_alert_time = t;
}

//+------------------------------------------------------------------+
//| Standard Indicator Functions                                     |
//+------------------------------------------------------------------+
int OnInit() {
   ArrayResize(g_keys, 0);
   if(InpUseSym1) SymbolSelect(InpSym1, true);
   if(InpUseSym2) SymbolSelect(InpSym2, true);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   ObjectsDeleteAll(0, "SMT_");
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &volume[],
                const int &spread[]) {
   
   if(rates_total < 150) return 0;
   
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   if(prev_calculated == 0) {
      ObjectsDeleteAll(0, "SMT_");
      ArrayResize(g_keys, 0);
   }

   // Logica timeframe (n = forza del pivot)
   int n = 9;
   long sec = PeriodSeconds();
   if(sec <= 900) n = 14;        // M1-M15
   else if(sec == 3600) n = 10;  // H1
   else if(sec >= 14400) n = 8;  // H4+

   int limit = (prev_calculated == 0) ? MathMin(rates_total - n - 5, InpMaxBarsBack) : 2;

   for(int i = limit; i >= 1; i--) {
      if(InpUseSym1) ProcessSMTLogic(i, n, time, high, low, InpSym1, InpInvertSym1, "S1");
      if(InpUseSym2) ProcessSMTLogic(i, n, time, high, low, InpSym2, InpInvertSym2, "S2");
   }

   return(rates_total);
}

void ProcessSMTLogic(int i, int n, const datetime &time[], const double &high[], const double &low[], 
                     string sym, bool invert, string prefix) {
   
   // --- BEARISH SMT (Highs) ---
   if(IsPivotHigh(high, i, n)) {
      int p2 = -1;
      for(int j=i+1; j<i+100 && j<ArraySize(high)-n; j++) {
         if(IsPivotHigh(high, j, n)) { p2 = j; break; }
      }
      
      if(p2 != -1) {
         double h1 = high[i], h2 = high[p2];
         double oh1 = GetExtPrice(sym, time[i], true, invert);
         double oh2 = GetExtPrice(sym, time[p2], true, invert);
         
         if(oh1 > 0 && oh2 > 0) {
            double slopeGraph = GetSlope(h2, h1, p2, i);
            double slopeExt   = GetSlope(oh2, oh1, p2, i);
            
            if((slopeGraph > 0 && slopeExt < 0) || (slopeGraph < 0 && slopeExt > 0)) {
               if(IsNewLine(time[p2], h2, time[i], h1)) {
                  CreateSMT(prefix+"_BEAR_"+IntegerToString(time[i]), time[p2], h2, time[i], h1, InpBearColor, "- SMT");
                  bool allowNotify = InpNotifyHistorical || i <= 2;
                  if(allowNotify)
                     NotifySmt("BEARISH", sym, time[i]);
               }
            }
         }
      }
   }

   // --- BULLISH SMT (Lows) ---
   if(IsPivotLow(low, i, n)) {
      int p2 = -1;
      for(int j=i+1; j<i+100 && j<ArraySize(low)-n; j++) {
         if(IsPivotLow(low, j, n)) { p2 = j; break; }
      }
      
      if(p2 != -1) {
         double l1 = low[i], l2 = low[p2];
         double ol1 = GetExtPrice(sym, time[i], false, invert);
         double ol2 = GetExtPrice(sym, time[p2], false, invert);
         
         if(ol1 > 0 && ol2 > 0) {
            double slopeGraph = GetSlope(l2, l1, p2, i);
            double slopeExt   = GetSlope(ol2, ol1, p2, i);
            
            if((slopeGraph > 0 && slopeExt < 0) || (slopeGraph < 0 && slopeExt > 0)) {
               if(IsNewLine(time[p2], l2, time[i], l1)) {
                  CreateSMT(prefix+"_BULL_"+IntegerToString(time[i]), time[p2], l2, time[i], l1, InpBullColor, "+ SMT");
                  bool allowNotify = InpNotifyHistorical || i <= 2;
                  if(allowNotify)
                     NotifySmt("BULLISH", sym, time[i]);
               }
            }
         }
      }
   }
}
