//
//  PerfectPushManager.m
//  PerfectPush
//
//  Created by Jimmy Liu on 2015/1/12.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "PerfectPushManager.h"
#import "IHouseURLManager.h"
#import "PerfectAPIManager.h"
@implementation PerfectPushManager

#pragma mark - 儲存至後台方法
//非同步方式傳送到Server後台 必須先做儲存DeviceToken 要不然會失敗
+(void)sendDeviceTokenToServer {

    PerfectPushManager *perfectManager = [[PerfectPushManager alloc] init];
    [perfectManager performSelectorInBackground:@selector(sendDeviceTokenToServerInBackground) withObject:nil];
}

-(void)sendDeviceTokenToServerInBackground {
    
    //先從UserFafaults中取出Token
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:DeviceTokenKey];
    //token = @"58978a7dd6bb7ea1a5c11f913b7882a4e7de77c6da6657d095b3dee3a164da2f"; //test token
    //檢查Token正確性
    if (!token || [token isEqualToString:@""]) {
        NSLog(@"警告 [PerfectPushManager sendDeviceTokenToServer] -- Token有誤(值為%@)",token);
        return;
    }

    //檢查網路狀態 todo
    
    //送資料到Server
    
    //組成GET參數
    //__block NSString *urlString = ServerURL;
    
    NSString *crmMemberCard = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CRM_MEMBER_ID];
    crmMemberCard = crmMemberCard == nil ? @"" : crmMemberCard;
    NSString *statusCode=[[NSUserDefaults standardUserDefaults]objectForKey:@"turnOnOff"];
    statusCode = statusCode == nil ? @"1" :statusCode;
    
    NSDictionary *arguments = @{@"MemberCardID"      :crmMemberCard,
                                @"Token"    :[token stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                                @"Source"   :@"iOS" , //IOS
                                @"Status"   :statusCode
                                };
    
//    [arguments.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
//        NSString *concatenateToken;
//
//        if (idx == 0) {
//            concatenateToken = @"?";
//        } else {
//            concatenateToken = @"&";
//        }
//        urlString = [urlString stringByAppendingFormat:@"%@%@=%@", concatenateToken, key, arguments[key]];
//
//    }];
    
    //config request
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    [request setHTTPMethod:@"POST"];
//    request.timeoutInterval = 10; //TimeOut設為10s
//    
//    
//    NSHTTPURLResponse *response;
//    NSError *error;
//    NSData *data =  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
//
//    //檢查有無錯誤 有錯誤直接return
//    if (error) {
//        NSLog(@"警告 [PerfectPushManager sendDeviceTokenToServerInBackground] -- 傳送Token到後台失敗");
//        NSLog(@"error -- %@", error);
//        return;
//    }
    PerfectAPIManager *apiManager = [[PerfectAPIManager alloc] init];
    NSString *url=[NSString stringWithFormat:@"%@",[IHouseURLManager getPerfectURLByAppName:PerfectServerURL]];
    NSData *data = [apiManager getDataByPostMethodUseEncryptionSync:url AndDic:arguments];
    NSString *test = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"test -- %@", test);
    //將回傳的Data轉換成NSString
    PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

    NSDictionary *dicData = [perfectAPIManager convertEncryptionNSDataToDic:data];
    
    NSString *status = [dicData objectForKey:@"Status"];
    if ([status isEqualToString:@"OK"]) {
        NSLog(@"成功傳送Token到Server");
    }else {
        NSString *msg = [dicData objectForKey:@"Msg"];
        NSLog(@"傳送Token失敗 msg -- %@", msg);
    }
    
//    NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//    if ([strData isEqualToString:@"OK"]) {
//        NSLog(@"[PerfectPushManager sendDeviceTokenToServerInBackground] 成功發送Token到後台");
//    }else {
//        NSLog(@"[PerfectPushManager sendDeviceTokenToServerInBackground] 發送Token到後台失敗 -- %@",strData);
//    }
}

#pragma mark - 取得Perfect後台語系
/*此方法取得本機的語系 然後轉換成Perfect後台的代表Flag
  0→中文 1→英文
*/
 -(NSString*) getCurrentLanguageFlag {
    //取得語系
    NSInteger languageResult = 0;
    NSString *currentLanguage = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    if ([currentLanguage isEqualToString:@"zh-Hant"]) {
        languageResult = 0;
    }else {
        languageResult = 1;
    }

    
    return [NSString stringWithFormat:@"%zd", languageResult];
}

#pragma mark - 存取DeviceToken方法
//儲存DeviceToken到UserDefaults中 Key為DeviceToken
+(void)saveDeviceTokenFromData:(NSData*)deviceToken {
    
    //檢查NSData是否為空
    if (!deviceToken) {
        NSLog(@"警告 [PerfectPushManager saveDeviceTokenFromData:deviceTOken] -- 所傳入的DevieToken為nil 儲存失敗!");
        return;
    }
    
    //轉換Token
    NSString *strToken = [self convertDeviceTokenFromNSDataToNSString:deviceToken];
    NSLog(@"此裝置的DeviceToken為 -- %@", strToken);
    
    //儲存Token到UserFafaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:strToken forKey:DeviceTokenKey];
    [userDefaults synchronize];
}

//從UserDeFaults中取得DeviceToken
+(NSString*)getDeviceToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [userDefaults objectForKey:DeviceTokenKey];
    
    if (deviceToken) {
        return deviceToken;
    }else {
        NSLog(@"警告 [PerfectPushManager getDeviceToken] -- 從UserDefaults取出的值為nil!");
        return @"";
    }
}

#pragma mark - 轉換NSData成NSString
+(NSString*)convertDeviceTokenFromNSDataToNSString:(NSData*)deviceToken {
    
    const unsigned *tokenBytes = [deviceToken bytes];
   
    NSString *strToken =
    [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
     ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
     ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
     ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    return strToken;
}

@end
