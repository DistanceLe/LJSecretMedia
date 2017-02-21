//
//  LJFileOperation.h
//  LJSecretMedia
//
//  Created by LiJie on 16/8/1.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJFileOperation : NSObject

/**  在document文件夹下，创建一个新的文件夹 */
+(instancetype)shareOperationWithDocument:(NSString*)documentName;

/**  保存文件(NSData 或者 UIImage)，名为name */
-(BOOL)saveObject:(id)object name:(NSString*)name;

/**  删除目录下面的名为name的文件 */
-(BOOL)deleteObjectWithName:(NSString*)name;

/**  读取名为name的文件 */
-(id)readObjectWithName:(NSString*)name;
-(void)readObjectAsyncWithName:(NSString*)name handler:(void(^)(NSData* data))handler;
-(NSString*)readFilePath:(NSString*)name;

/**  读取文件夹下的所有文件 */
-(NSArray*)readAllFileName;

/**  删除该目录下的所有文件 */
-(BOOL)deleteAllFile;

@end
