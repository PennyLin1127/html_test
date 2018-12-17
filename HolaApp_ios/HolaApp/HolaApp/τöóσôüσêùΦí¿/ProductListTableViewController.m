//
//  ProductListTableViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/10.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ProductListTableViewController.h"
#import "ProductListTableViewCell.h"
#import "SessionID.h"
#import "NSDefaultArea.h"
#import "URLib.h"
#import "ProductContentViewController.h"
#import "AFNetworking.h"
#import "AES.h"
#import "GetAndPostAPI.h"
#import "ProductInfoData.h"
#import "AsyncImageView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface ProductListTableViewController ()<UITableViewDataSource,UITableViewDelegate,ProductListContainerViewControllerDelegate2>
{
    GetAndPostAPI *getProductList;
    MBProgressHUD  *progressHUD;
}

@end

@implementation ProductListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    //註冊 ProductListTableViewController
    [self.tableView registerNib:[UINib nibWithNibName:@"ProductListTableViewCell" bundle:nil] forCellReuseIdentifier:@"DefaultTableViewCell"];

    // set scroll to top delegate
    self.containerController2.delegate2=self;
    
    self.productIDs=[[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.productList count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   //contect view 高度這邊設110 背景與背景色一樣 , 裡面的cellView 高度設100,白色圓角
    return 110;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{   // 底部有商品比較跟收藏清單高度，所以設 footer高度
    return 135;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{   // 因有上層有title高度，所以微調header高度
    //    return 15.0f;
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor =[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor =[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier=@"DefaultTableViewCell";
    ProductListTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    // cell 外觀
    [cell.cellView.layer setCornerRadius:10.0f];
    
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f]];
    
    ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];
    
    cell.prdNameLabel1.text=product.prdName;
    // 產品圖
    
    NSURL *url1 =nil;
    cell.prdImge1.imageURL = url1;
    [cell.prdImge1 setShowActivityIndicator:YES];
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.prdImge1.imageURL];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOLA_PIC_URL_STR, product.prdImg]];
    cell.prdImge1.imageURL = url;
    
    // 價錢
    cell.origPriceLabel1.text=[NSString stringWithFormat:@"售價 $%ld",product.origPrice];
    cell.salePriceLabel1.text=[NSString stringWithFormat:@"網購價 $%ld",product.salePrice];
    
    // set image and button action in selectButton outlet
    if (product.isSelected) {
        // 選取
        [cell.clickButton setImage:[UIImage imageNamed:@"Compare_2"] forState:UIControlStateNormal];
    }else {
        // 無選取
        [cell.clickButton setImage:[UIImage imageNamed:@"Compare_1"] forState:UIControlStateNormal];
    }
    
    cell.clickButton.tag = indexPath.row;
    [cell.clickButton addTarget:self action:@selector(DidSelectButton1:)forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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


#pragma mark - DidSelectButton1

- (void)DidSelectButton1:(UIButton*)sender {
    NSLog(@"DidSelectButton1");
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
        
        NSString *err = @"您最多選擇比較六件商品";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:err delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }
    

}


#pragma mark - scroll to top Delegate

-(void)toTop2{
    [self.containerController2 topButtonHideOrNot:NO];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - scrollViewDidScroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint origin = [scrollView contentOffset];
    [scrollView setContentOffset:CGPointMake(0.0, origin.y)];
    
    if ([scrollView.panGestureRecognizer translationInView:scrollView].y >= 0)
    {
        if(origin.y<350){
            [self.containerController2 topButtonHideOrNot:NO];
        }
        
    }
    else
    {
        if(origin.y>350){
            
            [self.containerController2 topButtonHideOrNot:YES];
            
        }
    }
    
    
    // 偵測滑到底部
    CGFloat scrollViewHeight = scrollView.bounds.size.height; // 內容高度
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height; //內容總高度
    CGFloat scrollOffset = scrollView.contentOffset.y; //從內容高度底部開始算y offset
    CGFloat bottomInset = scrollView.contentInset.bottom;
    CGFloat scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight;
    
    if (scrollOffset == scrollViewBottomOffset)
    {
        if ([[[NSDefaultArea GetWhichViewKeywordFromUserDefault] objectForKey:@"viewKeyword"] isEqualToString:@"GoToSearch"]) {

        if (self.totalPage >= self.currentPage) {
            
            [self.containerController2 loadMore];
        }
        }
        if (self.totalPage >= self.currentPage && self.containerController2.hasMore==YES) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self.containerController2 loadMore];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }
}

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
    
    progressHUD.removeFromSuperViewOnHide = YES;
    [progressHUD show:YES];
}

-(void)updateProductList:(NSArray *)productList {
    self.productList = productList;
    [self.tableView reloadData];
}



@end
