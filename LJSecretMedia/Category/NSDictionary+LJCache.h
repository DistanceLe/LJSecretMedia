//
//  NSDictionary+LJCache.h
//  StarWristVIP
//
//  Created by LiJie on 16/4/5.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (LJCache)

/**  保存字典、model */
-(BOOL)saveModelWithName:(NSString*)name;

/**  读取model */
+(id)readModelWithName:(NSString*)name;

/**  读取字典 */
+(NSDictionary*)onlyReadDictionaryWithName:(NSString*)name;

+(BOOL)deleteModelName:(NSString*)name;

@end
