//
//  CatalogueListViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CatalogueListViewController.h"
#import "CatalogueListCollectionViewCell.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "LatestCatalogueViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

static NSString *identifier = @"CatalogueListCell";

@interface CatalogueListViewController (){
//    CGRect viewRect;
//    CGRect cellRect;
}


@end

@implementation CatalogueListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //delegate
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    NSLog(@"共有幾筆 %zd", self.parentVC.dicArray.count);
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    viewRect = self.view.frame;
//    cellRect = CGRectMake(0, 0, viewRect.size.width/2, (viewRect.size.width/2)*1.5);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - collection delegate 

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(self.cellRect.size.width, self.cellRect.size.height);
    return size;
//    return self.cellRect.size;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.parentVC.dicArrayList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CatalogueListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *dic = [self.parentVC.dicArrayList objectAtIndex:indexPath.row];
    
    NSString *name = [dic objectForKey:@"catalogueTitle"];
    cell.nameLabel.text = name;
    
    NSString *startTime = [dic objectForKey:@"startDate"];
    NSString *endTime = [dic objectForKey:@"endDate"];
    
    startTime = [startTime substringToIndex:10];
    endTime = [endTime substringToIndex:10];
    
    cell.timeLabel.text = [NSString stringWithFormat:@"%@~%@", startTime, endTime];
    
    NSString *imgURLString = [dic objectForKey:@"img"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", IMAGE_PREFIX_HOLA, imgURLString];
    NSURL *url = [NSURL URLWithString:urlString];
    cell.asyncImageView.imageURL = url;
    
//    [cell.containerView.layer setCornerRadius:50.0f];
    [cell.layer setCornerRadius:5.0f];
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogueListCollectionViewCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell1.asyncImageView.imageURL = nil;
}

//點選cell
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //先取得資料
    NSDictionary *dic = [self.parentVC.dicArrayList objectAtIndex:indexPath.row];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Catalogue" bundle:nil];
    LatestCatalogueViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LatestCatalogueView"];
    vc.dicData = dic;

    //先撈資料
    [vc getFirstData];

    [self.navigationController pushViewController:vc animated:YES];
    
    NSInteger catalogueId = [[dic objectForKey:@"catalogueId"] integerValue];
    
    // GA -- 選擇哪一個商品
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/catalog/item/%ld",(long)catalogueId]];
    [tracker send : [ [ GAIDictionaryBuilder  createScreenView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/catalog/item/%ld",(long)catalogueId]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
}

@end
