//
//  LJFileOperation.m
//  LJSecretMedia
//
//  Created by LiJie on 16/8/1.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJFileOperation.h"

@interface LJFileOperation ()

@property(nonatomic, copy)NSString* documentName;
@property(nonatomic, strong)NSString* documentPath;

@end

@implementation LJFileOperation



+(instancetype)shareOperationWithDocument:(NSString *)documentName{
    
    LJFileOperation* operation=[[LJFileOperation alloc]init];
    operation.documentName=documentName;
    [operation creatDocumetPath];
    return operation;
}

-(void)creatDocumetPath{
    
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path=[paths firstObject];
    
    [[NSFileManager defaultManager]createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",path, self.documentName] withIntermediateDirectories:YES attributes:nil error:nil];
    
    self.documentPath=[path stringByAppendingPathComponent:self.documentName];
}

-(BOOL)saveObject:(id)object name:(NSString *)name{
    
    NSString* filePath=[self.documentPath stringByAppendingPathComponent:name];
    BOOL isSave;
    if ([object isKindOfClass:[UIImage class]]) {
        NSData *data=nil;
        if (UIImagePNGRepresentation(object) == nil) {
            data = UIImageJPEGRepresentation(object, 1);
        }else{
            data = UIImagePNGRepresentation(object);
        }
        isSave=[data writeToFile:filePath options:NSDataWritingAtomic error:nil];
    }else{
        isSave=[object writeToFile:filePath options:NSDataWritingAtomic error:nil];
    }
    return isSave;
}

-(BOOL)deleteObjectWithName:(NSString *)name{
    
    NSString* filePath=[self.documentPath stringByAppendingPathComponent:name];
    BOOL isDelete=[[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
    return isDelete;
}

-(id)readObjectWithName:(NSString *)name{
    
    NSString* filePath=[self.documentPath stringByAppendingPathComponent:name];
    NSData* data=[[NSData alloc]initWithContentsOfFile:filePath];
    return data;
}

-(void)readObjectAsyncWithName:(NSString *)name handler:(void (^)(NSData*))handler{
    
    //创建异步加载：
    dispatch_queue_t anyncQueue = dispatch_queue_create("anyncQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(anyncQueue, ^{
        NSString* filePath=[self.documentPath stringByAppendingPathComponent:name];
        NSData* data=[[NSData alloc]initWithContentsOfFile:filePath];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (handler) {
                handler(data);
            }
        });
    });
}
-(NSString *)readFilePath:(NSString *)name{
    NSString* filePath=[self.documentPath stringByAppendingPathComponent:name];
    return filePath;
}


-(NSArray *)readAllFileName{
    
    NSArray* directorys=[[NSFileManager defaultManager]contentsOfDirectoryAtPath:self.documentPath error:nil];
    return directorys;
}

-(BOOL)deleteAllFile{
    BOOL isDelete=[[NSFileManager defaultManager]removeItemAtPath:self.documentPath error:nil];
    return isDelete;
}





@end
