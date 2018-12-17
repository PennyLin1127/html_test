//
//  ProductInfoData.h
//  HolaApp
//
//  Created by Joseph on 2015/4/2.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductInfoData : NSObject


//基本資料
@property (nonatomic, strong) NSString *prdId;
@property (nonatomic, strong) NSString *sku;
@property (nonatomic, strong) NSString *prdName;
@property (nonatomic, strong) NSString *prdImg;
@property (nonatomic) NSInteger origPrice;
@property (nonatomic) NSInteger salePrice;
@property (nonatomic) NSInteger discountPrice;

@property(strong,nonatomic)NSString *prdHeight;
@property(strong,nonatomic)NSString *prdWidth;
@property (strong,nonatomic)NSString *prdDepth;


//@property (nonatomic) NSInteger o2oPrice;

//btnO2oCoupon info
@property (nonatomic) BOOL available;

//是否被選取
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) NSString *url;


////頁數
//@property (nonatomic,strong) NSString *page;
//@property (nonatomic,strong) NSString *totalPage;


//其他
//@property (nonatomic) BOOL hasBeenClicked; // 已經被按下按鈕

// 下架
@property (nonatomic) BOOL onShelf;


//初始化方法
+(ProductInfoData *)initWithDictionary:(NSDictionary*)dict;

@end
