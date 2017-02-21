//
//  UIImage+LJ.m
//  LJSecretMedia
//
//  Created by LiJie on 16/8/8.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "UIImage+LJ.h"

@implementation UIImage (LJ)

-(UIImage *)cutCircleImage{
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    
    //获取上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGRect rect=CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextAddEllipseInRect(context, rect);
    
    //裁剪
    CGContextClip(context);
    
    //将图片画上去
    [self drawInRect:rect];
    UIImage* image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
