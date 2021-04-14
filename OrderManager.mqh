#include "Logger.mqh"
//+------------------------------------------------------------------+
//| COrderManager                                   |
//+------------------------------------------------------------------+
class COrderManager
{
    private:
      static COrderManager* m_OrderManager;
      CLogger*              C_logger;
      //追加量テーブル定義(Todo)
      //ポジション限界値定義(Todo)
      //前回のポジション定義
      double                g_preoder_price[2];
      //magic number
      ulong                 MAGICNUM;      
      
      //プライベートコンストラクタ(他のクラスにNewはさせないぞ！！！)
      COrderManager(){
        MAGICNUM = 345678;
        C_logger = CLogger::GetLog();
      }

      //配列番号へ変換
      char ArreyNumFromOderType(ENUM_ORDER_TYPE type){
        if(type==ORDER_TYPE_BUY) return 0;
        if(type==ORDER_TYPE_SELL) return 1;
        C_logger.output_log_to_file("[ERROR] pre order num");
        return 0;
      }
      
    public:
      //	機能		： //シングルトンクラスインスタンス取得
      static COrderManager* GetOrderManager()
      {
        if(CheckPointer(m_OrderManager) == POINTER_INVALID){
          m_OrderManager = new COrderManager();
        }
        return m_OrderManager;
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
          C_logger.output_log_to_file("OrderType error "); 
          return;
        }
  
        request.deviation=5;                             // 価格からの許容偏差
        request.magic=MAGICNUM;                          
  
