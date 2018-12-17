//
//  getSettingsAPI.m
//  HOLA
//
//  Created by Joseph on 2015/9/30.
//  Copyright © 2015年 JimmyLiu. All rights reserved.
//

#import "getSettingsAPI.h"
#import "GetAndPostAPI.h"
#import "SessionID.h"
#import "IHouseURLManager.h"


@implementation getSettingsAPI{
    GetAndPostAPI *getAndPostAPI;
    getWhatKindAPI _getWhatKindAPI;
}


-(void)retrieveFromAPI:(getWhatKindAPI)APIType path:(NSString*)path{
 
    getAndPostAPI=[[GetAndPostAPI alloc]init];
    __block getSettingsAPI *this=self;
    _getWhatKindAPI=APIType;
    
    // get data from API
    getAndPostAPI.loadCompletionBlock=^(BOOL success,NSDictionary *dicData)
    {
        
        if (_getWhatKindAPI==GetMenu) {
            NSArray *productDicArray=[dicData objectForKey:@"data"];
            if (productDicArray!=nil) {
                this.menuArray=[[NSMutableArray alloc]initWithArray:productDicArray];
                this.loadCompleteBlock(YES,this.menuArray,this.htmlStr);
            }
        }else if (_getWhatKindAPI==GetHTML){
            NSString *htmlStr=[dicData objectForKey:@"data"];
            if (htmlStr!=nil) {
                this.htmlStr=htmlStr;
                this.loadCompleteBlock(YES,this.menuArray,this.htmlStr);
            }
            
        }
        
    };
    
    // get error from API
    getAndPostAPI.loadErrorBlock=^(NSString *message){
        this.loadErrorBlock(message);
    };
    
    NSDictionary *dictData;
#warning to do , link need change
    dictData = @{@"sessionId":  [SessionID getSessionID]};
    NSString *holaURL = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:@""]];
    
    if (_getWhatKindAPI==GetMenu) {
        [getAndPostAPI asyncPostData:holaURL path:SETTINGS dicBody:dictData];
    }
    else if (_getWhatKindAPI==GetHTML){
        [getAndPostAPI asyncPostData:holaURL path:path dicBody:dictData];
    }
}







@end
