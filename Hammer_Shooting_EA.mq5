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

CTrade trade;
datetime last_bar_time = 0;
ulong last_partial_ticket = 0;
bool partial_done = false;

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
      
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   ManagePartialClose();

   if(HasOpenPositionForThisEA()) return;

   datetime current_time = iTime(_Symbol, _Period, 0);
   if(current_time == last_bar_time) return; // Lavora solo su candela chiusa
   
   if(InpOnlyLondonNy && !IsLondonNySession(TimeTradeServer()))
   {
      last_bar_time = current_time;
      return;
   }
   
   // Dati candele
   double o[2], h[2], l[2], c[2];
   datetime t[2];
   if(CopyOpen(_Symbol, _Period, 1, 2, o) <= 0) return;
   if(CopyHigh(_Symbol, _Period, 1, 2, h) <= 0) return;
   if(CopyLow(_Symbol, _Period, 1, 2, l) <= 0) return;
   if(CopyClose(_Symbol, _Period, 1, 2, c) <= 0) return;
   if(CopyTime(_Symbol, _Period, 1, 2, t) <= 0) return;
   
   // Indici array: [1] è candela corrente appena chiusa (shift 1), [0] è candela precedente (shift 2)
   bool isGreen = (c[1] > o[1]);
   bool isRed = (c[1] < o[1]);
   
   bool hammer = false;
   bool shoot = false;
   datetime sigTime = t[1];
   
   if(!InpConfirmByNextCandle)
   {
      hammer = IsHammerCandle(o[1], h[1], l[1], c[1]);
      shoot = IsShootingCandle(o[1], h[1], l[1], c[1]);
   }
   else
   {
      // [0] = sigIndex, [1] = confirmIndex (candela chiusa ora)
      hammer = IsHammerCandle(o[0], h[0], l[0], c[0]) && isGreen;
      shoot = IsShootingCandle(o[0], h[0], l[0], c[0]) && isRed;
      sigTime = t[0];
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
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         if(InpStopLoss > 0) sl = ask - (InpStopLoss * point);
         if(InpTakeProfit > 0) tp = ask + (InpTakeProfit * point);
         
         trade.Buy(InpLotSize, _Symbol, ask, sl, tp, "Hammer Buy");
      }
   }
   
   if(shoot)
   {
      bool confirmed = (!InpConfirmWithDxy || !IsXauSymbol() || (haveDxy && dxyBull));
      if(!InpRequireConfirmation || confirmed)
      {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(InpStopLoss > 0) sl = bid + (InpStopLoss * point);
         if(InpTakeProfit > 0) tp = bid - (InpTakeProfit * point);
         
         trade.Sell(InpLotSize, _Symbol, bid, sl, tp, "Shooting Sell");
      }
   }
   
   last_bar_time = current_time;
}
