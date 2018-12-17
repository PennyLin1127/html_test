//
//  MyViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
#import "ServiceViewController.h"
#import "ServiceSucessViewController.h"
#import "ServiceNotLoginViewController.h"
@interface MyViewController : NavigationViewController <UIScrollViewDelegate,ServiceViewControllerDelegate, ServiceSucessViewControllerDelegate, ServiceNotLoginViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic) BOOL isMember; //是否為會員
@property (nonatomic) BOOL needToLogin;
@property (nonatomic) BOOL goToPoint;

@property (nonatomic) BOOL needJumpToService; // 進來後馬上跳到客服頁面

-(void)pushToLoginVC; // 登入方法
@end
