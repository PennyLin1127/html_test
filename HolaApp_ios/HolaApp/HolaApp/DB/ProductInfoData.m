//
//  ProductInfoData.m
//  HolaApp
//
//  Created by Joseph on 2015/4/2.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ProductInfoData.h"

@implementation ProductInfoData

//初始化方法
+(ProductInfoData *)initWithDictionary:(NSDictionary *)dict {
    
    ProductInfoData *product = [ProductInfoData new];
    product.prdId = [NSString stringWithFormat:@"%@",[dict objectForKey:@"prdId"]];
    product.prdName = [NSString stringWithFormat:@"%@",[dict objectForKey:@"prdName"]];
    
    if ([dict objectForKey:@"prdImg"] != nil) {
        product.prdImg = [NSString stringWithFormat:@"%@",[dict objectForKey:@"prdImg"]];
    }
    
    if ([dict objectForKey:@"origPrice"] != nil) {
        product.origPrice = [[dict objectForKey:@"origPrice"] integerValue];
    }
    if ([dict objectForKey:@"salePrice"] != nil) {
        product.salePrice = [[dict objectForKey:@"salePrice"] integerValue];
    }
    if ([dict objectForKey:@"onShelf"] != nil) {
        product.onShelf = [[dict objectForKey:@"onShelf"] boolValue];
    }
    
    
    if ([dict objectForKey:@"btnO2oCoupon"] != nil) {
        NSDictionary *o2oDict = [dict objectForKey:@"btnO2oCoupon"];
        if ([o2oDict objectForKey:@"available"] != nil) {
            product.available = [[o2oDict objectForKey:@"available"] boolValue];
        }
        if ([o2oDict objectForKey:@"discountPrice"] != nil) {
//            2015-05-03 Henry API 為何會有null?
            if ([o2oDict objectForKey:@"discountPrice"] != [NSNull null]) {
               product.discountPrice = [[o2oDict objectForKey:@"discountPrice"] integerValue];
            }
            
        }
        if ([o2oDict objectForKey:@"url"] != nil) {
            product.url = [NSString stringWithFormat:@"%@",[o2oDict objectForKey:@"url"]];
        }
    }
    
    
    
    
    if ([dict objectForKey:@"prdHeight"] !=nil) {
        product.prdHeight=[dict objectForKey:@"prdHeight"];
    }
    
    if ([dict objectForKey:@"prdWidth"] !=nil) {
        product.prdWidth=[dict objectForKey:@"prdWidth"];
    }
    
    if ([dict objectForKey:@"prdDepth"] !=nil) {
        product.prdDepth=[dict objectForKey:@"prdDepth"];
    }
    
    
    if ([dict objectForKey:@"sku"] !=nil) {
        product.sku=[dict objectForKey:@"sku"];
    }
    
    product.isSelected = NO;
    
    return product;
}

////init method
//- (instancetype)initWithDic2:(NSDictionary*)dic
//{
//    self = [super init];
//    if (self) {
//        NSString *prdId = [dic objectForKey:@"prdId"];
//        NSString *prdName = [dic objectForKey:@"prdName"];;
//        NSString *prdImg = [dic objectForKey:@"prdImg"];;
//        NSString *origPrice = [dic objectForKey:@"origPrice"];;
//        NSString *salePrice = [dic objectForKey:@"salePrice"];;
//        
//        NSString *available = [dic objectForKey:@"available"];;
//        NSString *discountPrice = [dic objectForKey:@"discountPrice"];;
//        NSString *url = [dic objectForKey:@"url"];;
//        
//        NSString *page=[dic objectForKey:@"page"];
//        NSString *totalPage=[dic objectForKey:@"totalPage"];
//        
//        BOOL onShelf =[[dic objectForKey:@"onShelf"] boolValue];
//        
//        self.prdId = prdId !=nil ? prdId: @"";
//        self.prdName = prdName != nil ? prdName : @"";
//        self.prdImg = prdImg != nil ? prdImg : @"";
//        self.origPrice = origPrice != nil ? origPrice: @"";
//        self.salePrice = salePrice != nil ? salePrice: @"";
//        self.available = available != nil ? available : @"";
//        self.discountPrice = discountPrice != nil ? discountPrice : @"";
//        self.url = url != nil ? url : @"";
//        self.hasBeenClicked = NO; //預設沒有被按過
//        
//        self.onShelf = onShelf;
//        
//        //        self.page = page !=nil ? page :@"";
//        //        self.totalPage = totalPage !=nil ? totalPage :@"";
//    }
//    return self;
//}

@end
