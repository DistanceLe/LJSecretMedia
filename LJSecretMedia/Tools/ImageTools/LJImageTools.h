//
//  LJImageTools.h
//  imageTools
//
//  Created by LiJie on 16/1/12.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LJImageTools : NSObject

/**  缩放图片 */
+(UIImage*)changeImageSize:(UIImage*)originImage toSize:(CGSize)size;
+(UIImage*)changeImageSizeOther:(UIImage*)originImage toSize:(CGSize)size;

/**  旋转图片90度一个单位 */
+(UIImage*)rotationImage:(UIImage*)image rotation:(UIImageOrientation)orientation;

/**  旋转图片 自定义角度 */
+(UIImage*)rotationImage:(UIImage*)image angle:(CGFloat)angle;

/**  等比例缩放 */
+(UIImage*)changeImage:(UIImage*)originImage toRatioSize:(CGSize)size;

/**  安装最短边，等比例压缩 */
+(UIImage*)changeImageRatioCompress:(UIImage*)originImage ratioCompressSize:(CGSize)size;

/**  剪切图片 */
+(UIImage*)cutImagePart:(UIImage*)originImage cutRect:(CGRect)rect;

/**   添加圆角 */
+(UIImage*)addImageRound:(UIImage*)originImage roundSize:(CGSize)size;


/**  获取网络图片大小 */
+(CGSize)getNetImageSizeWith:(id)imageURL;


/**  设置图片模糊效果0.0~1.0 */
+(UIImage*)setBlurImage:(UIImage*)image blurAmount:(CGFloat)blur;
+(UIImage*)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;







@end
