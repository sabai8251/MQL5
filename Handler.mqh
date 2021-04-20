//**************************************************
// class CHandler
//**************************************************
#include "Logger.mqh"
#include "OrderManager.mqh"
#include "DisplayInfo.mqh"
#include "CheckerException.mqh"
#include "Configuration.mqh"
#include "CheckerBars.mqh"
input int aaaaa;
class CHandler
{
	private:
		static CHandler*    m_handler;
		CLogger*            C_logger;
		COrderManager*      C_OrderManager;
		CDisplayInfo*       C_DisplayInfo;
		CCheckerException*  C_CheckerException;
		CCheckerBars*       C_CheckerBars;
		double              m_preoder_price[2];   //前回のポジション定義
		bool                m_buy_stop;//フェードアウトモード発動(BUY)
		bool                m_sell_stop;//フェードアウトモード発動(SELL)
	
		//プライベートコンストラクタ(他のクラスにNewはさせないぞ！！！)
		CHandler(){
			m_preoder_price[0] = 0;
			m_preoder_price[1] = 0;
			C_logger = CLogger::GetLog();
			C_OrderManager = COrderManager::GetOrderManager();
			C_DisplayInfo = CDisplayInfo::GetDisplayInfo();
			C_CheckerException = CCheckerException::GetCheckerException();
			C_CheckerBars = CCheckerBars::GetCheckerBars();
			UpdateLatestOrderOpenPrice();
			m_buy_stop=false;
			m_sell_stop=false;
		}

		//配列番号へ変換
		char ArreyNumFromOderType(ENUM_ORDER_TYPE type){
			if(type==ORDER_TYPE_BUY) return 0;
			if(type==ORDER_TYPE_SELL) return 1;
			C_logger.output_log_to_file("Handler::ArreyNumFromOderType[ERROR] pre order type");
			return 0;
		}
		char ArreyNumFromPositionType(ENUM_POSITION_TYPE type){
			if(type==POSITION_TYPE_BUY) return 0;
			if(type==POSITION_TYPE_SELL) return 1;
			C_logger.output_log_to_file("Handler::ArreyNumFromPositionType[ERROR] pre position type");
			return 0;
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
			m_preoder_price[0] = C_OrderManager.LatestOrderOpenPrice( POSITION_TYPE_BUY );//ポジションが0の場合は0がカエル
			m_preoder_price[1] = C_OrderManager.LatestOrderOpenPrice( POSITION_TYPE_SELL );//ポジションが0の場合は0がカエル
			//C_logger.output_log_to_file(StringFormat("COrderManager LatestOrderOpenPrice BUY  = %f ",m_preoder_price[0]));
			//C_logger.output_log_to_file(StringFormat("COrderManager LatestOrderOpenPrice SELL = %f ",m_preoder_price[1]));
		}
		// *************************************************************************
		//	機能		： 初期化処理
		//	注意		： なし
		//	メモ		： なし
		//	引数		： ノーポジの場合は最小ロット建てる、ポジションある場合は前回ポジション値更新、TPも更新
		//	返り値		： なし
		//	参考URL		： なし
		// **************************	履	歴	************************************
		// 		v1.0		2021.04.14			Taji		新規
		// *************************************************************************/
		void OnInit(){
			//ロット最小値のターミナルグローバル変数がなければ初期化
			if( false == GlobalVariableCheck("terminalg_lot")){
				GlobalVariableSet("terminalg_lot",g_base_lot);
			}
			g_base_lot=GlobalVariableGet("terminalg_lot");
			//フェードアウトモードのターミナルグローバル変数がない場合は初期化
			if( false == GlobalVariableCheck("terminalg_fadeout_mode")){
				GlobalVariableSet("terminalg_fadeout_mode",g_fadeout_mode);
			}
			g_fadeout_mode=GlobalVariableGet("terminalg_fadeout_mode");

			// 口座番号確認
			if( C_CheckerException.Chk_Account() == false ){
				C_logger.output_log_to_file("Handler::OnInit 特定口座ではない");
				//ExpertRemove();					// OnDeinit()をコールしてEA終了処理
			}
			//カスタムテーブル処理(Configuration.mqh)
			ConfigCustomizeLotList();
			ConfigCustomizeDiffPriceOrderList();
			ConfigCustomizeTPTable();

			//test 基本は各test項目をif(0)で制御
			if(0){
				C_OrderManager.unit_test();
			}

			//BUYまたはSELLがノーポジの場合,新規最小ロットを建てる(両建ての維持)
			OrderForNoPosition();
			UpdateLatestOrderOpenPrice();
		}

