//
//  LJPhotoAlbumDetailCollectionViewController.m
//  LJSecretMedia
//
//  Created by LiJie on 16/8/1.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJPhotoAlbumDetailCollectionViewController.h"

#import "LJPhotoCollectionViewCell.h"
#import "LJPHPhotoTools.h"
#import "LJFileOperation.h"


@interface LJPhotoAlbumDetailCollectionViewController ()

@property(nonatomic, strong)NSArray* images;
@property(nonatomic, strong)NSMutableArray* selectedIndex;

@end

@implementation LJPhotoAlbumDetailCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

-(void)dealloc{
    DLog(@"detail dealloc");
}

-(void)initData{
    
    self.images=[LJPHPhotoTools getAssetsInCollection:self.collection];
    self.selectedIndex=[NSMutableArray array];
    for (NSInteger i=0; i<self.images.count; i++) {
        [self.selectedIndex addObject:@(NO)];
    }
    [self.collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}

-(void)initUI{
    
    self.collectionView.backgroundColor=[UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LJPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [self initData];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@"确认选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightClick)]];
}

-(void)rightClick{
    [ProgressHUD show:@"保存中..." autoStop:NO];
    __block NSInteger index=0;
    for (NSNumber* obj in self.selectedIndex) {
        if ([obj boolValue]) {
            index++;
        }
    }
    __block NSMutableArray* assets=[NSMutableArray array];
    LJFileOperation* originOperation=[LJFileOperation shareOperationWithDocument:photoDictionary];
    LJFileOperation* thumbainOperation=[LJFileOperation shareOperationWithDocument:thumbnailDictionary];
    [self.selectedIndex enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj boolValue]) {
            PHAsset* asset=self.images[idx];
            [assets addObject:asset];
            __block NSString* tempName=nil;
            [LJPHPhotoTools getImageDataWithAsset:asset handler:^(NSData *imageData, NSString* imageName) {
                
                tempName=imageName;
                DLog(@"imageName=%@", imageName);
                [originOperation saveObject:imageData name:imageName];
            }];
            
            [LJPHPhotoTools getAsyncImageWithAsset:asset imageSize:CGSizeMake(IPHONE_WIDTH/1.5, IPHONE_WIDTH/1.5) handler:^(UIImage *image) {
                index--;
                DLog(@"imageName=%@", tempName);
                [thumbainOperation saveObject:image name:tempName];
                if (index==0) {
                    [self deleteSystemPhotos:assets];
                    [ProgressHUD dismiss];
                }
            }];
        }
    }];
}
-(void)deleteSystemPhotos:(NSArray<PHAsset*>*)assets{
    @weakify(self);
    [WKAlertView customAlertWithTitle:@"同时删除相册中对应的图片？" message:@"删除的图片会暂时存放在垃圾篓中" delegate:self cancelButtonTitle:@"不要" otherButtonTitles:@"删除" clickButton:^(NSInteger flag) {
        @strongify(self);
        if (flag==1) {
            [ProgressHUD show:@"删除中..." autoStop:NO];
            [LJPHPhotoTools deleteImageWithAssets:assets handler:^(BOOL success) {
                [ProgressHUD dismiss];
                if (success) {
                    [LJInfoAlert showInfo:@"删除成功" bgColor:nil];
                }else{
                    [LJInfoAlert showInfo:@"删除失败" bgColor:nil];
                }
                [[NSNotificationCenter defaultCenter]postNotificationName:@"addPhoto" object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }else{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"addPhoto" object:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LJPhotoCollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [LJPHPhotoTools getAsyncImageWithAsset:self.images[indexPath.item] imageSize:CGSizeMake(IPHONE_WIDTH/1.5, IPHONE_WIDTH/1.5) handler:^(UIImage *image) {
        cell.headImageView.image=image;
    }];
    cell.selectButton.hidden=NO;
    cell.selectButton.selected=[self.selectedIndex[indexPath.item] boolValue];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LJPhotoCollectionViewCell* cell=(LJPhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectButton.selected=!cell.selectButton.selected;
    [self.selectedIndex replaceObjectAtIndex:indexPath.item withObject:@(cell.selectButton.selected)];
}

@end
