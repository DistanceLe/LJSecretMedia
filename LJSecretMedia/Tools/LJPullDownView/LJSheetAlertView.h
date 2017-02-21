//
//  LJSheetAlertView.h
//  LJSecretMedia
//
//  Created by LiJie on 16/8/11.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LJSheetBlock)(NSInteger flag, NSString* title);

@interface LJSheetAlertView : UIView

/**  取消按钮不需要设置，默认已添加 */
+(void)showSheetWithTitles:(NSArray*)titles handler:(LJSheetBlock)handler;

@end
