//
//  CouponCategory.h
//  HOLA
//  折價券類別
//  Created by Henry on 2015/4/30.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CouponCategoryType)
{
    STORE_COUPON = 0, //門市折價券
    BOTH_COUPON = 1,//門市與線上共用
    EC_COUPON = 2 //線上折價券
    
};

@interface CouponCategory : NSObject
@property (nonatomic,strong) NSArray *couponList;
@property (nonatomic) CouponCategoryType categoryType;


@end
