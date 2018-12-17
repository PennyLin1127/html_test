//
//  ProductContentViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/21.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
#import "ProductListContainerViewController.h"
#import "ProductListCollectionViewController.h"
@interface ProductContentViewController : NavigationViewController <UIScrollViewDelegate>
/* pushVC from ProductListCollectionViewController container's navigation Controller
*/

@property (strong,nonatomic) ProductListContainerViewController *ProductListContainerVC;
@property(strong,nonatomic)  ProductListCollectionViewController *ProductListCollectionVC;

//產品ID
@property (strong,nonatomic) NSString *productID;
//產品SKU
@property (strong,nonatomic) NSString *productSKU;


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong,nonatomic) NSString *prdId;
@property (weak, nonatomic) IBOutlet UILabel *prdName;

@property (weak, nonatomic) IBOutlet UILabel *origPrice;
@property (weak, nonatomic) IBOutlet UILabel *salePrice;
@property (weak, nonatomic) IBOutlet UILabel *o2oDiscountPrice;

@property (weak, nonatomic) IBOutlet UIButton *o2oCouponButton;
@property (weak, nonatomic) IBOutlet UIButton *webShoppingButton;
@property (weak, nonatomic) IBOutlet UITextView *productDescription;

@property (strong,nonatomic) NSMutableArray *picArray;
@property (strong,nonatomic) NSMutableArray *recommendArray;



//存取prdId for recommend product
@property (strong,nonatomic)NSMutableDictionary *recommendPrdIdDataMuDic;

//存取btnO2oCoupon內url
@property(strong,nonatomic)NSMutableDictionary *urlDic;

//存取收藏清單
@property(strong,nonatomic)NSMutableArray *myFavoriteList;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *disccountConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webShopping;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gapConstraint;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewConstraintHeight;


@property (strong,nonatomic)NSString *sku;

@end
