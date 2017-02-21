//
//  LJButton.m
//  LJAnimation
//
//  Created by LiJie on 16/8/9.
//  Copyright © Radius*216年 LiJie. All rights reserved.
//

#import "LJButton.h"


@interface LJButton ()

@property(nonatomic, strong)CALayer*backLayer;
@property(nonatomic, strong)CALayer*backLayer1;

@property(nonatomic, assign)CGPoint currentTouchPoint;
@property(nonatomic, assign)BOOL    isTouchBegin;
@property(nonatomic, assign)BOOL    isTouchContinue;
@property(nonatomic, assign)BOOL    isTouchEnd;

@end

@implementation LJButton
-(UIColor *)circleEffectColor{
    if (!_circleEffectColor) {
        _circleEffectColor=[UIColor cyanColor];
    }
    return _circleEffectColor;
}

-(CGFloat)circleEffectTime{
    if (_circleEffectTime<0.001) {
        _circleEffectTime=0.35;
    }
    return _circleEffectTime;
}

-(CGFloat)minRadius{
    if (_minRadius<0.001) {
        _minRadius=20;
    }
    return _minRadius;
}

-(void)drawRect:(CGRect)rect{
    [self.circleEffectColor setFill];
    if (_isTouchBegin) {
        if (_backLayer.mask){
            [_backLayer.mask removeAllAnimations];
            _backLayer.mask=nil;
            [_backLayer removeFromSuperlayer];
        }
        CGFloat radius=MAX(MAX(_currentTouchPoint.x, self.lj_width-_currentTouchPoint.x),
                           MAX(_currentTouchPoint.y, self.lj_height-_currentTouchPoint.y));
        
        _backLayer=[CALayer layer];
        _backLayer.backgroundColor=self.circleEffectColor.CGColor;
        _backLayer.frame=self.bounds;
        [self.layer insertSublayer:_backLayer atIndex:0];
        
        CALayer* maskLayer=[CALayer layer];
        maskLayer.contents=(id)[UIImage imageNamed:@"mark.png"].CGImage;
        maskLayer.bounds=self.bounds;
        maskLayer.position=_currentTouchPoint;
        maskLayer.masksToBounds=YES;
        _backLayer.mask=maskLayer;
        
        CAKeyframeAnimation* cornerAnimation=[CAKeyframeAnimation animationWithKeyPath:@"cornerRadius"];
        cornerAnimation.duration=.3;
        cornerAnimation.values=@[@(radius), @(self.minRadius)];
        cornerAnimation.keyTimes=@[@0, @1];
        cornerAnimation.fillMode=kCAFillModeForwards;
        cornerAnimation.removedOnCompletion=NO;
        cornerAnimation.delegate=self;
        [_backLayer.mask addAnimation:cornerAnimation forKey:@"corner"];
        
        CAKeyframeAnimation* keyAnimation=[CAKeyframeAnimation animationWithKeyPath:@"bounds"];
        keyAnimation.duration=.3;
        keyAnimation.values=@[[NSValue valueWithCGRect:CGRectMake(0, 0, radius*2, radius*2)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, self.minRadius*2, self.minRadius*2)]];
        keyAnimation.keyTimes=@[@0, @1];
        keyAnimation.fillMode=kCAFillModeForwards;
        keyAnimation.removedOnCompletion=NO;
        keyAnimation.delegate=self;
        [_backLayer.mask addAnimation:keyAnimation forKey:@"mask"];
        
    }else if (_isTouchContinue){
        UIBezierPath* path=[UIBezierPath bezierPathWithRect:self.bounds];
        
        UIBezierPath* circlePath=[UIBezierPath bezierPathWithOvalInRect:CGRectMake(_currentTouchPoint.x-self.minRadius, _currentTouchPoint.y-self.minRadius, self.minRadius*2, self.minRadius*2)];
        [path appendPath:circlePath];
        path=[circlePath bezierPathByReversingPath];
        [path fill];
    }else if(_isTouchEnd){
        if (_backLayer.mask){
            [_backLayer.mask removeAllAnimations];
            _backLayer.mask=nil;
            [_backLayer removeFromSuperlayer];
        }
        if (_backLayer1.mask) {
            [_backLayer1.mask removeAllAnimations];
            _backLayer1.mask=nil;
            [_backLayer1 removeFromSuperlayer];
        }
        CGFloat radius=sqrt(pow(MAX(_currentTouchPoint.x, self.lj_width-_currentTouchPoint.x), 2)+
                            pow(MAX(_currentTouchPoint.y, self.lj_height-_currentTouchPoint.y), 2));
        
        _backLayer1=[CALayer layer];
        _backLayer1.backgroundColor=self.circleEffectColor.CGColor;
        _backLayer1.frame=self.bounds;
        [self.layer insertSublayer:_backLayer1 atIndex:0];
        
        CALayer* maskLayer=[CALayer layer];
        maskLayer.contents=(id)[UIImage imageNamed:@"mark.png"].CGImage;
        maskLayer.bounds=self.bounds;
        maskLayer.position=_currentTouchPoint;
        maskLayer.masksToBounds=YES;
        _backLayer1.mask=maskLayer;
        
        CAKeyframeAnimation* cornerAnimation=[CAKeyframeAnimation animationWithKeyPath:@"cornerRadius"];
        cornerAnimation.duration=.3;
        cornerAnimation.values=@[@(self.minRadius), @(radius)];
        cornerAnimation.keyTimes=@[@0, @1];
        cornerAnimation.fillMode=kCAFillModeForwards;
        cornerAnimation.removedOnCompletion=NO;
        cornerAnimation.delegate=self;
        [_backLayer1.mask addAnimation:cornerAnimation forKey:@"corner"];
        
        CAKeyframeAnimation* keyAnimation=[CAKeyframeAnimation animationWithKeyPath:@"bounds"];
        keyAnimation.duration=.3;
        keyAnimation.values=@[[NSValue valueWithCGRect:CGRectMake(0, 0, self.minRadius*2, self.minRadius*2)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, radius*2, radius*2)]];
        keyAnimation.keyTimes=@[@0, @1];
        keyAnimation.fillMode=kCAFillModeForwards;
        keyAnimation.removedOnCompletion=NO;
        keyAnimation.delegate=self;
        [_backLayer1.mask addAnimation:keyAnimation forKey:@"mask"];
    }
}

#pragma mark - ================ 动画代理 ==================
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        if (_backLayer.mask) {
            [_backLayer.mask removeAllAnimations];
            _backLayer.mask=nil;
            [_backLayer removeFromSuperlayer];
        }
        if (_isTouchEnd) {
            self.isTouchEnd=NO;
            [_backLayer1.mask removeAllAnimations];
            _backLayer1.mask=nil;
            [_backLayer1 removeFromSuperlayer];
        }
    }
}

#pragma mark - ================ 触摸代理 ==================
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.currentTouchPoint=[touch locationInView:self];
    self.isTouchBegin=YES;
    [self setNeedsDisplay];
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.currentTouchPoint=[touch locationInView:self];
    self.isTouchContinue=YES;
    self.isTouchBegin=NO;
    [self setNeedsDisplay];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.currentTouchPoint=[touch locationInView:self];
    self.isTouchEnd=YES;
    self.isTouchBegin=NO;
    self.isTouchContinue=NO;
    [self setNeedsDisplay];
}


@end
