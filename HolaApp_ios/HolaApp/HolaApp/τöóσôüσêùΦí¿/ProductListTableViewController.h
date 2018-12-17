//
//  ProductListTableViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/10.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ViewController.h"
#import "ProductListCollectionViewController.h"
#import "ProductListDelegate.h"

#import "ProductListContainerViewController.h"

@interface ProductListTableViewController : UIViewController

// 去存取 ProductListCollectionViewController.h 裡的 property(用property存取property)
@property (strong,nonatomic) ProductListCollectionViewController *getProductListCollectionViewController;

// 去存取 scroll to top 在 ProductListContainerViewController 的 delegate
@property(strong,nonatomic) ProductListContainerViewController *containerController2;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *productList;
-(void)updateProductList:(NSArray *)productList;

@property (nonatomic)  id <ProductDelegate> delegate;

@property(nonatomic) NSInteger currentPage;
@property(nonatomic) NSInteger totalPage;

@property (strong,nonatomic)NSMutableArray *productIDs;

@end


/*
 資料來源都來自container,詳細資料內容用之前抓API的方法
*/
