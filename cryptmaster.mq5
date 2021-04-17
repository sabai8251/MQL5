#include "Handler.mqh"
//**************************************************
// 定義（define）
//**************************************************
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
int OnInit(){
	C_Handler.OnInit();
	return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
	C_Handler.OnDeinit(reason);
	//--- destroy timer
	EventKillTimer();
 }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
	C_Handler.OnTick();
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(){
	C_Handler.OnTimer();
}

void OnTradeTransaction(
	const MqlTradeTransaction&    trans,        // 取引トランザクション構造体
	const MqlTradeRequest&      request,      //リクエスト構造体
	const MqlTradeResult&       result       // 結果構造体
){
	C_Handler.OnTradeTransaction(trans,request,result);
}