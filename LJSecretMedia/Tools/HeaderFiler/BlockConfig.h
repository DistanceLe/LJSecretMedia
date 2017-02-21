//
//  BlockConfig.h
//  LJTrack
//
//  Created by LiJie on 16/6/14.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#ifndef BlockConfig_h
#define BlockConfig_h

typedef void (^ReturnValueBlock) (id returnValue);
typedef void (^ErrorCodeBlock) (NSString* message);
typedef void (^FailureBlock)();
typedef void (^CompleteBlock)();

typedef void(^ButtonClickBlock)(id sender);
typedef void(^StatusBlock)(id sender, id status);

#endif /* BlockConfig_h */
