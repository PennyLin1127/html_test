//
//  AppDelegate.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/2/2.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "AppDelegate.h"
#import "CheckSystemServiceStatusViewController.h"
#import "PerfectPushManager.h"
#import "IBeaconManager.h"
#import "IHouseURLManager.h"
#import "ViewController.h"
#import "MainCouponViewController.h"
#import "SQLiteManager.h"
#import "NSDefaultArea.h"
#import "ThemeProductListViewController.h"
#import "ThemeStyleViewController.h"
#import "ProductContentViewController.h"
#import "MyViewController.h"
#import "MemberLoginViewController.h"
#import "LatestCatalogueViewController.h"
#import "NewsCategoryContainerViewController.h"
#import "NewsCategoryDetailViewController.h"
#import "RetailnfoViewController.h"
#import "CommonWebViewController.h"
#import "SearchContainer2ViewController.h"
#import "ThemeProductListCollectionViewController.h"
#import "SearchContainer1ViewController.h"
#import "IHouseUtility.h"
#import "GAI.h"
#import "RegisterViewController.h"
#import "orderVC.h"



@interface AppDelegate (){
    IBeaconManager *ibeaconManager;
}

@end

@implementation AppDelegate

#pragma mark - App Activity
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //UUID
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uuid = [userDefaults objectForKey:DEVICE_TOKEN_UUID];
    if (uuid == nil) {
        uuid = [[NSUUID UUID] UUIDString];
        [userDefaults setObject:uuid forKey:DEVICE_TOKEN_UUID];
    }
    NSLog(@"本機的裝置UUID為%@", uuid);
    
    //IBeaconManager
    ibeaconManager = [IBeaconManager shareIBeaconManager];
    [ibeaconManager startAllMonitoringBeacons];
    [ibeaconManager startAllRangingBeacons];
    
    //    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied) {
    //        [ibeaconManager.locationManager requestAlwaysAuthorization];
    //    }
    
    NSDictionary *notificationRemote = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationRemote != nil) {
        //NSLog(@"notificationRemote finish -- %@", notificationRemote);
        [userDefaults setObject:notificationRemote forKey:REMOTE_USER_INFO_KEY];
        [userDefaults setObject:@"YES" forKey:HAS_REMOTE_USER_INFO_KEY];
        [userDefaults synchronize];
    }
    
    UILocalNotification *notificationLocal = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notificationLocal != nil) {
        //NSLog(@"notificationLocal finish -- %@", notificationLocal);
        
    }
    
    
    // set rootVC is CheckSystemServiceStatusViewController(follow HOLA spec)
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    
    CheckSystemServiceStatusViewController *firstViewController = [[CheckSystemServiceStatusViewController alloc] initWithNibName:@"CheckSystemServiceStatusViewController" bundle:nil];
    
    self.window.rootViewController = firstViewController;
    [self.window makeKeyAndVisible];
    
    
    //for beacon background mode
    UIBackgroundTaskIdentifier *messageTask = [[UIApplication sharedApplication]
                                               beginBackgroundTaskWithExpirationHandler:^{
                                                   // If you're worried about exceeding 10 minutes, handle it here
                                               }];
    
    
    //註冊推播
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        
        NSLog(@"iOS 8 Notifications");
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings
          settingsForTypes:
          (UIUserNotificationTypeSound |
           UIUserNotificationTypeAlert |
           UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
        
    }else{
        
        NSLog(@"iOS < 8 Notifications");
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
        
    }
    
    
    // GA init
    // Google Analytics V3(Initializing the tracker)
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 30;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:GA_HOLA]; //請填入正確的代碼
    

//    [userDefaults setObject:@"0" forKey:@"cartNumbers"];
//    [userDefaults synchronize];
    
    return YES;
}

