//
//  WKAlertView.h
//  7dmallStore
//
//  Created by celink on 15/6/30.
//  Copyright (c) 2015年 celink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CommitBlock)(NSInteger flag);

@interface WKAlertView : UIAlertView<UIAlertViewDelegate>


+(void)customAlertWithTitle:(NSString*)title
                    message:(NSString *)message
                   delegate:(id)delegate
          cancelButtonTitle:(NSString *)cancelButtonTitle
          otherButtonTitles:(NSString *)otherButtonTitles
                clickButton:(CommitBlock)commit;

@end
