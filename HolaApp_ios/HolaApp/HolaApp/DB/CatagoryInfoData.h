//
//  CatagoryInfoData.h
//  HolaApp
//
//  Created by Joseph on 2015/4/6.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatagoryInfoData : NSObject<NSCoding>


//catagory
@property (nonatomic, strong) NSString *parentCategoryId;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *subCategorys;


//
@property (nonatomic,strong) NSMutableArray *subTitle;


//
@property (nonatomic, strong) NSString *subCategoryId;
@property (nonatomic, strong) NSString *subCategoryName;


//初始化方法
- (instancetype)initWithCategorysDic:(NSDictionary*)dic;
- (instancetype)initWithSubCategorysDic:(NSDictionary*)dic;


/*
因為存了自行定義的物件在NSDefault，NSDefault無法加入，所以需要加入NSCoding protocol
所以寫了 initWithCoder，encodeWithCoder方法
 http://blog.soff.es/archiving-objective-c-objects-with-nscoding/
*/


@end
