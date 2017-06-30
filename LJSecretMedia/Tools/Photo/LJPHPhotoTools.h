//
//  LJPHPhotoTools.h
//  相册Demo
//
//  Created by LiJie on 16/7/28.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^PHGroupBlock)         (NSArray<PHAssetCollection*>* group, NSArray* posterImages,
                                     NSArray* groupNames, NSArray* groupCounts);

typedef void(^PHImagesBlock)        (NSArray<UIImage*>* imageArray);
typedef void(^PHImageDataBlock)     (NSData* imageData, NSString* imageName);
typedef void(^PHOriginImageBlock)   (UIImage* image);
typedef void(^PHImageBlock)         (UIImage* image);
typedef void(^PHCompletionBlock)    (BOOL success);

@interface LJPHPhotoTools : NSObject

/**  获取所有相册 */
+(void)getAllGroup:(PHGroupBlock)handler;

/**  获取一个相册的所有图片信息 */
+(NSArray<PHAsset*>*)getAssetsInCollection:(PHAssetCollection*)collection;

/**  获取单张原始图片 */
+(void)getOriginImagesWithAsset:(PHAsset*)asset handler:(PHOriginImageBlock)handler;

/**  获取单张图片，size：PHImageManagerMaximumSize  则是原始图片 */
+(void)getImageWithAsset:(PHAsset*)asset imageSize:(CGSize)size handler:(PHImageBlock)handler;

/**  异步获取单张图片，推荐使用该方法 */
+(void)getAsyncImageWithAsset:(PHAsset*)asset imageSize:(CGSize)size handler:(PHImageBlock)handler;

/**  获取默认的所有缩略图，100*100 也相当于屏幕的50*50 */
+(void)getThumbnailImagesWithAssets:(NSArray<PHAsset*>*)assets handler:(PHImagesBlock)handler;

/**  获取自定义大小的所有缩略图， 如果图片太多太大，可能造成内存爆满 */
+(void)getThumbnailImagesWithAssets:(NSArray<PHAsset*>*)assets imageSize:(CGSize)size handler:(PHImagesBlock)handler;

/**  获取原始图片(视频)的二进制数据 */
+(void)getImageDataWithAsset:(PHAsset*)asset handler:(PHImageDataBlock)handler;

/**  删除系统图片 */
+(void)deleteImageWithAssets:(NSArray<PHAsset*>*)assets handler:(PHCompletionBlock)handler;

/**  保存图片到系统相册 */
+(void)saveImageToCameraRoll:(UIImage*)image handler:(PHCompletionBlock)handler;

/**  保存图片到自定义相册 */
+(void)saveImage:(UIImage*)image toCustomAlbum:(NSString*)albumName handler:(PHCompletionBlock)handler;

/**  保存沙盒视频文件到相册 */
+(void)saveVideoFromURL:(NSURL*)url toCustomAlbum:(NSString*)albumName handler:(PHCompletionBlock)handler;

/**  从相机获取图片 */
+(void)getImageFromCameraHandler:(PHImageBlock)handler;

/**  获取一张作为头像的图片 */
+(void)getHeadImageHandler:(PHImageBlock)handler;






@end
