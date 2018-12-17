//
//  CompareCollectionViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/17.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompareViewController.h"
#import "ProductListCollectionViewController.h"
#import "CompareCollectionViewCell.h"
#import "CompareListDelegate.h"

@class CompareViewController;
@interface CompareCollectionViewController : UICollectionViewController

// get ProductListCollectionViewController data property
@property(strong,nonatomic) ProductListCollectionViewController *getCollectionVCData;
@property (strong,nonatomic)NSMutableArray *prdNameDataArray;
@property (strong,nonatomic)NSMutableArray *prdImgDataArray;
@property (strong,nonatomic)NSMutableArray *origPriceDataArray;
@property (strong,nonatomic)NSMutableArray *salePriceDataArray;
@property(strong,nonatomic)NSMutableArray  *prdFeatureDataArray;
@property(strong,nonatomic)NSMutableArray  *onShelfDataArray;
@property(strong,nonatomic)NSMutableArray *btnO2oCouponDataArray;
@property(strong,nonatomic)NSMutableArray *btnO2oCouponAvailableArray;
@property(strong,nonatomic)NSMutableArray *btnO2oCouponDiscountPrice;

@property(strong,nonatomic)NSMutableArray *prdHeight;
@property(strong,nonatomic)NSMutableArray *prdWidth;
@property(strong,nonatomic)NSMutableArray *prdDepth;

// access product detail
@property(strong,nonatomic)NSMutableArray *prdIdDataArray;
@property(strong,nonatomic)NSMutableDictionary *prdIdForProductDetail1;

// favoriteTag
@property(strong,nonatomic)NSMutableArray *myFavoriteTag;

// save o2o URL array
@property (strong,nonatomic)NSMutableArray *urlArray;


@property (strong,nonatomic)NSArray *productList;

// 設定列表內容只能按一次，之後push到內容
@property (assign,nonatomic) BOOL clickStatus;

@property (strong,nonatomic) CompareViewController *compareViewController;

-(void)updateProductList:(NSArray *)productList;

@property (nonatomic)  id <ProductCompareDelegate> delegate;

@end
