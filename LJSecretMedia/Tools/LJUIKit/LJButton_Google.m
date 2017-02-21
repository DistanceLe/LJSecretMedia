//
//  LJButton-Google.m
//  LJAnimation
//
//  Created by LiJie on 16/8/10.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJButton_Google.h"

#define Radius      20

@interface LJButton_Google ()

@property(nonatomic, strong)CALayer*backLayer;

@property(nonatomic, assign)CGPoint     currentTouchPoint;
@property(nonatomic, assign)BOOL        isTouchBegin;
@property(nonatomic, assign)BOOL        isTouchContinue;
@property(nonatomic, assign)NSInteger   animationCount;

@end

@implementation LJButton_Google

-(UIColor *)circleEffectColor{
    if (!_circleEffectColor) {
        _circleEffectColor=kRGBColor(204, 156, 74, 0.5);
    }
    return _circleEffectColor;
}

-(CGFloat)circleEffectTime{
    if (_circleEffectTime<0.001) {
        _circleEffectTime=0.35;
    }
    return _circleEffectTime;
}

-(void)drawRect:(CGRect)rect{
    [self.circleEffectColor setFill];
    if (_isTouchBegin) {
        if (_backLayer.mask){
            _backLayer.mask.position=_currentTouchPoint;
            
        }else{
            _backLayer=[CALayer layer];
            _backLayer.backgroundColor=self.circleEffectColor.CGColor;
            _backLayer.frame=self.bounds;
            [self.layer insertSublayer:_backLayer atIndex:0];
            //[self.layer addSublayer:_backLayer];
            
            CALayer* maskLayer=[CALayer layer];
            maskLayer.contents=(id)[UIImage imageNamed:@"mark.png"].CGImage;
            maskLayer.bounds=self.bounds;
            maskLayer.position=_currentTouchPoint;
            maskLayer.masksToBounds=YES;
            _backLayer.mask=maskLayer;
        }
        CGFloat radius=sqrt(pow(MAX(_currentTouchPoint.x, self.lj_width-_currentTouchPoint.x), 2)+
                            pow(MAX(_currentTouchPoint.y, self.lj_height-_currentTouchPoint.y), 2));
        
        _animationCount++;
        CAKeyframeAnimation* cornerAnimation=[CAKeyframeAnimation animationWithKeyPath:@"cornerRadius"];
        cornerAnimation.duration=self.circleEffectTime;
        cornerAnimation.values=@[@(Radius), @(radius-1), @(radius)];
        cornerAnimation.keyTimes=@[@0, @0.99, @1];
        cornerAnimation.fillMode=kCAFillModeForwards;
        cornerAnimation.removedOnCompletion=NO;
        [_backLayer.mask addAnimation:cornerAnimation forKey:nil];
        
        CAKeyframeAnimation* opacityAnimation=[CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration=self.circleEffectTime;
        opacityAnimation.values=@[@(0.8), @(0.2), @(0.5)];
        opacityAnimation.keyTimes=@[@0, @0.99, @1];
        opacityAnimation.fillMode=kCAFillModeForwards;
        opacityAnimation.removedOnCompletion=NO;
        [_backLayer.mask addAnimation:opacityAnimation forKey:nil];
        
        CAKeyframeAnimation* keyAnimation=[CAKeyframeAnimation animationWithKeyPath:@"bounds"];
        keyAnimation.duration=self.circleEffectTime;
        keyAnimation.values=@[[NSValue valueWithCGRect:CGRectMake(0, 0, Radius*2, Radius*2)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, radius*2-2, radius*2-2)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, radius*2, radius*2)]];
        keyAnimation.keyTimes=@[@0, @0.99, @1];
        keyAnimation.fillMode=kCAFillModeForwards;
        keyAnimation.removedOnCompletion=NO;
        keyAnimation.delegate=self;
        [_backLayer.mask addAnimation:keyAnimation forKey:nil];
    }
}

#pragma mark - ================ 动画代理 ==================
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        _animationCount--;
        if (_backLayer.mask && _animationCount<=0 && !_isTouchContinue && !_isTouchBegin) {
            [_backLayer.mask removeAllAnimations];
            _backLayer.mask=nil;
            [_backLayer removeFromSuperlayer];
            _isTouchBegin=NO;
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
    
    _isTouchContinue=YES;
    CGPoint point=[touch locationInView:self];
    CGFloat offset=70;
    if (point.x<-offset || point.x>self.lj_width+offset || point.y<-offset || point.y>self.lj_height+offset) {
        self.isTouchBegin=NO;
        if (_backLayer.mask){
            [_backLayer.mask removeAllAnimations];
            _backLayer.mask=nil;
            [_backLayer removeFromSuperlayer];
            _animationCount=0;
        }
    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    _isTouchContinue=NO;
    self.isTouchBegin=NO;
    if (_backLayer.mask && _animationCount<=0){
        [_backLayer.mask removeAllAnimations];
        _backLayer.mask=nil;
        [_backLayer removeFromSuperlayer];
        _animationCount=0;
    }
}

-(void)cancelTrackingWithEvent:(UIEvent *)event{
    self.isTouchBegin=NO;
    _isTouchContinue=NO;
    if (_backLayer.mask && _animationCount<=0){
        [_backLayer.mask removeAllAnimations];
        _backLayer.mask=nil;
        [_backLayer removeFromSuperlayer];
    }
}

@end
