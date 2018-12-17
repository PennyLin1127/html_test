//
//  NavigationBack.h
//  HolaApp
//
//  Created by Joseph on 2015/3/11.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol NavigationBack <NSObject>

-(void)popToBack;

@end

@interface NavigationBack : UIViewController
@property (nonatomic, weak) id <NavigationBack> delegate;

@end
