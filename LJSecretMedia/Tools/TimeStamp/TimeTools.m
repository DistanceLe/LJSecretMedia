//
//  TimeTools.m
//  testJson
//
//  Created by gorson on 3/10/15.
//  Copyright (c) 2015 gorson. All rights reserved.
//

#import "TimeTools.h"

@implementation TimeTools

+ (NSString *)getCurrentTimestamp
{
    //获取系统当前的时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    // 转为字符型
    return timeString;
}

+ (NSString *)getCurrentStandarTime
{
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

+ (NSString*)getCurrentTimesType:(NSString*)type
{
    NSDate *  senddate=[NSDate date];
    
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:type];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

+ (NSString *)timestampChangesStandarTime:(NSString *)timestamp
{
    if (IFISNULL(timestamp))
    {
        return @"";
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString* tempStr=[timestamp substringToIndex:10];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[tempStr doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+(NSString *)timestampChangesStandarTime:(NSString *)timestamp Type:(NSString *)type
{
    if (IFISNULL(timestamp))
    {
        return @"";
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:type];
    NSString* tempStr=timestamp;
    if (timestamp.length>10) {
        tempStr=[timestamp substringToIndex:10];
    }else if(timestamp.length<10){
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[tempStr doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+(NSString *)timeToweek:(NSString *)time{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *formatterDate = [inputFormatter dateFromString:time];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    //    [outputFormatter setDateFormat:@"HH:mm 'on' EEEE MMMM d"];
    // For US English, the output is:
    // newDateString 10:30 on Sunday July 11
    [outputFormatter setDateFormat:@"EEEE"];
    NSString *newDateString = [outputFormatter stringFromDate:formatterDate];
    return newDateString;
}

+(NSString *)timestampChangeTimeStyle:(double)timestamp{
    if (timestamp < 0)
    {
        return @"";
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (timestamp>=3600) {
        [formatter setDateFormat:@"HH:mm:ss"];
    }else{
        [formatter setDateFormat:@"mm:ss"];
    }
    
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString* dateString = [formatter stringFromDate:date];
    
    return dateString;
}
@end
