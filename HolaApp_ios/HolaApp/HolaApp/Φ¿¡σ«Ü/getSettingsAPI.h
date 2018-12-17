//
//  getSettingsAPI.h
//  HOLA
//
//  Created by Joseph on 2015/9/30.
//  Copyright © 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getSettingsAPI : NSObject

typedef enum
{
    GetMenu,
    GetHTML
    
}getWhatKindAPI;

//retrieveFromAPI block
typedef void(^LoadCompleteBlock)(BOOL success, NSArray *htmlArray , NSString *htmlStr);
@property (strong,nonatomic)LoadCompleteBlock loadCompleteBlock;

typedef void(^LoadErrorBlock)(NSString *message);
@property(strong,nonatomic)LoadErrorBlock loadErrorBlock;


@property (strong,nonatomic)NSMutableArray *menuArray;
@property (strong,nonatomic)NSString *htmlStr;


-(void)retrieveFromAPI:(getWhatKindAPI)APIType path:(NSString*)path;

@end
