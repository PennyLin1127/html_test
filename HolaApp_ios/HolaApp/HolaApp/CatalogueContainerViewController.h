//
//  CatalogueContainerViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
@interface CatalogueContainerViewController : NavigationViewController

@property (nonatomic, strong) NSDictionary *dicData;
@property (nonatomic, strong) NSArray *dicArray;
@property (strong, nonatomic) NSString *strDate;
@property (strong, nonatomic) NSString *endDate;
@property (strong, nonatomic) NSArray *dicArrayList;

@end
