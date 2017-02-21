//
//  LJALAssetTools.h
//  相册Demo
//
//  Created by LiJie on 16/1/7.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^GroupBlock)(ALAssetsGroup* group, UIImage* groupThumbnail, NSString* groupName, NSInteger groupCount);

typedef void(^ImagesBlock)(NSArray<UIImage*>* imageArray);

typedef void(^ImageBlock)(UIImage* image);

typedef void(^ImageAssetsBlock)(NSArray<ALAsset*>* imageAssets);

typedef void(^ThumbnailsBlock)(NSArray<UIImage*>* thumbnails);

/**
 *  ALAssetLibrary -> ALAssetGroup -> ALAsset -> ALAssetRepresentation
 */
@interface LJALAssetTools : NSObject

/**  当有多个组的时候，会多次调用handler */
+(void)getAllALAssetGroupsHandler:(GroupBlock)handler;

/**  获取组内的图片资源 */
+(void)getImageAssetsWithAssetGroup:(ALAssetsGroup*)group handler:(ImageAssetsBlock)handler;

/**  根据Alasset获取高清图 */
+(UIImage*)getImagesWithAsset:(ALAsset*)asset;
/**  不推荐使用，内存会爆。。 */
+(void)getImagesWithAssets:(NSArray<ALAsset*>*)assets handler:(ImagesBlock)handler;

/**  根据ALAsset获取缩略图 */
+(void)getThumbnailsWithAssets:(NSArray<ALAsset*>*)assets handler:(ThumbnailsBlock)handler;

/**  根据ALAsset获取宽高比的缩略图 */
+(void)getAspectRatioThumbnailsWithAssets:(NSArray<ALAsset*>*)assets handler:(ThumbnailsBlock)handler;

/**  获取资源的二进制数据 */
+(NSData*)getDataWithALAsset:(ALAsset*)asset;

/**  吧资源的二进制数据缓存到文件路径下 */
+(BOOL)writeAssetData:(ALAsset*)asset toPath:(NSString*)filePath;





















@end
