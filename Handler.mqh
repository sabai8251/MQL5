//**************************************************
// class CHandler
//**************************************************
#include "Logger.mqh"
#include "OrderManager.mqh"
#include "DisplayInfo.mqh"
#include "CheckerException.mqh"
#define BASE_LOT 0.01
#define BASE_DIFF_PRICE_TO_ORDER1		120		// 追加注文判定用基準変動価格1
#define BASE_DIFF_PRICE_TO_ORDER2		140		// 追加注文判定用基準変動価格2
#define MAX_ORDER_NUM 8 // 追加数制限
class CHandler
{
    private:
      static CHandler*  m_handler;

      CLogger*          C_logger;
      COrderManager*    C_OrderManager;
      CDisplayInfo* C_DisplayInfo;
      CCheckerException*  C_CheckerException;
      
      //プライベートコンストラクタ(他のクラスにNewはさせないぞ！！！)
      CHandler(){
        C_logger = CLogger::GetLog();
        C_OrderManager = COrderManager::GetOrderManager();
        C_DisplayInfo = CDisplayInfo::GetDisplayInfo();
        C_CheckerException = CCheckerException::GetCheckerException();
      }

    public:    
      //	機能		： //シングルトンクラスインスタンス取得
      static CHandler* GetHandler()
      {
        if(CheckPointer(m_handler) == POINTER_INVALID){
          m_handler = new CHandler();
        }
        return m_handler;
      }

      // *************************************************************************
      //	機能		： ログファイルへの出力
      //	注意		： なし
      //	メモ		： なし
      //	引数		： ログに記録する文字
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			Taji		新規
      // *************************************************************************/
      void OnInit(){
        // 口座番号確認
        if( C_CheckerException.Chk_Account() == false ){
          C_logger.output_log_to_file("特定口座ではない");
          //ExpertRemove();					// OnDeinit()をコールしてEA終了処理
        }

        //test 基本は各test項目をif(0)で制御
        if(0){
          C_OrderManager.unit_test();
        }
        //両建て→ノーポジの場合新規ロットの最小値分建て
        if(1){
          if(0 == C_OrderManager.get_latestOrderOpenPrice(POSITION_TYPE_BUY) ){
            if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY) < MAX_ORDER_NUM ){
              C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_BUY);
            }
          }
          if(0 == C_OrderManager.get_latestOrderOpenPrice(POSITION_TYPE_SELL) ){
            if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL) < MAX_ORDER_NUM ){
              C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_SELL);
            }
          }
        }
        C_OrderManager.UpdateTP( POSITION_TYPE_BUY );
        C_OrderManager.UpdateTP( POSITION_TYPE_SELL );
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
      void OnTimer1sec() {}

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
        if( C_CheckerException.Chk_Expired() == false ){
          C_logger.output_log_to_file("1分タイマー終了処理");
          ExpertRemove();					// OnDeinit()をコールしてEA終了処理
        }	
      }

      void OnDeinit(const int reason){}

      void OnTimer(){
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

      void OnTick(){
        //C_DisplayInfo.UpdateOrderInfo();		// 注文情報を更新
        //C_DisplayInfo.ShowData();				// コメントをチャート上に表示
    
        //その他条件を満たしていたらOK→いろいろありそう(Todo)

//#######################################ロングの処理##################################################
        //ロングの前回の新規ポジション値からの変化Priceを計算
        double ask_diff = C_OrderManager.get_latestOrderOpenPrice(POSITION_TYPE_BUY) - SymbolInfoDouble(Symbol(),SYMBOL_ASK);
        //所定Price下がっていたら、ポジション限界値を超えない場合、追加量テーブルに従って所定量追加、
        //現在のポジション数に応じた変動値の指定(Todo)
        if(ask_diff > BASE_DIFF_PRICE_TO_ORDER1){
          if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY) < MAX_ORDER_NUM ){
            C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_BUY);
            //TP更新
            C_OrderManager.UpdateTP( POSITION_TYPE_BUY );
          }
        }
        //TP達成時に未決済があった場合のごみ処理(Tode)、


//#######################################ショートの処理##################################################
        //Shortの前回のポジション新規からの変化Priceを計算
        double bid_diff = SymbolInfoDouble(Symbol(),SYMBOL_BID) - C_OrderManager.get_latestOrderOpenPrice(POSITION_TYPE_SELL);
        //所定Price上がっていたら、ポジション限界値を超えない場合、追加量テーブルに従って所定量追加
        //現在のポジション数に応じた変動値の指定(Todo)
        if(bid_diff > BASE_DIFF_PRICE_TO_ORDER1){
          if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL) < MAX_ORDER_NUM ){
            C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_SELL);
            //TP更新
            C_OrderManager.UpdateTP( POSITION_TYPE_SELL );
          }
        }
        //TP達成時に未決済があった場合のごみ処理(Tode)、
   
      }

        //新規ロットの最小値分のlongし、前回の新規建てポジションpriceとして保存(Todo)
        //新規ロットの最小値分のShortし、前回の新規建てポジションpriceとして保存(Todo)
      void OnTradeTransaction(
        const MqlTradeTransaction&    trans,        // 取引トランザクション構造体
        const MqlTradeRequest&      request,      //リクエスト構造体
        const MqlTradeResult&       result       // 結果構造体
      ){
        //くそな実装をわかってますが、いったんこれで。最新の前回注文価格を更新。(Todo)
          C_OrderManager.UpdateLatestOrderOpenPrice();

          if(0 == C_OrderManager.get_latestOrderOpenPrice(POSITION_TYPE_BUY) ){
            if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY) < MAX_ORDER_NUM ){
              C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_BUY);
              C_OrderManager.UpdateTP( POSITION_TYPE_BUY );
            }
          }
          if(0 == C_OrderManager.get_latestOrderOpenPrice(POSITION_TYPE_SELL) ){
            if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL) < MAX_ORDER_NUM ){
              C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_SELL);
              C_OrderManager.UpdateTP( POSITION_TYPE_SELL );
            }
          }
      }
};
CHandler* CHandler::m_handler;