//
//  ThemeProductListCollectionViewController.h
//  HOLA
//
//  Created by Joseph on 2015/4/28.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
#import "ThemeCollectionReusableView.h"



@interface ThemeProductListCollectionViewController : NavigationViewController

@property (nonatomic) NSInteger themeID;

// 按鈕選取狀態
@property (strong,nonatomic)NSMutableArray *clickButtonStatus;

//商品資訊Array 裡面是ProductInfoData物件
@property (strong,nonatomic) NSArray *productList;


// 設定列表內容只能按一次，之後push到內容
@property (assign,nonatomic) BOOL clickStatus;


// for product detail API 存取prdId (只存一個prdId)
@property (strong,nonatomic)NSMutableDictionary *prdIdForProductDetail1;


// 給商品比較傳入API使用
@property (strong,nonatomic)NSMutableArray *prdIdsSelectedDataArray;


// 給商品比較已經下架的商品顯示用
@property (strong,nonatomic)NSMutableArray *SavePrdImgDataArray;
@property (strong,nonatomic)NSMutableArray *SavePrdNameDataArray;


@property (strong,nonatomic)NSMutableArray *prdIdDataArray;


@property (strong,nonatomic)NSMutableArray *productDataSourceArray;


@property(retain,nonatomic) NSNumber *page;
@property (strong,nonatomic) NSMutableArray *AddArray;
@property (strong,nonatomic) NSNumber *totalCount;

@property (strong,nonatomic) ThemeCollectionReusableView *supplementaryViewFooter;

@property(strong,nonatomic)NSMutableArray *productIDs;

@end
