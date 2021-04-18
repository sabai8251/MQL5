//**************************************************
// class CCheckerBars
//**************************************************
#include "Configuration.mqh"
//**************************************************
// 定義（define）
//**************************************************
class CCheckerBars
{
	private:
		static CCheckerBars* m_CheckerBars;
		CLogger*             C_logger;
		
		//プライベートコンストラクタ(他のクラスにNewはさせないぞ！！！)
		CCheckerBars(){
			C_logger = CLogger::GetLog();
		}

	public:
		//	機能		： //シングルトンクラスインスタンス取得
		static CCheckerBars* GetCheckerBars(){
			if(CheckPointer(m_CheckerBars) == POINTER_INVALID){
				m_CheckerBars = new CCheckerBars();
			}
			return m_CheckerBars;
		}

		// *************************************************************************
		//	機能		： 
		//	注意		： なし
		//	メモ		： なし
		//	引数		： なし
		//	返り値		： 
		//	参考URL		： なし
		// **************************	履	歴	************************************
		// 		v1.0		2021.04.14			Taji		新規
		// *************************************************************************/
		int Chk_preiod_m1_bars(void){
			int shift=0;
			double OpenArray[NUM_MINUTES_CUSTOM+1]={0};
			double CloseArray[NUM_MINUTES_CUSTOM+1]={0};
			//Barの取得
			for( int i = 0; i < NUM_MINUTES_CUSTOM+1; i++){
				OpenArray[i] = iOpen(Symbol(),PERIOD_M1,i);
				CloseArray[i] = iClose(Symbol(),PERIOD_M1,i);
			}

			double diff_latest;
			double diff_pre1;

			//1分チェック
			diff_latest = OpenArray[0] - CloseArray[0];//最新のBar
			diff_pre1   = OpenArray[1] - CloseArray[1];//1つ前のBar
			if( diff_latest > DIFF_MINUTES_1 ||  diff_pre1 > DIFF_MINUTES_1 ){
				//C_logger.output_log_to_file(StringFormat("CCheckerBars::Chk_preiod_m1_bars 1分値幅チェック下落局面 diff_latest = %f diff_pre1 = %f OpenArray[1] = %f CloseArray[1] = %f"
				//                            ,diff_latest,diff_pre1,OpenArray[1],CloseArray[1]));
				//下落局面なのでBUYは控える(過去‐現在が＋なので過去が高い、現在が低い→下落)
				return RECOMMEND_STOP_BUY_DEAL;
			}
			if( -diff_latest > DIFF_MINUTES_1 ||  -diff_pre1 > DIFF_MINUTES_1 ){
				//C_logger.output_log_to_file(StringFormat("CCheckerBars::Chk_preiod_m1_bars 1分値幅チェック上昇局面 diff_latest = %f diff_pre1 = %f OpenArray[1] = %f CloseArray[1] = %f"
				//                            ,diff_latest,diff_pre1,OpenArray[1],CloseArray[1]));
				return RECOMMEND_STOP_SELL_DEAL;
			}

			//3分チェック
			diff_latest = OpenArray[3] - CloseArray[1];//3つ前の1分足のオープン価格から1つ前のクローズ価格の差分
			if( diff_latest > DIFF_MINUTES_3 ){
				//C_logger.output_log_to_file(StringFormat("CCheckerBars::Chk_preiod_m1_bars 3分値幅チェック下落局面 diff_latest = %f OpenArray[3] = %f CloseArray[1] = %f"
				//                            ,diff_latest,OpenArray[3],CloseArray[1]));
				//下落局面なのでBUYは控える(過去‐現在が＋なので過去が高い、現在が低い→下落)
				return RECOMMEND_STOP_BUY_DEAL;
			}
			if( -diff_latest > DIFF_MINUTES_3){
				//C_logger.output_log_to_file(StringFormat("CCheckerBars::Chk_preiod_m1_bars 3分値幅チェック上昇局面 diff_latest = %f OpenArray[3] = %f CloseArray[1] = %f"
				//                            ,diff_latest,OpenArray[3],CloseArray[1]));
				return RECOMMEND_STOP_SELL_DEAL;
			}

			//カスタムチェック(デフォルト10分)
			diff_latest = OpenArray[NUM_MINUTES_CUSTOM] - CloseArray[1];//3つ前の1分足のオープン価格から1つ前のクローズ価格の差分
			if( diff_latest > DIFF_MINUTES_CUSTOM || -diff_latest > DIFF_MINUTES_CUSTOM ){
				//C_logger.output_log_to_file(StringFormat("CCheckerBars::Chk_preiod_m1_bars %d分値幅チェック下落局面 diff_latest = %f OpenArray[10] = %f CloseArray[1] = %f"
				//                            ,NUM_MINUTES_CUSTOM,diff_latest,OpenArray[NUM_MINUTES_CUSTOM],CloseArray[1]));
				//下落局面なのでBUYは控える(過去‐現在が＋なので過去が高い、現在が低い→下落)
				return RECOMMEND_STOP_BUY_DEAL;
			}
			if( -diff_latest > DIFF_MINUTES_CUSTOM ){
				//C_logger.output_log_to_file(StringFormat("CCheckerBars::Chk_preiod_m1_bars %d分値幅チェック上昇局面 diff_latest = %f OpenArray[10] = %f CloseArray[1] = %f"
				//                            ,NUM_MINUTES_CUSTOM,diff_latest,OpenArray[NUM_MINUTES_CUSTOM],CloseArray[1]));
				return RECOMMEND_STOP_SELL_DEAL;
			}

			return RECOMMEND_NO_PROBREM;
		}
};
CCheckerBars* CCheckerBars::m_CheckerBars;