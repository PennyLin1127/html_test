//
//  Utility.m
//  OmronCRMiPadApp
//
//  Created by Jimmy Liu on 2014/9/29.
//  Copyright (c) 2014年 JimmyLiu. All rights reserved.
//

#import "Utility.h"
#define len 18
@implementation Utility

#pragma mark 加密相關
//取得動態加密的Key
+(NSString*) get256Key:(NSString*)dynamicString
{
    
    if (dynamicString && [dynamicString length]==8 ) {
        return [NSString stringWithFormat:@"%@%@", dynamicString, [self getStaticKey]];
    }else {
        return [NSString stringWithFormat:@"%@%@", @"6e1c5de6", [self getStaticKey]];
    }
    
}

//取得固定Key
+(NSString*) getStaticKey
{
    static NSString *staticKey = @"Odc5XUZKWRXWV422Mg1lghDF";
    return staticKey;
}


#pragma mark 字串相關
//不足length長度之字串 在後面補空白
+(NSString*) returnString:(NSString*) str withLength:(int) length
{
    NSString *result = str;
    
    int stringLength = [self convertToInt:str];
    
    if (stringLength >= length) {
        return result;
    }
    
    for (int i = 0; i<length-stringLength; i++) {
        result = [NSString stringWithFormat:@"%@%@", result, @" "];
    }
    
    return result;
}

+ (int)convertToInt:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
        
    }
    return strlength;
}

//隨機取得length位數亂碼(包含 0-9 a-z A-Z)
+(NSString*) getRandomStringWithLength:(int)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *result = [NSMutableString stringWithCapacity: length];
    
    for (int i=0; i<length; i++) {
        [result appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return result;
}
@end
