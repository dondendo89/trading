//+------------------------------------------------------------------+
//|                                     SMT_FORCE_LAST_5_ALERTS.mq5  |
//|                                  Copyright 2026, Gemini AI       |
//+------------------------------------------------------------------+
#property copyright "Gemini AI"
#property indicator_chart_window
#property indicator_plots   0

input group "Asset 1"
input string  SymbolCompare1 = "DXY.cash"; 
input bool    InvertSymbol1  = true;

input group "Asset 2"
input bool    UseAsset2      = true;
input string  SymbolCompare2 = "UKOIL.cash"; 
input bool    InvertSymbol2  = true;

input group "Configurazione"
input int     PivotLeft      = 5;
input int     PivotRight     = 5;
input int     MaxBarsHistory = 500;
input color   TextColor      = clrWhite;

input group "Notifiche"
input bool    Send_Push      = true;
input bool    Send_Alert     = true; 
input int     AlertLimit     = 5;    // Quanti SMT "passati" notificare all'avvio

// Variabile per contare gli alert inviati all'avvio
int alertCounter = 0;
datetime lastAlertTime;

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &spread[], const int &stop_level[])
{
    if(prev_calculated == 0) alertCounter = 0; // Reset al caricamento

    double comp1H[], comp1L[], comp2H[], comp2L[];
    ArraySetAsSeries(comp1H, true); ArraySetAsSeries(comp1L, true);
    ArraySetAsSeries(comp2H, true); ArraySetAsSeries(comp2L, true);
    ArraySetAsSeries(high, true);   ArraySetAsSeries(low, true);
    ArraySetAsSeries(time, true);

    int copied1 = CopyHigh(SymbolCompare1, _Period, 0, rates_total, comp1H);
    int copied1L = CopyLow(SymbolCompare1, _Period, 0, rates_total, comp1L);

    int copied2 = 0;
    if(UseAsset2) {
        copied2 = CopyHigh(SymbolCompare2, _Period, 0, rates_total, comp2H);
        CopyLow(SymbolCompare2, _Period, 0, rates_total, comp2L);
    }

    if(copied1 <= 0) return(0);

    int limit = (prev_calculated == 0) ? MathMin(rates_total, MaxBarsHistory) : 10;
    int safe_limit = MathMin(limit, copied1 - PivotLeft - 1);

    // Ciclo al contrario (dal più recente al più vecchio) per contare gli ultimi 5
    for(int i = PivotRight; i < safe_limit; i++) {
        // --- SMT High ---
        if(isPivotHigh(high, i)) {
            int prevIdx = findPrevPivot(high, i, true);
            if(prevIdx != -1 && prevIdx < copied1) {
                checkAndDraw(high[i], high[prevIdx], comp1H[i], comp1H[prevIdx], time[i], true, SymbolCompare1, InvertSymbol1);
                if(UseAsset2 && copied2 > prevIdx) 
                    checkAndDraw(high[i], high[prevIdx], comp2H[i], comp2H[prevIdx], time[i], true, SymbolCompare2, InvertSymbol2);
            }
        }
        // --- SMT Low ---
        if(isPivotLow(low, i)) {
            int prevIdx = findPrevPivot(low, i, false);
            if(prevIdx != -1 && prevIdx < copied1) {
                checkAndDraw(low[i], low[prevIdx], comp1L[i], comp1L[prevIdx], time[i], false, SymbolCompare1, InvertSymbol1);
                if(UseAsset2 && copied2 > prevIdx) 
                    checkAndDraw(low[i], low[prevIdx], comp2L[i], comp2L[prevIdx], time[i], false, SymbolCompare2, InvertSymbol2);
            }
        }
    }
    return(rates_total);
}

void checkAndDraw(double currM, double prevM, double currC, double prevC, datetime t, bool isBear, string symName, bool invert) {
    if(invert) { currC = (currC!=0)?1.0/currC:0; prevC = (prevC!=0)?1.0/prevC:0; }
    double slopeMain = currM - prevM;
    double slopeComp = currC - prevC;
    
    if((slopeMain > 0 && slopeComp < 0) || (slopeMain < 0 && slopeComp > 0)) {
        string objId = symName + "_" + IntegerToString((long)t);
        string arrowName = "SMT_Arr_" + objId;
        
        if(ObjectFind(0, arrowName) < 0) {
            ObjectCreate(0, arrowName, OBJ_ARROW, 0, t, currM);
            ObjectSetInteger(0, arrowName, OBJPROP_ARROWCODE, isBear ? 242 : 241);
            ObjectSetInteger(0, arrowName, OBJPROP_COLOR, isBear ? clrRed : clrLime);
            ObjectSetInteger(0, arrowName, OBJPROP_WIDTH, 2);

            string txtName = "SMT_Txt_" + objId;
            ObjectCreate(0, txtName, OBJ_TEXT, 0, t, currM);
            ObjectSetString(0, txtName, OBJPROP_TEXT, "  " + symName);
            ObjectSetInteger(0, txtName, OBJPROP_COLOR, TextColor);
            ObjectSetInteger(0, txtName, OBJPROP_ANCHOR, isBear ? ANCHOR_BOTTOM : ANCHOR_TOP);

            // LOGICA ALERT "FORCE LAST 5"
            bool isRecent = (TimeCurrent() - t < PeriodSeconds() * (PivotRight + 2));
            bool forceAlert = (alertCounter < AlertLimit);

            if(t > lastAlertTime && (isRecent || forceAlert)) {
                string msg = "SMT " + (isBear?"Bearish":"Bullish") + " su " + _Symbol + " vs " + symName + " al " + TimeToString(t);
                
                if(Send_Alert) Alert(msg);
                if(Send_Push)  SendNotification(msg);
                
                Print(">>> Alert Eseguito per SMT del: ", TimeToString(t));
                
                lastAlertTime = t;
                if(!isRecent) alertCounter++; // Conta solo quelli "vecchi" forzati
            }
        }
    }
}

bool isPivotHigh(const double &price[], int i) {
    if(i + PivotLeft >= ArraySize(price) || i - PivotRight < 0) return false;
    for(int j=1; j<=PivotLeft; j++) if(price[i] < price[i+j]) return false;
    for(int j=1; j<=PivotRight; j++) if(price[i] < price[i-j]) return false;
    return true;
}

bool isPivotLow(const double &price[], int i) {
    if(i + PivotLeft >= ArraySize(price) || i - PivotRight < 0) return false;
    for(int j=1; j<=PivotLeft; j++) if(price[i] > price[i+j]) return false;
    for(int j=1; j<=PivotRight; j++) if(price[i] > price[i-j]) return false;
    return true;
}

int findPrevPivot(const double &price[], int start, bool high) {
    for(int j = start + 1; j < start + 300 && j < ArraySize(price) - PivotLeft; j++) {
        if(high && isPivotHigh(price, j)) return j;
        if(!high && isPivotLow(price, j)) return j;
    }
    return -1;
}