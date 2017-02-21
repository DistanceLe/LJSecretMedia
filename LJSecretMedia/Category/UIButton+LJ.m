//
//  UIButton+LJ.m
//  LJTrack
//
//  Created by LiJie on 16/6/14.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "UIButton+LJ.h"
#import <objc/runtime.h>

@interface UIButton ()

@property(nonatomic, strong)LJButHandler tempBlock;

@end

@implementation UIButton (LJ)


static char blockKey;
-(void)setTempBlock:(StatusBlock)tempBlock
{
    objc_setAssociatedObject(self, &blockKey, tempBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(StatusBlock)tempBlock
{
    return objc_getAssociatedObject(self, &blockKey);
}

-(void)addTargetClickHandler:(LJButHandler)handler
{
    self.tempBlock=handler;
    [self addTarget:self action:@selector(LJClickAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)LJClickAction:(UIButton*)but
{
    self.tempBlock(but, @(but.selected));
}






@end
