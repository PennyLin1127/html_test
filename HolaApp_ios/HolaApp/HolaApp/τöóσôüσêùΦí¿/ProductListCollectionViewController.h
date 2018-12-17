//
//  ProductListCollectionViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/5.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductListDelegate.h"

@class ProductListContainerViewController;

@interface ProductListCollectionViewController : UICollectionViewController

//產品清單
@property (strong,nonatomic) NSArray *productList;


// 給商品比較傳入API使用
@property (strong,nonatomic)NSMutableArray *prdIdsSelectedDataArray;

// 給商品比較已經下架的商品顯示用
@property (strong,nonatomic)NSMutableArray *SavePrdImgDataArray;
@property (strong,nonatomic)NSMutableArray *SavePrdNameDataArray;

@property(strong,nonatomic)NSMutableArray *SaveBtnO2oCouponAavilableArray;


// 去存取 scroll to top 在 ProductListContainerViewController 的 delegate
@property (strong,nonatomic) ProductListContainerViewController *containerController;

@property (strong,nonatomic) NSMutableArray *productIDs;



@property(retain,nonatomic) NSNumber *page;
@property(assign,nonatomic) int pagePlus;
@property(nonatomic) NSInteger currentPage;
@property(nonatomic) NSInteger totalPage;

-(void)DidSelectButton:(UIButton*)sender;
-(void)asyncPostDetailContext:(NSString*)httpClientURL path:(NSString*)BasePath dicBody:(NSDictionary*)dicBody;


-(void)updateProductList:(NSArray *)productList;
-(void)scrollToTop;

// 按某個cell跳到內容頁，由container去執行delegate method
@property (nonatomic)  id <ProductDelegate> delegate;
/*
 資料來源都來自container,詳細資料內容用之前抓API的方法
*/


@end
