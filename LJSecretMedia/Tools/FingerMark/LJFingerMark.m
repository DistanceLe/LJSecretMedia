//
//  LJFingerMark.m
//  LJSecretMedia
//
//  Created by LiJie on 16/7/28.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJFingerMark.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <objc/runtime.h>

@interface LJFingerMark ()

@property(nonatomic, strong)LAContext* context;
@property(nonatomic, strong)StatusBlock tempHandler;

@end

@implementation LJFingerMark

-(void)dealloc{
    DLog(@"finger dealloc");
}
static char fingerKye;

+(void)addCheckingFingerHandler:(StatusBlock)handler{
    LJFingerMark* tempSelf=[[LJFingerMark alloc]init];
    tempSelf.tempHandler=handler;
    
    id  appDelegate=[[UIApplication sharedApplication] delegate];
    //添加 动态属性：
    objc_setAssociatedObject(appDelegate, &fingerKye, tempSelf, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [tempSelf authenticateUser];
}

-(void)authenticateUser{
    
    //上下文
    self.context=[[LAContext alloc]init];
    NSError* error=nil;
    /** LAErrorSystemCancel         切换到其他app，系统取消验证TouchID
        LAErrorUserCancel
        LAErrorUserFallback         用户选择其他验证方式
        LAErrorTouchIDNotEnrolled   没有登记touchID
        LAErrorPasscodeNotSet       系统未设置密码
     */
    
    NSString* result=@"请输入您的指纹吧";
    
    //判断设备是否支持：
    if ([self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //支持
        @weakify(self);
        [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError * _Nullable error) {
            @strongify(self);
            if (success) {
                //验证成功：
                [self commitResult:nil];
            }else{
                [self commitResult:error];
            }
        }];
    }else{
        //不支持指纹识别
        [self commitResult:error];
    }
}

-(void)commitResult:(NSError*)error{
    
    dispatch_async(dispatch_get_main_queue(), ^
   {
       if (self.tempHandler) {
           if (error) {
               self.tempHandler(@(NO), error.localizedDescription);
           }else{
               self.tempHandler(@(YES), nil);
           }
       }
       id  appDelegate=[[UIApplication sharedApplication] delegate];
       objc_setAssociatedObject(appDelegate, &fingerKye, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
   });
}












@end
