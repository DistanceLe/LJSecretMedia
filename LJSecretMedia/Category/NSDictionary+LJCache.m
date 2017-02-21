//
//  NSDictionary+LJCache.m
//  StarWristVIP
//
//  Created by LiJie on 16/4/5.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "NSDictionary+LJCache.h"

static NSString *modelCachePath = nil;

@implementation NSDictionary (LJCache)

static inline NSString* ModelCacheDirectory()
{
    if(!modelCachePath) {
        NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        modelCachePath = [[cachesDirectory stringByAppendingPathComponent:@"ModelCache"] copy];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:modelCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    return modelCachePath;
}

-(BOOL)saveModelWithName:(NSString *)name
{
    if (name.length == 0) {
        return NO;
    }
    NSString *modelCacheDir = ModelCacheDirectory();
    NSString *filePath = [modelCacheDir stringByAppendingPathComponent:name];
    
    BOOL hadSave=[NSKeyedArchiver archiveRootObject:self toFile:filePath];
    return hadSave;
}

+(id)readModelWithName:(NSString *)name
{
    if (name.length == 0) {
        return nil;
    }
    NSString* modelCacheDir = ModelCacheDirectory();
    NSString *filePath = [modelCacheDir stringByAppendingPathComponent:name];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSDictionary* modelDic=[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    Class modelClass=NSClassFromString(name);
    id model=[[modelClass alloc]init];
    [model setValuesForKeysWithDictionary:modelDic];
    
    return model;
}

+(NSDictionary*)onlyReadDictionaryWithName:(NSString *)name
{
    if (name.length == 0) {
        return nil;
    }
    NSString* modelCacheDir = ModelCacheDirectory();
    NSString *filePath = [modelCacheDir stringByAppendingPathComponent:name];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSDictionary* modelDic=[NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    return modelDic;
}

+(BOOL)deleteModelName:(NSString *)name
{
    NSFileManager* fileManger=[NSFileManager defaultManager];
    NSError* error=nil;
    BOOL delete= [fileManger removeItemAtPath:[ModelCacheDirectory() stringByAppendingPathComponent:name] error:&error];
    if (error) {
        NSLog(@"..error: %@..", error.description);
    }
    return delete;
}

@end
