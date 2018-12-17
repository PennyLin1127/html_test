//
//  SessionID.h
//  HolaApp
//
//  Created by Joseph on 2015/2/25.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SessionID : NSObject

// get session ID
+(NSString*)getSessionID;

// save session ID
+(void)saveSessionID:(NSString*)sessionID;

@end
