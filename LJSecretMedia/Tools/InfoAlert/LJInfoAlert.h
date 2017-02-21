

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kLJInfoAlert_fontSize       15
#define kLJInfoAlert_width          200
#define kLJVertical                 0.65
#define kMax_ConstrainedSize        CGSizeMake(200, 100)


@interface LJInfoAlert : UIView
{
    CGColorRef bgcolor_;
    NSString *info_;
    CGSize fontSize_;
}

// info为提示信息，view是为消息框的superView
// vertical 为垂直方向上出现的位置 从 取值 0 ~ 1。
+ (void)showInfo:(NSString*)info 
         bgColor:(CGColorRef)color;

@end
