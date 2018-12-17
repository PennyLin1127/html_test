//
//  NewsCategoryContainerViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/14.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

@interface NewsCategoryContainerViewController : NavigationViewController <UIScrollViewDelegate>

//導向特定分類使用
@property (nonatomic)  BOOL needToGoSpecialCategory;
@property (nonatomic) NSString *specialCategory;
@end
