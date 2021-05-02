//**************************************************
// class CLogger
//**************************************************
class CLogger
{
	private:
		static CLogger* m_log;
		string          executionlog_directory_name;
		string          executionlog_base_file_name;
	
		//�v���C�x�[�g�R���X�g���N�^(���̃N���X��New�͂����Ȃ����I�I�I)
		CLogger(){
			executionlog_directory_name = "Executionlogs";
			executionlog_base_file_name = "logfile.log";
		}

	public:
		//	�@�\		�F //�V���O���g���N���X�C���X�^���X�擾
		static CLogger* GetLog()
		{
			if(CheckPointer(m_log) == POINTER_INVALID){
				m_log = new CLogger();
			}
			return m_log;
		}

		// *************************************************************************
		//	�@�\		�F ���O�t�@�C���ւ̏o��
		//	����		�F �Ȃ�
		//	����		�F �Ȃ�
		//	����		�F ���O�ɋL�^���镶��
		//	�Ԃ�l		�F �Ȃ�
		//	�Q�lURL		�F �Ȃ�
		// **************************	��	��	************************************
		// 		v1.0		2021.04.14			Taji		�V�K
		// *************************************************************************/
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
				Print("[Error] can not log. file_handle = " + (string)file_handle);
				Print("[Error] can not log. output file filename = " + filepath + logtext);
			}
		}
};
CLogger* CLogger::m_log;