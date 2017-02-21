//
//  LJALAssetTools.m
//  相册Demo
//
//  Created by LiJie on 16/1/7.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJALAssetTools.h"

@implementation LJALAssetTools

/**  当有多个组的时候，会多次调用handler */
+(void)getAllALAssetGroupsHandler:(GroupBlock)handler
{
    
    ALAssetsLibraryGroupsEnumerationResultsBlock libraryGroupsEnumeration=^(ALAssetsGroup* group, BOOL* stop)
    {
        if (group==nil || group.numberOfAssets<1)
        {
            NSLog(@"无数据的照片组：%@",group);
        }
        else
        {
            NSString* g=[NSString stringWithFormat:@"%@",group];//获取相簿的组
            //g:ALAssetsGroup - Name:Camera Roll, Type:Saved Photos, Assets count:14
            
            NSString* groupName=nil;
            NSInteger groupImageCount=0;
            
            NSMutableArray* groupData=[NSMutableArray array];
            NSError* error=NULL;
            //从:开始到,结束   或者没有,
            NSRegularExpression* regular=[NSRegularExpression regularExpressionWithPattern:@"((?<=:)[\\w\\s]+(?=,))|((?<=:)[\\w\\s]+)" options:NSRegularExpressionCaseInsensitive error:&error];
            NSArray<NSTextCheckingResult*>* results=[regular matchesInString:g options:NSMatchingReportProgress range:NSMakeRange(0, g.length)];
            for (NSTextCheckingResult* result in results) {
                NSString* searchStr=[g substringWithRange:result.range];
                [groupData addObject:searchStr];
            }
            groupName=groupData.firstObject;
            groupImageCount=[groupData.lastObject integerValue];
            
            if ([groupName isEqualToString:@"Camera Roll"])
            {
                groupName=@"相机胶卷";
            }
            
            UIImage* thumbnail=[UIImage imageWithCGImage:group.posterImage]; //海报图
            if (handler)
            {
                handler(group, thumbnail, groupName, groupImageCount);
            }
        }
    };
    
    static ALAssetsLibrary* library=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        library=[[ALAssetsLibrary alloc]init];
    });
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:libraryGroupsEnumeration failureBlock:nil];
}

/**  获取组内的图片资源，和图片缩略图 */
+(void)getImageAssetsWithAssetGroup:(ALAssetsGroup*)group handler:(ImageAssetsBlock)handler
{
    __block NSMutableArray* assetArray=[NSMutableArray array];
    
    NSInteger groupImageCount=group.numberOfAssets;
    
    ALAssetsGroupEnumerationResultsBlock groupEnumerAtion=^(ALAsset* resutl, NSUInteger index, BOOL *stop)
    {
        if (resutl!=NULL)
        {
            if ([[resutl valueForProperty:ALAssetPropertyType]isEqualToString:ALAssetTypePhoto])//选择照片类型（或者视频）
            {
                [assetArray addObject:resutl];
            }
            if (index==groupImageCount-1)
            {
                if (handler)
                {
                    handler(assetArray);
                }
            }
        }
    };
    [group enumerateAssetsUsingBlock:groupEnumerAtion];
}

/**  根据Alasset获取高清图 */
+(void)getImagesWithAssets:(NSArray<ALAsset*>*)assets handler:(ImagesBlock)handler
{
    __block NSMutableArray* imagesArray=[NSMutableArray array];
    
    [assets enumerateObjectsUsingBlock:^(ALAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        ALAssetRepresentation* rep=[obj defaultRepresentation];
        UIImage* image=[UIImage imageWithCGImage:rep.fullResolutionImage];
        [imagesArray addObject:image];
    }];
    
    if (handler)
    {
        handler(imagesArray);
    }
}

+(UIImage *)getImagesWithAsset:(ALAsset *)asset{
    ALAssetRepresentation* rep=[asset defaultRepresentation];
    UIImage* image=[UIImage imageWithCGImage:rep.fullResolutionImage];
    return image;
}

/**  根据ALAsset获取缩略图 */
+(void)getThumbnailsWithAssets:(NSArray<ALAsset*>*)assets handler:(ThumbnailsBlock)handler
{
    __block NSMutableArray* thumbnailArray=[NSMutableArray array];
    
    [assets enumerateObjectsUsingBlock:^(ALAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         UIImage* image=[UIImage imageWithCGImage:obj.thumbnail];
         [thumbnailArray addObject:image];
     }];
    
    if (handler)
    {
        handler(thumbnailArray);
    }
}

/**  根据ALAsset获取宽高比的缩略图 */
+(void)getAspectRatioThumbnailsWithAssets:(NSArray<ALAsset*>*)assets handler:(ThumbnailsBlock)handler{
    
    __block NSMutableArray* thumbnailArray=[NSMutableArray array];
    
    [assets enumerateObjectsUsingBlock:^(ALAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         UIImage* image=[UIImage imageWithCGImage:obj.aspectRatioThumbnail];
         [thumbnailArray addObject:image];
     }];
    
    if (handler)
    {
        handler(thumbnailArray);
    }
}

/**  获取资源的二进制数据 */
+(NSData*)getDataWithALAsset:(ALAsset*)asset
{
    ALAssetRepresentation* rep=[asset defaultRepresentation];
    Byte* buffer=(Byte*)malloc(rep.size);
    NSUInteger buffered=[rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
    NSData* data=[NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    return data;
}

/**  吧资源的二进制数据缓存到文件路径下 */
+(BOOL)writeAssetData:(ALAsset*)asset toPath:(NSString*)filePath
{
    [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    NSFileHandle* handle=[NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!handle)
    {
        return NO;
    }
    static const NSUInteger BufferSize=1024*1024;
    ALAssetRepresentation* rep=[asset defaultRepresentation];
    uint8_t* buffer=calloc(BufferSize, sizeof(*buffer));
    NSUInteger offset=0, bytesRead=0;
    do {
        @try {
            bytesRead=[rep getBytes:buffer fromOffset:offset length:BufferSize error:nil];
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            offset+=bytesRead;
        }
        @catch (NSException *exception) {
            free(buffer);
            return NO;
        }
    } while (bytesRead>0);
    free(buffer);
    return YES;
}

@end
