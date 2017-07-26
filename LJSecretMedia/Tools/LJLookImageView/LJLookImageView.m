//
//  LJLookImageView.m
//  图片查看
//
//  Created by LiJie on 16/3/23.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJLookImageView.h"
#import "PhotoBrowerOriginCell.h"
#import "UIImageView+WebCache.h"
#import "LJFileOperation.h"
#import "LJImageTools.h"
#import "FLAnimatedImage.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

@interface LJLookImageView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic,strong) UICollectionViewFlowLayout * originLayout;
@property (nonatomic,strong) UICollectionView           * originCollectionView;

@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) UILabel * pageLabel;
@property (nonatomic,assign) CGPoint showoPoint;
@property (nonatomic,assign) CGSize  thumbnailSize;

@property (nonatomic,strong)dispatch_queue_t concurrentQueue;
@property (nonatomic,strong) LJFileOperation * operation;
@property (nonatomic,strong) LJFileOperation * thumbnailOperation;

@property (nonatomic,strong) PointBlock      tempHandler;
@property (nonatomic,strong) StatusBlock     tempRemoveHandler;


@end

@implementation LJLookImageView

- (instancetype)initWithShowPoint:(CGPoint)point size:(CGSize)size{
    self = [super init];
    if (self) {
        self.concurrentQueue = dispatch_queue_create("lookImageQueue", DISPATCH_QUEUE_CONCURRENT);
        self.showoPoint=point;
        self.thumbnailSize=size;
        self.layer.masksToBounds=YES;
        [self initUI];
    }
    return self;
}
-(LJFileOperation *)operation{
    if (_operation==nil) {
        _operation=[LJFileOperation shareOperationWithDocument:photoDictionary];
    }
    return _operation;
}
-(LJFileOperation *)thumbnailOperation{
    if (_thumbnailOperation==nil) {
        _thumbnailOperation=[LJFileOperation shareOperationWithDocument:thumbnailDictionary];
    }
    return _thumbnailOperation;
}

-(void)dealloc{
    DLog(@"look Image Dealloc...");
}
-(void)initUI{
    self.backgroundColor=[UIColor blackColor];
    self.frame=CGRectMake(0, 0, ScreenW, ScreenH);
    self.originCollectionView.frame = CGRectMake(0, 0, ScreenW, ScreenH);
    [self addSubview:self.originCollectionView];
    
    UIButton* backButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"关闭" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.frame=CGRectMake(ScreenW-60, 20, 60, 40);
    [backButton addTarget:self action:@selector(hideSelf) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    
    _pageLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, ScreenH-35, ScreenW, 35)];
    _pageLabel.textColor=[UIColor whiteColor];
    _pageLabel.font=[UIFont systemFontOfSize:14];
    _pageLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:_pageLabel];
    
//    [[[[UIApplication sharedApplication]delegate]window]addSubview:self];
}
-(void)willMoveToSuperview:(UIView *)newSuperview{
    CGRect myFrame=self.frame;
    self.frame=CGRectMake(self.showoPoint.x-self.thumbnailSize.width/2, self.showoPoint.y-self.thumbnailSize.height/2, self.thumbnailSize.width, self.thumbnailSize.height);
    [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.frame=myFrame;
    } completion:^(BOOL finished) {
        [super willMoveToSuperview:newSuperview];
    }];
}

-(void)hideSelf{
    CGPoint hidePoint=self.tempHandler(self.tapIndex-1);
    [UIView animateWithDuration:.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha=0;
        self.frame=CGRectMake(hidePoint.x-self.thumbnailSize.width/2, hidePoint.y-self.thumbnailSize.height/2, self.thumbnailSize.width, self.thumbnailSize.height);
        if (self.tempRemoveHandler) {
            self.tempRemoveHandler(nil, nil);
        }
    } completion:^(BOOL finished) {
        self.hidden=YES;
        [self removeFromSuperview];
    }];
}
-(void)requestTheHidePoint:(PointBlock)handler{
    self.tempHandler=handler;
}
-(void)removeSelfHandler:(StatusBlock)handler{
    self.tempRemoveHandler = handler;
}
-(void)showLookView{
    self.hidden=NO;
    [self.originCollectionView reloadData];
}

-(void)setImageUrlArray:(NSArray *)imageUrlArray{
    _imageUrlArray=imageUrlArray;
    self.dataSource=imageUrlArray;
    self.pageLabel.text=[NSString stringWithFormat:@"1/%ld", imageUrlArray.count];
    [self.originCollectionView reloadData];
}
-(void)setImageNameArray:(NSArray *)imageNameArray{
    _imageUrlArray=imageNameArray;
    _imageNameArray=imageNameArray;
    self.pageLabel.text=[NSString stringWithFormat:@"1/%ld", imageNameArray.count];
    [self.originCollectionView reloadData];
}
-(void)setTapIndex:(NSInteger)tapIndex{
    _tapIndex=tapIndex;
    self.pageLabel.text=[NSString stringWithFormat:@"%ld/%ld", tapIndex+1, _imageUrlArray.count];
    [self imageWillAppearWithIndex:tapIndex];
}

