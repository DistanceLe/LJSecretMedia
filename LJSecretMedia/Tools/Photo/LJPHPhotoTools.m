//
//  LJPHPhotoTools.m
//  相册Demo
//
//  Created by LiJie on 16/7/28.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJPHPhotoTools.h"
#import "LJImageTools.h"
#import "TimeTools.h"
#import "LJSheetAlertView.h"
#import <objc/runtime.h>

@interface LJPHPhotoTools ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong)PHImageBlock tempImageBlock;

@end


@implementation LJPHPhotoTools

/**             
                Photos框架须知
 1.PHAsset : 一个PHAsset对象代表一张图片或者一个视频文件
 1> 负责查询一堆的PHAsset对象
 
 2.PHAssetCollection : 一个PHAssetCollection对象代表一个相册
 1> 负责查询一堆的PHAssetCollection对象
 
 3.PHAssetChangeRequest
 1> 负责执行对PHAsset(照片或视频)的【增删改】操作
 2> 这个类只能放在-[PHPhotoLibrary performChanges:completionHandler:] 或者 -[PHPhotoLibrary performChangesAndWait:error:]方法的block中使用
 
 4.PHAssetCollectionChangeRequest
 1> 负责执行对PHAssetCollection(相册)的【增删改】操作
 2> 这个类只能放在-[PHPhotoLibrary performChanges:completionHandler:] 或者 -[PHPhotoLibrary performChangesAndWait:error:]方法的block中使用
  */
    
static dispatch_queue_t concurrentQueue;
#define asyncDispatch(code) dispatch_async(concurrentQueue, ^{ code });
#define mainDispatch(code)  dispatch_sync(dispatch_get_main_queue(), ^{ code });
    
+(void)load{
    concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
}
    
#pragma mark - ================ PHPhoto判断对相册的权限 ==================
+(BOOL)isHadAuthorization{
    BOOL author=NO;
    PHAuthorizationStatus status=[PHPhotoLibrary authorizationStatus];
    if (status==PHAuthorizationStatusDenied) {
        //用户拒绝当前应用访问相册
        author=NO;
    }else if (status==PHAuthorizationStatusRestricted){
        //系统限制，不允许访问相册 比如家长模式
        author=NO;
    }else if (status==PHAuthorizationStatusNotDetermined){
        //用户还没有做出选择
        author=NO;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
    }else if (status==PHAuthorizationStatusAuthorized){
        //已经授权
        author=YES;
    }else{
        author=NO;
    }
    return author;
}

#pragma mark - ================ HPPhote 获取图片（相册） ==================
+(void)getAllGroup:(PHGroupBlock)handler{
    if (![self isHadAuthorization]) {
        [WKAlertView customAlertWithTitle:@"你没有打开相册权限哦" message:@"是否去设置" delegate:nil cancelButtonTitle:@"不去" otherButtonTitles:@"设置" clickButton:^(NSInteger flag) {
            if (flag==1) {
                NSURL* url=[NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication]openURL:url];
            }
        }];
    }
    NSMutableArray* alubms=[NSMutableArray array];
    NSMutableArray* counts=[NSMutableArray array];
    NSMutableArray* names=[NSMutableArray array];
    __block NSMutableArray* images=[NSMutableArray array];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    PHFetchResult *userAlbums = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
    //注意类型
    for (PHAssetCollection *sub in smartAlbums){
        //遍历到数组中
        [alubms addObject:sub];
        [names addObject:sub.localizedTitle];
        
        PHFetchResult* result=[PHAsset fetchAssetsInAssetCollection:sub options:nil];
        NSInteger count=[result countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        count += [result countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
        [counts addObject:@(count)];
        
        if (count>0) {
            [self getImageWithAsset:result.firstObject imageSize:CGSizeMake(200, 200) handler:^(UIImage *image) {
                [images addObject:image];
            }];
        }else{
            [images addObject:[UIImage imageNamed:@"auth"]];
        }
    }
    for (PHAssetCollection* sub in userAlbums) {
        [alubms addObject:sub];
        [names addObject:sub.localizedTitle];
        
        PHFetchResult* result=[PHAsset fetchAssetsInAssetCollection:sub options:nil];
        NSInteger count=[result countOfAssetsWithMediaType:PHAssetMediaTypeImage];
        [counts addObject:@(count)];
        
        if (count>0) {
            [self getImageWithAsset:result.firstObject imageSize:CGSizeMake(200, 200) handler:^(UIImage *image) {
                [images addObject:image];
            }];
        }else{
            [images addObject:[UIImage imageNamed:@"auth"]];
        }
    }
    
    if (handler) {
        handler(alubms, images, names, counts);
    }
}

+(NSArray<PHAsset *> *)getAssetsInCollection:(PHAssetCollection *)collection{
    
    NSMutableArray* assets=[NSMutableArray array];
    PHFetchOptions* option=[[PHFetchOptions alloc]init];
    option.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult* result=[PHAsset fetchAssetsInAssetCollection:collection options:option];
    for (PHAsset* asset in result) {
        [assets addObject:asset];
    }
    return assets;
}

+(void)getOriginImagesWithAsset:(PHAsset *)asset handler:(PHOriginImageBlock)handler{
    //创建异步加载：
    asyncDispatch(
                  __block UIImage* tempImage=nil;
                  PHImageRequestOptions* option=[[PHImageRequestOptions alloc]init];
                  option.resizeMode=PHImageRequestOptionsResizeModeFast;//缩放模式
                  option.synchronous=YES;//是否同步
                  option.deliveryMode=PHImageRequestOptionsDeliveryModeFastFormat;//图片质量， synchronous YES时才有效
                  option.networkAccessAllowed=NO;
                  
                  
                  [[PHCachingImageManager defaultManager]requestImageForAsset:asset
                                                                   targetSize:PHImageManagerMaximumSize
                                                                  contentMode:PHImageContentModeAspectFit
                                                                      options:option
                                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                    if (result) {
                                                                        tempImage=result;
                                                                        DLog(@"========%@, %@\n\n", result, info);
                                                                    }
                                                                }];
                  mainDispatch(
                               if (handler) {
                                   handler(tempImage);
                               })
                  )
    
    
    
}

