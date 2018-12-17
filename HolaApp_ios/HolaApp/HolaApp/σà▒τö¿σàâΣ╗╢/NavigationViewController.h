//
//  NavigationViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/2/11.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBBadgeBarButtonItem.h"

typedef NS_ENUM(NSInteger, PRODUCT_LIST_MODE)
{
    TWO_COLUMN = 0, //兩欄
    ONE_COLUMN = 1//一欄
};


@interface NavigationViewController : UIViewController

//push to VC via customise menu button
-(void)changeMenuActionToPushVC;
//push to theme VC via customise menu button
-(void)changeMenuActionToPushThemeVC;


//產品列表顯示切換
-(void)listSwitchChanged:(PRODUCT_LIST_MODE)product_list_mode;

//分享按鈕事件
-(void)sharePressed:(UIBarButtonItem *)barButtonItem;


-(void)setBackButton;

// 購物車數目
@property(strong,nonatomic)BBBadgeBarButtonItem *cartsMountBtn;
+(NavigationViewController *)currentInstance;//無繼承的先呼叫這個method傳回實體class
-(void)reflashMyCarts:(NSString*)numStr;  //有繼承的直接用self存取

@end
