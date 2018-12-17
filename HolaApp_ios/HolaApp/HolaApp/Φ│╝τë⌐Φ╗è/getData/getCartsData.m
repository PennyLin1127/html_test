//
//  getCartsData.m
//  HOLA
//
//  Created by Joseph on 2015/9/21.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "getCartsData.h"
#import "GetAndPostAPI.h"
#import "IHouseURLManager.h"
#import "SessionID.h"

@implementation getCartsData

-(void)getDataViaAPI:(NSArray*)skuArray{
    getCartsData *this=self;
    GetAndPostAPI *getAndPostAPI=[[GetAndPostAPI alloc]init];
    getAndPostAPI.loadCompletionBlock=^(BOOL success,NSDictionary *dicData){
        BOOL status = [[dicData objectForKey:@"status"] integerValue];
        if (status == NO) {
            this.failBlock([dicData objectForKey:@"msg"]);
        } else {
            this.completeBlock([dicData objectForKey:@"msg"],dicData);
        }
    };
    NSString *holaURL = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:@""]];
    NSDictionary *dicBody=@{@"sessionId":[SessionID getSessionID],@"skus":skuArray};
    
    [getAndPostAPI asyncPostData:holaURL path:ADD_CART dicBody:dicBody];
    
}

-(void)reloadCartsNum{
    getCartsData *this=self;
    GetAndPostAPI *getAndPostAPI=[[GetAndPostAPI alloc]init];
    getAndPostAPI.loadCompletionBlock=^(BOOL success,NSDictionary *dicData){
        BOOL status = [[dicData objectForKey:@"status"] integerValue];
        if (status == NO) {
            this.failBlock([dicData objectForKey:@"msg"]);
        } else {
            this.completeBlock([dicData objectForKey:@"msg"],dicData);
        }
    };
    NSString *holaURL = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:@""]];
    NSDictionary *dicBody=@{@"sessionId":[SessionID getSessionID]};
    
    [getAndPostAPI asyncPostData:holaURL path:HOLA_CART_DELETE dicBody:dicBody];
    
}


@end
