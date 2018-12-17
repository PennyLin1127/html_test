//
//  ProductListDelegate.h
//  HOLA
//
//  Created by Henry on 2015/5/3.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ProductDelegate
@required
-(void)productSelected:(NSString *)productID SKU:(NSString*)skuStr;
@end


@interface ProductListDelegate : NSObject

@end
