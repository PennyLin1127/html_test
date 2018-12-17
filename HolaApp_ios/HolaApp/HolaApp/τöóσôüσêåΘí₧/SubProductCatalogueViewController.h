//
//  SubProductCatalogueViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/3.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ViewController.h"
#import "NavigationViewController.h"

@interface SubProductCatalogueViewController : NavigationViewController

//分類物件
@property (strong,nonatomic) NSArray *subProductCatalogueArray;

// Save categoryId to Array
@property(strong,nonatomic)NSArray *categoryIdArray;

// Set subProductCatalogueTitle
@property (weak, nonatomic) IBOutlet UILabel *subProductCatalogueTitle;
@property (strong,nonatomic) NSString *titleName;

@property (strong,nonatomic) NSString *categoryID;

// Product Catalogue裡的第二層array
@property(strong,nonatomic) NSArray *sub2ProductCatalogueArray;

@end
