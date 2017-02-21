//
//  LJPullDownView.h
//  TestPullDownView
//
//  Created by LiJie on 15/12/30.
//  Copyright © 2015年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJPullDownView : UIView

/**  用户自定义的ContentView */
@property(nonatomic, weak)UIView* pullDownContentView;

/**  下拉视图的ContentView的高度，默认原始高度 */
@property(nonatomic, assign)CGFloat   contentViewHeight;

/**  是否是向下滑，或者上滑 */
@property(nonatomic, assign)BOOL isPullDown;

/**  是否是展开状态， 亦可通过该属性直接改变其状态 */
@property(nonatomic, assign)BOOL isShowStatus;


/**  获取下拉视图的单例 */
+(instancetype)sharePullDownViewWithFrame:(CGRect)frame;

/**  开始下拉 */
-(void)showPullDownView;

/**  收起 */
-(void)dismissPullDownView;


@end
