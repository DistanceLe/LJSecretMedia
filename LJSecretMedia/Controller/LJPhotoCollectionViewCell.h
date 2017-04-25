//
//  LJPhotoCollectionViewCell.h
//  相册Demo
//
//  Created by LiJie on 16/1/7.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJPhotoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UILabel *videoDurationTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;

-(void)longTapGestureHandler:(StatusBlock)handler;

@end
