//
//  CatagoryInfoData.m
//  HolaApp
//
//  Created by Joseph on 2015/4/6.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CatagoryInfoData.h"

@implementation CatagoryInfoData

- (instancetype)initWithCategorysDic:(NSDictionary*)dic
{
    self=[super init];
    if (self) {
        NSString *parentCategoryId = [dic objectForKey:@"categoryId"];
        NSString *categoryName = [dic objectForKey:@"categoryName"];
        NSString *subCategorys = [dic objectForKey:@"subCategorys"];
        
        
        self.parentCategoryId =parentCategoryId !=nil ? parentCategoryId :@"";
        self.categoryName =categoryName !=nil ? categoryName :@"";
        self.subCategorys =subCategorys !=nil ? subCategorys :@"";
        
        
        
    }
    
    
    return self;
}





- (instancetype)initWithSubCategorysDic:(NSDictionary*)dic
{
    self=[super init];
    if (self) {
        
        NSString *subCategoryId = [dic objectForKey:@"subCategoryId"];
        NSString *subCategoryName = [dic objectForKey:@"subCategoryName"];

        self.subCategoryId=subCategoryId !=nil ? subCategoryId:@"";
        self.subCategoryName=subCategoryName !=nil ? subCategoryName:@"";
        
        
    }
    
    return self;
}




- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.parentCategoryId = [decoder decodeObjectForKey:@"parentCategoryId"];
        self.categoryName = [decoder decodeObjectForKey:@"categoryName"];
        self.subCategorys = [decoder decodeObjectForKey:@"subCategorys"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.parentCategoryId forKey:@"parentCategoryId"];
    [encoder encodeObject:self.categoryName forKey:@"categoryName"];
    [encoder encodeObject:self.subCategorys forKey:@"subCategorys"];
}



/*
 
 http://apidemo.i-house.com.tw/v1/goods/index
 
 
 parentCategoryId(api 傳入) = categoryId (api 吐回來)
 
 subCategoryId(api 傳入)  = categoryId (api 吐回來)
 
 
 */

@end
