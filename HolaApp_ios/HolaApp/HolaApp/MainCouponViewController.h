//
//  MainCouponViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/13.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

typedef enum : NSUInteger {
    CouponTypeTakeCoupon,     // 折價卷索取頁面
    CouponTypeMyCoupon,       // 我的折價卷頁面
} CouponType;

@interface MainCouponViewController : NavigationViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (nonatomic) BOOL goToMyCoupon;

@end
