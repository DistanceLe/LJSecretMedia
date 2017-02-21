//
//  UIView+LJ.h
//  LJTrack
//
//  Created by LiJie on 16/6/17.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LJTapBlock)(UITapGestureRecognizer* tap, UIView* itself);
typedef void(^LJPanBlock)(UIPanGestureRecognizer* pan, UIView* itself);

@interface UIView (LJ)


@property (nonatomic, assign)CGFloat lj_height;
@property (nonatomic, assign)CGFloat lj_width;
@property (nonatomic, assign)CGFloat lj_y;
@property (nonatomic, assign)CGFloat lj_x;

@property(nonatomic, assign) CGPoint lj_origin;
@property(nonatomic, assign) CGSize  lj_size;

@property(nonatomic, assign)CGFloat  lj_maxX;
@property(nonatomic, assign)CGFloat  lj_maxY;

@property(nonatomic, assign)CGFloat  lj_centerX;
@property(nonatomic, assign)CGFloat  lj_centerY;

/**  添加一个点击事件 */
-(void)addTapGestureHandler:(LJTapBlock)handler;

/**  添加一个双击事件 */
-(void)addDoubleTapGestureHandler:(LJTapBlock)handler;

/**  添加一个滑动事件 */
-(void)addPanGestureHandler:(LJPanBlock)handler;


@end