+(void)getImageWithAsset:(PHAsset *)asset imageSize:(CGSize)size handler:(PHImageBlock)handler{
    
    __block UIImage* tempImage=nil;
    PHImageRequestOptions* option=[[PHImageRequestOptions alloc]init];
    option.resizeMode=PHImageRequestOptionsResizeModeExact;//缩放模式
    option.synchronous=YES;//是否同步
    option.deliveryMode=PHImageRequestOptionsDeliveryModeFastFormat;//图片质量
    option.networkAccessAllowed=NO;
    
    [[PHCachingImageManager defaultManager]requestImageForAsset:asset
                                                     targetSize:size
                                                    contentMode:PHImageContentModeAspectFill
                                                        options:option
                                                  resultHandler:^(UIImage * _Nullable result,
                                                                  NSDictionary * _Nullable info) {
                                                      if (result) {
                                                          tempImage=result;
                                                          DLog(@"========%@, %@\n\n", result, info);
                                                      }
                                                  }];
    if (handler) {
        handler(tempImage);
    }
}

+(void)getAsyncImageWithAsset:(PHAsset *)asset imageSize:(CGSize)size handler:(PHImageBlock)handler{
    PHImageRequestOptions* option=[[PHImageRequestOptions alloc]init];
    option.resizeMode=PHImageRequestOptionsResizeModeExact;//缩放模式
    option.synchronous=NO;//是否同步
    option.deliveryMode=PHImageRequestOptionsDeliveryModeOpportunistic;//图片质量
    option.networkAccessAllowed=NO;
    
    [[PHCachingImageManager defaultManager]requestImageForAsset:asset
                                                     targetSize:size
                                                    contentMode:PHImageContentModeAspectFill
                                                        options:option
                                                  resultHandler:^(UIImage * _Nullable result,
                                                                  NSDictionary * _Nullable info) {
                                                      if (handler) {
                                                          handler(result);
                                                      }
                                                  }];
    
    
}

+(void)getHighQualityImageWithAsset:(PHAsset *)asset imageSize:(CGSize)size handler:(PHImageBlock)handler{
    PHImageRequestOptions* option=[[PHImageRequestOptions alloc]init];
    option.resizeMode=PHImageRequestOptionsResizeModeExact;//缩放模式
    option.synchronous=NO;//是否同步
    option.deliveryMode=PHImageRequestOptionsDeliveryModeHighQualityFormat;//图片质量
    option.networkAccessAllowed=NO;
    
    [[PHCachingImageManager defaultManager]requestImageForAsset:asset
                                                     targetSize:size
                                                    contentMode:PHImageContentModeAspectFill
                                                        options:option
                                                  resultHandler:^(UIImage * _Nullable result,
                                                                  NSDictionary * _Nullable info) {
                                                      if (handler) {
                                                          handler(result);
                                                      }
                                                  }];
    
    
}

