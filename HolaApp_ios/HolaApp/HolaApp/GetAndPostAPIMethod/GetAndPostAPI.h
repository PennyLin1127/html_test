//
//  GetAndPostAPI.h
//  HolaApp
//
//  Created by Joseph on 2015/2/25.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
// 2015-05-02 Henry 修正非同步回傳資料方式

#import <Foundation/Foundation.h>

@interface GetAndPostAPI : NSObject
@property (strong,nonatomic) NSArray *productListArray;
@property(strong,nonatomic)  NSData *ayncPOSTData;

// get raw NSData (sync POST) 更新->加密
-(NSData*)syncPostData:(NSString*)url dicBody:(NSDictionary*)dicBody;

// get product list
+(NSArray*)getProductList;

//
-(NSMutableArray*)MuArray;

// get raw NSData MuArray (async POST) 更新->加密
-(void)asyncPostData:(NSString*)httpClientURL path:(NSString*)BasePath dicBody:(NSDictionary*)dicBody;


#pragma - mark 轉換格式
// NSDataToDic (flash meat)
-(NSDictionary*) NSDataToDic:(NSData*)data ;

//轉換加密後的NSData成JSON Dic
-(NSDictionary*) convertEncryptionNSDataToDic:(NSData*)data;

// 2015-05-02 Henry
//API傳入字尾參數
+(NSString *)suffix;

// 2015-05-02 Henry
//由api回傳產品列表資料
typedef void (^APILoadCompletionBlock)(BOOL success, NSDictionary *dictData);
typedef void (^APILoadErrorBlock)(NSString *message);
@property (strong) APILoadCompletionBlock loadCompletionBlock;
@property (strong) APILoadErrorBlock loadErrorBlock;

-(NSDictionary*) convertEncryptionStringToDic:(NSString *)dataString;
@end
