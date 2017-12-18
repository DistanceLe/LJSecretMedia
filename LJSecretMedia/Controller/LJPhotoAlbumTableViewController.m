//
//  LJPhotoAlbumTableViewController.m
//  LJSecretMedia
//
//  Created by LiJie on 16/8/1.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJPhotoAlbumTableViewController.h"
#import "LJPhotoAlbumDetailCollectionViewController.h"
#import "LJPHPhotoTools.h"
#import "LJAttachementLayout.h"

@interface LJPhotoAlbumTableViewController ()

@property(nonatomic, strong)NSArray* albums;
@property(nonatomic, strong)NSArray* names;
@property(nonatomic, strong)NSArray* posterImages;
@property(nonatomic, strong)NSArray* imageCounts;


@end

@implementation LJPhotoAlbumTableViewController

/**  相册列表 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"相册";
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self initData];
}

-(void)dealloc{
    DLog(@"...dealloc");
}

-(void)initData{
    
    @weakify(self);
    [LJPHPhotoTools getAllGroup:^(NSArray<PHAssetCollection *> *group, NSArray *posterImages, NSArray *groupNames, NSArray *groupCounts) {
        @strongify(self);
        self.albums=group;
        self.names=groupNames;
        self.posterImages=posterImages;
        self.imageCounts=groupCounts;
        [self initUI];
    }];
}

-(void)initUI{
    self.tableView.rowHeight=60;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
}

#pragma mark - ================ Delegate ==================
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albums.count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 0.001;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.imageView.contentMode=UIViewContentModeScaleToFill;
        cell.imageView.backgroundColor=[UIColor whiteColor];
        cell.textLabel.font=[UIFont systemFontOfSize:15];
        cell.detailTextLabel.font=[UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor=[[UIColor lightGrayColor]colorWithAlphaComponent:0.9];
    }
    cell.imageView.image=self.posterImages[indexPath.row];
    cell.textLabel.text=self.names[indexPath.row];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"共%@张图片", self.imageCounts[indexPath.row]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.imageCounts[indexPath.row] integerValue]<1) {
        return;
    }
    CGFloat itemWidth=(self.view.bounds.size.width-16)/3;
    UICollectionViewFlowLayout* layout=[[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing=8;
    layout.minimumInteritemSpacing=8;
    layout.itemSize=CGSizeMake(itemWidth, itemWidth);
    LJPhotoAlbumDetailCollectionViewController* detaliVC=[[LJPhotoAlbumDetailCollectionViewController alloc]initWithCollectionViewLayout:layout];
    detaliVC.collection=self.albums[indexPath.row];
    detaliVC.title=self.names[indexPath.row];
    [self.navigationController pushViewController:detaliVC animated:YES];
}





@end
