//
//  CommonWebViewController.h
//  HOLA
//
//  Created by Jimmy Liu on 2015/4/16.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
@interface CommonWebViewController : NavigationViewController
@property (nonatomic, strong) NSString *urlStr;

// send YES , if you would like to load html string tag
@property (assign,nonatomic) BOOL isHtmlStrTag;
@property (strong,nonatomic) NSString *baseUrlStr;


@end
