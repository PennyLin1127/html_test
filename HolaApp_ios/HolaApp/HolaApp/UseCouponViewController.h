//
//  UseCouponViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/14.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CouponDetailViewController.h"

typedef void (^FinishCallBack)();

@interface UseCouponViewController : UIViewController

@property (nonatomic) NSInteger useCount;

@property (nonatomic, strong) NSDictionary *dicData;

@property (nonatomic) BOOL isForStore; //  使用User的API

@property (copy) FinishCallBack finishCallBack;

@end
