//**************************************************
// Configurationパターン切り替え
//**************************************************
#define CONFICRATION_PATERN1
//#define CONFICRATION_PATERN2


#ifdef CONFICRATION_PATERN1
//**************************************************
// Configuration
//**************************************************
//#define MAGICNUM 345675
#define MAGICNUM 345676

//OrderManager::CalculateNewTP()の計算方法をモードを定義やリスト定義
#define TP_CALCULATION_MODE_TAKA	1
#define TP_CALCULATION_MODE_TAJI	2
int Config_tp_calculation_mode=TP_CALCULATION_MODE_TAKA;

//**************************************************
// ロット数に関する定義、リスト、カスタム関数
//**************************************************
#define BASE_LOT (0.01)
#define MAX_ORDER_NUM 6 // 注文追加数制限
#define MAX_LOT_LIST_NUM 16 // ロットリストのリスト数

double g_base_lot = BASE_LOT;//最小ロット数
//デフォルト注文時のBaseLotに対する倍率List
double lot_list[]={
	1,//注文１つ目のベースロット倍率
	2,//注文２つ目のベースロット倍率
	3,//注文３つ目のベースロット倍率
	4,//注文４つ目のベースロット倍率
	5,//注文５つ目のベースロット倍率
	6,//注文６つ目のベースロット倍率
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16
};

//LotListのカスタマイズ(Handlerのinitでコール)
void ConfigCustomizeLotList(){

	//**************taji用**********************
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAJI){ 
		for ( int i =0; i < MAX_LOT_LIST_NUM; i++ ){
			lot_list[i] = 1;
		}
	}
	//*******************************************

	//**************taka用**********************
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAKA){ 
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
	BASE_DIFF_PRICE_TO_ORDER1,//現在注文が1つの場合で、2つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER2,//現在注文が2つの場合で、3つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER3,//現在注文が3つの場合で、4つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER4,//現在注文が4つの場合で、5つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER5,//現在注文が5つの場合で、6つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER6,//現在注文が6つの場合で、7つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER7,//現在注文が7つの場合で、8つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER8,//現在注文が8つの場合で、9つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER9,//現在注文が9つの場合で、10つ目の注文をかける基準となる変動値.
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
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAJI){ 
		//デフォルト
		return;
	}
	//*******************************************

	//**************taka用**********************
	// ポイント：極力4ピン目を打たせないようにする
	// 数値は、1BTC約550～650万円での値
	// 標準で6ピンまでの耐え幅 4200USD(400 + 500 + 1000 + 1500 + 1800) → 約50万円程度
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAKA){ 

		for ( int i =0; i < MAX_DIFF_PRICE_LIST_NUM; i++ ){
			
			// ピン幅設定
			switch( i ){
				
				case 0:		// [0]: 2ピン目（1-2ピン間の価格差）
					diff_price_order[i] = 400;
					break;

				case 1:		// [1]: 3ピン目（2-3ピン間の価格差）
					diff_price_order[i] = 500;
					break;

				case 2:		// [2]: 4ピン目（3-4ピン間の価格差）
					diff_price_order[i] = 1000;
					break;

				case 3:		// [3]: 5ピン目（4-5ピン間の価格差）
					diff_price_order[i] = 1500;
					break;
				
				case 4:		// [4]: 6ピン目（5-6ピン間の価格差）
				case 5:		// [5]: 7ピン目（6-7ピン間の価格差）
					diff_price_order[i] = 1800;
					break;
					
				default:	// [5以降]: 8ピン目～
					diff_price_order[i] = 2000;
					break;
			}
		}
		return;
	}
	//*******************************************
	Print("ConfigCustomizeDiffPriceOrderList end");
	return;
}

//**************************************************
// TP値に関する定義、リスト、カスタム関数
//**************************************************
//TPテーブル用定義値
#define TP_ALPHA1	100.0
#define TP_ALPHA2	1.0
#define TP_ALPHA3	60.0 
#define MAX_TP_TABLE_ARRAY_NUM 16 //リスト数

//TPの指定テーブル
struct _tbl_TP{
	int specify_price_num;  //BUYまたはSELLにおいていくつめの注文かを表す番号
	double alpha;  //ゲタ
};
_tbl_TP tbl_TP[] = {
	{ 1, TP_ALPHA1 },//positionが1つの場合. 1番のpositionの価格＋α1
	{ 1, TP_ALPHA2 },//positionが2つの場合. 1番のpositionの価格＋α2
	{ 2, TP_ALPHA1 },//positionが3つの場合. 2番のpositionの価格＋α1
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
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAJI){
		//デフォルト
		return;
	}
	//*******************************************

	//**************taka用**********************
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAKA){ 
		//デフォルト;
		return;
	}
	//*******************************************

	return;
}