+(void)getThumbnailImagesWithAssets:(NSArray<PHAsset *> *)assets handler:(PHImagesBlock)handler{
    
    asyncDispatch(
       NSMutableArray* images=[NSMutableArray array];
       PHImageRequestOptions* option=[[PHImageRequestOptions alloc]init];
       option.resizeMode=PHImageRequestOptionsResizeModeFast;//缩放模式
       option.synchronous=YES;//是否同步
       option.deliveryMode=PHImageRequestOptionsDeliveryModeFastFormat;//图片质量
       option.networkAccessAllowed=NO;
       
       for (NSInteger index=0; index<assets.count; index++) {
           PHAsset* asset=assets[index];
           [[PHCachingImageManager defaultManager]requestImageForAsset:asset
                                                            targetSize:CGSizeMake(100, 100)
                                                           contentMode:PHImageContentModeAspectFit
                                                               options:option
                                                         resultHandler:^(UIImage * _Nullable result,
                                                                         NSDictionary * _Nullable info) {
                                                             if (result) {
                                                                 [images addObject:result];
                                                                 DLog(@"========%@, %@\n\n", result, info);
                                                             }
                                                         }];
       }
       mainDispatch(
                    if (handler) {
                        handler(images);
                    })
    )
    
}

+(void)getThumbnailImagesWithAssets:(NSArray<PHAsset *> *)assets imageSize:(CGSize)size handler:(PHImagesBlock)handler{
    
    asyncDispatch(
        NSMutableArray* images=[NSMutableArray array];
        PHImageRequestOptions* option=[[PHImageRequestOptions alloc]init];
        option.resizeMode=PHImageRequestOptionsResizeModeExact;//缩放模式
        option.synchronous=YES;//是否同步
        option.deliveryMode=PHImageRequestOptionsDeliveryModeFastFormat;//图片质量
        option.networkAccessAllowed=NO;
        
        for (NSInteger index=0; index<assets.count; index++) {
            PHAsset* asset=assets[index];
            [[PHCachingImageManager defaultManager]requestImageForAsset:asset
                                                             targetSize:size
                                                            contentMode:PHImageContentModeAspectFill
                                                                options:option
                                                          resultHandler:^(UIImage * _Nullable result,
                                                                          NSDictionary * _Nullable info) {
                                                              if (result) {
                                                                  [images addObject:result];
                                                                  DLog(@"========%@, %@\n\n", result, info);
                                                              }
                                                          }];
        }
        mainDispatch(
            if (handler) {
                handler(images);
            })
        )
}

+(void)getImageDataWithAsset:(PHAsset *)asset handler:(PHImageDataBlock)handler{
    
    if (asset.mediaType == PHAssetMediaTypeVideo){
        //视频资源处理
        
        NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
        PHAssetResource *resource;
        for (PHAssetResource *assetRes in assetResources) {
            if (assetRes.type == PHAssetResourceTypePairedVideo ||
                assetRes.type == PHAssetResourceTypeVideo) {
                resource = assetRes;
            }
        }
        if (!resource) {
            handler(nil, nil);
            return;
        }
        __block NSMutableData* videoDatas = [NSMutableData data];
        [[PHAssetResourceManager defaultManager]requestDataForAssetResource:resource
                                                                    options:nil
                                                        dataReceivedHandler:^(NSData * _Nonnull data)
        {
            [videoDatas appendData:data];
        } completionHandler:^(NSError * _Nullable error) {
            if (error) {
                DLog(@"获取视频资源失败：%@", error);
                handler(nil, nil);
            }else{
                handler(videoDatas, @"MOV");
            }
        }];
        
    }else{
        PHImageRequestOptions* option=[[PHImageRequestOptions alloc]init];
        option.resizeMode=PHImageRequestOptionsResizeModeExact;//缩放模式
        option.synchronous=NO;//是否同步
        option.deliveryMode=PHImageRequestOptionsDeliveryModeFastFormat;//图片质量
        option.networkAccessAllowed=NO;
        
        [[PHCachingImageManager defaultManager]requestImageDataForAsset:asset
                                                                options:option
                                                          resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)
         {
            if (handler) {
                NSURL* imageURL=[info valueForKey:@"PHImageFileURLKey"];
                NSArray* tempArray=[imageURL.absoluteString componentsSeparatedByString:@"/"];
                NSString* imageName=nil;
                if (tempArray.count) {
                    imageName=tempArray.lastObject;
                }else{
                    imageName=[TimeTools getCurrentTimestamp];
                }
                handler(imageData, imageName);
            }
        }];
    }
}

