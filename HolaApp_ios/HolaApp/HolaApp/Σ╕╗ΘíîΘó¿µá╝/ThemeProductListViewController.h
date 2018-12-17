////
////  ThemeProductListViewController.h
////  HolaApp
////
////  Created by Joseph on 2015/4/9.
////  Copyright (c) 2015年 JimmyLiu. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//#import "ProductListContainerViewController.h"
//#import "ProductListCollectionViewController.h"
//
//// 繼承產品列表container
//@interface ThemeProductListViewController : ProductListContainerViewController<UIScrollViewDelegate>
//
//@property (strong,nonatomic)NSMutableArray *productDataSourceArray;
//
//@property (nonatomic)NSInteger themeID;
//// label
//@property (weak, nonatomic) IBOutlet UILabel *themeTitle;
//@property (weak, nonatomic) IBOutlet UILabel *themeDescription;
//
//// view
//@property (weak, nonatomic) IBOutlet UIImageView *themePic;
//@property (weak, nonatomic) IBOutlet UIView *showCollectionView;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//
//// button
//@property (weak, nonatomic) IBOutlet UIButton *searchMore;
//
//
//// layout height constraint -> 經由觸發事件 變高 or 變低
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *whiteLineHeightConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerHeightConstraint;
//
//@end
