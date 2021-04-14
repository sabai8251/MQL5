#include "Handler.mqh"
#include "DisplayInfo.mqh"
//**************************************************
// 定義（define）
//**************************************************
#define EA_START_DATE	"2019.10.1 00:00"		// EA利用開始日
#define EA_END_DATE		"2021.12.1 00:00"		// EA利用終了日
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
CDisplayInfo* C_DisplayInfo = CDisplayInfo::GetDisplayInfo();


// *************************************************************************
//	機能		： 有効期限チェック関数
//	注意		： なし
//	メモ		： なし
//	引数		： なし
//	返り値		： TRUE: 有効期限内、FALSE: 有効期限外
//	参考URL		： なし
// **************************	履	歴	************************************
// 		v1.0		2021.04.14			Taji		新規
// *************************************************************************/
bool Chk_Expired(void){
	
	datetime start;		// 利用開始日 
	datetime end;		// 利用終了日
	datetime now;		// 現在日時

	start = StringToTime( EA_START_DATE );		// 利用開始日 
	end = StringToTime( EA_END_DATE );			// 利用終了日
	now = TimeLocal();							// 現在日時（ローカル時間）
//	now = TimeCurrent();						// 現在日時
	
	/* 有効期限 */
	if( ( start < now ) && ( now < end ) ){		// 期限内
		
		return true;
	}
	else{
		C_logger.output_log_to_file("CryptoMasterSystem Expired");
		return false;
	}
}
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
	
//	Print("start timer");
//	C_logger.output_log_to_file("1分");
	
	// 有効期限切れ
	if( Chk_Expired() == false ){
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
//	C_logger.output_log_to_file("OnTick i=" + (string)i + "買い=" + (string)GET_BUY_PRICE  + "売り=" + (string)GET_SELL_PRICE );
  C_DisplayInfo.UpdateOrderInfo();		// 注文情報を更新
  //SetTP();				// TPを設定★ここはいったんコメント.COrderManagerに関数作ったがChandlerクラスからのみ呼んだほうがいい by taji
  C_DisplayInfo.ShowData();				// コメントをチャート上に表示
	
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
