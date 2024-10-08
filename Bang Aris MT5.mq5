//-------------------------------------------------------------+
//  Etasoft Inc. Forex EA and Script Generator version 7.x   EA|
//-------------------------------------------------------------+
// Keywords: MT4, Forex EA builder, create EA, expert advisor developer

#property copyright "Copyright © 2014-2020, Etasoft Inc. Forex EA Generator v7.x"
#property link      "http://www.forexgenerator.com"

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
// exported variables
input double   Lots10         = 0.01;
input int      Stoploss10     = 20;
input int      Takeprofit10   = 30;
input double   Lots11         = 0.01;
input int      Stoploss11     = 20;
input int      Takeprofit11   = 30;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
// local variables
double PipValue=1;    // this variable is here to support 5-digit brokers
bool Terminated = false;
string LF = "\n";  // use this in custom or utility blocks where you need line feeds
int NDigits = 4;   // used mostly for NormalizeDouble in Flex type blocks
int ObjCount = 0;  // count of all objects created on the chart, allows creation of objects with unique names
int current = 0;
ENUM_ORDER_TYPE_FILLING FillingMode = ORDER_FILLING_FOK;

int handle1 = 0;
int handle2 = 0;
int handle3 = 0;
int handle4 = 0;
int handle5 = 0;
int handle6 = 0;
int handle7 = 0;
int handle8 = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   NDigits = Digits();
   if (NDigits == 3 || NDigits == 5) PipValue = 10;

   if (AccountInfoInteger(ACCOUNT_TRADE_EXPERT) == false) {
      Print("Check terminal options because EA trade option is set to not allowed.");
      Comment("Check terminal options because EA trade option is set to not allowed.");
   }
   FillingMode = ORDER_FILLING_FOK;

   if (false) ObjectsDeleteAll(0);      // clear the chart

   handle1 = iMA(NULL, PERIOD_CURRENT,8,0,MODE_EMA,PRICE_CLOSE);
   handle2 = iMA(NULL, PERIOD_CURRENT,19,0,MODE_EMA,PRICE_CLOSE);
   handle3 = iCCI(NULL, PERIOD_CURRENT,20,PRICE_CLOSE);
   handle4 = iCCI(NULL, PERIOD_CURRENT,20,PRICE_CLOSE);
   handle5 = iMA(NULL, PERIOD_CURRENT,8,0,MODE_EMA,PRICE_CLOSE);
   handle6 = iMA(NULL, PERIOD_CURRENT,19,0,MODE_EMA,PRICE_CLOSE);
   handle7 = iCCI(NULL, PERIOD_CURRENT,20,PRICE_CLOSE);
   handle8 = iCCI(NULL, PERIOD_CURRENT,20,PRICE_CLOSE);

   Comment("");    // clear the chart
//---
   return(0);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   if (false) ObjectsDeleteAll(0);

   IndicatorRelease(handle1);
   IndicatorRelease(handle2);
   IndicatorRelease(handle3);
   IndicatorRelease(handle4);
   IndicatorRelease(handle5);
   IndicatorRelease(handle6);
   IndicatorRelease(handle7);
   IndicatorRelease(handle8);

   return;
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   if (Terminated == true) {
      Comment("EA Terminated.");
   }

   OnEveryTick1();
   return;
}

//+------------------------------------------------------------------+
//| Get Low for specified bar index                                  |
//+------------------------------------------------------------------+
double Low(int index)
{
   double arr[];
   double low = 0;
   ArraySetAsSeries(arr, true);
   int copied = CopyLow(Symbol(), PERIOD_CURRENT, 0, Bars(Symbol(), PERIOD_CURRENT), arr);
   if(copied>0 && index<copied){low = arr[index];};
   return low;
}
//+------------------------------------------------------------------+
//| Get the High for specified bar index                             |
//+------------------------------------------------------------------+
double High(int index)
{
   double arr[];
   double high = 0;
   ArraySetAsSeries(arr, true);
   int copied = CopyHigh(Symbol(), PERIOD_CURRENT, 0, Bars(Symbol(), PERIOD_CURRENT), arr);
   if(copied>0 && index<copied){high=arr[index];};
   return high;
}
//+------------------------------------------------------------------+
//| Get Close for specified bar index                                |
//+------------------------------------------------------------------+
double Close(int index)
{
   double arr[];
   double close = 0;
   ArraySetAsSeries(arr, true);
   int copied = CopyClose(Symbol(), PERIOD_CURRENT, 0, Bars(Symbol(), PERIOD_CURRENT), arr);
   if(copied>0 && index<copied){close = arr[index];};
   return close;
}
//+------------------------------------------------------------------+
//| Get Open for specified bar index                                 |
//+------------------------------------------------------------------+
double Open(int index)
{
   double arr[];
   double open = 0;
   ArraySetAsSeries(arr, true);
   int copied = CopyOpen(Symbol(), PERIOD_CURRENT, 0, Bars(Symbol(), PERIOD_CURRENT), arr);
   if(copied>0 && index<copied){open = arr[index];};
   return open;
}
//+------------------------------------------------------------------+
//| Get current bid value                                            |
//+------------------------------------------------------------------+
double Bid()
{
   return (SymbolInfoDouble(Symbol(), SYMBOL_BID));
}

//+------------------------------------------------------------------+
//| Get current ask value                                            |
//+------------------------------------------------------------------+
double Ask()
{
   return (SymbolInfoDouble(Symbol(), SYMBOL_ASK));
}

