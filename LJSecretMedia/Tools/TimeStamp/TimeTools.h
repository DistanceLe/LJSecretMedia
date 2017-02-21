//
//  TimeTools.h
//  testJson
//
//  Created by gorson on 3/10/15.
//  Copyright (c) 2015 gorson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeTools : NSObject


/**  获取当前时间的时间戳（例子：1464326536） */
+ (NSString *)getCurrentTimestamp;

/**  获取当前标准时间（例子：2015-02-03） */
+ (NSString *)getCurrentStandarTime;

/**  获取当前时间，格式自定义 ：yyyy-MM-dd HH:mm:ss（完整） */
+ (NSString*)getCurrentTimesType:(NSString*)type;

/**  时间戳转换为时间的方法 */
+ (NSString *)timestampChangesStandarTime:(NSString *)timestamp;

/**  时间戳转换为自定义格式的时间：yyyy-MM-dd HH:mm:ss（完整） */
+ (NSString *)timestampChangesStandarTime:(NSString *)timestamp Type:(NSString*)type;

//时间转换星期
+(NSString *)timeToweek:(NSString *)time;

@end
