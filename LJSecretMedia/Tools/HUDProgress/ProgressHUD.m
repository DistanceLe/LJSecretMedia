

#import "ProgressHUD.h"

@implementation ProgressHUD
{
    BOOL _stop;
}
@synthesize window, hud, spinner, image, label, backView;

//=====================================================
+ (ProgressHUD *)shared
{
    
	static dispatch_once_t once = 0;
	static ProgressHUD *progressHUD;
	
	dispatch_once(&once, ^
    {
        progressHUD = [[ProgressHUD alloc] init];
    });
	
	return progressHUD;
}
+ (void)stop
{
    [[self shared]setStatusStop:YES];
}
+(void)start
{
    [[self shared]setStatusStop:NO];
}
-(void)setStatusStop:(BOOL)isStop
{
    _stop=isStop;
}
//=====================================================
+ (void)dismiss
{
	[[self shared] hudHide];
}

//=====================================================
+ (void)show:(NSString *)status
{
	[[self shared] hudMake:status imgage:nil spin:YES hide:YES];
}
+(void)show:(NSString *)status autoStop:(BOOL)stop
{
    [[self shared] hudMake:status imgage:nil spin:YES hide:stop];
}
//=====================================================
+ (void)showSuccess:(NSString *)status
{
	[[self shared] hudMake:status imgage:HUD_IMAGE_SUCCESS spin:NO hide:YES];
}

//=====================================================
+ (void)showError:(NSString *)status
{
	[[self shared] hudMake:status imgage:HUD_IMAGE_ERROR spin:NO hide:YES];
}

//=====================================================
- (id)init
{
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
	
	id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
	
	if ([delegate respondsToSelector:@selector(window)])
		window = [delegate performSelector:@selector(window)];
	else window = [[UIApplication sharedApplication] keyWindow];
	
    hud = nil; spinner = nil; image = nil; label = nil; backView=nil;
	
    self.hidden=YES;
	
	return self;
}

//=====================================================
- (void)hudMake:(NSString *)status imgage:(UIImage *)img spin:(BOOL)spin hide:(BOOL)hide
{
    if (_stop)
    {
        return;
    }
	[self hudCreate];
	
	label.text = status;
	label.hidden = (status == nil) ? YES : NO;
	
	image.image = img;
	image.hidden = (img == nil) ? YES : NO;
	
	if (spin)
    {
        [spinner startAnimating];
    }
	else
    {
        [spinner stopAnimating];
    }
	[self hudOrient];
	[self hudSize];
	[self hudShow];
	
	if (hide)
    {
        [NSThread detachNewThreadSelector:@selector(timedHide) toTarget:self withObject:nil];
    }
    
}

//=====================================================
- (void)hudCreate
{
	
	if (hud == nil)
	{
		hud = [[UIToolbar alloc] initWithFrame:CGRectZero];
		hud.barTintColor = HUD_BACKGROUND_COLOR;
		hud.translucent = NO;
        hud.alpha=0.7;
		hud.layer.cornerRadius = 10;
		hud.layer.masksToBounds = YES;
		//------------------------------------------------------------------
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
    if (backView==nil)
    {
        backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT)];
        backView.backgroundColor=[UIColor clearColor];
    }
    if (backView.superview==nil)
    {
        [window addSubview:backView];
    }
	if (hud.superview == nil) [window addSubview:hud];
	
	if (spinner == nil)
	{
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		spinner.color = HUD_SPINNER_COLOR;
		spinner.hidesWhenStopped = YES;
	}
	if (spinner.superview == nil) [hud addSubview:spinner];
	
	if (image == nil)
	{
		image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
	}
	if (image.superview == nil) [hud addSubview:image];
	
	if (label == nil)
	{
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.font = HUD_STATUS_FONT;
		label.textColor = HUD_STATUS_COLOR;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		label.numberOfLines = 0;
	}
	if (label.superview == nil) [hud addSubview:label];
	
}

//=====================================================
- (void)hudDestroy
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	
	[label removeFromSuperview];	label = nil;
	[image removeFromSuperview];	image = nil;
	[spinner removeFromSuperview];	spinner = nil;
    [backView removeFromSuperview]; backView=nil;
	[hud removeFromSuperview];		hud = nil;
}

//=====================================================
- (void)rotate:(NSNotification *)notification
{
	[self hudOrient];
}

//=====================================================
- (void)hudOrient
{
	CGFloat rotate = 0.0;
	
	UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
	
	if (orient == UIInterfaceOrientationPortrait)			rotate = 0.0;
	if (orient == UIInterfaceOrientationPortraitUpsideDown)	rotate = M_PI;
	if (orient == UIInterfaceOrientationLandscapeLeft)		rotate = - M_PI_2;
	if (orient == UIInterfaceOrientationLandscapeRight)		rotate = + M_PI_2;
	
	hud.transform = CGAffineTransformMakeRotation(rotate);
}

//=====================================================
- (void)hudSize
{
	CGRect labelRect = CGRectZero;
	CGFloat hudWidth = 100, hudHeight = 100;
	
	if (label.text != nil)
	{
		NSDictionary *attributes = @{NSFontAttributeName:label.font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		labelRect = [label.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];
        
		labelRect.origin.x = 12;
		labelRect.origin.y = 66;

		hudWidth = labelRect.size.width + 24;
		hudHeight = labelRect.size.height + 80;

		if (hudWidth < 100)
		{
			hudWidth = 100;
			labelRect.origin.x = 0;
			labelRect.size.width = 100;
		}
	}
	
	CGSize screen = [UIScreen mainScreen].bounds.size;
	
	hud.center = CGPointMake(screen.width/2, screen.height/2);
	hud.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
	
	CGFloat imagex = hudWidth/2;
	CGFloat imagey = (label.text == nil) ? hudHeight/2 : 36;
	image.center = spinner.center = CGPointMake(imagex, imagey);
	
	label.frame = labelRect;
}

//=====================================================
- (void)hudShow
{
    if (self.hidden==YES)
    {
        self.hidden=NO;
        hud.hidden=YES;
        hud.transform = CGAffineTransformScale(hud.transform, 1.4, 1.4);
        
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
        
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            hud.transform = CGAffineTransformScale(hud.transform, 1/1.4, 1/1.4);
            hud.hidden=NO;
        }
        completion:^(BOOL finished){ }];
    }
}

//=====================================================
NSLock static* myLock=nil;
- (void)hudHide
{
   
    if (myLock==nil)
    {
        myLock=[[NSLock alloc]init];
    }
    [myLock lock];
	if (self.hidden==NO || backView!=nil)
	{
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;

		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			hud.transform = CGAffineTransformScale(hud.transform, 0.7, 0.7);
            hud.hidden=YES;
		}
		completion:^(BOOL finished)
		{
			[self hudDestroy];
            self.hidden=YES;
		}];
	}
    [myLock unlock];
}

//=====================================================
- (void)timedHide
{
	@autoreleasepool
	{
        if (!_isNotAutomaticDismiss)
        {
            CGFloat delayTime=8.0;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime*NSEC_PER_SEC)), dispatch_get_main_queue(), ^
           {
               [self hudHide];
           });
        }
	}
}

@end