		// *************************************************************************
		//	機能		：BUYまたはSELLがノーポジの場合,新規最小ロットを建てる、TPの最新アップデート
		//	注意		： なし
		//	メモ		： タイマー関数内でコール
		//	引数		： なし
		//	返り値		： なし
		//	参考URL		： なし
		// **************************	履	歴	************************************
		// 		v1.0		2021.04.14			Taji		新規
		// *************************************************************************/
		void OrderForNoPosition() {
			//ノーポジの場合のみ新規ロットの最小値分建てを行う
			if(0 == get_latestOrderOpenPrice(POSITION_TYPE_BUY) ){
				if( true == g_fadeout_mode){
					//BUYのポジションが0になったのでフェードアウトモード発動(BUY)
					m_buy_stop=true;
				}else{
					if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY) < MAX_ORDER_NUM ){
						C_logger.output_log_to_file("Handler::OrderForNoPosition BUYで新規ロットの最小値分建てを行う");
						C_OrderManager.OrderTradeActionDeal( g_base_lot, ORDER_TYPE_BUY);
					}
				}
			}
			if(0 == get_latestOrderOpenPrice(POSITION_TYPE_SELL) ){
				if( true == g_fadeout_mode){
					//SELLのポジションが0になったのでフェードアウトモード発動(SELL)
					m_sell_stop=true;
				}else{
					if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL) < MAX_ORDER_NUM ){
						C_logger.output_log_to_file("Handler::OrderForNoPosition SELLで新規ロットの最小値分建てを行う");
						C_OrderManager.OrderTradeActionDeal( g_base_lot, ORDER_TYPE_SELL);
					}
				}
			}
			C_OrderManager.UpdateTP( POSITION_TYPE_BUY );
			C_OrderManager.UpdateTP( POSITION_TYPE_SELL );
		}

		// *************************************************************************
		//	機能		： ポジション数取得
		//	注意		： なし
		//	メモ		： なし
		//	引数		： なし
		//	返り値		： なし
		//	参考URL		： なし
		// **************************	履	歴	************************************
		// 		v1.0		2021.04.14			Taka		新規
		// *************************************************************************/
		int CalculatePositionNum( ENUM_POSITION_TYPE req_type ){
			int position_num=0; //　指定されたタイプの保有ポジション数
			
			C_logger.output_log_to_file("Handler::CalculatePositionNum start");

			//全てのポジション数取得
			int total=PositionsTotal();
			for(int i=0; i<total; i++)
			{
				ulong position_ticket	= PositionGetTicket( i );
				ulong magic			= PositionGetInteger( POSITION_MAGIC );
				ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
			
				if(magic == MAGICNUM){
					if( req_type == type ){
						position_num++;
					}
				}
			}
			return position_num;
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

		// *************************************************************************
		//	機能		： Timer関数
		//	注意		： なし
		//	メモ		： 
		//	引数		： なし
		//	返り値		： なし
		//	参考URL		： なし
		// **************************	履	歴	************************************
		// 		v1.0		2021.04.14			Taji		新規
		// *************************************************************************/
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

		// *************************************************************************
		//	機能		： 価格更新ごとに実行される関数
		//	注意		： なし
		//	メモ		： 
		//	引数		： なし
		//	返り値		： なし
		//	参考URL		： なし
		// **************************	履	歴	************************************
		// 		v1.0		2021.04.14			Taji		新規
		// *************************************************************************/
		void OnTick(){
			//C_DisplayInfo.UpdateOrderInfo();		// 注文情報を更新
			//C_DisplayInfo.ShowData();				// コメントをチャート上に表示
			g_base_lot=GlobalVariableGet("terminalg_lot");
			g_fadeout_mode=GlobalVariableGet("terminalg_fadeout_mode");

			//フェードアウトモードから通常モードへ復帰
			if( g_fadeout_mode == false ){
				m_buy_stop = false;
				m_sell_stop = false;
			}

			//証拠金維持率チェック(500％下回ったら取引しない)
			if( AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) != 0){//ポジションが0の時は維持率0になる
				if( AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) < MINIMUN_ACCOUNT_MARGIN_LEVEL ){
					C_logger.output_log_to_file(StringFormat("証拠金維持率　=　%f",AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)));
					return;
				}
			}

			//値幅チェック
			int deal_recomment;
			int diff_price_for_order = BASE_DIFF_PRICE_TO_ORDER2;
			deal_recomment = C_CheckerBars.Chk_preiod_m1_bars();
			//#######################################ロングの処理start##################################################
			if( RECOMMEND_STOP_BUY_DEAL != deal_recomment && m_buy_stop == false ){ //BUYが値幅チェックにより制限がかかっていなければ処理開始
				//ロングの前回ポジからの現在価格との差を計算
				double ask_diff = get_latestOrderOpenPrice(POSITION_TYPE_BUY) - SymbolInfoDouble(Symbol(),SYMBOL_ASK);

				//所有ポジション数に応じた変動値の指定
				int TotalOrderNumBuy = C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY);
				if(0 != TotalOrderNumBuy){
					diff_price_for_order = diff_price_order[TotalOrderNumBuy-1];
					//所定Price下がったら、追加量テーブルに従って所定量追加
					if(ask_diff > diff_price_for_order){
						//ポジション限界値を超えない場合
						if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY) < MAX_ORDER_NUM ){
							int num = CalculatePositionNum( POSITION_TYPE_BUY );
							C_logger.output_log_to_file(StringFormat("Handler::OnTick　注文判断変化量=%d 直前ポジと現在価格の差(ASK)=%f lot=%f num=%d",
																	diff_price_for_order,ask_diff,lot_list[num]*g_base_lot,num));
							C_OrderManager.OrderTradeActionDeal( lot_list[num]*g_base_lot, ORDER_TYPE_BUY);
							//TP更新
							C_OrderManager.UpdateTP( POSITION_TYPE_BUY );
							UpdateLatestOrderOpenPrice();
						}
					}
				}
				else{
					OrderForNoPosition();
					UpdateLatestOrderOpenPrice();
				}
			}
			//#######################################ロングの処理end######################################################
			//#######################################ショートの処理start##################################################
			if( RECOMMEND_STOP_SELL_DEAL != deal_recomment && m_sell_stop == false ){ //SELLが値幅チェックにより制限がかかっていなければ処理開始
				//ショートの前回ポジと現在価格との差を計算
				double bid_diff = SymbolInfoDouble(Symbol(),SYMBOL_BID) - get_latestOrderOpenPrice(POSITION_TYPE_SELL);
				
				//所有ポジション数に応じた変動値の指定
				int TotalOrderNumSell = C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL);
				if(0 != TotalOrderNumSell){
					diff_price_for_order = diff_price_order[TotalOrderNumSell-1];
					//所定Price上がったら、追加量テーブルに従って所定量追加
					if(bid_diff > diff_price_for_order){
						//ポジション限界値を超えない場合
						if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL) < MAX_ORDER_NUM ){
							int num = CalculatePositionNum( POSITION_TYPE_SELL );
							C_logger.output_log_to_file(StringFormat("Handler::OnTick　注文判断変化量=%d 直前ポジと現在価格の差(BID)=%f lot=%f num=%d",
																	diff_price_for_order,bid_diff,lot_list[num]*g_base_lot,num));
							C_OrderManager.OrderTradeActionDeal( lot_list[num]*g_base_lot, ORDER_TYPE_SELL);
							//TP更新
							C_OrderManager.UpdateTP( POSITION_TYPE_SELL );
							UpdateLatestOrderOpenPrice();
						} 
					}
				}
				else{
					OrderForNoPosition();
					UpdateLatestOrderOpenPrice();
				}
			}
			//#######################################ショートの処理end######################################################
		}

		// *************************************************************************
		//	機能		： Trunsaction更新ごとに実行される関数
		//	注意		： なし
		//	メモ		： 
		//	引数		： なし
		//	返り値		： なし
		//	参考URL		： なし
		// **************************	履	歴	************************************
		// 		v1.0		2021.04.14			Taji		新規
		// *************************************************************************/
		void OnTradeTransaction(
			const MqlTradeTransaction&    trans,        // 取引トランザクション構造体
			const MqlTradeRequest&      request,      //リクエスト構造体
			const MqlTradeResult&       result       // 結果構造体
		){
		//くそな実装をわかってますが、いったんこれで。最新の前回注文価格を更新。(Todo)
			if(trans.type == TRADE_TRANSACTION_DEAL_ADD){
				C_logger.output_log_to_file(StringFormat("Handler::OnTradeTransaction trans.type == TRADE_TRANSACTION_DEAL_ADD %d",trans.deal_type));
				UpdateLatestOrderOpenPrice();

				//ノーポジの場合のみ新規ロットの最小値分建て
				OrderForNoPosition();
				
				UpdateLatestOrderOpenPrice();
			}
		}

		// *************************************************************************
		//	機能		： 終了関数
		//	注意		： なし
		//	メモ		： 
		//	引数		： なし
		//	返り値		： なし
		//	参考URL		： なし
		// **************************	履	歴	************************************
		// 		v1.0		2021.04.14			Taji		新規
		// *************************************************************************/
		void OnDeinit(const int reason){}
};
CHandler* CHandler::m_handler;