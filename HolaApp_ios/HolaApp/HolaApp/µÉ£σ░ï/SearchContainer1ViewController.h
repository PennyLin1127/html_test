//
//  SearchContainer1ViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/4/1.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

@interface SearchContainer1ViewController : NavigationViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong,nonatomic) NSMutableArray *saveSearchWords; //2015-04-30 這個物件誤地是?
@property (strong,nonatomic) NSMutableArray *saveAllSearchWords;
@property (nonatomic) BOOL focusOnSearchBarAtStart;//進入畫面則直接Focus搜尋框


//從AppDelegate進來
//@property (nonatomic) BOOL needAutoSearch;
//@property (strong, nonatomic) NSString *searchText;

/*
 UISearchController for iOS8 , 目前還沒有storyboard 元件可拉 ,所以先用code方式產生,
 這邊先指定UISearchBar的 outlet給他
 self.searchController.searchBar.frame=self.searchBAr.frame;
 */


@end
