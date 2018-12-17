//
//  GetAndPostAPI.m
//  HolaApp
//
//  Created by Joseph on 2015/2/25.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "GetAndPostAPI.h"
#import "SessionID.h"
#import "URLib.h"
#import "AFNetworking.h"
#import "AES.h"
#import "IHouseURLManager.h"

@interface GetAndPostAPI  ()
{
    NSArray *arrayTest;
    BOOL status;

}
@property (strong,nonatomic)NSMutableArray *rawDataArray;

@end

@implementation GetAndPostAPI

+(NSString *)suffix {
    return @"GqmnTisl";
//    return @"jDEo8S0P";
}
-(NSMutableArray*)MuArray{
    
    self.rawDataArray=[[NSMutableArray alloc]initWithCapacity:0];
    return self.rawDataArray;
}


#pragma mark - Sync post
-(NSData*)syncPostData:(NSString*)url dicBody:(NSDictionary*)dic
{
    //check dic is nil or not
    if (dic == nil) {
        NSLog(@"GetAndPostAPI->syncPostData->dictionary get nil now");
        return nil;
    }

    //set json data from dictionary
    NSError *dicError;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&dicError];
    
    //set json string from json data (in order to add inputData=jsonStr in http post body)
    NSString *jsonStr;
    if (!dicError) {
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"POST to JSON string is : %@",jsonStr);
    }else{
        NSLog(@"JSON to String is error : %@", dicError);
        return nil;
    }
    
    //加密
    //再把JSON Str轉換成加密後字串
    NSString *encodeStr = [AES aesEncryptionWithString:jsonStr];
    
    //傳過去前8碼亂數，加密內容，固定8碼辦視來源
    //傳過來的加密後字串的尾端再加上固定的八個字元” jDEo8S0P” 這八個字元是辦視來源用的
    // for ihouse -->jDEo8S0P 尾巴要再加上這行
    // for HOLA --> GqmnTisl
    
    encodeStr = [NSString stringWithFormat:@"%@%@", encodeStr, [GetAndPostAPI suffix]];
    
    
    //再把JSON 轉換成POST BODY
    NSData *requestPostBodyData = [[NSString stringWithFormat:@"inputData=%@",encodeStr] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
        
    /*無加密
    //setting URL request POST http body's data (inputData=jsonStr that is follow HOLA spec)
    NSData *requestPostBodyData = [[NSString stringWithFormat:@"inputData=%@",jsonStr] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
     */
    
    //set URL from string
    NSURL *nsurl = [NSURL URLWithString:url];
    
    //set URLRequest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:nsurl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];
    [request setHTTPMethod:@"POST"];
    
    //set Content-Length
    NSString *postLength = [NSString stringWithFormat:@"%zd",[requestPostBodyData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //set HTTP Body
    [request setHTTPBody:requestPostBodyData];
    
    //set sync request
    NSError *requestError;
    NSURLResponse *urlResponse;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
    if (requestError) {
        NSLog(@"GetAndPostAPI->syncPostData->request error is : %@",requestError);
        return nil;
    }
    
    return response;
}



#pragma mark - NSData to NSDictionary (flash meat)轉換格式
// NSDataToDic (flash meat)
-(NSDictionary*) NSDataToDic:(NSData*)data {
    NSError *Error;
    NSDictionary *result;
    
    result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&Error];
    if (Error) {
        NSLog(@"GetAndPostAPI->NSDataToDic->error now : %@",Error);
        return nil;
    }
    
    return result;
}


//轉換加密後的NSData成JSON Dic
-(NSDictionary*) convertEncryptionNSDataToDic:(NSData*)data {
    
    if (data == nil) {
        NSLog(@"資料為空 不能轉換成JSON Dic");
        return nil;
    }
    
    NSError *dicError;
    NSDictionary *result;
    
    //轉換成字串
    NSString *encryptionStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *jsonStr = [AES aesDecryptWithBase64String:encryptionStr];
    
    NSLog(@"解密後的jsonStr -- %@", jsonStr);
    
    if (jsonStr == nil) {
        NSLog(@"jsonStr 為空! 返回空值!");
        return nil;
    }
    
    result = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&dicError];
    
    if (dicError) {
        NSLog(@"GetAndPostAPI convertEncryptionNSDataToDic: 轉換JSONTODIC失敗 -- dicError -- %@",dicError);
        return nil;
    }
    
    return result;
    
}

//轉換加密後的String成JSON Dic
-(NSDictionary*) convertEncryptionStringToDic:(NSString *)dataString {
    

    NSError *dicError;
    NSDictionary *result;
    
    NSString *jsonStr = [AES aesDecryptWithBase64String:dataString];
    
    NSLog(@"解密後的jsonStr -- %@", jsonStr);
    
    if (jsonStr == nil) {
        NSLog(@"jsonStr 為空! 返回空值!");
        return nil;
    }
    
    result = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&dicError];
    
    if (dicError) {
        NSLog(@"GetAndPostAPI convertEncryptionNSDataToDic: 轉換JSONTODIC失敗 -- dicError -- %@",dicError);
        return nil;
    }
    
    return result;
    
}


