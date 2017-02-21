//
//  LJPullDownView.m
//  TestPullDownView
//
//  Created by LiJie on 15/12/30.
//  Copyright © 2015年 LiJie. All rights reserved.
//

#import "LJPullDownView.h"

@interface LJPullDownView ()

@property(nonatomic, strong)UIView* backView;

/**  下拉视图的高度, 一般为屏幕高度 */
@property(nonatomic, assign)CGFloat   pullDownViewHeight;

@end

@implementation LJPullDownView


+(instancetype)sharePullDownViewWithFrame:(CGRect)frame
{
    static LJPullDownView* tempSelf=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tempSelf=[[LJPullDownView alloc]init];
        tempSelf.backgroundColor=[UIColor clearColor];
//        tempSelf.clipsToBounds=YES;
        tempSelf.backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT)];
        tempSelf.backView.backgroundColor=[UIColor clearColor];
        
        UITapGestureRecognizer* tap=[[UITapGestureRecognizer alloc]initWithTarget:tempSelf action:@selector(dismissPullDownView)];
        [tempSelf.backView addGestureRecognizer:tap];
        
        [tempSelf addSubview:tempSelf.backView];
    });
    
    tempSelf.pullDownViewHeight=IPHONE_HEIGHT;
    frame.size.height=0;
    tempSelf.frame=frame;
    return tempSelf; 
}

-(void)setPullDownContentView:(UIView *)pullDownContentView
{
    _pullDownContentView=pullDownContentView;
    _pullDownContentView.clipsToBounds=YES;
    for (UIView* subView in self.subviews)
    {
        if (subView!=self.backView)
        {
            [subView removeFromSuperview];
        }
    }
    [self addSubview:pullDownContentView];
    self.contentViewHeight=pullDownContentView.bounds.size.height;
    CGRect frame=pullDownContentView.frame;
    frame.size.height=0;
    _pullDownContentView.frame=frame;
}

-(void)setIsShowStatus:(BOOL)isShowStatus{
    _isShowStatus=isShowStatus;
    if (isShowStatus){
        [self showPullDownView];
    }else{
        [self dismissPullDownView];
    }
}

-(void)setIsPullDown:(BOOL)isPullDown{
    _isPullDown=isPullDown;
}

-(void)showPullDownView
{
    self.hidden=NO;
    _isShowStatus=YES;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame=self.frame;
        frame.size.height=self.pullDownViewHeight;
        self.frame=frame;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame=self.pullDownContentView.frame;
        frame.size.height=self.contentViewHeight;
        self.pullDownContentView.frame=frame;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        self.backView.backgroundColor=[[UIColor blackColor]colorWithAlphaComponent:0.2];
    }];
}

-(void)dismissPullDownView
{
    _isShowStatus=NO;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame=self.frame;
        frame.size.height=0;
        self.frame=frame;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame=self.pullDownContentView.frame;
        frame.size.height=0;
        self.pullDownContentView.frame=frame;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        self.backView.backgroundColor=[UIColor clearColor];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45*NSEC_PER_SEC)), dispatch_get_main_queue(), ^
   {
       self.hidden=YES;
   });
}



@end
