//
//  WKAlertView.m
//  7dmallStore
//
//  Created by celink on 15/6/30.
//  Copyright (c) 2015年 celink. All rights reserved.
//

#import "WKAlertView.h"
#import "AppDelegate.h"
#import <objc/runtime.h>

@interface WKAlertView ()

@property(nonatomic, strong)CommitBlock tempBlock;
#ifdef __IPHONE_8_0
@property(nonatomic, strong)UIAlertController* tempAlert;
#endif

@end

@implementation WKAlertView
{
    __weak UIViewController* tempVC;
}

static char alertKey;
//自定义 弹出框：
+(void)customAlertWithTitle:(NSString*)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles clickButton:(CommitBlock)commit
{
    WKAlertView* tempSelf=[[WKAlertView alloc]initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles andClick:commit];
    [tempSelf show];
}
-(void)dealloc{
    DLog(@"alert dealloc");
}
-(instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles andClick:(CommitBlock)commit
{
    
    //回调Block：
    self.tempBlock=commit;
    
#ifdef __IPHONE_8_0 //ios8 用UIAlertController 替换
    if (IS_OS_8_OR_LATER)
    {
        _tempAlert=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction=nil;
        UIAlertAction* otherAction=nil;
        
        tempVC=delegate;
        if (!delegate) {
            tempVC=AppDelegateInstance.window.rootViewController;
        }
        objc_setAssociatedObject(AppDelegateInstance, &alertKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        @weakify(self);
        if (cancelButtonTitle!=nil)
        {
            cancelAction=[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
              {
                  @strongify(self);
                  if (self.tempBlock)
                  {
                      self.tempBlock(0);
                      objc_setAssociatedObject(AppDelegateInstance, &alertKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                  }
              }];
            [_tempAlert addAction:cancelAction];
        }
        if (otherButtonTitles!=nil)
        {
            otherAction=[UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
            {
                @strongify(self);
                if (self.tempBlock)
                {
                    self.tempBlock(1);
                    objc_setAssociatedObject(AppDelegateInstance, &alertKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                }
            }];
            [_tempAlert addAction:otherAction];
        }
        self=[super init];
        return self;
    }
    else
    {
        self=[super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
        self.delegate=self;
        return self;
    }
#else
    self=[super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    self.delegate=self;
    return self;
#endif
    
    
}
-(void)show
{
#ifdef __IPHONE_8_0
    if (IS_OS_8_OR_LATER)
    {
        if (tempVC!=nil)
        {
            [tempVC presentViewController:_tempAlert animated:YES completion:nil];
        }
    }
    else
    {
       [super show];
    }
#else
    [super show];
#endif
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        if (self.tempBlock)
        {
            self.tempBlock(1);
        }
    }
    else
    {
        if (self.tempBlock)
        {
            self.tempBlock(0);
        }
    }
}



@end
