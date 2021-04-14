#include "Logger.mqh"
#include "OrderManager.mqh"

float BASE_LOT = 0.01;
CLogger* C_logger = CLogger::GetLog();
COrderManager* C_OrderManager = COrderManager::GetOrderManager();
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
     }else{
       //前回のポジションPriceを取得し保存(Todo) 
     }
   }
   //Short、Longについて、前回の新規建てポジションpriceとして保存(Todo)

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
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
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
  }