#pragma mark - Remote Push Notification
//收到遠端通知
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"receive deviceToken: %@", deviceToken);
    //    NSString *token = [deviceToken description];
    
    [PerfectPushManager saveDeviceTokenFromData:deviceToken];
    NSString *token = [PerfectPushManager getDeviceToken];
    NSLog(@"解析後token -- %@", token);
    [PerfectPushManager sendDeviceTokenToServer];
    
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"註冊推播失敗 -- %@", error);
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"收到的推播資訊 userInfo -- %@",userInfo);
    
    NSDictionary *dic = [userInfo objectForKey:@"aps"];
    NSString *msg = [dic objectForKey:@"alert"];
    NSLog(@"remote msg -- %@", msg);
    
    NSString *str = [userInfo objectForKey:@"url"];
    
    if (str == nil || [str isEqualToString:@""]) {
        NSLog(@"收到url為空!");
        return;
    }
    
    UIApplicationState applicationState = application.applicationState;
    
    // 若前景收到通知發 alert  -> alert delegate -> 跳轉頁面
    if (applicationState == UIApplicationStateActive) {
        NSDictionary *dicData = @{@"Alert":msg, @"url":str};
        
        [self showAlertMessage:dicData];
    }
    // 若背景收到通知 -> push 到通知裡面的 URL 頁面
    else if (applicationState == UIApplicationStateInactive)
    {
        [self pushToAnotherViewByURL:str];
    }
}

#pragma mark - Local Push Notification
//收到本地通知 (for beacon)
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSDictionary *beaconReturnDic = notification.userInfo;
    NSDictionary *dic = [beaconReturnDic objectForKey:@"BeaconReturnDic"];
    NSString *str = [dic objectForKey:@"url"];
    NSLog(@"didReceiveLocalNotification str -- %@", str);
    
    // 若前景收到通知發 alert  -> alert delegate -> 跳轉頁面
    UIApplicationState applicationState = application.applicationState;
    if (applicationState == UIApplicationStateActive)
    {
        [self showAlertMessage:dic];
        
        // 若背景收到通知 -> push 到通知裡面的 URL 頁面
    }else if (applicationState == UIApplicationStateInactive)
    {
        [self pushToAnotherViewByURL:str];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //    [[IBeaconManager shareIBeaconManager] startAllMonitoringBeacons];
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //    [[IBeaconManager shareIBeaconManager]startAllRangingBeacons];
    
    
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied) {
        [ibeaconManager.locationManager requestAlwaysAuthorization];
    }
    
    //進入前景前 先做自動登入
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [IHouseUtility autoLogin];
        NSLog(@"WillEnterForeground Login");
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 收到訊息後要打開Alert視窗
-(void)showAlertMessage:(NSDictionary*)dicData {
    
    NSString *msg = [dicData objectForKey:@"Alert"];
    NSLog(@"showAlertMessage -- %@", [dicData objectForKey:@"url"]);
    NSString *key = [NSString stringWithFormat:@"MSG%@", msg];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[dicData objectForKey:@"url"] forKey:key];
    [userDefaults synchronize];
    
    //UIAlertView
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:@"取消", nil];
    alert.delegate = self;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 根據url，跳轉頁面
    if (buttonIndex == 0) {
        NSString *key = [NSString stringWithFormat:@"MSG%@", alertView.message];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *str = [userDefaults objectForKey:key];
        NSLog(@"clickedButtonAtIndex str -- %@, key -- %@", str, key);
        [self pushToAnotherViewByURL:str];
    }else if (buttonIndex == 1 ) {
        NSLog(@"取消");
    }
    
}

