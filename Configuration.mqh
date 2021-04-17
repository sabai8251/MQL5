//**************************************************
// Configuration
//**************************************************
#define MAGICNUM 345678
#define TP_ALPHA1	60.0
#define TP_ALPHA2	1.0
#define TP_ALPHA3	60.0
//TPの指定テーブル
struct _tbl_TP{
	int specify_price_num;  //いくつめ注文か
	double alpha;  //ゲタ
};
_tbl_TP tbl_TP[] = {
	{ 1, TP_ALPHA1 },//注文が1つの場合. 1番の注文の価格＋α1
	{ 1, TP_ALPHA2 },//注文が2つの場合. 1番の注文の価格＋α2
	{ 2, TP_ALPHA1 },//注文が3つの場合. 2番の注文の価格＋α2
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
	{ 8, TP_ALPHA2 },
};

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

int diff_price_order[] = {
	BASE_DIFF_PRICE_TO_ORDER1 ,//現在注文が1つの場合.
	BASE_DIFF_PRICE_TO_ORDER2,
	BASE_DIFF_PRICE_TO_ORDER3,
	BASE_DIFF_PRICE_TO_ORDER4,
	BASE_DIFF_PRICE_TO_ORDER5,
	BASE_DIFF_PRICE_TO_ORDER6,
	BASE_DIFF_PRICE_TO_ORDER7,
	BASE_DIFF_PRICE_TO_ORDER8,
	BASE_DIFF_PRICE_TO_ORDER9,
};

#define BASE_LOT 0.05 //最小ロット数
#define MAX_ORDER_NUM 8 // 追加数制限

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
