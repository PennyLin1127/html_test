//
//  getCartsData.h
//  HOLA
//
//  Created by Joseph on 2015/9/21.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getCartsData : NSObject

typedef void(^completeBlock)(NSString *msg,NSDictionary *dicData);
typedef void(^failBlock)(NSString *msg);
@property (strong,nonatomic)completeBlock completeBlock;
@property (strong,nonatomic)failBlock failBlock;

-(void)getDataViaAPI:(NSArray*)skuArray;
-(void)reloadCartsNum;

@end
