//
//  LJLookImageView.h
//  图片查看
//
//  Created by LiJie on 16/3/23.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef CGPoint(^PointBlock)(NSInteger index);

@interface LJLookImageView : UIView

@property(nonatomic, weak)UIViewController* superVC;

/**  从网络下载图片，和NameArray 二选一  暂时没用到*/
@property(nonatomic, strong)NSArray* imageUrlArray;

/**  在缓存里面取图片，和UrlArray 二选一 */
@property(nonatomic, strong)NSArray* imageNameArray;

/**  对应第几张图片 */
@property(nonatomic, assign)NSInteger tapIndex;

/**  point,即从该点开始显示放大 小尺寸图片大小*/
- (instancetype)initWithShowPoint:(CGPoint)point size:(CGSize)size;

/**  开始展示图片 */
-(void)showLookView;

/**  滑动图片后，小图片做相应的操作，并返回对应小图片 的中心位置 */
-(void)requestTheHidePoint:(PointBlock)handler;
/**  移除照片查看器后的回调 */
-(void)removeSelfHandler:(StatusBlock)handler;
@end
