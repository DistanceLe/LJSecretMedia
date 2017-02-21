//
//  SGInfoAlert.m
//
//  Created by Azure_Sagi on 3/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LJInfoAlert.h"

@implementation LJInfoAlert


// 画出圆角矩形背景
static void addRoundedRectToPath(CGContextRef context, CGRect rect,
                                 float ovalWidth,float ovalHeight)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        //没有圆角的矩形
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context); 
    CGContextTranslateCTM (context, CGRectGetMinX(rect), 
                           CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight); 
    fw = CGRectGetWidth (rect) / ovalWidth; 
    fh = CGRectGetHeight (rect) / ovalHeight; 
    CGContextMoveToPoint(context, fw, fh/2);
    
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1); 
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); 
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); 
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); 
    CGContextClosePath(context); 
    CGContextRestoreGState(context); 
}

- (id)initWithFrame:(CGRect)frame bgColor:(CGColorRef)color info:(NSString*)info{
    CGRect viewR = CGRectMake(0, 0, frame.size.width*1.2, frame.size.height*1.2);
    self = [super initWithFrame:viewR];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bgcolor_ = color;
        if (!bgcolor_)
        {
            bgcolor_=[UIColor grayColor].CGColor;
        }
        info_ = [[NSString alloc] initWithString:info];
        fontSize_ = frame.size;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 背景0.8透明度
    CGContextSetAlpha(context, .8);
    
    //不设置圆角用0
    addRoundedRectToPath(context, rect, 0.0f, 0.0f);
//    addRoundedRectToPath(context, rect, 4.0f, 4.0f);
    CGContextSetFillColorWithColor(context, bgcolor_);
    CGContextFillPath(context);
    
    // 文字1.0透明度
    CGContextSetAlpha(context, 1.0);
//    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 1, [[UIColor whiteColor] CGColor]);
//    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    float x = (rect.size.width - fontSize_.width) / 2.0;
    float y = (rect.size.height - fontSize_.height) / 2.0;
    CGRect r = CGRectMake(x, y, fontSize_.width, fontSize_.height);
    
    [info_ drawInRect:r withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kLJInfoAlert_fontSize],  NSForegroundColorAttributeName:kFontColor}];
}
-(void)dealloc
{
    DLog(@"info View dealloc==========");
}
// 从上层视图移除并释放
- (void)remove{
    [self removeFromSuperview];
}

// 渐变消失
- (void)fadeAway{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0f];
    self.alpha = .0;
    [UIView commitAnimations];
    [self performSelector:@selector(remove) withObject:nil afterDelay:1.5f];
}

+ (void)showInfo:(NSString *)info 
         bgColor:(CGColorRef)color
{
//    height = height < 0 ? 0 : height > 1 ? 1 : height;
    if (IFISNULL(info))
    {
        return;
    }
    color=[kSystemColor CGColor];
    CGColorSpaceRef  space= CGColorGetColorSpace(color);
    const CGFloat* components=CGColorGetComponents(color);
    color =CGColorCreate(space, components);
    
    
    
    CGFloat height=kLJVertical;
    CGRect rect=[info boundingRectWithSize:CGSizeMake(320, 300) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kLJInfoAlert_fontSize]} context:nil];
    CGSize size=CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    //不再加到 view上面，直接加到 window上
    __block UIWindow* mainWindow=[[[UIApplication sharedApplication]delegate]window];
    LJInfoAlert *alert = [[LJInfoAlert alloc] initWithFrame:frame bgColor:color info:info];
    alert.center = CGPointMake(mainWindow.center.x, mainWindow.frame.size.height*height);
    alert.alpha = 0;
    [mainWindow addSubview:alert];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.3f];
    alert.alpha = 1.0;
    [UIView commitAnimations];
    [alert performSelector:@selector(fadeAway) withObject:nil afterDelay:0.7];
    
    NSArray* windows=[[UIApplication sharedApplication]windows];
    Class keyboardClass=NSClassFromString(@"UIRemoteKeyboardWindow");
    [windows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:keyboardClass]) {
            mainWindow=obj;
            *stop=YES;
            LJInfoAlert *alert = [[LJInfoAlert alloc] initWithFrame:frame bgColor:color info:info];
            alert.center = CGPointMake(mainWindow.center.x, mainWindow.frame.size.height*height);
            alert.alpha = 0;
            [mainWindow addSubview:alert];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:.3f];
            alert.alpha = 1.0;
            [UIView commitAnimations];
            [alert performSelector:@selector(fadeAway) withObject:nil afterDelay:0.7];
        }
    }];
}

@end
