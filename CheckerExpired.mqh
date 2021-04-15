//**************************************************
// 定義（define）
//**************************************************
#define EA_START_DATE	"2019.10.1 00:00"		// EA利用開始日
#define EA_END_DATE		"2021.12.1 00:00"		// EA利用終了日

class CCheckerExpired
{
    private:
      static CCheckerExpired* m_CheckerExpired;
      
      //プライベートコンストラクタ(他のクラスにNewはさせないぞ！！！)
      CCheckerExpired(){
      }

    public:
      //	機能		： //シングルトンクラスインスタンス取得
      static CCheckerExpired* GetCheckerExpired()
      {
        if(CheckPointer(m_CheckerExpired) == POINTER_INVALID){
          m_CheckerExpired = new CCheckerExpired();
        }
        return m_CheckerExpired;
      }

      // *************************************************************************
      //	機能		： 有効期限チェック関数
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： TRUE: 有効期限内、FALSE: 有効期限外
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			Taji		新規
      // *************************************************************************/
      bool Chk_Expired(void){
        
        datetime start;		// 利用開始日 
        datetime end;		// 利用終了日
        datetime now;		// 現在日時

        start = StringToTime( EA_START_DATE );		// 利用開始日 
        end = StringToTime( EA_END_DATE );			// 利用終了日
        now = TimeLocal();							// 現在日時（ローカル時間）
      //	now = TimeCurrent();						// 現在日時
        
        /* 有効期限 */
        if( ( start < now ) && ( now < end ) ){		// 期限内
          return true;
        }
        else{
          C_logger.output_log_to_file("CryptoMasterSystem Expired");
          return false;
        }
      }
};
CCheckerExpired*           CCheckerExpired::m_CheckerExpired;