        C_logger.output_log_to_file("ordersend start");
        if(!OrderSend(request,result)){
          C_logger.output_log_to_file(StringFormat("OrderSend error %d",GetLastError()));  
        }else{
          Sleep(1000);
          PositionSelectByTicket(result.order);
          g_preoder_price[ArreyNumFromOderType(type)]=PositionGetDouble(POSITION_PRICE_OPEN);
        }
        C_logger.output_log_to_file(StringFormat("retcode=%u  deal=%I64u  order=%I64u  type=%d[0:buy 1:sell], preoderprice=%f",
                                  result.retcode,result.deal,result.order,type,g_preoder_price[ArreyNumFromOderType(type)]));
        C_logger.output_log_to_file("ordersend end");
      }


      //ポジションすべて決済(req_typeは決済したい建てているポジションタイプ)
      void OrderTradeActionCloseAll(ENUM_POSITION_TYPE req_type){
        C_logger.output_log_to_file("OrderTradeActionCloseAll start");
        MqlTradeRequest request;
        MqlTradeResult result;
        int total=PositionsTotal(); //　保有ポジション数  
        C_logger.output_log_to_file(StringFormat("OrderTradeActionCloseAll done PositionsTotal() = %d",total));
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
    
          C_logger.output_log_to_file(StringFormat("#%I64u %s  %s  %.2f  %s [%I64d] price_open=%f",
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
            C_logger.output_log_to_file(StringFormat("Close #%I64d %s %s",position_ticket,
                                        position_symbol,EnumToString(type)));
            //--- リクエストの送信
            if(!OrderSend(request,result)){
              C_logger.output_log_to_file(StringFormat("OrderSend error %d",GetLastError())); // リクエストの送信に失敗した場合、エラーコードを出力
            }
            //--- 操作情報 
            C_logger.output_log_to_file(StringFormat("retcode=%u  deal=%I64u  order=%I64u ",
                                       result.retcode,result.deal,result.order));
            //---
          }
        }
      }

      //test用関数
      void unit_test(){
        //test(両建てして前回の値を表示する)
        if(0){
          OrderTradeActionDeal( 0.01, ORDER_TYPE_BUY);
          OrderTradeActionDeal( 0.01, ORDER_TYPE_SELL);
          C_logger.output_log_to_file(StringFormat("preoder_buy=%f  preoder_sell=%f ",
                                       g_preoder_price[ArreyNumFromOderType(ORDER_TYPE_BUY)],g_preoder_price[ArreyNumFromOderType(ORDER_TYPE_SELL)]));
        }
        //test(すべて決済)
        if(1){
          OrderTradeActionCloseAll( POSITION_TYPE_BUY);
          OrderTradeActionCloseAll( POSITION_TYPE_SELL);
        }
      }
      //for文で回す(Todo)、SELLも対応する(Todo)、TPは基準値テーブルで設定するようにする(Todo)
      // *************************************************************************
      //	機能		： BuyのTPを設定する
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			Taka		新規
      // *************************************************************************/
      void SetTP_Buy( int index ){
        
        MqlTradeRequest	request;
        MqlTradeResult	result;
        ulong position_ticket;				// ポジションチケット
        string	position_symbol;			// シンボル
        int	digits;							// 小数点以下の桁数
        ulong	magic;						// ポジションのMagicNumber
        double	volume;						// ポジションボリューム
        double sl;							// ポジションのStop Loss
        double tp;							// ポジションのTake Profit
        double new_tp = 0.0;				// 新しいTake Profit
        double ask;							// 注文の価格
        double now;							// 現在価格
        
        position_ticket	= PositionGetTicket( index );		// ポジションチケット(この関数コールすると、後はID指定不要)
        position_symbol	= PositionGetString( POSITION_SYMBOL );						// シンボル
        digits			= (int)SymbolInfoInteger( position_symbol,SYMBOL_DIGITS ); 	// 小数点以下の桁数
        magic			= PositionGetInteger( POSITION_MAGIC );						// ポジションのMagicNumber
        volume			= PositionGetDouble( POSITION_VOLUME );						// ポジションボリューム
      	sl				= PositionGetDouble( POSITION_SL ); 						// ポジションのStop Loss
        tp				= PositionGetDouble( POSITION_TP ); 						// ポジションのTake Profit
        ask				= PositionGetDouble( POSITION_PRICE_OPEN );					// 注文の価格
        now				= SymbolInfoDouble(Symbol(),SYMBOL_ASK);											// 現在の価格（Buy）
      #ifdef DISPLAY
        // ポジション情報の出力
        PrintFormat("#%I64u %s  %s  %.2f  %s  sl: %s  tp: %s  [%I64d]",
          position_ticket,			// ポジションチケット
          position_symbol,			// シンボル
          volume,						// ボリューム
          DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),		// 価格
          DoubleToString(sl,digits),	// SL
          DoubleToString(tp,digits),	// TP
          magic						// マジックナンバー
        );
      #endif
        C_logger.output_log_to_file("★BUYのTPセット");
        // EAの注文でない場合はセットしない
      //	if( magic != EXPERT_MAGIC ) return;
        
        C_logger.output_log_to_file("★マジックナンバーあり");
        // 注文数に応じたTPを取得
        /* ★for文で回してカウントし、テーブルに従って計算する(Todo)
        if( OrderNow.buy_cnt == 1 ){
          
          new_tp = NormalizeDouble( ask + 60.0, digits );			// 60USD増やして設定
      		C_logger.output_log_to_file("★オーダー1つ");
        }
        else if( OrderNow.buy_cnt == 2 ){
          C_logger.output_log_to_file("★オーダー2つ");
          return;				// 指定以外は何もしない
        }
        else{
          C_logger.output_log_to_file("★オーダー1つじゃない");
          return;				// 指定以外は何もしない
        }*/
        
        C_logger.output_log_to_file("★現在価格" + (string)now + "購入価格" + (string)ask + "今のTP=" + (string)tp + "新しいTP" + (string)new_tp );
        // TPがすでに所望の値なら何もしない
        if( tp == new_tp ) return;
        
        C_logger.output_log_to_file("★価格更新をする");
        // リクエストと結果の値のゼロ化
        ZeroMemory(request);
        ZeroMemory(result);
        // 操作パラメータの設定
        request.action		= TRADE_ACTION_SLTP;	// 取引操作タイプ
        request.position	= position_ticket;		// ポジションシンボル
        request.symbol		= position_symbol;	  	// シンボル
        request.sl			= sl;					// ポジションのStop Loss
        request.tp			= new_tp;				// ポジションのTake Profit
        request.magic		= MAGICNUM;			// MagicNumber
        // 変更情報の出力
        C_logger.output_log_to_file(StringFormat("Modify #%I64d %s %s",position_ticket,position_symbol,POSITION_TYPE_BUY));
        // リクエストの送信
        if(!OrderSend(request,result))
        C_logger.output_log_to_file(StringFormat("OrderSend error %d",GetLastError())); // リクエストの送信に失敗した場合、エラーコードを出力する
        // 操作情報
        C_logger.output_log_to_file(StringFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order));
        C_logger.output_log_to_file("★価格更新");
      }
};
COrderManager*            COrderManager::m_OrderManager;