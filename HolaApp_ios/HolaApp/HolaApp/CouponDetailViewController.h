//
//  CouponDetailViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/13.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "NavigationViewController.h"
@interface CouponDetailViewController : NavigationViewController<UIWebViewDelegate>

@property (nonatomic,strong) NSDictionary *dicData;
@property (nonatomic) BOOL needToSendApi; //需要去告訴EC說這張使用過了

@property (nonatomic) BOOL isForStore; //  限門市使用
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
