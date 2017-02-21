//
//  LJSheetAlertView.m
//  LJSecretMedia
//
//  Created by LiJie on 16/8/11.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJSheetAlertView.h"
#import <objc/runtime.h>

#define ButHeight  50

@interface LJSheetAlertView ()

@property(nonatomic, strong)LJSheetBlock    tempHandler;
@property(nonatomic, strong)NSArray*        titles;

@property(nonatomic, strong)UIView*         butBackView;

@end

@implementation LJSheetAlertView

//static char sheetKey;
+(void)showSheetWithTitles:(NSArray *)titles handler:(LJSheetBlock)handler{
    
    LJSheetAlertView* sheet=[[LJSheetAlertView alloc]initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT)];
    sheet.backgroundColor=[UIColor clearColor];
    sheet.titles=titles;
    sheet.tempHandler=handler;
    sheet.hidden=YES;
    [sheet initUI];
}

-(void)dealloc{
    DLog(@"sheet dealloc...");
}

-(void)initUI{
    self.butBackView=[[UIView alloc]initWithFrame:CGRectMake(0, IPHONE_HEIGHT, IPHONE_WIDTH, (self.titles.count+1)*ButHeight+6)];
    self.butBackView.backgroundColor=kRGBColor(200, 200, 200, 1);
    self.butBackView.layer.masksToBounds=YES;
    @weakify(self);
    for (NSInteger i=0; i<self.titles.count; i++) {
        NSString* title=self.titles[i];
        LJButton_Google* but=[LJButton_Google buttonWithType:UIButtonTypeCustom];
        [but setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [but setTitle:title forState:UIControlStateNormal];
        [but addTargetClickHandler:^(UIButton *but, id obj) {
            @strongify(self);
            if (self.tempHandler) {
                self.tempHandler(i+1, title);
                [self dismiss];
            }
        }];
        but.backgroundColor=[UIColor whiteColor];
        but.frame=CGRectMake(0, ButHeight*i, IPHONE_WIDTH, ButHeight-0.5);
        [self.butBackView addSubview:but];
    }
    LJButton_Google* but=[LJButton_Google buttonWithType:UIButtonTypeCustom];
    [but setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [but setTitle:@"取消" forState:UIControlStateNormal];
    [but addTargetClickHandler:^(UIButton *but, id obj) {
        @strongify(self);
        if (self.tempHandler) {
            self.tempHandler(0, @"取消");
            [self dismiss];
        }
    }];
    but.backgroundColor=[UIColor whiteColor];
    but.frame=CGRectMake(0, self.butBackView.lj_height-ButHeight-0.5, IPHONE_WIDTH, ButHeight-0.5);
    [self.butBackView addSubview:but];
    [self addSubview:self.butBackView];
    
    [self addTapGestureHandler:^(UITapGestureRecognizer *tap, UIView *itself) {
        @strongify(self);
        [self dismiss];
    }];
    
    [[AppDelegateInstance window]addSubview:self];
    [self show];
}

-(void)show{
    self.hidden=NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor=[[UIColor lightGrayColor]colorWithAlphaComponent:0.3];
    }];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.butBackView.lj_y=IPHONE_HEIGHT-self.butBackView.lj_height;
    }];
}


-(void)dismiss{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.butBackView.lj_y=IPHONE_HEIGHT;
    } completion:^(BOOL finished) {
        self.hidden=YES;
        [self removeFromSuperview];
    }];
}












@end
