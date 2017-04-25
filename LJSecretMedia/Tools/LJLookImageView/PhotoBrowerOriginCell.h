//
//  PhotoViewCell.h
//  myHelper
//
//  Created by wangyan on 2016－03－15.
//  Copyright © 2016年 idea. All rights reserved.
//

#import "PhotoBrowerBaseCell.h"

@interface PhotoBrowerOriginCell : PhotoBrowerBaseCell

@property (nonatomic,strong) UIScrollView * scrollView;

- (void)reuse;
- (void)imageGestureHandler:(StatusBlock)handler;
- (void)playButtonClickHandler:(StatusBlock)handler;

@end
