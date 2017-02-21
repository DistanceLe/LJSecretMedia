//
//  LJFingerMark.h
//  LJSecretMedia
//
//  Created by LiJie on 16/7/28.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJFingerMark : NSObject

/**  handler 回调不会造成循环引用 */
+(void)addCheckingFingerHandler:(StatusBlock)handler;

@end
