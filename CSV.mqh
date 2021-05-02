//**************************************************
// class CCSV
//**************************************************
class CCSV
{
	private:
		static CCSV* m_CSV;
		string          executioncsv_directory_name;
		string          executioncsv_base_file_name;
		int             file_handle;
		//�v���C�x�[�g�R���X�g���N�^(���̃N���X��New�͂����Ȃ����I�I�I)
		CCSV(){
			executioncsv_directory_name = "CSVFiles";
			executioncsv_base_file_name = ".csv";
			file_handle = 0;
		}

	public:
		//	�@�\		�F //�V���O���g���N���X�C���X�^���X�擾
		static CCSV* GetCSV()
		{
			if(CheckPointer(m_CSV) == POINTER_INVALID){
				m_CSV = new CCSV();
			}
			return m_CSV;
		}

		// *************************************************************************
		//	�@�\		�F CSV�t�@�C���ւ̏o��
		//	����		�F �Ȃ�
		//	����		�F �Ȃ�
		//	����		�F CSV�ɋL�^���镶��
		//	�Ԃ�l		�F �Ȃ�
		//	�Q�lURL		�F �Ȃ�
		// **************************	��	��	************************************
		// 		v1.0		2021.04.14			Taji		�V�K
		// *************************************************************************/
		void output_csv_to_file(string csvtext, string str_type = "Unknown" ){
			string timestamptxt;
			MqlDateTime st_currenttime;
			
			//FileOpen
			TimeCurrent(st_currenttime);
			timestamptxt = StringFormat("%4d%02d%02d%02d%02d",
						st_currenttime.year,st_currenttime.mon,st_currenttime.day,st_currenttime.hour,st_currenttime.min);
			string filepath = executioncsv_directory_name  + "\\" + str_type + timestamptxt + executioncsv_base_file_name;
			if ( 0 == file_handle){
				file_handle = FileOpen(filepath,FILE_READ|FILE_WRITE); 
				Print("[Success] csv file open ");
			}

			if(file_handle!=INVALID_HANDLE) {
				string csvtext_to_file = csvtext;
				
				FileSeek(file_handle, 0, SEEK_END);
				FileWrite(file_handle, csvtext_to_file );
			}
			else{
				Print("[Error] can not write. file_handle = " + (string)file_handle);
				Print("[Error] can not write. output file filename = " + filepath + csvtext);
			}
		}
		
		void close_csv_file(){
			if ( 0 == file_handle){
				return; 
			} 
			
			if(file_handle!=INVALID_HANDLE) {
				FileFlush(file_handle);
				FileClose(file_handle);
				file_handle = 0;
			}
			else{
				Print("[Error] can not close. file_handle = " + (string)file_handle);
			}
		}
};
CCSV* CCSV::m_CSV;