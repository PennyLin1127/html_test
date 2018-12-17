//
//  CompareCollectionViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/17.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CompareCollectionViewController.h"
#import "CompareCollectionViewCell.h"
#import "URLib.h"
#import "SessionID.h"
#import "AFNetworking.h"
#import "NSDefaultArea.h"
#import "AES.h"
#import "GetAndPostAPI.h"
#import "Model.h"
#import "ProductContentViewController.h"
#import "CompareWebViewController.h"
#import "ProductInfoData.h"
#import "AsyncImageView.h"
#import "CompareViewController.h"
#import "getCartsData.h"

@interface CompareCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ProductCompareDelegate>
{
    MBProgressHUD  *progressHUD;
    NSDictionary *productCompareDic;
    CompareCollectionViewController *compareCollectionViewController;
    CompareViewController *CVC;
    BOOL LVStatus;
    CGSize collectionVCell;
    CGRect cellRect;
    
    
}

@property (strong,nonatomic)NSMutableArray *outOfStockPrdFeature;
@property (strong,nonatomic)NSMutableArray *btnO2oCouponAvailableOrNotArray;




@end

@implementation CompareCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    // 設定列表內容只能按一次，之後push到內容之後再給他tag
    self.clickStatus=YES;
}

- (void)addMyFavoriteList:(id)sender {
    
    
    UIButton *button=sender;
    [button setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    
    ProductInfoData *product = [self.productList objectAtIndex:button.tag];

    //加入我的最愛清單
    [Model addToFavoriteList:@[product.prdId]];
    
}

-(void)addMyCarts:(id)sender{
    UIButton *button=sender;
    ProductInfoData *product = [self.productList objectAtIndex:button.tag];
    NSArray *skuArray=[NSArray arrayWithObjects:product.sku, nil];
    [self addToCarts:skuArray];
    UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:@"已加入購物車" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
    [av show];
    
}

-(void)addToCarts:(NSArray*)skuArray {
    
    getCartsData *_getCartsData=[[getCartsData alloc]init];
    _getCartsData.completeBlock=^(NSString *msg,NSDictionary *dicData){
        
        BOOL status=[[dicData objectForKey:@"status"]integerValue];
        
        if (status) {
            // 為購物車數目
            NSNumber *cartNums=[[dicData objectForKey:@"data"]objectForKey:@"cartNums"];
            [[NavigationViewController currentInstance] reflashMyCarts:[cartNums stringValue]];

        }else{
            UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
            [av show];
        }
    };
    
    [_getCartsData getDataViaAPI:skuArray];
    
}



- (void)getO2oDiscount:(id)sender {
    
    UIButton *button=sender;
    
    ProductInfoData *product = [self.productList objectAtIndex:button.tag];
    NSString *urlStr=product.url;
//    NSString *urlStr=[[NSDefaultArea GetBtoURLArrayFromUserDefault]objectAtIndex:button.tag];
    NSDictionary *urlDic= @{@"btoURL": urlStr};
    [NSDefaultArea btoURLToUserDefault:urlDic ];
    
    
    // pushVC from container's navigation Controller
    UIStoryboard *compareSB=[UIStoryboard storyboardWithName:@"Compare" bundle:nil];
    
    CompareWebViewController *vc=[compareSB instantiateViewControllerWithIdentifier:@"webView"];
    [self.compareViewController.navigationController pushViewController:vc animated:YES];
    
}

-(void)geto2oDiscountButtonTag{
    
    
}


-(void)updateProductList:(NSArray *)productList {
    NSLog(@"productList count %lu",(unsigned long)productList.count);
    self.productList = productList;
    
    [self.collectionView reloadData];
}

#pragma mark - CollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"prdNameDataArray count %lu",(unsigned long)self.productList.count);
    if (self.productList != nil) {
        return [self.productList count];
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify=@"Cell";
    CompareCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    if ([self.productList count]>0) {
        // Configure the cell
        if (cell == nil) {
            cell = [[CompareCollectionViewCell alloc] initWithFrame:cellRect];
            NSLog(@"cellRect -- %@", NSStringFromCGRect(cellRect));
        }
        
        ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];
        
        cell.prdName.text=product.prdName;
//        NSLog(@"%@", product.prdName);
        
        NSURL *url1 =nil;
        cell.prdImg.imageURL = url1;
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.prdImg.imageURL];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOLA_PIC_URL_STR, product.prdImg]];
        [cell.prdImg setImageURL:url];
        
        
        cell.heigh.text=[NSString stringWithFormat:@"高:%@ (公分)",product.prdHeight];
        cell.width.text=[NSString stringWithFormat:@"寬:%@ (公分)",product.prdWidth];
        cell.deep.text=[NSString stringWithFormat:@"深:%@ (公分)",product.prdDepth];
        
        
        cell.origPrice.text=[NSString stringWithFormat:@"售價$%ld",product.origPrice];
        cell.salePrice.text=[NSString stringWithFormat:@"網購價$%ld",product.salePrice];
        
        
        //設定b2oCoupon tag for url purpose
        cell.btnO2oCouponAvailable.tag=indexPath.row;
        [cell.btnO2oCouponAvailable addTarget:self action:@selector(getO2oDiscount:) forControlEvents:UIControlEventTouchUpInside];
        
        //設定愛心按鈕出現於否
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSArray *favoriteArray=[NSArray arrayWithArray:[defaults objectForKey:@"FavoriteList"]];
        
        if ([favoriteArray containsObject:product.prdId]) {
            [cell.MyfavoriteButton setImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
        }else
        {
            [cell.MyfavoriteButton setImage:[UIImage imageNamed:@"heart_1"] forState:UIControlStateNormal];
        }
        
        
        //設定愛心按鈕觸發事件
        cell.MyfavoriteButton.tag=indexPath.row;
        LVStatus=YES;
        [cell.MyfavoriteButton addTarget:self action:@selector(addMyFavoriteList:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //加入購物車
        cell.addCarts.tag=indexPath.row;
        [cell.addCarts addTarget:self action:@selector(addMyCarts:) forControlEvents:UIControlEventTouchUpInside];
        
        //以有無btnO2oCouponAvailable來判斷顯示內容
        if (product.available) {
            [cell.btnO2oCouponAvailable setHidden:NO];
            [cell.MyfavoriteButton setHidden:NO];
            [cell.outLine setHidden:NO];
            [cell.btnPriceTextLabel setHidden:NO];
            cell.btnPriceTextLabel.text=[NSString stringWithFormat:@"只要$ %ld",(long)product.discountPrice];
        }else
        {
            [cell.btnO2oCouponAvailable setHidden:YES];
            [cell.outLine setHidden:YES];
            [cell.btnPriceTextLabel setHidden:YES];
        }
        
        
    }
    
    [cell.layer setCornerRadius:5.0f];
    
    // 客制iphone4 size
    int iphoneSize=[[UIScreen mainScreen ]bounds].size.height;
    if (iphoneSize==480) {
        //title
        cell.titleLabelHeightcons.constant=30.0f;
        [cell.prdName setFont:[UIFont boldSystemFontOfSize:14.0f]];
        //商品尺寸
        cell.sizeLableHeightCons.constant=11.0f;
        cell.sizeLabelGapHeighCons.constant=4.0f;
        cell.sizeLabelGapHeigh2.constant=0.0f;
        [cell.sizeLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        //size
        [cell.heigh setFont:[UIFont systemFontOfSize:10.0f]];
        [cell.width setFont:[UIFont systemFontOfSize:10.0f]];
        [cell.deep setFont:[UIFont systemFontOfSize:10.0f]];
        cell.sizeLableHeightCons.constant=11.0f;
        cell.sizeWidthCons.constant=11.0f;
        cell.sizeDeepCons.constant=11.0f;
        cell.deepGapCons.constant=4.0f;
        cell.widthCap.constant=2.0f;
        //price
        [cell.origPrice setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [cell.salePrice setFont:[UIFont boldSystemFontOfSize:12.0f]];
        cell.salePriceGap.constant=4.0f;
        //favorite
        cell.myFavoriteGap.constant=4.0f;
//        cell.myFavoriteButtonHeighCons.constant=23.0f;
        //coupon
        cell.couponHeightCons.constant=18.0f;
        cell.framHeightCons.constant=30.0f;
        [cell.btnPriceTextLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
        cell.justGap.constant=-50.0f;
    }
    
    return cell;
}


#pragma mark - CollectionView Delegate

// called when the user taps on an already-selected item in multi-select mode
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
 
        
    ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];
    
    if (self.delegate) {
        [self.delegate productSelected:product.prdId];
    }
    
}



#pragma mark - cell size
// controll cell size via itemSize property
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    int iphoneSize=[[UIScreen mainScreen ]bounds].size.height;
    
    // for iphone 4
    if (iphoneSize==480) {
        
        CGRect rect=self.view.frame;
        NSLog(@"self.view.frame2 -- %@", NSStringFromCGRect(rect));
        cellRect = CGRectMake(0, 0, (rect.size.width/2)*0.9, (rect.size.width/2)*2.3);
        //    cellRect = CGRectMake(0, 0, (rect.size.width/2)*0.9,rect1.size.height-150);
        
        NSLog(@"rect2 %@",NSStringFromCGRect(cellRect));
        
        return cellRect.size;
        
    }else{
    
    CGRect rect=self.view.frame;
    NSLog(@"self.view.frame2 -- %@", NSStringFromCGRect(rect));
    cellRect = CGRectMake(0, 0, (rect.size.width/2)*0.9, (rect.size.width/2)*2.8);
//    cellRect = CGRectMake(0, 0, (rect.size.width/2)*0.9,rect1.size.height-150);

    NSLog(@"rect2 %@",NSStringFromCGRect(cellRect));
    
    return cellRect.size;
    
    }
    return cellRect.size;
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
    //    progressHUD.yOffset = -100.0f;
    
    progressHUD.removeFromSuperViewOnHide = YES;
    [progressHUD show:YES];
}


@end
