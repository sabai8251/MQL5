#include "Logger.mqh"
float BASE_LOT = 0.01; //ロットの最小値
// ログ
string executionlog_directory_name = "Executionlogs";
string executionlog_base_file_name = "logfile.log";
//追加量テーブル定義(Todo)
//ポジション限界値定義(Todo)
//前回のポジション定義
double g_preoder_price[ORDER_TYPE_SELL+1];
//magic number
ulong MAGICNUM = 345678;


//+------------------------------------------------------------------+
//| Output logs function                                   |
//+------------------------------------------------------------------+
void output_log_to_file(string logtext){
   string timestamptxt;
   MqlDateTime st_currenttime;
   
   //FileOpen
   TimeCurrent(st_currenttime);
   timestamptxt = StringFormat("%4d%02d%02d",
                     st_currenttime.year,st_currenttime.mon,st_currenttime.day);
   string filepath = executionlog_directory_name  + "\\" + timestamptxt + executionlog_base_file_name;
   int file_handle = FileOpen(filepath,FILE_READ|FILE_WRITE); 

   if(file_handle!=INVALID_HANDLE) {
      timestamptxt = StringFormat("%4d.%02d.%02d %02d.%02d.%02d:",
                     st_currenttime.year,st_currenttime.mon,st_currenttime.day,
                     st_currenttime.hour,st_currenttime.min,st_currenttime.sec);
      string logtext_to_file = timestamptxt + logtext;
            
      FileSeek(file_handle, 0, SEEK_END);
      FileWrite(file_handle, logtext_to_file );
      FileFlush(file_handle);
      FileClose(file_handle);
   }
   else{
      Print("[Error] can not log. file_handle = " + file_handle);
      Print("[Error] can not log. output file filename = " + filepath + logtext);
   }
}

char pre_order_num(ENUM_ORDER_TYPE type){
  if(type==ORDER_TYPE_BUY) {
    return 0;
  }
  else if(type==ORDER_TYPE_SELL){
    return 1;
  }
  output_log_to_file("[ERROR] pre order num");
  return 0;

}

//新規成り行き注文
void OrderTradeActionDeal(double volume, ENUM_ORDER_TYPE type){
  
  MqlTradeRequest request={0};
  MqlTradeResult result={0};
  
  request.action   =TRADE_ACTION_DEAL;                     // 取引操作タイプ
  request.symbol   =Symbol();                              // シンボル
  request.volume   =volume;                                 // ロット数
  request.type     =type;                                   // 注文タイプ
  if ( ORDER_TYPE_BUY == type){
    request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // 発注価格
  } else if( ORDER_TYPE_SELL == type ){
    request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }else{
    output_log_to_file("OrderType error "); 
    return;
  }
  
  request.deviation=5;                             // 価格からの許容偏差
  request.magic=MAGICNUM;                          // 注文のMagicNumber
  
  output_log_to_file("ordersend start");
  if(!OrderSend(request,result)){
    output_log_to_file(StringFormat("OrderSend error %d",GetLastError()));
    
  }else{
    Sleep(1000);
    PositionSelectByTicket(result.order);
    g_preoder_price[pre_order_num(type)]=PositionGetDouble(POSITION_PRICE_OPEN);
     
  }
  output_log_to_file(StringFormat("retcode=%u  deal=%I64u  order=%I64u  type=%d[0:buy 1:sell], preoderprice=%f",
                                  result.retcode,result.deal,result.order,type,g_preoder_price[pre_order_num(type)]));
  output_log_to_file("ordersend end");
}


//sellまたはbuyポジをすべて決済(req_typeは決済したい建てているポジションタイプ)
void OrderTradeActionCloseAll(ENUM_POSITION_TYPE req_type){
  output_log_to_file("OrderTradeActionCloseAll start");
  MqlTradeRequest request;
  MqlTradeResult result;
  int total=PositionsTotal(); //　保有ポジション数  
  output_log_to_file(StringFormat("OrderTradeActionCloseAll done PositionsTotal() = %d",total));
//--- 全ての保有ポジションの取捨
  for(int i=total-1; i>=0; i--)
    {
    ulong  position_ticket=PositionGetTicket(i);                                     // ポジションチケット
    string position_symbol=PositionGetString(POSITION_SYMBOL);                       // シンボル
    int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);             // 小数点以下の桁数
    ulong  magic=PositionGetInteger(POSITION_MAGIC);                                 // ポジションのMagicNumber
    double volume=PositionGetDouble(POSITION_VOLUME);                                 // ポジションボリューム
    double price_open=PositionGetDouble(POSITION_PRICE_OPEN);
    ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);   // ポジションタイプ
    
    output_log_to_file(StringFormat("#%I64u %s  %s  %.2f  %s [%I64d] price_open=%f",
                 position_ticket,
                 position_symbol,
                EnumToString(type),
                 volume,
                DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                 magic,
                 price_open));
    //--- MagicNumberが一致している場合
    if(magic==MAGICNUM)
       {
        //--- リクエストと結果の値のゼロ化
        ZeroMemory(request);
        ZeroMemory(result);
        //--- 操作パラメータの設定
        request.action   =TRADE_ACTION_DEAL;       // 取引操作タイプ
        request.position =position_ticket;         // ポジションチケット
        request.symbol   =position_symbol;         // シンボル
        request.volume   =volume;                   // ポジションボリューム
        request.deviation=5;                       // 価格からの許容偏差
        request.magic    =MAGICNUM;             // ポジションのMagicNumber
        //--- ポジションタイプによる注文タイプと価格の設定
        if(type==POSITION_TYPE_BUY && type==req_type)
          {
           request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
           request.type =ORDER_TYPE_SELL;
          }
        else if(type==POSITION_TYPE_SELL && type==req_type)
          {
           request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
           request.type =ORDER_TYPE_BUY;
          }else{
            continue;
          }
        //--- 決済情報の出力
        output_log_to_file(StringFormat("Close #%I64d %s %s",position_ticket,
                                        position_symbol,EnumToString(type)));
        //--- リクエストの送信
        if(!OrderSend(request,result)){
          output_log_to_file(StringFormat("OrderSend error %d",GetLastError())); // リクエストの送信に失敗した場合、エラーコードを出力
        }
        //--- 操作情報 
        output_log_to_file(StringFormat("retcode=%u  deal=%I64u  order=%I64u ",
                                       result.retcode,result.deal,result.order));
        //---
       }
    }
 }

void unit_test(){
   //test(両建てして前回の値を表示する)
   if(0){
   OrderTradeActionDeal( 0.01, ORDER_TYPE_BUY);
   OrderTradeActionDeal( 0.01, ORDER_TYPE_SELL);
   output_log_to_file(StringFormat("preoder_buy=%f  preoder_sell=%f ",
                                       g_preoder_price[pre_order_num(ORDER_TYPE_BUY)],g_preoder_price[pre_order_num(ORDER_TYPE_SELL)]));
  }
   //test(すべて決済)
   if(0){
   OrderTradeActionCloseAll( POSITION_TYPE_BUY);
   OrderTradeActionCloseAll( POSITION_TYPE_SELL);
   }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   //output_log_to_file(StringFormat("init startaa %d %d",ORDER_TYPE_BUY,ORDER_TYPE_SELL));
//---
   unit_test();


   //ノーポジの場合新規ロットの最小値分、両建て
   if(0){
     if(0 == PositionsTotal()){
       OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_BUY);
       OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_SELL);
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
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+
