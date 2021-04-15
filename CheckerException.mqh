//**************************************************
// 定義（define）
//**************************************************
#define EA_START_DATE	"2019.10.1 00:00"		// EA利用開始日
#define EA_END_DATE		"2021.12.1 00:00"		// EA利用終了日

const long account_array[] = {
          1257601,
          1257701,
          1257711,
          1257721,
          1257731,
          1257741,
          1257751
};

class CCheckerException
{
    private:
      static CCheckerException* m_CheckerException;

      CLogger*          C_logger;
      
      //プライベートコンストラクタ(他のクラスにNewはさせないぞ！！！)
      CCheckerException(){
        C_logger = CLogger::GetLog();
      }

    public:
      //	機能		： //シングルトンクラスインスタンス取得
      static CCheckerException* GetCheckerException()
      {
        if(CheckPointer(m_CheckerException) == POINTER_INVALID){
          m_CheckerException = new CCheckerException();
        }
        return m_CheckerException;
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
      // *************************************************************************
      //	機能		： 口座番号チェック関数
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： TRUE: 有効期限内、FALSE: 有効期限外
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			Taji		新規
      // *************************************************************************/
      bool Chk_Account(void){
        
        long account = AccountInfoInteger( ACCOUNT_LOGIN );
        long near_account;		// 近いアカウント値
        
        /* 最も近い口座を取得 */
        near_account = ArrayBsearch( account_array, account );
        
        C_logger.output_log_to_file("AccountNo:" + (string)account + " NearNo:" + (string)account_array[near_account] );

        /* 口座チェック */
        if( account == account_array[near_account] ){		// 同一ID
          return true;
        }
        else{
          C_logger.output_log_to_file("CryptoMasterSystem Expired");
          return false;
        }
      }
};
CCheckerException*           CCheckerException::m_CheckerException;