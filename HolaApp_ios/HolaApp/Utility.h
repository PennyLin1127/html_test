//
//  Utility.h
//  OmronCRMiPadApp
//
//  Created by Jimmy Liu on 2014/9/29.
//  Copyright (c) 2014年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject
#pragma mark 加密相關
//取得動態加密的Key
+(NSString*) get256Key:(NSString*)dynamicString;
//取得固定Key
+(NSString*) getStaticKey;

#pragma mark 字串相關
//不足length長度之字串 在後面補空白
+(NSString*) returnString:(NSString*) str withLength:(int) length;
//隨機取得length位數亂碼(包含 0-9 a-z A-Z)
+(NSString*) getRandomStringWithLength:(int)length;
@end
