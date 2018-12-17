//
//  SessionID.m
//  HolaApp
//
//  Created by Joseph on 2015/2/25.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "SessionID.h"

@implementation SessionID




#pragma mark - Get session ID
+(NSString*)getSessionID{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSString *result=[userDefaults objectForKey:@"sessionId"];
    
    // if session ID is nil , assign @"" to it (follow HOLA API spec)
    return (result == nil ? @"" : result);
}



#pragma mark - Save session ID to user default
+(void)saveSessionID:(NSString*)sessionID{
    NSUserDefaults *userDefaults =[NSUserDefaults standardUserDefaults];
    if (sessionID) {
        [userDefaults setObject:sessionID forKey:@"sessionId"];
    }else{
        [userDefaults setObject:@"" forKey:@"sessionId"];
    }
    
    [userDefaults synchronize];
}


@end