#pragma mark - Get product list (sync)
+(NSArray*)getProductList{
    NSArray *result;
    NSDictionary *dic = @{@"sessionID": [SessionID getSessionID]};
    GetAndPostAPI *getAndPostAPI=[[GetAndPostAPI alloc]init];
    NSString *productListStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:HOLA_PRODUCTLIST]];

    NSData *getRawData=[getAndPostAPI syncPostData:productListStr dicBody:dic];
    
    if (getRawData) {
        NSDictionary *flashProductList=[getAndPostAPI convertEncryptionNSDataToDic:getRawData];
        result = [flashProductList objectForKey:@"data"];
        NSLog(@"product list :%@",result);
        
    }
    
    return result;
}

//#pragma mark - Get sub product list
//+(NSArray*)getSubProductList{
//    NSArray *temp;
//    NSDictionary *tempDic;
//    NSArray *result;
//    
//    NSDictionary *dic =@{@"sessionID": [SessionID getSessionID]};
//    GetAndPostAPI *getAndPostAPI=[[GetAndPostAPI alloc]init];
//    NSData *getRawData=[getAndPostAPI syncPostData:HOLA_PRODUCTLIST dicBody:dic];
//    
//    if (getRawData) {
//        NSDictionary *flashProductList=[getAndPostAPI NSDataToDic:getRawData];
//        temp=[flashProductList objectForKey:@"data"];
//        
//        for(int i=0;i<[temp count];i++){
//            tempDic=[temp objectAtIndex:i];
//            result=[tempDic objectForKey:@"subCategorys"];
//        }
//    }
//    
//    return  result;
//}

#pragma mark - Async POST
-(void)asyncPostData:(NSString*)httpClientURL path:(NSString*)BasePath dicBody:(NSDictionary*)dicBody{

    
    // Prepare the HTTP Client
    AFHTTPClient *httpClient =
    [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:httpClientURL]];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:BasePath
                                                      parameters:nil];
    
    //set json data from dictionary
    NSError *dicError;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dicBody options:NSJSONWritingPrettyPrinted error:&dicError];
    
    //set json string from json data (in order to add inputData=jsonStr in http post body)
    NSString *jsonStr;
    if (!dicError) {
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"ASYNC POST: %@",jsonStr);
    }else{
        NSLog(@"JSON to String is error : %@", dicError);
    }
    
    //加密
    //再把JSON Str轉換成加密後字串
    NSString *encodeStr = [AES aesEncryptionWithString:jsonStr];
    
    //傳過去前8碼亂數，加密內容，固定8碼辦視來源
    //傳過來的加密後字串的尾端再加上固定的八個字元” jDEo8S0P” 這八個字元是辦視來源用的
    // for ihouse -->jDEo8S0P 尾巴要再加上這行
    // for HOLA --> GqmnTisl
    
    encodeStr = [NSString stringWithFormat:@"%@%@", encodeStr, [GetAndPostAPI suffix]];
    
    
    //再把JSON 轉換成POST BODY
    NSData *requestPostBodyData = [[NSString stringWithFormat:@"inputData=%@",encodeStr] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];

    /*無加密
    //setting URL request POST http body's data (inputData=jsonStr that is follow HOLA spec)
    NSData *requestPostBodyData = [[NSString stringWithFormat:@"inputData=%@",jsonStr] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    */
    
    //set Content-Length
    NSString *postLength = [NSString stringWithFormat:@"%zd",[requestPostBodyData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //set HTTP Body
    [request setHTTPBody:requestPostBodyData];
    
    
    // Set the opration
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    // Set the callback block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictData = nil;
        
        NSLog(@"operation:%@",operation.responseString);
        if (!operation.responseString) {
            NSLog(@"no responseObject");
        }
        else{
             dictData = [self convertEncryptionStringToDic:operation.responseString];
        }
        //2015-05-02 Henry 加入完成區塊
        if (self.loadCompletionBlock) {
            self.loadCompletionBlock(true, dictData);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error");
        //2015-05-02 Henry 加入完成區塊
        if (self.loadErrorBlock) {
//            self.loadErrorBlock([NSString stringWithFormat:@"%ld",[operation.response statusCode]]);
            self.loadErrorBlock([NSString stringWithFormat:@"請檢查網路連線"]);
        }
    }];
    
    
    // Start the opration
    [operation start];
    

//    2015-05-02 Henry 非同步不會立即有回傳值，這裡有問題
//    return self.rawDataArray;

}




@end
