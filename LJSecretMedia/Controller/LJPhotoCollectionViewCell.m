//
//  LJPhotoCollectionViewCell.m
//  相册Demo
//
//  Created by LiJie on 16/1/7.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJPhotoCollectionViewCell.h"

@implementation LJPhotoCollectionViewCell
{
    StatusBlock tempBlock;
}
- (void)awakeFromNib {
    // Initialization code
    UILongPressGestureRecognizer* longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTap:)];
    [self addGestureRecognizer:longPress];
}

-(void)longTapGestureHandler:(StatusBlock)handler{
    
    tempBlock=handler;
}

-(void)longTap:(UILongPressGestureRecognizer*)longPress{
    
    if (tempBlock && longPress.state==UIGestureRecognizerStateBegan) {
        tempBlock(longPress, nil);
    }
}

@end
