//
//  PhotoBrowerBaseCell.m
//  Goddess
//
//  Created by wangyan on 2016－03－17.
//  Copyright © 2016年 Goddess. All rights reserved.
//

#import "PhotoBrowerBaseCell.h"

@implementation PhotoBrowerBaseCell
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.userInteractionEnabled=YES;
        _imageView.tag = 500;
    }
    return _imageView;
}
@end
