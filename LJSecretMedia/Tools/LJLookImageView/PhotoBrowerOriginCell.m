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
@property (nonatomic,strong) StatusBlock    tempPlayBlock;
@property (nonatomic,assign) BOOL           buttonHideState;

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
        [self.playButton addTargetClickHandler:^(UIButton *but, id obj) {
            @strongify(self);
            if (self.tempPlayBlock) {
                self.tempPlayBlock(nil, nil);
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
    self.buttonHideState = self.playButton.hidden;
}
-(void)imageGestureHandler:(StatusBlock)handler{
    self.tempBlock=handler;
}

-(void)playButtonClickHandler:(StatusBlock)handler{
    self.tempPlayBlock = handler;
}


-(void)zoomImage{
    CGFloat zoom=self.scrollView.zoomScale>1 ? 1 : 2.5;
    [UIView animateWithDuration:.5 animations:^{
        self.scrollView.zoomScale=zoom;
    }completion:^(BOOL finished) {
        if (!_buttonHideState) {
            if (zoom <1.1) {
                self.playButton.hidden = NO;
            }else{
                self.playButton.hidden = YES;
            }
        }
    }];
}

- (void)layoutSubviews
{
    self.scrollView.frame = self.bounds;
    self.imageView.frame = self.bounds;
    self.playButton.frame = CGRectMake(self.lj_width/2-30, self.lj_height/2-30, 60, 60);
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        [_scrollView addSubview:self.imageView];
        [_scrollView addSubview:self.playButton];
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

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
    if (!_buttonHideState) {
        self.playButton.hidden = YES;
    }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (!_buttonHideState && scrollView.zoomScale<1.1 && scrollView.zoomScale>0) {
        self.playButton.hidden = NO;
    }
}


@end
