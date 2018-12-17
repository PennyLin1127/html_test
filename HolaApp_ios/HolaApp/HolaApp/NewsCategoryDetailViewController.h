//
//  NewsCategoryDetailViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/14.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

@interface NewsCategoryDetailViewController : NavigationViewController

@property (nonatomic, strong) NSDictionary *dicData;
@property (nonatomic) BOOL isLife2;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@end
