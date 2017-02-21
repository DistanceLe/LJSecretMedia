//
//  UIView+LJ.m
//  LJTrack
//
//  Created by LiJie on 16/6/17.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "UIView+LJ.h"
#import <objc/runtime.h>

@interface UIView ()

@property(nonatomic, strong)NSMutableDictionary* handlerDictionary;

@end

@implementation UIView (LJ)

- (CGFloat)lj_height{
    return self.frame.size.height;
}

- (void)setLj_height:(CGFloat)lj_height{
    CGRect temp = self.frame;
    temp.size.height = lj_height;
    self.frame = temp;
}

- (CGFloat)lj_width{
    return self.frame.size.width;
}

- (void)setLj_width:(CGFloat)lj_width{
    CGRect temp = self.frame;
    temp.size.width = lj_width;
    self.frame = temp;
}


- (CGFloat)lj_y{
    return self.frame.origin.y;
}

- (void)setLj_y:(CGFloat)lj_y{
    CGRect temp = self.frame;
    temp.origin.y = lj_y;
    self.frame = temp;
}

- (CGFloat)lj_x{
    return self.frame.origin.x;
}

- (void)setLj_x:(CGFloat)lj_x{
    CGRect temp = self.frame;
    temp.origin.x = lj_x;
    self.frame = temp;
}

//=====================================
-(void)setLj_origin:(CGPoint)lj_origin{
    CGRect frame=self.frame;
    frame.origin=lj_origin;
    self.frame=frame;
}
-(CGPoint)lj_origin{
    return self.frame.origin;
}

-(void)setLj_size:(CGSize)lj_size{
    CGRect frame=self.frame;
    frame.size=lj_size;
    self.frame=frame;
}

-(CGSize)lj_size{
    return self.frame.size;
}

-(CGFloat)lj_maxX{
    return self.lj_x+self.lj_width;
}

-(CGFloat)lj_maxY{
    return self.lj_y+self.lj_height;
}

-(CGFloat)lj_centerX{
    return self.lj_x+self.lj_width/2.0f;
}

-(CGFloat)lj_centerY{
    return self.lj_y+self.lj_height/2.0f;
}

-(void)setLj_maxX:(CGFloat)lj_maxX{
    CGRect frame=self.frame;
    frame.size.width = lj_maxX;
    self.frame=frame;
}

-(void)setLj_maxY:(CGFloat)lj_maxY{
    CGRect frame=self.frame;
    frame.size.height = lj_maxY;
    self.frame=frame;
}

-(void)setLj_centerX:(CGFloat)lj_centerX{
    CGPoint center=self.center;
    center.x=lj_centerX;
    self.center=center;
}

-(void)setLj_centerY:(CGFloat)lj_centerY{
    CGPoint center=self.center;
    center.y=lj_centerY;
    self.center=center;
}

static char temDicKey;
-(void)setHandlerDictionary:(NSMutableDictionary *)handlerDictionary
{
    objc_setAssociatedObject(self, &temDicKey, handlerDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableDictionary*)handlerDictionary
{
    return  objc_getAssociatedObject(self, &temDicKey);
}

-(void)addTapGestureHandler:(LJTapBlock)handler
{
    self.userInteractionEnabled=YES;
    if (!self.handlerDictionary) {
        self.handlerDictionary=[NSMutableDictionary dictionary];
    }
    [self.handlerDictionary setObject:handler forKey:@"tap"];
    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handlerTapAction:)];
    [self addGestureRecognizer:tap];
    for (UITapGestureRecognizer* gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            if (gesture.numberOfTapsRequired==2) {
                [tap requireGestureRecognizerToFail:gesture];
                break;
            }
        }
    }
}

-(void)addDoubleTapGestureHandler:(LJTapBlock)handler{
    self.userInteractionEnabled=YES;
    if (!self.handlerDictionary) {
        self.handlerDictionary=[NSMutableDictionary dictionary];
    }
    [self.handlerDictionary setObject:handler forKey:@"doubleTap"];
    UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handlerDoubleTapAction:)];
    tap.numberOfTapsRequired=2;
    [self addGestureRecognizer:tap];
    
    for (UITapGestureRecognizer* gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            if (gesture.numberOfTapsRequired==1) {
                [gesture requireGestureRecognizerToFail:tap];
                break;
            }
        }
    }
}

-(void)addPanGestureHandler:(LJPanBlock)handler{
    self.userInteractionEnabled=YES;
    if (!self.handlerDictionary) {
        self.handlerDictionary=[NSMutableDictionary dictionary];
    }
    [self.handlerDictionary setObject:handler forKey:@"pan"];
    UIPanGestureRecognizer* pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlerPanAction:)];
    [self addGestureRecognizer:pan];
}

-(void)handlerPanAction:(UIPanGestureRecognizer*)pan{
    LJPanBlock tempBlock=[self.handlerDictionary objectForKey:@"pan"];
    if (tempBlock) {
        tempBlock(pan, self);
    }
}

-(void)handlerTapAction:(UITapGestureRecognizer*)tap{
    LJTapBlock tempBlock=[self.handlerDictionary objectForKey:@"tap"];
    if (tempBlock) {
        tempBlock(tap, self);
    }
}
-(void)handlerDoubleTapAction:(UITapGestureRecognizer*)tap{
    LJTapBlock tempBlock=[self.handlerDictionary objectForKey:@"doubleTap"];
    if (tempBlock) {
        tempBlock(tap, self);
    }
}

@end