#pragma mark - 根據不同的url的 轉跳方法
-(BOOL) pushToAnotherViewByURL:(NSString*)urlStr{
    BOOL result = YES;
    NSLog(@"pushToAnotherViewByURL -- %@", urlStr);
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[str rangeOfString:@"HappyDay"].location != NSNotFound)
    
    //if ([urlStr containsString:@"homepage"]) {
    if ([urlStr rangeOfString:@"homepage"].location != NSNotFound) {
        //首頁
        
        //        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        ViewController *vc=[storyBoard instantiateViewControllerWithIdentifier:@"ViewController"];
        //        [navigationController pushViewController:vc animated:YES];
        [navigationController popToRootViewControllerAnimated:YES];
        
        //}else if ([urlStr containsString:@"coupon/get"]) {
    }else if ([urlStr rangeOfString:@"coupon/get"].location != NSNotFound) {
        //折價券專區 - 折價券索取
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coupon" bundle:nil];
        MainCouponViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MainCouponView"];
        [navigationController pushViewController:vc animated:YES];
        
        //}else if ([urlStr containsString:@"/coupon/my"]) {
    }else if ([urlStr rangeOfString:@"/coupon/my"].location != NSNotFound) {
        //折價券專區 - 我的折價券
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coupon" bundle:nil];
        MainCouponViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MainCouponView"];
        vc.goToMyCoupon = YES;
        [navigationController pushViewController:vc animated:YES];
        
        //    }else if ([urlStr containsString:@"/theme/category/"]) {
    }else if ([urlStr rangeOfString:@"/theme/category/"].location != NSNotFound) {
        //熱門話題 - 某個分類
        //熱門話題
        
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/theme/category/"];
        urlStr = startArray[1];
        //        NSArray *endArray = [urlStr componentsSeparatedByString:@"["];
        //        urlStr = endArray[1];
        NSLog(@"整理後的strValue -- %@", urlStr);
        NSLog(@"整理後integerValue %ld",(long)[urlStr integerValue]);
        
        // get date (YYYY-MM-dd)
        NSDate *date=[NSDate date];
        NSString *dateStrFormate=[IHouseUtility createDateFormat:date];
        NSArray *subCategories;
        
        if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
            
            subCategories =[SQLiteManager getThemeData:[urlStr integerValue] date:dateStrFormate];
        }
        else{
            subCategories =[SQLiteManager getThemeData:[urlStr integerValue]];
        }
        
        if(subCategories.count<2){
            // 數量太少就不顯示瀑布牆，直接到熱門話題商品列表
            
            NSInteger subThemeId = [[[subCategories objectAtIndex:0]objectForKey:@"themeId"] integerValue];
            UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ThemeProductListCollectionViewController *vc=[sb instantiateViewControllerWithIdentifier:@"ThemeProductListCollectionView"];
            vc.themeID = subThemeId;
            [navigationController pushViewController:vc animated:YES];
        } else {   // 數量大於2，顯示瀑布牆
            
            ThemeStyleViewController *vc=[[ThemeStyleViewController alloc]init];
            vc.themeID = [urlStr integerValue];
            [navigationController pushViewController:vc animated:YES];
        }
        
        
        //    }else if ([urlStr containsString:@"/theme/item/"]) {
    }else if ([urlStr rangeOfString:@"/theme/item/"].location != NSNotFound) {
        //熱門話題 - 某個分類 - 某個風格
        NSLog(@"熱門話題 - 某個分類 - 某個風格");
        
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/theme/item/"];
        urlStr = startArray[1];
        //        NSArray *endArray = [urlStr componentsSeparatedByString:@"["];
        //        urlStr = endArray[1];
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        // get date (YYYY-MM-dd)
        NSDate *date=[NSDate date];
        NSString *dateStrFormate=[IHouseUtility createDateFormat:date];
        NSArray *subCategories;
        
        if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
            
            subCategories =[SQLiteManager getThemeData:[urlStr integerValue]date:dateStrFormate];
        }else{
            subCategories =[SQLiteManager getThemeData:[urlStr integerValue]];
            
        }
        
        NSInteger subThemeId = [[[subCategories objectAtIndex:0]objectForKey:@"themeId"] integerValue];
        
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ThemeProductListCollectionViewController *vc=[sb instantiateViewControllerWithIdentifier:@"ThemeProductListCollectionView"];
        vc.themeID = subThemeId;
        [navigationController pushViewController:vc animated:YES];
        
        //        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //        ThemeProductListViewController *vc=[sb instantiateViewControllerWithIdentifier:@"ThemeProductListVC"];
        //        vc.themeID = [urlStr integerValue];
        //        [navigationController pushViewController:vc animated:YES];
        
        //    }else if ([urlStr containsString:@"/product/category/"]) {
    }else if ([urlStr rangeOfString:@"/product/category/"].location != NSNotFound) {
        //商品分類 - 某個分類
        NSLog(@"商品分類 - 某個分類");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/product/category/"];
        urlStr = startArray[1];
        //        NSArray *endArray = [urlStr componentsSeparatedByString:@"["];
        //        urlStr = endArray[1];
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ProductListContainerViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ProductListContainer"];
        
        vc.categoryID = urlStr;
        //        vc.titleName=dict[@"subCategoryName"];
        [navigationController pushViewController:vc animated:YES];
        
        //    }else if ([urlStr containsString:@"/product/item/"]) {
    }else if ([urlStr rangeOfString:@"/product/item/"].location != NSNotFound) {
        //商品分類 - 某個商品
        NSLog(@"商品分類 - 某個商品");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/product/item/"];
        urlStr = startArray[1];
        //        NSArray *endArray = [urlStr componentsSeparatedByString:@"["];
        //        urlStr = endArray[1];
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        //導向頁面
        UIStoryboard *contentSB=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
        ProductContentViewController *vc = [contentSB instantiateViewControllerWithIdentifier:@"contentVC"];
        vc.productID = urlStr;
        vc.sku=urlStr;
        [navigationController pushViewController:vc animated:YES];
        
    }else if ([urlStr rangeOfString:@"/product/detail/id"].location != NSNotFound) {
        //購物車 - 某個商品
        NSLog(@"商品分類 - 某個商品");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/product/detail/id/"];
        urlStr = startArray[1];
        //        NSArray *endArray = [urlStr componentsSeparatedByString:@"["];
        //        urlStr = endArray[1];
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        //導向頁面
        UIStoryboard *contentSB=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
        ProductContentViewController *vc = [contentSB instantiateViewControllerWithIdentifier:@"contentVC"];
        vc.productID = urlStr;
        [navigationController pushViewController:vc animated:YES];
    }
    
    else if ([urlStr rangeOfString:@"/product/search/"].location != NSNotFound) {
        //商品分類 - 某些關鍵字
        NSLog(@"商品分類 - 某些關鍵字");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/product/search/"];
        urlStr = startArray[1];
        
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SearchContainer2ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"container2"];
        vc.searchText = urlStr;
        vc.needAutoSearch = YES;
        [navigationController pushViewController:vc animated:YES];
        
        //    }else if ([urlStr containsString:@"member/point"]) {
    }else if ([urlStr rangeOfString:@"member/point"].location != NSNotFound) {
        //會員專區 - 點數專區
        
        NSString *isLogin = [userDefaults objectForKey:USER_IS_LOGIN];
        
        //可以導向畫面
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
        MyViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MyView"];
        if (![isLogin isEqualToString:@"YES"]) {
            vc.needToLogin = YES;
        }
        vc.isMember = YES;
        vc.goToPoint = YES;
        [navigationController pushViewController:vc animated:NO];
        
        
        //}else if ([urlStr containsString:@"/member/register"]) {
    }else if ([urlStr rangeOfString:@"/member/register"].location != NSNotFound) {
        //會員專區 - 註冊
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        
        //registerVC
        RegisterViewController *vc=[sb instantiateViewControllerWithIdentifier:@"registerVC"];
        vc.popToVCTagBOOL=YES;
        [navigationController pushViewController:vc animated:YES];
        
    }else if ([urlStr rangeOfString:@"/member/login"].location != NSNotFound) {
        //會員專區 - 登入
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        
        MemberLoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MemberLogin"];
        
        UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
        
        vc.isDismissViewController=YES;
        
        [navigationController presentViewController:myNavigation animated:YES completion:nil];
        
    }else if ([urlStr rangeOfString:@"order"].location != NSNotFound){
        //訂單
        //hola://order
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
        orderVC *vc = [sb instantiateViewControllerWithIdentifier:@"orderVC"];
        [navigationController pushViewController:vc animated:YES];        
    }
    
    //}else if ([urlStr containsString:@"/catalog/item/"]) {
    else if ([urlStr rangeOfString:@"/catalog/item/"].location != NSNotFound) {
        //線上型錄 - 型錄編號
        
        NSLog(@"線上型錄 - 型錄編號");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/catalog/item/"];
        urlStr = startArray[1];
        //        NSArray *endArray = [urlStr componentsSeparatedByString:@"["];
        //        urlStr = endArray[1];
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        //線上型錄
        NSDictionary *dicData = @{@"catalogueId": urlStr};
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Catalogue" bundle:nil];
        LatestCatalogueViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LatestCatalogueView"];
        vc.dicData = dicData;
        
        //先撈資料
        [vc getFirstData];
        
        [navigationController pushViewController:vc animated:YES];
        
        //}else if ([urlStr containsString:@"/news/category/"]) {
    }else if ([urlStr rangeOfString:@"/news/category/"].location != NSNotFound) {
        //最新消息 - 某個分類
        NSLog(@"//最新消息 - 某個分類");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/news/category/"];
        urlStr = startArray[1];
        //        NSArray *endArray = [urlStr componentsSeparatedByString:@"["];
        //        urlStr = endArray[1];
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NewsCategory" bundle:nil];
        NewsCategoryContainerViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NewsCategoryContainerView"];
        
        vc.needToGoSpecialCategory = YES;
        vc.specialCategory = urlStr;
        
        [navigationController pushViewController:vc animated:YES];
        
        //}else if ([urlStr containsString:@"/news/item/"]) {
    }else if ([urlStr rangeOfString:@"/news/item/"].location != NSNotFound) {
        //最新消息 - 某個分類 - 某個訊息
        
        NSLog(@"最新消息 - 某個分類 - 某個訊息");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"news/item/"];
        urlStr = startArray[1];
        //        NSArray *endArray = [urlStr componentsSeparatedByString:@"["];
        //        urlStr = endArray[1];
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        NSArray *tempArray = [SQLiteManager getNewsDetailDataByNewsId:urlStr];
        
        if (tempArray.count > 0) {
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NewsCategory" bundle:nil];
            NewsCategoryDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NewsCategoryDetailView"];
            vc.dicData = tempArray[0];
            
            [navigationController pushViewController:vc animated:YES];
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"無此筆資料" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alert show];
        }
        
        //    }else if ([urlStr containsString:@"/store"]) {
    }else if ([urlStr rangeOfString:@"/store"].location != NSNotFound) {
        //門市資訊
        NSLog(@"門市資訊");
        UIStoryboard *sb =[UIStoryboard storyboardWithName:@"RetailInfo" bundle:nil];
        RetailnfoViewController *vc=[sb instantiateViewControllerWithIdentifier:@"RetailInfo"];
        [navigationController pushViewController:vc animated:YES];
        
        //    }else if ([urlStr containsString:@"http"]) {
    }else if ([urlStr rangeOfString:@"http"].location != NSNotFound) {
        //HTTP開頭
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
        CommonWebViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CommonWebView"];
        vc.urlStr = urlStr;
        [navigationController pushViewController:vc animated:YES];
    }
    else {
        result = NO;
    }
    
    
    return result;
}

#pragma mark - open url methord
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    
    //    NSString *urlStr = [NSString stringWithFormat:@"%@", url];
    NSLog(@"ComeFromOtherWay:%@",url.absoluteString);
    
    NSString *str = [self subStringAndSendToGa:url.absoluteString];
    
    BOOL result = [self pushToAnotherViewByURL:str];
    
    return result;
}

#pragma mark - 截掉字串傳送GA
-(NSString*)subStringAndSendToGa:(NSString*)str {
    NSString *result;
    
    NSArray *strArray = [str componentsSeparatedByString:@"?"];
    
    //裡面沒有? 回傳原本的字串回去
    if (strArray.count < 2) {
        return str;
    }
    
    NSString *gaStr = [strArray objectAtIndex:1];
    result = [strArray objectAtIndex:0];
    
    NSLog(@"準備送到GA的字串 -- %@", gaStr);
    NSLog(@"準備開啟URL的字串 -- %@", result);
    
    return result;
}

@end
