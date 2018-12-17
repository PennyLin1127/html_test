//
//  CompareViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/15.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
#import "CompareCollectionViewController.h"
#import "CompareListDelegate.h"
#import "CompareTableViewController.h"
@class CompareCollectionViewController;
@class CompareTableViewController;

@interface CompareViewController : NavigationViewController <ProductCompareDelegate>
/*
Compare API 需要prdIds＆sessionID，prdIds資料由ProductListCollectionViewController取得
CompareViewController 作為一個container容器去裝collectionView horizontally ,非同步post做在
CompareCollectionViewController
*/

@property (weak, nonatomic) IBOutlet UIButton *editOrder;

@property (weak, nonatomic) IBOutlet UIView *showCompareVC;
@property (strong,nonatomic) __block NSArray *productList;

@property (strong,nonatomic)CompareCollectionViewController *compareCollectionViewController;
@property (strong,nonatomic)CompareTableViewController *compareTableViewController;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightCons;

@end
