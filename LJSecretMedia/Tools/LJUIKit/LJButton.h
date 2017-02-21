//
//  LJButton.h
//  LJAnimation
//
//  Created by LiJie on 16/8/9.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJButton : UIButton

/**  圆圈动画效果颜色 */
@property(nonatomic, strong)UIColor* circleEffectColor;

/**  动画时间默认0.35秒 */
@property(nonatomic, assign)CGFloat  circleEffectTime;

/**  小圆的半径  默认20*/
@property(nonatomic, assign)CGFloat  minRadius;

@end