#pragma mark - ================ C方法保存图片到相册 ==================
-(void)savePhoto{
    UIImage* image=[UIImage imageNamed:@"auth"];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        [LJInfoAlert showInfo:@"保存失败" bgColor:nil];
    }else{
        [LJInfoAlert showInfo:@"保存成功" bgColor:nil];
    }
}

#pragma mark - ================ PHPhoto 删除图片 ==================
+(void)deleteImageWithAssets:(NSArray<PHAsset *> *)assets handler:(PHCompletionBlock)handler{
    
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        [PHAssetChangeRequest deleteAssets:assets];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(success);
            });
        }
    }];
}

#pragma mark - ================ PHPhoto 保存图片 ==================
+(void)saveImageToCameraRoll:(UIImage *)image handler:(PHCompletionBlock)handler{
    if (image == nil) {
        [LJInfoAlert showInfo:@"保存失败" bgColor:nil];
        return;
    }
    //异步操作
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        //.placeholderForCreatedAsset.localIdentifier    同步的话，可以使用占位ID
        //[PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil]; 通过占位ID获取图片

        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(success);
            });
        }
    }];
}

+(void)saveImage:(UIImage *)image toCustomAlbum:(NSString *)albumName handler:(PHCompletionBlock)handler{
    if (nil==albumName || [albumName isEqualToString:@""]) {
        albumName=[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    }
    
    PHAssetCollection *createdCollection = nil;
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //判断是否已经有同名的相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:albumName]) {
            createdCollection = collection;
            break;
        }
    }
    if (!createdCollection) {
        __block NSString *createdCollectionId = nil;
        // 创建一个新的相册  同步操作
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
        } error:nil];
        
        // 创建完毕后再取出相册
        createdCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
    }
    if (image == nil || createdCollection == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(NO);
        });
        return;
    }
    
    __block NSString *createdAssetId = nil;
    NSError* error=nil;
    //同步 首先保存图片到系统相册
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        createdAssetId=[PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    PHFetchResult<PHAsset *> *createdAssets=[PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
    if (error || !createdAssets) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO);
            });
        }
        return;
    }
    
    //最后 再保存图片到指定的相册
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        //取到指定的相册请求
        PHAssetCollectionChangeRequest* request=[PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        //插入 图片，或者直接增加图片
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(success);
            });
        }
    }];
}

/**  保存沙盒视频文件到相册 */
+(void)saveVideoFromURL:(NSURL*)url toCustomAlbum:(NSString*)albumName handler:(PHCompletionBlock)handler{
    if (nil==albumName || [albumName isEqualToString:@""]) {
        albumName=[NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    }
    
    PHAssetCollection *createdCollection = nil;
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //判断是否已经有同名的相册
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:albumName]) {
            createdCollection = collection;
            break;
        }
    }
    if (!createdCollection) {
        __block NSString *createdCollectionId = nil;
        // 创建一个新的相册  同步操作
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
        } error:nil];
        
        // 创建完毕后再取出相册
        createdCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
    }
    if (url == nil || createdCollection == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(NO);
        });
        return;
    }
    
    __block NSString *createdAssetId = nil;
    NSError* error=nil;
    //同步 首先保存图片到系统相册
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        createdAssetId=[PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    PHFetchResult<PHAsset *> *createdAssets=[PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
    if (error || !createdAssets) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO);
            });
        }
        return;
    }
    
    //最后 再保存图片到指定的相册
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        //取到指定的相册请求
        PHAssetCollectionChangeRequest* request=[PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        //插入 图片，或者直接增加图片
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(success);
            });
        }
    }];
}



