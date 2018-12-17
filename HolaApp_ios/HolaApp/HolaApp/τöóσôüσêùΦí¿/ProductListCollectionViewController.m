//
//  ProductListCollectionViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/5.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ProductListCollectionViewController.h"
#import "NSDefaultArea.h"
#import "GetAndPostAPI.h"
#import "SessionID.h"
#import "URLib.h"
#import "ProductListCollectionViewCell.h"
#import "AFNetworking.h"
#import "AES.h"
#import "ProductContentViewController.h"
#import "AsyncImageView.h"
#import "ProductInfoData.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"




@interface ProductListCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ProductListContainerViewControllerDelegate>
{
    MBProgressHUD  *progressHUD;
    CGSize collectionVCell;
    CGRect cellRect;

 }

@end

@implementation ProductListCollectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    // init page at first time , load more start from page 2
    self.pagePlus=1;
    // set scroll to top delegate
    self.containerController.delegate = self;
    self.productIDs=[[NSMutableArray alloc]init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.productList != nil) {
        return [self.productList count];
    }
    
    return 0;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"Cell";
    ProductListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell
    if (cell == nil) {
        cell = [[ProductListCollectionViewCell alloc] initWithFrame:cellRect];
        NSLog(@"cellRect -- %@", NSStringFromCGRect(cellRect));
    }

    ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];
    
    cell.prdNameLabel.text=product.prdName;
    
    NSURL *url1 =nil;
    cell.prdImge.imageURL = url1;
    [cell.prdImge setShowActivityIndicator:YES];
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.prdImge.imageURL];


    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOLA_PIC_URL_STR, product.prdImg]];
    [cell.prdImge setImageURL:url];
    
    cell.origPriceLabel.text=[NSString stringWithFormat:@"售價 $%ld",product.origPrice];
    cell.salePriceLabel.text=[NSString stringWithFormat:@"網購價 $%ld",product.salePrice];

    if (product.isSelected) {
        // 選取
        [cell.selectButton setImage:[UIImage imageNamed:@"Compare_2"] forState:UIControlStateNormal];
    }else {
        // 無選取
        [cell.selectButton setImage:[UIImage imageNamed:@"Compare_1"] forState:UIControlStateNormal];
    }
    
    // selectButton indexPath.row=0,1,2,3.....
    cell.selectButton.tag = indexPath.row;
    [cell.selectButton addTarget:self action:@selector(DidSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundColor=[UIColor whiteColor];
    [cell.layer setCornerRadius:5.0f];
    
    return cell;
}



#pragma mark - CollectionView Delegate

// called when the user taps on an already-selected item in multi-select mode
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];

    if (self.delegate) {
        [self.delegate productSelected:product.prdId SKU:product.sku];
    }
    
    // GA -- 選擇哪一個商品
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/product/item/%@",product.prdId]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/product/item/%@",product.prdId]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
   

    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"Did deselect row: %lu",(long)indexPath.row);
}

#pragma mark - cell size and cell end display's action
// controll cell size via itemSize property
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGRect rect=self.view.frame;
    NSLog(@"self.view.frame -- %@", NSStringFromCGRect(rect));
    cellRect = CGRectMake(0, 0, (rect.size.width/2-15.0), (rect.size.width/2)*1.45);
    
    NSLog(@"rect1 %@",NSStringFromCGRect(cellRect));
    
    return cellRect.size;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //let cell's img stop flashing
    static NSString *identifier = @"Cell";
    ProductListCollectionViewCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell1.prdImge.imageURL = nil;
}

#pragma mark - DidSelectButton

- (void)DidSelectButton:(UIButton*)sender {
    
    UIButton *button= (UIButton *)sender;
    ProductInfoData *product = [self.productList objectAtIndex:button.tag];
    product.isSelected = !product.isSelected;
    

    if (product.isSelected) {
        NSLog(@"product is Selected");
        [button setImage:[UIImage imageNamed:@"Compare_2"] forState:UIControlStateNormal];
        [self.productIDs addObject:product.prdId];
     

    } else {
        NSLog(@"product is not Selected");
        [button setImage:[UIImage imageNamed:@"Compare_1"] forState:UIControlStateNormal];
        [self.productIDs removeObject:product.prdId];
    }
    

    if (self.productIDs.count==7) {
        
        NSString *err = @"您最多可以選擇六件商品";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:err delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }
    
}


#pragma mark - initializeProgressHUD

- (void)initializeProgressHUD:(NSString *)msg
{
    if (progressHUD)
        [progressHUD removeFromSuperview];
    
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUD];
    progressHUD.dimBackground = NO;
    // progressHUD.delegate = self;
    progressHUD.labelText = msg;
    progressHUD.margin = 20.f;
    
    // -100為5S
    //    progressHUD.yOffset = -(HUDsize.height/4);
    progressHUD.removeFromSuperViewOnHide = YES;
    [progressHUD show:YES];
}


-(void)toTop {
    NSLog(@"Top");
    if(self.productList.count==0){
        return;
    }else{
    [self.containerController topButtonHideOrNot:NO];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

#pragma mark - scrollViewDidScroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint origin = [scrollView contentOffset];
    [scrollView setContentOffset:CGPointMake(0.0, origin.y)];
    
    if ([scrollView.panGestureRecognizer translationInView:scrollView].y >= 0)
    {
        if(origin.y<350){
            [self.containerController topButtonHideOrNot:NO];
        }
    }
    else
    {
        if(origin.y>350){
            [self.containerController topButtonHideOrNot:YES];
        }
    }
    
    // 偵測滑到底部, do not use float, you may not get the right value for matching the offset
    NSInteger scrollViewHeight = scrollView.bounds.size.height; // 內容高度
    NSInteger scrollContentSizeHeight = scrollView.contentSize.height; //內容總高度
    NSInteger scrollOffset = scrollView.contentOffset.y; //從內容高度底部開始算y offset
    NSInteger bottomInset = scrollView.contentInset.bottom;
    NSInteger scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight;
    [self scrollYOffset:scrollOffset bottomOffset:scrollViewBottomOffset];

}

-(void)scrollYOffset:(NSInteger)scrollOffset bottomOffset:(NSInteger)scrollViewBottomOffset
{
    //NSLog(@"scrollOffset == %ld, scrollViewBottomOffset == %ld", (long)scrollOffset, (long)scrollViewBottomOffset);
    if (scrollOffset == scrollViewBottomOffset)
    {
        if ([[[NSDefaultArea GetWhichViewKeywordFromUserDefault] objectForKey:@"viewKeyword"] isEqualToString:@"GoToSearch"]) {
            if (self.totalPage >= self.currentPage) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                [self.containerController loadMore];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
        }
        if (self.totalPage >= self.currentPage && self.containerController.hasMore==YES) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self.containerController loadMore];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }
}

-(void)updateProductList:(NSArray *)productList {
    self.productList = productList;
    [self.collectionView reloadData];
}


@end
