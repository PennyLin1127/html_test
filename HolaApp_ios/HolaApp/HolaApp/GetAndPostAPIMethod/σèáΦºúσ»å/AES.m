//
//  AES.m
//  OmronCRMiPadApp
//
//  Created by Jimmy Liu on 2014/10/16.
//  Copyright (c) 2014年 JimmyLiu. All rights reserved.
//

#import "AES.h"
#import "Utility.h"
#import "NSData+ENBase64.h"
#import "NSData+AES.h"
@implementation AES

//給予字串 做AES加密動作
+(NSString *) aesEncryptionWithString:(NSString *)passStr
{
    // NSString *random = [Utility getRandomStringWithLength:8];
    //  NSString *key = [Utility get256Key:random];
    
    //NSString *encryptedData = [AESCrypt encrypt:passStr password:key];
    
    return  [self encryptAndBase64EncodedByString:passStr];
    
    //    return [NSString stringWithFormat:@"%@%@", random, encryptedData];
}

//給予加密過的字串 做AES解密
+(NSString *) aesDecryptWithBase64String:(NSString *)passStr
{
    //長度小於8位 回傳空字串
    if ([passStr length]<8) {
        NSLog(@"字串小於解密長度，不能作解密");
        return @"";
    }
    
    NSString *first8 = [passStr substringToIndex:8];
    NSLog(@"first 8 key -- %@", first8);

    NSString *otherString = [passStr substringFromIndex:8];
    NSString *key = [NSString stringWithFormat:@"%@%@", first8, [Utility getStaticKey]];
    
    NSData *data = [NSData dataFromBase64String:otherString];
    //NSData* data = [otherString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *resultData = [data AES256DecryptWithKey:key];
    
    NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    
    
    return result;
}

+ (NSString *)encryptAndBase64EncodedByString:(NSString *)passString
{
    //加密
    //Key為前8碼亂數,接著廠商固定string＠“Odc5XUZKWRXWV422Mg1lghDF“,用這組key去做256加密
    NSString *random = [Utility getRandomStringWithLength:8];
    NSString *key = [Utility get256Key:random];
    NSLog(@"key:%@",key);
    
    //256位元來加密JSON
    NSData *data = [[passString dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:key];
    //base64
    //    NSLog(@"[data base64EncodedString] %@", [data base64EncodedString]);
    NSString *passURLString = [data base64EncodedString];
    passURLString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)passURLString, NULL,(CFStringRef)@"!*’();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    //    NSLog(@"passURLString %@", passURLString);
    //return passURLString;
    
    //傳過去前8碼亂數，加密內容，固定8碼辦視來源->都寫在API method裡ㄋ
    //傳過來的加密後字串的尾端再加上固定的八個字元” jDEo8S0P” 這八個字元是辦視來源用的
    //    NSString *key1=@"jDEo8S0P";
    return [NSString stringWithFormat:@"%@%@",random,passURLString];
}

@end
