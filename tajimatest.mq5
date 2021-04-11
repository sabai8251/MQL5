float base_lot = 0.01; //ロットの最小値
// ログ
string executionlog_directory_name = "Executionlogs";
string executionlog_base_file_name = "logfile.log";
//追加量テーブル定義(Todo)
//ポジション限界値定義(Todo)
//前回のポジション定義(Todo) 
//magic number(Todo) 


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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   output_log_to_file("init start");
//---
   //新規ロットの最小値分、両建て(Todo)
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
    output_log_to_file("OnTick start");
    //その他条件を満たしていたらOK→いろいろありそう(Todo)

    //ポジション限界値を超えている場合は無視(Todo)

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
