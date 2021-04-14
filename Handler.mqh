#include "Logger.mqh"
#include "OrderManager.mqh"
class CHandler
{
    private:
      static CHandler*            m_handler;
      CLogger* C_logger;
      COrderManager* C_OrderManager;
      CHandler(){
        C_logger = CLogger::GetLog();
        C_OrderManager = COrderManager::GetOrderManager();
      }

    public:    
      // *************************************************************************
      //	機能		： HandlerClassSIngletongInstanceGetter
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			Taji		新規
      // *************************************************************************/
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
        //--- create timer
        EventSetTimer(60);
        //output_log_to_file(StringFormat("init startaa %d %d",ORDER_TYPE_BUY,ORDER_TYPE_SELL));
        //---
        C_OrderManager.unit_test();

        //ノーポジの場合新規ロットの最小値分、両建て
        if(0){
          if(0 == PositionsTotal()){
            C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_BUY);
            C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_SELL);
          }
          else
          {
            //前回のポジションPriceを取得し保存(Todo) 
          }
        }
      //Short、Longについて、前回の新規建てポジションpriceとして保存(Todo)
      }
      
      void OnDeinit(const int reason){
      }

      void OnTimer(){
      }

      void OnTick(){
        //---
        //output_log_to_file("OnTick start");
    
        //その他条件を満たしていたらOK→いろいろありそう(Todo)

        //longの前回の新規ポジション値からの変化Priceを計算(Todo)
        //所定Price下がっていたら、ポジション限界値を超えない場合、追加量テーブルに従って所定量追加、前回の新規建てポジションpriceとして保存(Todo)
        //所定Price上がっていたら全てのmagicnumberへ一致するlongを決済し、新規ロットの最小値分のlongし、前回の新規建てポジションpriceとして保存(Todo)
    
    
        //Shortの前回のポジション新規からの変化Priceを計算(Todo)
        //所定Price上がっていたら、ポジション限界値を超えない場合、追加量テーブルに従って所定量追加、前回の新規建てポジションpriceとして保存(Todo)
        //所定Price下がっていたら全てのmagicnumberへ一致するShortを決済し、新規ロット最小値分のShortし、前回の新規建てポジションpriceとして保存(Todo)
   
      }
};
CHandler*           CHandler::m_handler;