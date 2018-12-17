//
//  ServiceSucessViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/6.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServiceSucessViewControllerDelegate <NSObject>

-(void)completeSucess:(BOOL)isNotLogin;

@end

@interface ServiceSucessViewController : UIViewController

@property (nonatomic,strong) NSDictionary *dicData;

@property (nonatomic) id<ServiceSucessViewControllerDelegate> delegate;

@end
