//**************************************************
// Configuration
//**************************************************
#define MAGICNUM 345675

//**************************************************
// ロット数に関する定義、リスト、カスタム関数
//**************************************************
#define BASE_LOT (0.05) //最小ロット数
#define MAX_ORDER_NUM 8 // 注文追加数制限
#define MAX_LOT_LIST_NUM 16 // ロットリストのリスト数

//デフォルト注文LotList
double lot_list[]={
	BASE_LOT*1,
	BASE_LOT*2,
	BASE_LOT*3,
	BASE_LOT*4,
	BASE_LOT*5,
	BASE_LOT*6,
	BASE_LOT*7,
	BASE_LOT*8,
	BASE_LOT*9,
	BASE_LOT*10,
	BASE_LOT*11,
	BASE_LOT*12,
	BASE_LOT*13,
	BASE_LOT*14,
	BASE_LOT*15,
	BASE_LOT*16
};

//LotListのカスタマイズ(Handlerのinitでコール)
void ConfigCustomizeLotList(){
	//**************taji用**********************
	if(0){ 
		for ( int i =0; i < MAX_LOT_LIST_NUM; i++ ){
			lot_list[i] = BASE_LOT;
		}
	}
	//*******************************************

	//**************taka用**********************
	if(0){ 
		//デフォルト
		return;
	}
	//*******************************************
	return;
}

//**************************************************
// ピン幅に関する定義、リスト、カスタム関数
//**************************************************
//前回注文価格との変動差分を定義。次の注文を実施する判断値と使用。
#define MAX_DIFF_PRICE_LIST_NUM 16 // ピン幅リストのリスト数
#define BASE_DIFF_PRICE 50
#define BASE_DIFF_PRICE_TO_ORDER1		120		// 追加注文判定用基準変動価格1
#define BASE_DIFF_PRICE_TO_ORDER2		BASE_DIFF_PRICE_TO_ORDER1+BASE_DIFF_PRICE		// 追加注文判定用基準変動価格2
#define BASE_DIFF_PRICE_TO_ORDER3		BASE_DIFF_PRICE_TO_ORDER2+BASE_DIFF_PRICE	
#define BASE_DIFF_PRICE_TO_ORDER4		BASE_DIFF_PRICE_TO_ORDER3+BASE_DIFF_PRICE	
#define BASE_DIFF_PRICE_TO_ORDER5		BASE_DIFF_PRICE_TO_ORDER4+BASE_DIFF_PRICE
#define BASE_DIFF_PRICE_TO_ORDER6		BASE_DIFF_PRICE_TO_ORDER5+BASE_DIFF_PRICE	
#define BASE_DIFF_PRICE_TO_ORDER7		BASE_DIFF_PRICE_TO_ORDER6+BASE_DIFF_PRICE	
#define BASE_DIFF_PRICE_TO_ORDER8		BASE_DIFF_PRICE_TO_ORDER7+BASE_DIFF_PRICE	
#define BASE_DIFF_PRICE_TO_ORDER9		BASE_DIFF_PRICE_TO_ORDER8+BASE_DIFF_PRICE
#define BASE_DIFF_PRICE_TO_ORDER10		BASE_DIFF_PRICE_TO_ORDER9+BASE_DIFF_PRICE
#define BASE_DIFF_PRICE_TO_ORDER11		BASE_DIFF_PRICE_TO_ORDER10+BASE_DIFF_PRICE
#define BASE_DIFF_PRICE_TO_ORDER12		BASE_DIFF_PRICE_TO_ORDER11+BASE_DIFF_PRICE
#define BASE_DIFF_PRICE_TO_ORDER13		BASE_DIFF_PRICE_TO_ORDER12+BASE_DIFF_PRICE
#define BASE_DIFF_PRICE_TO_ORDER14		BASE_DIFF_PRICE_TO_ORDER13+BASE_DIFF_PRICE
#define BASE_DIFF_PRICE_TO_ORDER15		BASE_DIFF_PRICE_TO_ORDER14+BASE_DIFF_PRICE
#define BASE_DIFF_PRICE_TO_ORDER16		BASE_DIFF_PRICE_TO_ORDER15+BASE_DIFF_PRICE

