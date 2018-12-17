//
//  SearchContainer2ViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/4/1.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductListContainerViewController.h"
#import "SearchContainer1ViewController.h"

typedef enum : NSUInteger {
    categoryFilter,
    conditionFilter,
    
} WhichFilter;


@class ProductListContainerViewController;
@interface SearchContainer2ViewController : ProductListContainerViewController
@property (weak, nonatomic) IBOutlet UIView *container2;


@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;//2015-05-01 Henry 加入
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong,nonatomic) NSMutableArray *mainCatagorysArray;

@property (assign,nonatomic)NSInteger tagForRow;
@property (nonatomic) BOOL focusOnSearchBarAtStart;//進入畫面則直接Focus搜尋框

@property (strong,nonatomic) NSMutableArray *saveAllSearchWords;
@property (strong,nonatomic)NSMutableArray *saveYouSearchWords;
@property (strong,nonatomic) NSMutableArray *saveSearchWords;


@property (assign,nonatomic)BOOL popToViewTagBOOL;

//從AppDelegate進來
@property (nonatomic) BOOL needAutoSearch;
@property (strong, nonatomic) NSString *searchText;

@property (assign,nonatomic)BOOL showTextTag;


@end

/*
UISearchController for iOS8 , 目前還沒有storyboard 元件可拉 ,所以先用code方式產生,
self.searchController1.searchBar.frame要用相對位置產生。
*/