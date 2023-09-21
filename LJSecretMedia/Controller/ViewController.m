//
//  ViewController.m
//  LJSecretMedia
//
//  Created by LiJie on 16/7/28.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import "LJPhotoAlbumTableViewController.h"
#import "LJPhotoCollectionViewCell.h"
#import "LJAttachementLayout.h"

#import "LJPHPhotoTools.h"
#import "LJImageTools.h"
#import "LJFileOperation.h"
#import "LJLookImageView.h"
#import "TimeTools.h"
#import "LJSheetAlertView.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) BOOL             isEdit;
@property (nonatomic, strong) NSMutableArray   * photosName;
@property (nonatomic, strong) NSMutableArray   * selectedIndex;
@property (nonatomic, strong) NSMutableArray   * thumbnailsCache;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) LJFileOperation  * operation;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.hidden=YES;
    [self initData];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self refreshDataReload:YES];
}

-(void)initData{
    
    [[NSNotificationCenter defaultCenter]addObserverName:@"access" object:nil handler:^(id sender, id status) {
        self.view.hidden=NO;
    }];
    [[NSNotificationCenter defaultCenter]addObserverName:@"resign" object:nil handler:^(id sender, id status) {
        self.view.hidden=YES;
    }];
    [[NSNotificationCenter defaultCenter]addObserverName:@"addPhoto" object:nil handler:^(id sender, id status) {
        [self.thumbnailsCache removeAllObjects];
    }];
    self.thumbnailsCache=[NSMutableArray array];
    self.selectedIndex=[NSMutableArray array];
    self.operation=[LJFileOperation shareOperationWithDocument:thumbnailDictionary];
    [self initUI];
}
-(void)refreshDataReload:(BOOL)reload{
    self.photosName=[NSMutableArray arrayWithArray:[self.operation readAllFileName]];
    [self.photosName sortUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    [self.selectedIndex removeAllObjects];
    for (NSInteger i=0; i<self.photosName.count; i++) {
        [self.selectedIndex addObject:@(NO)];
    }
    if (reload) {
        [self.collectionView reloadData];
    }
}

-(void)initUI{
    self.title=@"照片墙";
    
    UICollectionViewFlowLayout* layout=[[UICollectionViewFlowLayout alloc]init];
    NSInteger itemWidth=(IPHONE_WIDTH-9)/4;
    layout.minimumInteritemSpacing = 3;
    layout.minimumLineSpacing = 3;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.sectionInset = UIEdgeInsetsMake(2, 0, 2, 0);
    
    
    self.collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
    self.collectionView.bounces=YES;
    self.collectionView.backgroundColor=[[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    [self.collectionView registerNib:[UINib nibWithNibName:@"LJPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    [self.view addSubview:self.collectionView];
    
    [self setNavLeftWithText:@"编辑"];
    [self setNavRightWithText:@"添加图片"];
}

- (void)setNavLeftWithText:(NSString *)text {
    
    float width=[text boundingRectWithSize:CGSizeMake(200, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.width;
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, 44)];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [button addTarget:self action:@selector(onLeftNavBarItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)setNavRightWithText:(NSString *)text {
    
    float width=[text boundingRectWithSize:CGSizeMake(200, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size.width;
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, width, 44)];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -5)];
    [button addTarget:self action:@selector(onRightNavBarItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

-(void)onLeftNavBarItemClicked:(UIButton*)but{
    but.selected=!but.selected;
    UIButton* rightBut =self.navigationItem.rightBarButtonItem.customView;
    rightBut.selected=but.selected;
    self.isEdit=but.selected;
    if (but.selected) {
        [but setTitle:@"完成" forState:UIControlStateNormal];
        [rightBut setTitle:@"删除" forState:UIControlStateNormal];
        [self refreshDataReload:YES];
    }else{
        [but setTitle:@"编辑" forState:UIControlStateNormal];
        [rightBut setTitle:@"添加图片" forState:UIControlStateNormal];
        [self.collectionView  reloadData];
    }
    
}

-(void)onRightNavBarItemClicked:(UIButton*)but{
    
    if (!but.selected) {
        @weakify(self);
        [LJSheetAlertView showSheetWithTitles:@[@"从手机相册中获取", @"打开照相机"] handler:^(NSInteger flag, NSString *title) {
            @strongify(self);
            if (flag==1) {
                LJPhotoAlbumTableViewController* albumVC=[[LJPhotoAlbumTableViewController alloc]init];
                [self.navigationController pushViewController:albumVC animated:YES];
            }else if (flag==2){
                [self openCamera];
            }
        }];
    }else{
        [self deletePhoto];
    }
}

#pragma mark - ================ Delegate ==================
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photosName.count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LJPhotoCollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSString* imageName = self.photosName[indexPath.item];
    if (self.thumbnailsCache.count == indexPath.item) {
        NSData* imageData=[self.operation readObjectWithName:imageName];
        UIImage* image=[UIImage imageWithData:imageData];
        [self.thumbnailsCache addObject:image];
    }
    if (self.thumbnailsCache.count<=indexPath.item) {
        NSData* imageData=[self.operation readObjectWithName:imageName];
        UIImage* image=[UIImage imageWithData:imageData];
        cell.headImageView.image=image;
    }else{
        cell.headImageView.image=self.thumbnailsCache[indexPath.item];
    }
    if ([imageName hasSuffix:@".MOV"]) {
        cell.playImageView.hidden = NO;
    }else{
        cell.playImageView.hidden = YES;
    }
    @weakify(self);
    [cell longTapGestureHandler:^(id sender, id status) {
        @strongify(self);
        [self deletePhotoIndex:indexPath.item];
    }];
    cell.selectButton.hidden=!self.isEdit;
    cell.selectButton.selected=[self.selectedIndex[indexPath.item] boolValue];
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isEdit) {
        LJPhotoCollectionViewCell* cell=(LJPhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        cell.selectButton.selected=!cell.selectButton.selected;
        [self.selectedIndex replaceObjectAtIndex:indexPath.item withObject:@(cell.selectButton.selected)];
        return;
    }
    LJPhotoCollectionViewCell* cell=(LJPhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectButton.selected=!cell.selectButton.selected;
    
    CGPoint pointTo=[cell convertPoint:CGPointMake(cell.lj_width/2, cell.lj_height/2) toView:self.view];
    
    LJLookImageView* imageLookView=[[LJLookImageView alloc]initWithShowPoint:pointTo size:cell.lj_size];
    imageLookView.superVC = self;
    imageLookView.imageNameArray=self.photosName;
    imageLookView.tapIndex=indexPath.item;
    [imageLookView showLookView];
    @weakify(self);
    [imageLookView requestTheHidePoint:^CGPoint(NSInteger index) {
        @strongify(self);
        BOOL isExit=NO;
        for (NSIndexPath* visibleIndexPath in self.collectionView.indexPathsForVisibleItems) {
            if (visibleIndexPath.item==index) {
                isExit=YES;
                break;
            }
        }
        if (!isExit) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        }
        LJPhotoCollectionViewCell* cell=(LJPhotoCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
        
        CGPoint pointTo=[cell convertPoint:CGPointMake(cell.lj_width/2, cell.lj_height/2) toView:self.view];
        
        return pointTo;
    }];
    
    [imageLookView removeSelfHandler:^(id sender, id status) {
        @strongify(self);
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }];
    [self.view addSubview:imageLookView];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
#pragma mark - ================ cell出现时的动画 ==================
//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    cell.alpha=0.7;
//    [UIView animateWithDuration:0.4 animations:^{
//        cell.alpha=1;
//    }];
//}

#pragma mark - ================ 打开照相机 ==================
-(void)openCamera{
    @weakify(self);
    [LJPHPhotoTools getImageFromCameraHandler:^(UIImage *image) {
        @strongify(self);
        if (image) {
            UIImage* thumbnail=[LJImageTools changeImage:image toRatioSize:CGSizeMake(IPHONE_WIDTH/1.5, IPHONE_WIDTH/1.5)];
            NSString* imageName=[NSString stringWithFormat:@"%@.JPG",[TimeTools getCurrentTimestamp]];
            LJFileOperation* photoOperation=[LJFileOperation shareOperationWithDocument:photoDictionary];
            [photoOperation saveObject:image name:imageName];
            [self.operation saveObject:thumbnail name:imageName];
            [self.thumbnailsCache removeAllObjects];
            [self refreshDataReload:YES];
        }
    }];
}

#pragma mark - ================ 删除图片 ==================
-(void)deletePhotoIndex:(NSInteger)index{
    
    @weakify(self);
    [LJSheetAlertView showSheetWithTitles:@[@"保存到相册", @"删除"] handler:^(NSInteger flag, NSString *title) {
        @strongify(self);
        if (flag==1) {
            [self saveImageIndex:index];
        }else if (flag==2){
            [self deleteFileIndex:index];
        }
    }];
}
-(void)saveImageIndex:(NSInteger)index{
    [ProgressHUD show:@"保存中..."];
    LJFileOperation* operation=[LJFileOperation shareOperationWithDocument:photoDictionary];
    NSData* imageData=[operation readObjectWithName:self.photosName[index]];
    NSString* imageName = self.photosName[index];
    if ([imageName hasSuffix:@"MOV"]) {
        NSString* filePath = [operation readFilePath:imageName];
        [LJPHPhotoTools saveVideoFromURL:[NSURL URLWithString:filePath] toCustomAlbum:nil handler:^(BOOL success) {
            [ProgressHUD dismiss];
            if (success) {
                [LJInfoAlert showInfo:@"保存成功" bgColor:nil];
            }else{
                [LJInfoAlert showInfo:@"保存失败" bgColor:nil];
            }
        }];
    }else{
        [LJPHPhotoTools saveImage:[UIImage imageWithData:imageData] toCustomAlbum:nil handler:^(BOOL success) {
            [ProgressHUD dismiss];
            if (success) {
                [LJInfoAlert showInfo:@"保存成功" bgColor:nil];
            }else{
                [LJInfoAlert showInfo:@"保存失败" bgColor:nil];
            }
        }];
    }
}

-(void)deleteFileIndex:(NSInteger)index{
    LJFileOperation* photoOperation=[LJFileOperation shareOperationWithDocument:photoDictionary];
    [photoOperation deleteObjectWithName:self.photosName[index]];
    [self.operation deleteObjectWithName:self.photosName[index]];
    [self.photosName removeObjectAtIndex:index];
    if (self.thumbnailsCache.count == self.photosName.count) {
        [self.thumbnailsCache removeObjectAtIndex:index];
    }else{
        [self.thumbnailsCache removeAllObjects];
    }
    [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

-(void)deletePhoto{
    LJFileOperation* photoOperation=[LJFileOperation shareOperationWithDocument:photoDictionary];
    NSMutableArray* deleteIndexPaths=[NSMutableArray array];
    
    for (NSInteger index=0; index<self.selectedIndex.count; index++) {
        if ([self.selectedIndex[index] boolValue]) {
            [photoOperation deleteObjectWithName:self.photosName[index]];
            [self.operation deleteObjectWithName:self.photosName[index]];
            [deleteIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }
    }
    if (deleteIndexPaths.count<1) {
        return;
    }
    if (self.thumbnailsCache.count==self.photosName.count) {
        NSInteger loc=[(NSIndexPath*)deleteIndexPaths.firstObject item];
        [self.thumbnailsCache removeObjectsInRange:NSMakeRange(loc, self.thumbnailsCache.count-loc)];
    }else{
        [self.thumbnailsCache removeAllObjects];
    }
    
    [self refreshDataReload:NO];
    [self.collectionView deleteItemsAtIndexPaths:deleteIndexPaths];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

@end
