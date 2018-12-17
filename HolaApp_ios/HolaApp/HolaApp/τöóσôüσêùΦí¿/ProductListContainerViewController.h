//
//  ProductListContainerViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/4.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//



#import "ViewController.h"
#import "NavigationViewController.h"
#import "SubProductCatalogueViewController.h"
#import "ProductListDelegate.h"
#import "ProductListContainerViewController.h"
#import "ProductListTableViewController.h"

/*
此container容器裡面裝了collectionView和tableView,API資料非同步POST的拿取是做在colletionView裡,資料的拿取都從colletionView取
*/

// Delegate for productListCollectionViewController scroll to top button (collection View)
@protocol ProductListContainerViewControllerDelegate <NSObject>

-(void)toTop;

@end

// Delegate for productListTableViewController scroll to top button (table view)
@protocol ProductListContainerViewControllerDelegate2 <NSObject>

-(void)toTop2;

@end


@class ProductListTableViewController;
@interface ProductListContainerViewController : NavigationViewController<ProductDelegate>

@property (strong,nonatomic) NSArray *productList;
@property (strong,nonatomic) NSArray *productCatagory;

// Set sub2ProductCatalogueTitle
@property (strong,nonatomic) NSString *titleName;
@property (weak, nonatomic) IBOutlet UIButton *sub2ProductCatalogueTitle;

// srollToTop button outlet
@property (weak, nonatomic) IBOutlet UIButton *scrolToTop;


@property(weak,nonatomic) id<ProductListContainerViewControllerDelegate> delegate;
@property(weak,nonatomic) id<ProductListContainerViewControllerDelegate2> delegate2;


@property (weak, nonatomic) IBOutlet UIView *showCollectionViewOrTableView;

@property (strong,nonatomic)ProductListCollectionViewController *productListCollectionViewController;
@property (strong,nonatomic)ProductListTableViewController *productListTableViewController;

//商品資訊Array 裡面是ProductInfoData物件
@property (strong,nonatomic) NSMutableArray *productInfoArray;
@property (strong,nonatomic) NSMutableArray *catagoryInfoArray;


@property (strong,nonatomic) NSNumber *totalCount;

@property (strong,nonatomic) NSMutableArray *AddArray;

//@property (strong,nonatomic) SearchContainer2ViewController *searchContainer2ViewController;


@property (strong,nonatomic)NSMutableArray *productIDs;

// for search get data
-(void)SyncGetData;
// for product list get data
-(void)SyncGetProductListData;
// for theme style get data
-(void)SyncGetProductCompareData ;


// for scrollToTop button
-(void)topButtonHideOrNot:(BOOL)topTag;

-(IBAction)list:(id)sender ;


-(void)loadMore ;


//傳入的商品分類
@property (strong,nonatomic) NSString *categoryID;

//傳入的搜尋關鍵字
@property (strong,nonatomic) NSString *keyword;
@property (assign,nonatomic) BOOL hasMore;



/*
 
ContainerVC 藉由showCollectionViewOrTableView UIView 裝了 CollectionView,TableView
裡頭的資料由containerVC 統一提供，裡面兩個VC有相同的 scrollToTop delegate need follow
 
*/


@end
