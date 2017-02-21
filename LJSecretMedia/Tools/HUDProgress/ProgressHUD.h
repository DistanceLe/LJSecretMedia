
//--------------------------------------------------------------------------
//#define sheme_white
#define sheme_black
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
#define HUD_STATUS_FONT			[UIFont boldSystemFontOfSize:16]
//--------------------------------------------------------------------------
#ifdef sheme_white
#define HUD_STATUS_COLOR		[UIColor whiteColor]
#define HUD_SPINNER_COLOR		[UIColor whiteColor]
#define HUD_BACKGROUND_COLOR	[UIColor colorWithWhite:0 alpha:0.8]
#define HUD_IMAGE_SUCCESS		[UIImage imageNamed:@"success-white.png"]
#define HUD_IMAGE_ERROR			[UIImage imageNamed:@"error-white.png"]
#endif
//--------------------------------------------------------------------------
#ifdef sheme_black
#define HUD_STATUS_COLOR		[UIColor whiteColor]
#define HUD_SPINNER_COLOR		[UIColor whiteColor]
#define HUD_BACKGROUND_COLOR	kSystemColor        //需要自定义的背景色
#define HUD_IMAGE_SUCCESS		[UIImage imageNamed:@"success-black.png"]
#define HUD_IMAGE_ERROR			[UIImage imageNamed:@"error-black.png"]
#endif
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
@interface ProgressHUD : UIView
//--------------------------------------------------------------------------

+ (ProgressHUD *)shared;
+ (void)stop; //都停止
+ (void)start; //重新开始
+ (void)dismiss;
+ (void)show:(NSString *)status;
+ (void)show:(NSString *)status autoStop:(BOOL)stop;
//+ (void)showSuccess:(NSString *)status;
//+ (void)showError:(NSString *)status;

@property (atomic, strong) UIActivityIndicatorView *spinner;
@property (atomic, strong) UIImageView *image;
@property (atomic, strong) UIWindow    *window;
@property (atomic, strong) UIToolbar   *hud;
@property (atomic, strong) UILabel     *label;
@property (atomic, strong) UIView      * backView;

@property (nonatomic) BOOL isNotAutomaticDismiss;


@end