#pragma mark - ================ 从相机获取图片： ==================
static char photoToolsKey;
+(void)getImageFromCameraHandler:(PHImageBlock)handler{
    LJPHPhotoTools* tempSelf=[[LJPHPhotoTools alloc]init];
    tempSelf.tempImageBlock=handler;
    objc_setAssociatedObject(AppDelegateInstance, &photoToolsKey, tempSelf, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [tempSelf openCameraCanEdit:NO];
}

+(void)getHeadImageHandler:(PHImageBlock)handler{
    LJPHPhotoTools* tempSelf=[[LJPHPhotoTools alloc]init];
    tempSelf.tempImageBlock=handler;
    objc_setAssociatedObject(AppDelegateInstance, &photoToolsKey, tempSelf, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    __weak typeof(LJPHPhotoTools*) tempWeakSelf=tempSelf;
    [LJSheetAlertView showSheetWithTitles:@[@"拍照", @"从手机相册选择"] handler:^(NSInteger flag, NSString *title) {
        if (flag==1) {
            [tempWeakSelf openCameraCanEdit:YES];
        }else if (flag==2){
            [tempWeakSelf selectHeadImage];
        }
    }];
    
//    UIViewController* rootVC=[AppDelegateInstance window].rootViewController;
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
//        [tempSelf openCameraCanEdit:YES];
//    }]];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle:@"从手机相册选择" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
//        [tempSelf selectHeadImage];
//    }]];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
//        
//    }]];
//    [rootVC presentViewController:alertController animated:YES completion:nil];
}

-(void)openCameraCanEdit:(BOOL)edit{
    UIImagePickerController* picker=[[UIImagePickerController alloc]init];
    picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    picker.delegate=self;
    picker.allowsEditing=edit;
    UIViewController* rootVC=[AppDelegateInstance window].rootViewController;
    [rootVC presentViewController:picker animated:YES completion:nil];
}
-(void)selectHeadImage{
    UIImagePickerController* picker=[[UIImagePickerController alloc]init];
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate=self;
    picker.allowsEditing=YES;
    UIViewController* rootVC=[AppDelegateInstance window].rootViewController;
    [rootVC presentViewController:picker animated:YES completion:nil];
}
#pragma mark - ================ 相机代理方法 ==================
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (self.tempImageBlock) {
        self.tempImageBlock(nil);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    objc_setAssociatedObject(AppDelegateInstance, &photoToolsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage* image=[info valueForKey:@"UIImagePickerControllerEditedImage"];
    if (!image) {
        image=[info valueForKey:@"UIImagePickerControllerOriginalImage"];
        image=[LJImageTools changeImage:image toRatioSize:CGSizeMake(image.size.width*0.6, image.size.height*0.6)];
        NSData* imageData=UIImageJPEGRepresentation(image, 0.1);
        image=[UIImage imageWithData:imageData];
    }
    if (self.tempImageBlock) {
        self.tempImageBlock(image);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    objc_setAssociatedObject(AppDelegateInstance, &photoToolsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)dealloc{
    DLog(@"photo tools dealloc...");
}









//- (UIImage *)originImage {
//    if (_originImage) {
//        return _originImage;
//        }
//    __block UIImage *resultImage;
//    if (_usePhotoKit) {
//        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
//        phImageRequestOptions.synchronous = YES;
//        [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset
//                 targetSize:PHImageManagerMaximumSize
//                 contentMode:PHImageContentModeDefault
//                 options:phImageRequestOptions
//                 resultHandler:^(UIImage *result, NSDictionary *info) {
//                     resultImage = result;
//                     }];
//        } else {
//            CGImageRef fullResolutionImageRef = [_alAssetRepresentation fullResolutionImage];
//            // 通过 fullResolutionImage 获取到的的高清图实际上并不带上在照片应用中使用“编辑”处理的效果，需要额外在 AlAssetRepresentation 中获取这些信息
//            NSString *adjustment = [[_alAssetRepresentation metadata] objectForKey:@"AdjustmentXMP"];
//            if (adjustment) {
//                // 如果有在照片应用中使用“编辑”效果，则需要获取这些编辑后的滤镜，手工叠加到原图中
//                NSData *xmpData = [adjustment dataUsingEncoding:NSUTF8StringEncoding];
//                CIImage *tempImage = [CIImage imageWithCGImage:fullResolutionImageRef];
//                
//                NSError *error;
//                NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
//                                                    inputImageExtent:tempImage.extent
//                                                    error:&error];
//                CIContext *context = [CIContext contextWithOptions:nil];
//                if (filterArray && !error) {
//                    for (CIFilter *filter in filterArray) {
//                        [filter setValue:tempImage forKey:kCIInputImageKey];
//                        tempImage = [filter outputImage];
//                        }
//                    fullResolutionImageRef = [context createCGImage:tempImage fromRect:[tempImage extent]];
//                    } 
//                }
//            // 生成最终返回的 UIImage，同时把图片的 orientation 也补充上去
//            resultImage = [UIImage imageWithCGImage:fullResolutionImageRef scale:[_alAssetRepresentation scale] orientation:(UIImageOrientation)[_alAssetRepresentation orientation]];
//            }
//    _originImage = resultImage;
//    return resultImage;
//}



@end
