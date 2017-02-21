//
//  PhotoViewCell.m
//  myHelper
//
//  Created by wangyan on 2016－03－15.
//  Copyright © 2016年 idea. All rights reserved.
//

#import "PhotoBrowerOriginCell.h"
@interface PhotoBrowerOriginCell()<UIScrollViewDelegate>

@property (nonatomic,strong) StatusBlock    tempBlock;

@end
@implementation PhotoBrowerOriginCell
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode=UIViewContentModeScaleAspectFit;
        @weakify(self);
        [self.imageView addTapGestureHandler:^(UITapGestureRecognizer *tap, UIView *itself) {
            @strongify(self);
            if (tap.state==UIGestureRecognizerStateEnded) {
                if (self.tempBlock) {
                    self.tempBlock(tap, @(1));
                }
            }
        }];
        [self.imageView addDoubleTapGestureHandler:^(UITapGestureRecognizer *tap, UIView *itself) {
            @strongify(self);
            if (tap.state==UIGestureRecognizerStateEnded) {
                if (self.tempBlock) {
                    self.tempBlock(tap, @(2));
                }
                [self zoomImage];
            }
        }];
        [self addSubview:self.scrollView];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}
- (void)reuse
{
    self.scrollView.zoomScale = 1.0;
}
-(void)imageGestureHandler:(StatusBlock)handler{
    self.tempBlock=handler;
}


-(void)zoomImage{
    CGFloat zoom=self.scrollView.zoomScale>1 ? 1 : 2.5;
    [UIView animateWithDuration:.5 animations:^{
        self.scrollView.zoomScale=zoom;
    }];
}

- (void)layoutSubviews
{
    self.scrollView.frame = self.bounds;
    self.imageView.frame = self.bounds;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        [_scrollView addSubview:self.imageView];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale=3.0;
        _scrollView.minimumZoomScale=1.0;
    }
    return _scrollView;
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:500];
}



@end
