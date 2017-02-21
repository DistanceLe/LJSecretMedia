//
//  LJOptionPlistFile.m
//  WKStore
//
//  Created by LiJie on 15/11/24.
//  Copyright © 2015年 celink. All rights reserved.
//

#import "LJOptionPlistFile.h"

@implementation LJOptionPlistFile

+(NSString*)plistPath:(NSString*)plistName
{
    NSArray* paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path=[paths firstObject];
    NSString* fileName=[path stringByAppendingPathComponent:plistName];
    return fileName;
}

+(void)saveArray:(NSArray*)array ToPlistFile:(NSString*)plistName
{
    if (!array)
    {
        return;
    }
    [array writeToFile:[self plistPath:plistName] atomically:YES];
}
+(void)saveObject:(id)object ToPlistFile:(NSString*)plistName
{
    if (!object)
    {
        return;
    }
    NSMutableArray* historyArray=[NSMutableArray arrayWithContentsOfFile:[self plistPath:plistName]];
    if (!historyArray)
    {
        historyArray=[NSMutableArray array];
    }
    [historyArray insertObject:object atIndex:0];
    [historyArray writeToFile:[self plistPath:plistName] atomically:YES];
}
+(void)deleteObject:(id)object InPlistFile:(NSString*)plistName
{
    if (!object)
    {
        return;
    }
    NSMutableArray* historyArray=[NSMutableArray arrayWithContentsOfFile:[self plistPath:plistName]];
    if (!historyArray)
    {
        return;
    }
    [historyArray removeObject:object];
    [historyArray writeToFile:[self plistPath:plistName] atomically:YES];
    
}
+(void)deleteAllObjectInPlistFile:(NSString*)plistName
{
    [@[] writeToFile:[self plistPath:plistName] atomically:YES];
    [[NSFileManager defaultManager]removeItemAtPath:[self plistPath:plistName] error:nil];
}
+(NSArray*)readPlistFile:(NSString*)plistName
{
    NSArray* fileArray=[NSArray arrayWithContentsOfFile:[self plistPath:plistName]];
    return fileArray;
}

@end
