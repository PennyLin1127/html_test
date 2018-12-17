//
//  NewsCategoryListViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/14.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

@interface NewsCategoryListViewController : NavigationViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) NSArray *arrayData;

@property (nonatomic) BOOL isLife1;

@end
