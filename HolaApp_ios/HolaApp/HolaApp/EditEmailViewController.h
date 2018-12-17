//
//  EditEmailViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
@interface EditEmailViewController : NavigationViewController <UITextFieldDelegate>

@property (nonatomic,strong) NSDictionary *dicData;

@end
