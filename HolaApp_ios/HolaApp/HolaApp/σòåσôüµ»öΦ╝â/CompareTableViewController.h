//
//  CompareTableViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/20.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ViewController.h"
#import "CompareCollectionViewController.h"

@class CompareCollectionViewController;
@interface CompareTableViewController : ViewController
@property (strong,nonatomic) CompareCollectionViewController *compareCollectionViewController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSArray *productList;
@property (strong, nonatomic)   NSMutableArray *productMuArray1;
-(void)updateProductList:(NSArray *)productList ;
@end
