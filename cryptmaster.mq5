#include "Handler.mqh"
//**************************************************
// 定義（define）
//**************************************************
#define GET_BUY_PRICE	SymbolInfoDouble(Symbol(),SYMBOL_ASK)		// 買い注文価格
#define GET_SELL_PRICE	SymbolInfoDouble(Symbol(),SYMBOL_BID)		// 売り注文価格
//**************************************************
// アプリ表示データ
//**************************************************
#property copyright 	"Copyright 2021, Team T&T."
#property link			"https://www.mql5.com"
#property version		EA_VERSION

CHandler* C_Handler = CHandler::GetHandler();
CLogger*  C_logger = CLogger::GetLog();

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    C_Handler.OnInit();
    return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    C_Handler.OnDeinit(reason);
//--- destroy timer
    EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  C_Handler.OnTick();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
  C_Handler.OnTimer();
}
