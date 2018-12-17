//
//  AppDelegate.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/2/2.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

-(BOOL) pushToAnotherViewByURL:(NSString*)urlStr;
@end

