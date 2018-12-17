//
//  CartsVC.h
//  HOLA
//
//  Created by Joseph on 2015/9/21.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

@interface CartsVC : NavigationViewController<UIWebViewDelegate,NSURLConnectionDelegate>

-(void)postData:(NSString*)urlStr;

/*
 shopping cart send sessionID , load webView HTML can get contect .
 
 DEMO機刷卡測試卡號
 
 信用卡號：4938-1799-9999-9908
 到期日(MMYY)：12/26
 CVC：235
 
 */

@end
