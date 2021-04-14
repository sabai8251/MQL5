
class CHandler
{
    private:

      static CHandler*            m_hendler;
      CLogger* C_logger = CLogger::GetLog();
      COrderManager* C_OrderManager = COrderManager::GetOrderManager();
      
      CHandler(){
      }

    public:    
      // *************************************************************************
      //	機能		： HandlerClassSIngletongInstanceGetter
      //	注意		： なし
      //	メモ		： なし
      //	引数		： なし
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			Taji		新規
      // *************************************************************************/
      static CHandler* GetHandler()
      {
        if(CheckPointer(m_hendler) == POINTER_INVALID){
          m_hendler = new CHandler();
        }
        return m_hendler;
      }

      // *************************************************************************
      //	機能		： ログファイルへの出力
      //	注意		： なし
      //	メモ		： なし
      //	引数		： ログに記録する文字
      //	返り値		： なし
      //	参考URL		： なし
      // **************************	履	歴	************************************
      // 		v1.0		2021.04.14			Taji		新規
      // *************************************************************************/
      int OnInit(){
      }
      void OnDeinit(const int reason){
      }
      void OnTick(){
      }
      
};
CLogger*           CLogger::m_log;