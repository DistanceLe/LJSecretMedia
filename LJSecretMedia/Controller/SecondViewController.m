//
//  SecondViewController.m
//  LJSecretMedia
//
//  Created by LiJie on 16/7/28.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "SecondViewController.h"
#import "LJFingerMark.h"
@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

-(void)dealloc{
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self show];
}

-(void)show{
    [LJFingerMark addCheckingFingerHandler:^(id sender, id status) {
        NSLog(@"...aaa%@", status);
        self.view.backgroundColor=[UIColor orangeColor];
    }];
}
@end
