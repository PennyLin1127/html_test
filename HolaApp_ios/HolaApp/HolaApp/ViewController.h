//
//  ViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/2/2.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

@interface ViewController : NavigationViewController <UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong,nonatomic) NSMutableArray *sliderPicArray;
@property (strong,nonatomic) NSMutableArray *saveSkuArray;

@property (weak, nonatomic) IBOutlet UIButton *news;
@property (weak, nonatomic) IBOutlet UIButton *product;
@property (weak, nonatomic) IBOutlet UIButton *catagory;
@property (weak, nonatomic) IBOutlet UIButton *member;
@property (weak, nonatomic) IBOutlet UIButton *coupon;
@property (weak, nonatomic) IBOutlet UIButton *life;

@end