//ピン幅リスト
int diff_price_order[] = {
	BASE_DIFF_PRICE_TO_ORDER1,//現在注文が1つの場合で、次の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER2,//現在注文が2つの場合で、次の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER3,
	BASE_DIFF_PRICE_TO_ORDER4,
	BASE_DIFF_PRICE_TO_ORDER5,
	BASE_DIFF_PRICE_TO_ORDER6,
	BASE_DIFF_PRICE_TO_ORDER7,
	BASE_DIFF_PRICE_TO_ORDER8,
	BASE_DIFF_PRICE_TO_ORDER9,
	BASE_DIFF_PRICE_TO_ORDER10,
	BASE_DIFF_PRICE_TO_ORDER11,
	BASE_DIFF_PRICE_TO_ORDER12,
	BASE_DIFF_PRICE_TO_ORDER13,
	BASE_DIFF_PRICE_TO_ORDER14,
	BASE_DIFF_PRICE_TO_ORDER15,
	BASE_DIFF_PRICE_TO_ORDER16
};

//ピン幅リストのカスタマイズ(Handlerのinitでコール)
void ConfigCustomizeDiffPriceOrderList(){
	Print("ConfigCustomizeDiffPriceOrderList start");
	//**************taji用**********************
	if(0){ 
		//デフォルト
		return;
	}
	//*******************************************

	//**************taka用**********************
	//・2,3ピンを300USD
	//・4ピン～を500USD
	if(1){ 
		for ( int i =0; i < MAX_DIFF_PRICE_LIST_NUM; i++ ){
			if( i < 2 ){
				Print("ConfigCustomizeDiffPriceOrderList i=%d",i);
				diff_price_order[i] = 300;
			}
			else{
				Print("ConfigCustomizeDiffPriceOrderList i=%d",i);
				diff_price_order[i] = 500;
			}
		}
	}
	//*******************************************
	Print("ConfigCustomizeDiffPriceOrderList end");
	return;
}

//**************************************************
// TP値に関する定義、リスト、カスタム関数
//**************************************************
//TPテーブル用定義値
#define TP_ALPHA1	60.0
#define TP_ALPHA2	1.0
#define TP_ALPHA3	60.0 
#define MAX_TP_TABLE_ARRAY_NUM 16 //リスト数

//TPの指定テーブル
struct _tbl_TP{
	int specify_price_num;  //BUYまたはSELLにおいていくつめの注文かを表す番号
	double alpha;  //ゲタ
};
_tbl_TP tbl_TP[] = {
	{ 1, TP_ALPHA1 },//注文が1つの場合. 1番の注文の価格＋α1
	{ 1, TP_ALPHA2 },//注文が2つの場合. 1番の注文の価格＋α2
	{ 2, TP_ALPHA1 },//注文が3つの場合. 2番の注文の価格＋α1
	{ 2, TP_ALPHA2 },
	{ 3, TP_ALPHA1 },
	{ 3, TP_ALPHA2 },
	{ 4, TP_ALPHA1 },
	{ 4, TP_ALPHA2 },
	{ 5, TP_ALPHA1 },
	{ 5, TP_ALPHA2 },
	{ 6, TP_ALPHA1 },
	{ 6, TP_ALPHA2 },
	{ 7, TP_ALPHA1 },
	{ 7, TP_ALPHA2 },
	{ 8, TP_ALPHA1 },
	{ 8, TP_ALPHA2 }
};

//TPテーブルのカスタマイズ(Handlerのinitでコール)
void ConfigCustomizeTPTable(){
	
	//**************taji用**********************
	if(1){
		//デフォルト
		return;
	}
	//*******************************************

	//**************taka用**********************
	if(1){ 
		//デフォルト;
		return;
	}
	//*******************************************

	return;
}

#define TP_CALCULATION_MODE_TAKA	1
#define TP_CALCULATION_MODE_TAJI	2
//OrderManager::CalculateNewTP()の計算方法をモードを定義
int Config_tp_calculation_mode=TP_CALCULATION_MODE_TAKA;

//**************************************************
// Checker用定義、リスト
//**************************************************
#define EA_STAGE		"Prototype"				// ステージ表示
#define EA_VERSION		"1.00"					// バージョン表示

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