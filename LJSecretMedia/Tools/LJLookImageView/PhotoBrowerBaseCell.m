//
//  PhotoBrowerBaseCell.m
//  Goddess
//
//  Created by wangyan on 2016－03－17.
//  Copyright © 2016年 Goddess. All rights reserved.
//

#import "PhotoBrowerBaseCell.h"

@implementation PhotoBrowerBaseCell
- (FLAnimatedImageView *)animationImageView
{
    if (!_animationImageView) {
        _animationImageView = [[FLAnimatedImageView alloc]init];
        _animationImageView.userInteractionEnabled=YES;
        _animationImageView.tag = 500;
    }
    return _animationImageView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.userInteractionEnabled=YES;
        _imageView.tag = 1000;
    }
    return _imageView;
}

-(UIButton*)playButton{
    
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    return _playButton;
}


@end
