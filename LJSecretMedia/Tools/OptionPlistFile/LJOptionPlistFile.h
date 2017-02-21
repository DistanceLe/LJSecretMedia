/*! 头文件基本信息，用在每个源代码文件的头文件的最开头
 
WKStore
 
@header LJOptionPlistFile.h
 
@abstract   关于这个源代码的基本描述..
 
@author Created by LiJie on 15/11/24.
 
@version 1.00 __DATE_Creation(版本信息)
 
  Copyright © 2015年 celink. All rights reserved.

*/

#import <Foundation/Foundation.h>

@interface LJOptionPlistFile : NSObject

+(void)saveArray:(NSArray*)array ToPlistFile:(NSString*)plistName;
+(void)saveObject:(id)object ToPlistFile:(NSString*)plistName;


+(void)deleteObject:(id)object InPlistFile:(NSString*)plistName;
+(void)deleteAllObjectInPlistFile:(NSString*)plistName;


+(NSArray*)readPlistFile:(NSString*)plistName;


@end
