//
//  AES.h
//  OmronCRMiPadApp
//
//  Created by Jimmy Liu on 2014/10/16.
//  Copyright (c) 2014年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AES : NSObject

//要使用此class 需要複製下面class
//#import "Utility.h"
//#import "CocoaSecurity.h"

//給予字串 做AES加密動作
+(NSString *) aesEncryptionWithString:(NSString *)passStr;

//給予加密過的字串 做AES解密
+(NSString *) aesDecryptWithBase64String:(NSString *)passStr;

@end


/*
 HOLA 的API加密訊息
 Key1: 8d2YXximGjj142saVXG5N7G6
 加密後字串尾端固定的八碼：GqmnTisl

 ihouse 的API加密訊息
 key1 = "Odc5XUZKWRXWV422Mg1lghDF";
 加密後字串尾端固定的八碼：jDEo8S0P
*/