//+------------------------------------------------------------------+
//| Is there an error                                                |
//+------------------------------------------------------------------+
bool IsError(MqlTradeResult& result, string function)
{
   if(result.retcode != 0 && result.retcode != TRADE_RETCODE_DONE && result.retcode != TRADE_RETCODE_PLACED){
      Print("Function: ", function, " Error: ", result.retcode, " ", result.comment);
      return true;
   }
   else{
      Print("> Executed: [", function, "]");
   }   
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsError(CTrade& trade, string function)
{
   if(trade.ResultRetcode() != 0 && trade.ResultRetcode() != TRADE_RETCODE_DONE && trade.ResultRetcode() != TRADE_RETCODE_PLACED) {
     Print("Function: ", function, " Error: ", trade.ResultRetcode(), " ", trade.ResultRetcodeDescription());
     
     return true;
   } 
   else{
      Print("> Executed: [", function, "]");
   }   
   return false;
}

//+------------------------------------------------------------------+
//| Get indicator value back                                         |
//+------------------------------------------------------------------+
double GetIndicator(int handle, int buffer_num, int index)
{
//--- array for the indicator values
   double arr[];
   ArraySetAsSeries(arr, true);
//--- obtain the indicator value in the last two bars
   if (CopyBuffer(handle, buffer_num, 0, index+1, arr) <= 0) {
      Sleep(200);
      for(int i=0; i<100; i++) {
         if (BarsCalculated(handle) > 0)
            break;
         Sleep(50);
      }
      int copied = CopyBuffer(handle, buffer_num, 0, index+1, arr);
      if(copied <= 0){
         Print("CopyBuffer failed. Maybe history has not download yet? Error = ", GetLastError());
         return -1;
      }
      else{
         return arr[index];
      }   
   }
   else{
      return arr[index];
   }

   return 0;
}

//+------------------------------------------------------------------+
//| Building blocks                                                  |
//+------------------------------------------------------------------+
void OnEveryTick1()
{

   if(NDigits == 3 || NDigits == 5){PipValue = 10;};

   TechnicalAnalysis2();
   TechnicalAnalysis8();

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TechnicalAnalysis2(){

   if(GetIndicator(handle1,0,current) > GetIndicator(handle2,0,current)){
      TechnicalAnalysis3();
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TechnicalAnalysis3(){

   if(GetIndicator(handle3,0,current) > 150){
      TechnicalAnalysis4();
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TechnicalAnalysis4(){

   if(GetIndicator(handle4,0,current+1) < 150){
      IfPositionDoesNotExist5();

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IfPositionDoesNotExist5(){

   bool exists = false;

   // go through all positions
   for(int i=PositionsTotal()-1;i>=0;i--){
      
      string symbol = PositionGetSymbol(i);
      if(symbol == Symbol()){
         // position with appropriate ORDER_MAGIC, symbol and order type
         if(PositionGetInteger(POSITION_MAGIC) == 1 && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
            exists = true;
         }   
      }
   }

   if (exists == false){
      BuyOrder10();

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BuyOrder10(){

   //--- prepare a request
   MqlTradeRequest request;
   ZeroMemory(request);
   request.action = TRADE_ACTION_DEAL;                      // setting a deal order
   request.magic = 1;                                       // ORDER_MAGIC
   request.symbol = Symbol();                               // symbol
   request.volume= Lots10;                                  // volume in lots
   request.price = Ask();
   request.sl = Ask() - Stoploss10*PipValue*Point();        // Stop Loss specified
   request.tp = Ask() + Takeprofit10*PipValue*Point();      // Take Profit specified
   request.deviation= 4;             // deviation in points
   request.type = ORDER_TYPE_BUY;
   request.comment = "Order";
   request.type_filling = FillingMode;
   MqlTradeResult result;
   ZeroMemory(result);
   bool ok = OrderSend(request,result);
// check the result
   if (ok && !IsError(result, __FUNCTION__)) {

   }


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TechnicalAnalysis8()
{

   if (GetIndicator(handle5,0,current) < GetIndicator(handle6,0,current)) {
      TechnicalAnalysis7();

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TechnicalAnalysis7()
{

   if (GetIndicator(handle7,0,current) < -150) {
      TechnicalAnalysis6();

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TechnicalAnalysis6()
{

   if (GetIndicator(handle8,0,current+1) > -150) {
      IfPositionDoesNotExist9();

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IfPositionDoesNotExist9()
{

   bool exists = false;

// go through all positions
   for (int i=PositionsTotal()-1;i>=0;i--) {
      string symbol = PositionGetSymbol(i);
      if (symbol == Symbol()) {
         // position with appropriate ORDER_MAGIC, symbol and order type
         if (PositionGetInteger(POSITION_MAGIC) == 2 && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
            exists = true;
      }
   }

   if (exists == false) {
      SellOrder11();

   }


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SellOrder11()
{

//--- prepare a request
   MqlTradeRequest request;
   ZeroMemory(request);

   request.action = TRADE_ACTION_DEAL;          // setting a deal order
   request.magic = 2;                   // ORDER_MAGIC
   request.symbol = Symbol();                   // symbol
   request.volume = Lots11;                      // volume in lots
   request.price = Bid();
   request.sl = Bid() + Stoploss11*PipValue*Point();      // Stop Loss specified
   request.tp = Bid() - Takeprofit11*PipValue*Point();    // Take Profit specified
   request.deviation = 4;             // deviation in points
   request.type = ORDER_TYPE_SELL;
   request.comment = "Order";
   request.type_filling = FillingMode;
   MqlTradeResult result;
   ZeroMemory(result);
   bool ok = OrderSend(request,result);
   
   // check the result
   if (ok && !IsError(result, __FUNCTION__)) {

   }
}





