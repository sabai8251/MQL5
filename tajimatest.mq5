//+------------------------------------------------------------------+
//|                                                   tajimatest.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- input parameters
input int      stoploss=30;
input int      TakeProfit=100;
input int      ADX_Period=8;
input int      MA_Period=8;
input int      EA_Magic=12345;   // EA Magic Number
input double   Adx_Min=22.0;     // Minimum ADX Value
input double   Lot=0.1;          // Lots to Trade
//sssddd
//rrreee
//--- Other parameters
int adxHandle; // handle for our ADX indicator
int maHandle;  // handle for our Moving Average indicator
double plsDI[],minDI[],adxVal[]; // Dynamic arrays to hold the values of +DI, -DI and ADX values for each bars
double maVal[]; // Dynamic array to hold the values of Moving Average for each bars
double p_close; // Variable to store the close value of a bar
int STP, TKP;   // To be used for ストップロス & テイクプロフィット values
// ログ
string executionlog_directory_name = "Executionlogs";
string executionlog_base_file_name = "logfile.log";
//+------------------------------------------------------------------+
//| Output logs function                                   |
//+------------------------------------------------------------------+
void output_file(string logtext){
   string timestamptxt;
   string filepath;
   MqlDateTime st_currenttime;
   
   //FileOpen
   TimeCurrent(st_currenttime);
   timestamptxt = StringFormat("%4d%02d%02d",
                  st_currenttime.year,st_currenttime.mon,st_currenttime.day);
   filepath = executionlog_directory_name  + "\\" + timestamptxt + executionlog_base_file_name;
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
      Print("[Error] can not log. output file filename = " + filepath);
   }
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   output_file("ooooi");
//---
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
    output_file("OnTick");
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   Print("start timer");
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