//**************************************************
// 値幅対応用定義、リスト
//**************************************************
//■急激な価格変更の検知時に、新規注文を入れない
//・1分の所定(250USD/60000USD)の値幅
#define DIFF_MINUTES_1 200
//・3分の所定(350USD/60000USD)の値幅
#define DIFF_MINUTES_3 250
//・10分の所定(500USD/60000USD)の値幅
#define DIFF_MINUTES_CUSTOM 350
#define NUM_MINUTES_CUSTOM 25 //カスタムチェックの期間(デフォルト10分)この値はチェックする最大の値にすること。最大配列Noに使っているためOutOfRangeErrorの原因になります

#define RECOMMEND_NO_PROBREM 0 //問題なし
#define RECOMMEND_STOP_BUY_DEAL 1 //BUYの取引一時停止
#define RECOMMEND_STOP_SELL_DEAL 2 //SELLの取引一時停止


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

#define MINIMUN_ACCOUNT_MARGIN_LEVEL 700 //取引可能な最低証拠金維持率(％)
#endif








//tajiいろいろいじる用
#ifdef CONFICRATION_PATERN2
//**************************************************
// Configuration
//**************************************************
//#define MAGICNUM 345675
#define MAGICNUM 345676
//OrderManager::CalculateNewTP()の計算方法をモードを定義やリスト定義
#define TP_CALCULATION_MODE_TAKA	1
#define TP_CALCULATION_MODE_TAJI	2
int Config_tp_calculation_mode=TP_CALCULATION_MODE_TAKA;

//**************************************************
// ロット数に関する定義、リスト、カスタム関数
//**************************************************
#define BASE_LOT (0.03) //最小ロット数
#define MAX_ORDER_NUM 6 // 注文追加数制限
#define MAX_LOT_LIST_NUM 16 // ロットリストのリスト数

double g_base_lot = BASE_LOT;//最小ロット数
//デフォルト注文LotList
double lot_list[]={
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16
};

//LotListのカスタマイズ(Handlerのinitでコール)
void ConfigCustomizeLotList(){
	//**************taji用**********************
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAJI){ 
		for ( int i =0; i < MAX_LOT_LIST_NUM; i++ ){
			lot_list[i] = 1;
		}
	}
	//*******************************************

	//**************taka用**********************
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAKA){ 
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
	BASE_DIFF_PRICE_TO_ORDER1,//現在注文が1つの場合で、2つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER2,//現在注文が2つの場合で、3つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER3,//現在注文が3つの場合で、4つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER4,//現在注文が4つの場合で、5つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER5,//現在注文が5つの場合で、6つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER6,//現在注文が6つの場合で、7つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER7,//現在注文が7つの場合で、8つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER8,//現在注文が8つの場合で、9つ目の注文をかける基準となる変動値.
	BASE_DIFF_PRICE_TO_ORDER9,//現在注文が9つの場合で、10つ目の注文をかける基準となる変動値.
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
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAJI){ 
		//デフォルト
		return;
	}
	//*******************************************

	//**************taka用**********************
	//・2,3ピンを300USD
	//・4,5ピン～を500USD
	//・6ピン～を800USD
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAKA){ 
		for ( int i =0; i < MAX_DIFF_PRICE_LIST_NUM; i++ ){
			if( i < 2 ){
				diff_price_order[i] = 300;
			}
			else if( i < 4 ){
				diff_price_order[i] = 500;
			}
			else{
				diff_price_order[i] = 800;
			}
		}
		return;
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
	{ 1, TP_ALPHA1 },//positionが1つの場合. 1番のpositionの価格＋α1
	{ 1, TP_ALPHA2 },//positionが2つの場合. 1番のpositionの価格＋α2
	{ 2, TP_ALPHA1 },//positionが3つの場合. 2番のpositionの価格＋α1
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
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAJI){
		//デフォルト
		return;
	}
	//*******************************************

	//**************taka用**********************
	if(Config_tp_calculation_mode == TP_CALCULATION_MODE_TAKA){ 
		//デフォルト;
		return;
	}
	//*******************************************

	return;
}



//**************************************************
// 値幅対応用定義、リスト
//**************************************************
//■急激な価格変更の検知時に、新規注文を入れない
//・1分の所定(250USD/60000USD)の値幅
#define DIFF_MINUTES_1 200
//・3分の所定(350USD/60000USD)の値幅
#define DIFF_MINUTES_3 250
//・10分の所定(500USD/60000USD)の値幅
#define DIFF_MINUTES_CUSTOM 350
#define NUM_MINUTES_CUSTOM 15 //カスタムチェックの期間(デフォルト10分)この値はチェックする最大の値にすること。最大配列Noに使っているためOutOfRangeErrorの原因になります

#define RECOMMEND_NO_PROBREM 0 //問題なし
#define RECOMMEND_STOP_BUY_DEAL 1 //BUYの取引一時停止
#define RECOMMEND_STOP_SELL_DEAL 2 //SELLの取引一時停止


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

#define MINIMUN_ACCOUNT_MARGIN_LEVEL 500 //取引可能な最低証拠金維持率(％)
#endif