//
//  NSNotificationCenter+LJ.m
//  LJTrack
//
//  Created by LiJie on 16/6/15.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "NSNotificationCenter+LJ.h"
#import <objc/runtime.h>

@interface NSNotificationCenter ()

@property(nonatomic, strong)NSMutableDictionary* handlerDictionary;

@end

@implementation NSNotificationCenter (LJ)

static char notiKey;

-(void)setHandlerDictionary:(NSMutableDictionary *)handlerDictionary
{
    objc_setAssociatedObject(self, &notiKey, handlerDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableDictionary*)handlerDictionary
{
    return  objc_getAssociatedObject(self, &notiKey);
}

-(void)addObserverName:(NSString*)name object:(id)obj handler:(StatusBlock)handler
{
    if (!self.handlerDictionary) {
        self.handlerDictionary=[NSMutableDictionary dictionary];
    }
    [self.handlerDictionary setObject:handler forKey:name];
    [self addObserver:self selector:@selector(receiveObserverNoti:) name:name object:obj];
}

-(void)receiveObserverNoti:(NSNotification*)noti
{
    StatusBlock tempBlock=[self.handlerDictionary objectForKey:noti.name];
    if (tempBlock) {
        tempBlock(noti, nil);
    }
}

-(void)removeHandlerObserverWithName:(NSString *)name object:(id)obj
{
    [self removeObserver:self name:name object:obj];
    [self.handlerDictionary removeObjectForKey:name];
}

@end