- (UICollectionView *)originCollectionView{
    if (!_originCollectionView) {
        _originCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.originLayout];
        
        [_originCollectionView setDelegate:self];
        [_originCollectionView setDataSource:self];
        [_originCollectionView setBounces:NO];
        [_originCollectionView setAlwaysBounceHorizontal:NO];
        [_originCollectionView setShowsVerticalScrollIndicator:NO];
        [_originCollectionView setShowsHorizontalScrollIndicator:NO];
        [_originCollectionView setScrollEnabled:YES];
        [_originCollectionView setPagingEnabled:YES];
        [_originCollectionView setBackgroundColor:[UIColor clearColor]];
        [_originCollectionView registerClass:[PhotoBrowerOriginCell class] forCellWithReuseIdentifier:@"PhotoBrowerOriginCell"];
    }
    return _originCollectionView;
}

- (UICollectionViewFlowLayout *)originLayout{
    if (!_originLayout) {
        _originLayout = [[UICollectionViewFlowLayout alloc]init];
        _originLayout.itemSize = CGSizeMake(ScreenW,ScreenH);
        _originLayout.minimumLineSpacing = 0.0;
        _originLayout.minimumInteritemSpacing = 0.0;
        [_originLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }
    return _originLayout;
}

#pragma mark - ================ 代理 ==================
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger num =0;
    if (self.dataSource) {
        num=self.dataSource.count;
    }else{
        num=self.imageNameArray.count;
    }
    return num;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoBrowerOriginCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoBrowerOriginCell" forIndexPath:indexPath];
    if (self.dataSource.count) {
        NSURL * url = [NSURL URLWithString:self.dataSource[indexPath.item]];
        [cell.imageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageProgressiveDownload];
    }else{
        NSString* imageName = self.imageNameArray[indexPath.item];
        //创建异步加载：
        dispatch_async(self.concurrentQueue, ^{
            if ([imageName hasSuffix:@".MOV"]) {
                NSData* imageData=[self.thumbnailOperation readObjectWithName:imageName];
                UIImage* image=[UIImage imageWithData:imageData];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    cell.imageView.image = image;
                    cell.imageView.hidden = NO;
                    cell.animationImageView.hidden = YES;
                    cell.animationImageView.animatedImage=nil;
                    
                    cell.playButton.hidden = NO;
                    cell.playButton.enabled = YES;
                });
            }else{
                NSData* imageData=[self.operation readObjectWithName:imageName];
                UIImage* commonImage= nil;
                FLAnimatedImage* image = [[FLAnimatedImage alloc]initWithAnimatedGIFData:imageData];
                if (!image.frameCount) {
                    commonImage = [UIImage imageWithData:imageData];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (commonImage) {
                        cell.imageView.image = commonImage;
                        cell.imageView.hidden = NO;
                        cell.animationImageView.hidden = YES;
                        cell.animationImageView.animatedImage=nil;
                    }else{
                        cell.imageView.image = nil;
                        cell.imageView.hidden = YES;
                        cell.animationImageView.hidden = NO;
                        cell.animationImageView.animatedImage=image;
                    }
                    
                    cell.playButton.hidden = YES;
                    cell.playButton.enabled = NO;
                });
            }
        });
        @weakify(self);
        [cell playButtonClickHandler:^(id sender, id status) {
            @strongify(self);
            DLog(@"开始播放");
            [self playVideo:imageName];
        }];
//        cell.imageView.image=[UIImage imageWithData:imageData];
//        
//        
//        NSString* filePaht=[self.operation readFilePath:self.imageNameArray[indexPath.item]];
//        cell.imageView.image=[UIImage imageNamed:@"backImage"];
//        DLog(@"%@", filePaht);
    }
    @weakify(self);
    [cell imageGestureHandler:^(id sender, id status) {
        @strongify(self);
        if ([status integerValue]==1) {
            [self hideSelf];
        }
    }];
    [cell reuse];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    _tapIndex=indexPath.item+1;
    self.tempHandler(self.tapIndex-1);
    self.pageLabel.text=[NSString stringWithFormat:@"%ld/%ld", _tapIndex, _imageUrlArray.count];
}

-(void)imageWillAppearWithIndex:(NSInteger)index{
    NSIndexPath* indexPath=[NSIndexPath indexPathForItem:index inSection:0];
    if (index>=_imageUrlArray.count) {
        return;
    }
    [self.originCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}



-(void)playVideo:(NSString*)videoName{
    //videoURL使用的是NSURL的fileURLWithPath，
    //而不是URLWithString，前者用来访问本地视频，后者用来访问网络视频
    NSURL* url = [NSURL fileURLWithPath:[self.operation readFilePath:videoName]];
    AVPlayerItem* item = [[AVPlayerItem alloc]initWithURL:url];
    AVPlayer* player = [[AVPlayer alloc]initWithPlayerItem:item];
    
    AVPlayerViewController* playVC = [[AVPlayerViewController alloc]init];
    playVC.player = player;
    playVC.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.superVC presentViewController:playVC animated:YES completion:nil];
    [player play];
}









@end
