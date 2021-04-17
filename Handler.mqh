//**************************************************
// class CHandler
//**************************************************
#include "Logger.mqh"
#include "OrderManager.mqh"
#include "DisplayInfo.mqh"
#include "CheckerException.mqh"
#include "Configuration.mqh"
class CHandler
{
	private:
		static CHandler*  m_handler;

		CLogger*          C_logger;
		COrderManager*    C_OrderManager;
		CDisplayInfo* C_DisplayInfo;
		CCheckerException*  C_CheckerException;
		double              m_preoder_price[2];   //前回のポジション定義
	
		//プライベートコンストラクタ(他のクラスにNewはさせないぞ！！！)
		CHandler(){
			m_preoder_price[0] = 0;
			m_preoder_price[1] = 0;
			C_logger = CLogger::GetLog();
			C_OrderManager = COrderManager::GetOrderManager();
			C_DisplayInfo = CDisplayInfo::GetDisplayInfo();
			C_CheckerException = CCheckerException::GetCheckerException();
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
			m_preoder_price[0] = C_OrderManager.LatestOrderOpenPrice( POSITION_TYPE_BUY );
			m_preoder_price[1] = C_OrderManager.LatestOrderOpenPrice( POSITION_TYPE_SELL );
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
			// 口座番号確認
			if( C_CheckerException.Chk_Account() == false ){
				C_logger.output_log_to_file("特定口座ではない");
				//ExpertRemove();					// OnDeinit()をコールしてEA終了処理
			}

			//test 基本は各test項目をif(0)で制御
			if(0){
				C_OrderManager.unit_test();
			}

			//ノーポジの場合のみ新規ロットの最小値分建て
			if(0 == get_latestOrderOpenPrice(POSITION_TYPE_BUY) ){
				if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY) < MAX_ORDER_NUM ){
					C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_BUY);
				}
			}
			if(0 == get_latestOrderOpenPrice(POSITION_TYPE_SELL) ){
				if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL) < MAX_ORDER_NUM ){
					C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_SELL);
				}
			}
			C_OrderManager.UpdateTP( POSITION_TYPE_BUY );
			C_OrderManager.UpdateTP( POSITION_TYPE_SELL );
		}

		// *************************************************************************
		//	機能		：ノーポジなら最小ポジションを立てる、TPの最新アップデート
		//	注意		： なし
		//	メモ		： タイマー関数内でコール
		//	引数		： なし
		//	返り値		： なし
		//	参考URL		： なし
		// **************************	履	歴	************************************
		// 		v1.0		2021.04.14			Taji		新規
		// *************************************************************************/
		void UpdatePositionInfo() {}

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
		
			//その他条件を満たしていたらOK→いろいろありそう(Todo)
			int diff_price_for_order = BASE_DIFF_PRICE_TO_ORDER2;
			
			//#######################################ロングの処理start##################################################
			//ロングの前回ポジからの変化を計算
			double ask_diff = get_latestOrderOpenPrice(POSITION_TYPE_BUY) - SymbolInfoDouble(Symbol(),SYMBOL_ASK);

			//所有ポジション数に応じた変動値の指定 実装はまだくそ(Todo)
			int TotalOrderNumBuy = C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY);
			//C_logger.output_log_to_file(StringFormat("TotalOrderNumBuy=%d",TotalOrderNumBuy));

			if(0 != TotalOrderNumBuy){
				diff_price_for_order = diff_price_order[TotalOrderNumBuy-1];
				//C_logger.output_log_to_file(StringFormat("diff_price_for_order=%d ask_diff=%f",diff_price_for_order,ask_diff));
				//所定Price下がったら、追加量テーブルに従って所定量追加
				if(ask_diff > diff_price_for_order){
					C_logger.output_log_to_file(StringFormat("diff_price_for_order=%d ask_diff=%f",diff_price_for_order,ask_diff));
					//ポジション限界値を超えない場合
					if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY) < MAX_ORDER_NUM ){
						C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_BUY);
						//TP更新
						C_OrderManager.UpdateTP( POSITION_TYPE_BUY );
					}
				}
			}
			//#######################################ロングの処理end######################################################
			//#######################################ショートの処理start##################################################
			//ショートの前回ポジからの変化を計算
			double bid_diff = SymbolInfoDouble(Symbol(),SYMBOL_BID) - get_latestOrderOpenPrice(POSITION_TYPE_SELL);
			
			//所有ポジション数に応じた変動値の指定 実装はまだくそ(Todo)
			int TotalOrderNumSell = C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL);
			//C_logger.output_log_to_file(StringFormat("TotalOrderNumSell=%d",TotalOrderNumSell));
			if(0 != TotalOrderNumSell){
				diff_price_for_order = diff_price_order[TotalOrderNumSell-1];
				//C_logger.output_log_to_file(StringFormat("diff_price_for_order=%d bid_diff=%f",diff_price_for_order,bid_diff));
				//所定Price上がったら、追加量テーブルに従って所定量追加
				if(bid_diff > diff_price_for_order){
					C_logger.output_log_to_file(StringFormat("diff_price_for_order=%d bid_diff=%f",diff_price_for_order,bid_diff));
					//ポジション限界値を超えない場合
					if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL) < MAX_ORDER_NUM ){
						C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_SELL);
						//TP更新
						C_OrderManager.UpdateTP( POSITION_TYPE_SELL );
					} 
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
			UpdateLatestOrderOpenPrice();

			//ノーポジの場合のみ新規ロットの最小値分建て
			if(0 == get_latestOrderOpenPrice(POSITION_TYPE_BUY) ){
				if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_BUY) < MAX_ORDER_NUM ){
					C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_BUY);
					C_OrderManager.UpdateTP( POSITION_TYPE_BUY );
				}
			}
			if(0 == get_latestOrderOpenPrice(POSITION_TYPE_SELL) ){
				if( C_OrderManager.get_TotalOrderNum(POSITION_TYPE_SELL) < MAX_ORDER_NUM ){
					C_OrderManager.OrderTradeActionDeal( BASE_LOT, ORDER_TYPE_SELL);
					C_OrderManager.UpdateTP( POSITION_TYPE_SELL );
				}
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