#include "Handler.mqh"
#include "CheckerExpired.mqh"
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
CCheckerExpired*  C_CheckerExpired = CCheckerExpired::GetCheckerExpired();
CLogger*  C_logger = CLogger::GetLog();

// *************************************************************************
//	機能		： 1秒ごとに実行される関数
//	注意		： なし
//	メモ		： タイマー関数内でコール
//	引数		： なし
//	返り値		： なし
//	参考URL		： なし
// **************************	履	歴	************************************
// 		v1.0		2021.04.14			Taji		新規
// *************************************************************************/
void OnTimer1sec() {

//	C_logger.output_log_to_file("1秒");
}
// *************************************************************************
//	機能		： 1分ごとに実行される関数
//	注意		： なし
//	メモ		： タイマー関数内でコール
//	引数		： なし
//	返り値		： なし
//	参考URL		： なし
// **************************	履	歴	************************************
// 		v1.0		2021.04.14			Taji		新規
// *************************************************************************/
void OnTimer1min() {
	// 有効期限切れ
	if( C_CheckerExpired.Chk_Expired() == false ){
		C_logger.output_log_to_file("1分タイマー終了処理");
		ExpertRemove();					// OnDeinit()をコールしてEA終了処理
	}	
}
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
  static int i = 0;

 	OnTimer1sec();			// 1秒ごとに実施する関数
  // 1分
  if( i == 3 ){
		OnTimer1min();		// 1分ごとに実施する関数
		i = 1;
	}
	else{
		i++;
	}
}
