//
//  PhotoBrowerBaseCell.h
//  Goddess
//
//  Created by wangyan on 2016－03－17.
//  Copyright © 2016年 Goddess. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"
@interface PhotoBrowerBaseCell : UICollectionViewCell

@property (nonatomic,strong) FLAnimatedImageView * animationImageView;
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UIButton* playButton;

@end
