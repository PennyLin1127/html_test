//
//  MenuTableViewInViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/2/11.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "NavigationBackViewController.h"
#import "NavigationViewController.h"

@interface MenuTableViewInViewController : NavigationViewController
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


@property (strong, nonatomic) NSString *url; //導到其他畫面用的url
@property (nonatomic) BOOL needToJumpToOtherVC; //需要導向到其他頁面
@end
