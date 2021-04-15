//**************************************************
// class COrderManager
//**************************************************
#include "Logger.mqh"
#define TP_ALPHA1	60.0
#define TP_ALPHA2	1.0
//TPの指定テーブル
struct _tbl_TP{
  int specify_price_num;  //いくつめ注文か
  double alpha;  //ゲタ
};
_tbl_TP tbl_TP[] = {
  { 1, TP_ALPHA1 },//注文が1つの場合. 1番の注文の価格＋α1
  { 1, TP_ALPHA2 },//注文が2つの場合. 1番の注文の価格＋α2
  { 2, TP_ALPHA2 },//注文が3つの場合. 2番の注文の価格＋α2
  { 2, TP_ALPHA2 },
  { 3, TP_ALPHA2 },
  { 3, TP_ALPHA2 },
  { 4, TP_ALPHA2 },
  { 4, TP_ALPHA2 },
  { 5, TP_ALPHA2 },
  { 5, TP_ALPHA2 },
  { 6, TP_ALPHA2 },
  { 6, TP_ALPHA2 },
  { 7, TP_ALPHA2 },
  { 7, TP_ALPHA2 },
  { 8, TP_ALPHA2 },
  { 8, TP_ALPHA2 },
};

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
      double                m_preoder_price[2];
      //magic number
      ulong                 MAGICNUM;      
      

      //プライベートコンストラクタ(他のクラスにNewはさせないぞ！！！)
      COrderManager(){
        m_preoder_price[0] = 0;
        m_preoder_price[1] = 0;
        MAGICNUM = 345678;
        C_logger = CLogger::GetLog();
        UpdateLatestOrderOpenPrice();
      }

      //配列番号へ変換
      char ArreyNumFromOderType(ENUM_ORDER_TYPE type){
        if(type==ORDER_TYPE_BUY) return 0;
        if(type==ORDER_TYPE_SELL) return 1;
        C_logger.output_log_to_file("[ERROR] pre order type");
        return 0;
      }
      char ArreyNumFromPositionType(ENUM_POSITION_TYPE type){
        if(type==POSITION_TYPE_BUY) return 0;
        if(type==POSITION_TYPE_SELL) return 1;
        C_logger.output_log_to_file("[ERROR] pre position type");
        return 0;
      }

      // *************************************************************************
      //	機能		： 初期化　オーダーが残存している場合は、前回注文した注文価格を取得し保持する
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			taji		新規
      // *************************************************************************/
      double LatestOrderOpenPrice( ENUM_POSITION_TYPE req_type ){
        double latest_position_price = 0; //　指定されたタイプの最後に注文したポジションの価格

        int total=PositionsTotal(); //　全保有ポジション数
        C_logger.output_log_to_file(StringFormat("LatestOrderOpenPrice PositionsTotal() = %d ",total));
        
        //指定されたタイプのポジション数をカウントし、各プライスを保持
        for(int i=0; i<total; i++)
        {
          ulong position_ticket	= PositionGetTicket( i );
          string position_symbol	= PositionGetString( POSITION_SYMBOL );						// シンボル
          ulong magic			= PositionGetInteger( POSITION_MAGIC );						// ポジションのMagicNumber
          ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);   // ポジションタイプ
        
          if(magic == MAGICNUM){
            if( req_type == type ){
              latest_position_price = PositionGetDouble( POSITION_PRICE_OPEN );
            }
          }
        }

        return latest_position_price;
      }
      
    public:
      // *************************************************************************
      //	機能		： 前回注文した注文価格を更新する
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			taji		新規
      // *************************************************************************/
      void UpdateLatestOrderOpenPrice(){
        m_preoder_price[0] = LatestOrderOpenPrice( POSITION_TYPE_BUY );
        m_preoder_price[1] = LatestOrderOpenPrice( POSITION_TYPE_SELL );
        C_logger.output_log_to_file(StringFormat("COrderManager LatestOrderOpenPrice BUY  = %f ",m_preoder_price[0]));
        C_logger.output_log_to_file(StringFormat("COrderManager LatestOrderOpenPrice SELL = %f ",m_preoder_price[1]));
      }

    
      //	機能		： //シングルトンクラスインスタンス取得
      static COrderManager* GetOrderManager()
      {
        if(CheckPointer(m_OrderManager) == POINTER_INVALID){
          m_OrderManager = new COrderManager();
        }
        return m_OrderManager;
      }
      // *************************************************************************
      //	機能		： オーダー数取得
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			taji		新規
      // *************************************************************************/
      int get_TotalOrderNum( ENUM_POSITION_TYPE req_type ){
        int order_num=0;//オーダー数
        int total=PositionsTotal(); //　全保有ポジション数
        C_logger.output_log_to_file(StringFormat("LatestOrderOpenPrice PositionsTotal() = %d ",total));
        
        //指定されたタイプのポジション数をカウントし、各プライスを保持
        for(int i=0; i<total; i++)
        {
          ulong position_ticket	= PositionGetTicket( i );
          ulong magic			= PositionGetInteger( POSITION_MAGIC );						// ポジションのMagicNumber
          ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);   // ポジションタイプ
        
          if(magic == MAGICNUM){
            if( req_type == type ){
              order_num++;
            }
          }
        }

        return order_num;
      }
      // *************************************************************************
      //	機能		： 指定されたタイプの最後に注文したポジションの価格を取得する
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			taji		新規
      // *************************************************************************/
      double get_latestOrderOpenPrice( ENUM_POSITION_TYPE req_type ){
        return m_preoder_price[ArreyNumFromPositionType(req_type)];
      }


      // *************************************************************************
      //	機能		： 新規成り行き注文
      //	注意		： なし
      //	メモ		： なし
      //	引数		： req:ポジションタイプ
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			taji		新規
      // *************************************************************************/
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
          m_preoder_price[ArreyNumFromOderType(type)]=PositionGetDouble(POSITION_PRICE_OPEN);
        }
        C_logger.output_log_to_file(StringFormat("retcode=%u  deal=%I64u  order=%I64u  type=%d[0:buy 1:sell], preoderprice=%f",
                                  result.retcode,result.deal,result.order,type,m_preoder_price[ArreyNumFromOderType(type)]));
        C_logger.output_log_to_file("ordersend end");
      }

      // *************************************************************************
      //	機能		： ポジションすべて決済
      //	注意		： なし
      //	メモ		： なし
      //	引数		： req_typeは決済したい建てているポジションタイプ
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			taji		新規
      // *************************************************************************/
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

      // *************************************************************************
      //	機能		： TPを設定する
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			Taka		新規
      // *************************************************************************/
      void UpdateTP( ENUM_POSITION_TYPE req_type ){
        MqlTradeRequest	request;
        MqlTradeResult	result;

        int position_num=0; //　指定されたタイプの保有ポジション数
        double position_price_array[10]={0}; //　指定されたタイプの各ポジションの価格
        int position_digits_array[10]={0}; //　指定されたタイプの各ポジションの小数点以下の桁数

        int total=PositionsTotal(); //　全保有ポジション数
        C_logger.output_log_to_file(StringFormat("UpdateTP ★TPセット done PositionsTotal() = %d ",total));
        
        //指定されたタイプのポジション数をカウントし、各プライスを保持
        for(int i=0; i<total; i++)
        {
          ulong position_ticket	= PositionGetTicket( i );
          string position_symbol	= PositionGetString( POSITION_SYMBOL );						// シンボル
          ulong magic			= PositionGetInteger( POSITION_MAGIC );						// ポジションのMagicNumber
          ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);   // ポジションタイプ
        
          if(magic == MAGICNUM){
            if( req_type == type ){
              position_price_array[position_num] = PositionGetDouble( POSITION_PRICE_OPEN );
              position_digits_array[position_num] = (int)SymbolInfoInteger( position_symbol,SYMBOL_DIGITS ); 	// 小数点以下の桁数
              position_num++;
            }
          }
        }
        C_logger.output_log_to_file(StringFormat("UpdateTP position_num = %d",position_num));

        if(0 == position_num){
          C_logger.output_log_to_file("[ERROR Fatal]UpdateTP Position nothing ");
          return;
        }

        //TPの更新処理
        for(int i=total-1; i>=0; i--)
        {
          ulong position_ticket	= PositionGetTicket( i );		// ポジションチケット(この関数コールすると、後はID指定不要)
          string position_symbol	= PositionGetString( POSITION_SYMBOL );						// シンボル
          int digits			= (int)SymbolInfoInteger( position_symbol,SYMBOL_DIGITS ); 	// 小数点以下の桁数
          ulong magic			= PositionGetInteger( POSITION_MAGIC );						// ポジションのMagicNumber
          double volume			= PositionGetDouble( POSITION_VOLUME );						// ポジションボリューム
      	  double sl				= PositionGetDouble( POSITION_SL ); 						// ポジションのStop Loss
          double tp				= PositionGetDouble( POSITION_TP ); 						// ポジションのTake Profit
          double openprice	= PositionGetDouble( POSITION_PRICE_OPEN );					// 注文の価格
          ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);   // ポジションタイプ
          //double now				= SymbolInfoDouble(Symbol(),SYMBOL_ASK);						// 現在の価格（Buy）
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
          // EAの注文でない場合はスキップ
        	if( magic != MAGICNUM ) continue;
          // 指定されたポジションタイプでない場合はスキップ
          if( req_type != type ) continue;

		    	// テーブルに従ってTPの更新値を決定
          double new_tp;
          int array_num = tbl_TP[position_num-1].specify_price_num;   //いくつめの注文価格に合わせるか
          double alpha = tbl_TP[position_num-1].alpha;

          if( req_type == POSITION_TYPE_BUY ){
            new_tp = NormalizeDouble( position_price_array[array_num-1] + alpha, 
                                    position_digits_array[array_num-1] );
            C_logger.output_log_to_file( "POSITION_TYPE_BUY" + (string)array_num + "つ目の注文価格 = " 
                                        +(string)position_price_array[array_num-1] + " alpha = " + (string)alpha );
          }
          else if( req_type == POSITION_TYPE_SELL ){
            new_tp = NormalizeDouble( position_price_array[array_num-1] - alpha, 
                                    position_digits_array[array_num-1] );
            C_logger.output_log_to_file( "POSITION_TYPE_SELL" + (string)array_num + "つ目の注文価格 = " 
                                        +(string)position_price_array[array_num-1] + " alpha = " + (string)alpha );
          }else{
            C_logger.output_log_to_file("[ERROR] UpdateTP req_type");
            return;
          }

          C_logger.output_log_to_file( "購入価格" + (string)openprice + "今のTP=" + (string)tp + "新しいTP" + (string)new_tp );
          
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
      }

      // *************************************************************************
      //	機能		： test用関数
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			taji		新規
      // *************************************************************************/
      void unit_test(){
        //test(両建てして前回の値を表示する)
        if(0){
          OrderTradeActionDeal( 0.01, ORDER_TYPE_BUY);
          OrderTradeActionDeal( 0.01, ORDER_TYPE_SELL);
          OrderTradeActionDeal( 0.01, ORDER_TYPE_BUY);
          OrderTradeActionDeal( 0.01, ORDER_TYPE_SELL);
          OrderTradeActionDeal( 0.01, ORDER_TYPE_BUY);
          OrderTradeActionDeal( 0.01, ORDER_TYPE_SELL);
          C_logger.output_log_to_file(StringFormat("preoder_buy=%f  preoder_sell=%f ",
                                       m_preoder_price[ArreyNumFromOderType(ORDER_TYPE_BUY)],m_preoder_price[ArreyNumFromOderType(ORDER_TYPE_SELL)]));
        }
        //test(すべて決済)
        if(0){
          OrderTradeActionCloseAll( POSITION_TYPE_BUY);
          OrderTradeActionCloseAll( POSITION_TYPE_SELL);
        }
        //test(TP更新)
        if(0){
          UpdateTP( POSITION_TYPE_BUY );
          UpdateTP( POSITION_TYPE_SELL );
        }
      }
};
COrderManager*            COrderManager::m_OrderManager;