//
//  PerfectPushManager.h
//  PerfectPush
//
//  Created by Jimmy Liu on 2015/1/12.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

/*
 使用方式
 1.傳Token到Server
 在application didRegisterForRemoteNotificationsWithDeviceToken方法中加入
 [PerfectPushManager saveDeviceTokenFromData:deviceToken];
 [PerfectPushManager sendDeviceTokenToServer];
 
 2.取得當前Token
 [PerfectPushManager getDeviceToken];
 
 PS:AppName記得要換
 */

#import <Foundation/Foundation.h>

#define DeviceTokenKey @"DeviceToken" //UuseDefaults 存取的Key
#define AppName @"" //此App名稱 供Perfect後台操作使用


@interface PerfectPushManager : NSObject
//非同步方式傳送到Server後台 必須先做儲存DeviceToken 要不然會失敗
+(void)sendDeviceTokenToServer;

//儲存DeviceToken到UserDefaults中 Key為DeviceToken
+(void)saveDeviceTokenFromData:(NSData*)deviceToken;

//從UserDeFaults中取得DeviceToken
+(NSString*)getDeviceToken;
@end
