//
//  NavigationViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/2/11.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//  2015-05-01 Henry 增加目前NavigationController自動左方ICON判斷

#import "NavigationViewController.h"
#import "MenuTableViewInViewController.h"
#import "MyFavoriteViewController.h"
#import "SearchContainer1ViewController.h"
#import "ProductListContainerViewController.h"
#import "NSDefaultArea.h"
#import "ThemeStyleViewController.h"
#import "SQLiteManager.h"
#import "ThemeProductListCollectionViewController.h"
#import "AppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "IHouseUtility.h"
#import "CartsVC.h"
#import "BBBadgeBarButtonItem.h"

static NavigationViewController *naviVC=nil;


@interface NavigationViewController () {
    UIBarButtonItem *searchBarBtn;
    UIButton *btnListSwitch; //產品列表顯示方式切換Icon
    PRODUCT_LIST_MODE product_list_mode; //產品列表顯示方式
    UIBarButtonItem *barListSwitch;
    UIBarButtonItem *rightFixedItem;
    NSUserDefaults *userDefault;
}


@end

@implementation NavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    userDefault=[NSUserDefaults standardUserDefaults];
    
    [self setNavigationBar];

}

-(void)setBackButton{
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(popToView)];
    self.navigationItem.leftBarButtonItem = barBtnItem;

}

//-(void)viewDidAppear:(BOOL)animated{
//    NSString *numStr = [userDefault objectForKey:@"cartNumbers"];
//    [self reflashMyCarts:numStr];
//}

-(void)viewWillAppear:(BOOL)animated{
    NSString *numStr = [userDefault objectForKey:@"cartNumbers"];
    [self reflashMyCarts:numStr];
}

-(void)setNavigationBar{
    naviVC=self;
    
    product_list_mode = TWO_COLUMN;
    
    // set navigationbar color
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:111.0/255.0 green:76.0/255.0 blue:35.0/255.0 alpha:1.0f];
    
    
    NSString *currentClassName = NSStringFromClass([self class]);
    
    //2015-05-01 Henry 左方圖示按鈕,如果非最上層，則變成回上頁圖示
    if ([self.navigationController.viewControllers count] > 1) {
        UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        //2015-05-01 Henry 應該用initWithImage ,因為用 initWithTitle有時會造成系統重繪向下偏移
        UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backAction)];
        self.navigationItem.leftBarButtonItem = barBtnItem;
    } else {
        //2015-05-01 Henry 應該用initWithImage ,因為用 initWithTitle有時會造成系統重繪向下偏移
        UIImage *image1 = [[UIImage imageNamed:@"LOGO-1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(pushToMenuTableViewInViewController:)];
        self.navigationItem.leftBarButtonItem = barBtnItem;
    }
    
    // search bar button
    UIButton *rightButton1=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25.0f, 25.0f)];
    
    if ([currentClassName isEqualToString:@"SearchContainer1ViewController"]
        || [currentClassName isEqualToString:@"SearchContainer2ViewController"]) { //判斷如果Class名稱為搜尋，亮起圖片
        [rightButton1 setBackgroundImage:[UIImage imageNamed:@"bar_search_2"] forState:UIControlStateNormal];
    } else {
        [rightButton1 setBackgroundImage:[UIImage imageNamed:@"icon_search_nav"] forState:UIControlStateNormal];
    }
    
    [rightButton1 addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    searchBarBtn =[[UIBarButtonItem alloc]initWithCustomView:rightButton1];
    
    // my cart bar button
    UIButton *rightButton2=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30.0f, 25.0f)];
    NSString *cartNumStr=[userDefault objectForKey:@"cartNumbers"];
    
    if (cartNumStr==nil||[cartNumStr isEqualToString:@"0"]) {
        [rightButton2 setBackgroundImage:[UIImage imageNamed:@"Shopping_Cart"] forState:UIControlStateNormal];
    }else{
        [rightButton2 setBackgroundImage:[UIImage imageNamed:@"Shopping_Cart_1"] forState:UIControlStateNormal];
    }
    [rightButton2 addTarget:self action:@selector(myCarts) forControlEvents:UIControlEventTouchUpInside];
    self.cartsMountBtn = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:rightButton2];
    self.cartsMountBtn.badgeValue = cartNumStr;
    self.cartsMountBtn.badgeBGColor=[UIColor colorWithRed:251.0/255.0 green:200.0/255.0 blue:13.0/255.0 alpha:1.0];
    self.cartsMountBtn.badgeOriginX = 20;
    self.cartsMountBtn.badgeOriginY = -9;
    
    // right bar button 間距
    rightFixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightFixedItem.width = 14.0f;
    
    
    barListSwitch = nil;
    if ([currentClassName isEqualToString:@"SearchContainer2ViewController"] || [currentClassName isEqualToString:@"ProductListContainerViewController"]) { //判斷如果Class名稱為搜尋結果或產品，加入切換列表選項
        btnListSwitch = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25.0f, 25.0f)];
        [btnListSwitch setBackgroundImage:[UIImage imageNamed:@"list_2"] forState:UIControlStateNormal];
        [btnListSwitch addTarget:self action:@selector(list:) forControlEvents:UIControlEventTouchUpInside];
        barListSwitch = [[UIBarButtonItem alloc]initWithCustomView:btnListSwitch];
    }
    
    if ([currentClassName isEqualToString:@"ProductContentViewController"]) {
        btnListSwitch =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
        [btnListSwitch setBackgroundImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [btnListSwitch addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        barListSwitch =[[UIBarButtonItem alloc]initWithCustomView:btnListSwitch];
    }
    if (barListSwitch != nil) {
        self.navigationItem.rightBarButtonItems =@[self.cartsMountBtn,searchBarBtn,rightFixedItem,barListSwitch];
    } else {
        self.navigationItem.rightBarButtonItems =@[self.cartsMountBtn,searchBarBtn,rightFixedItem];
    }
    
}


+(NavigationViewController *)currentInstance {
    return naviVC;
}

-(void)reflashMyCarts:(NSString*)numStr{
    [userDefault setObject:numStr forKey:@"cartNumbers"];
    [userDefault synchronize];
    [self setNavigationBar];
}

-(void)popToView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)list:(id)sender {
    
    if (product_list_mode == TWO_COLUMN) {
        product_list_mode = ONE_COLUMN;
    } else {
        product_list_mode = TWO_COLUMN;
    }
    
    if(product_list_mode == TWO_COLUMN){
        [btnListSwitch setBackgroundImage:[UIImage imageNamed:@"list_2"] forState:UIControlStateNormal];
        
    }else{
        [btnListSwitch setBackgroundImage:[UIImage imageNamed:@"list_3"] forState:UIControlStateNormal];
    }
    
    [self listSwitchChanged:product_list_mode];
}

-(void)share:(id)sender {
    [self sharePressed:barListSwitch];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) backAction {
    // 存下tag for search (for scroll view did scroll tag)
    NSString *key=@"";
    NSDictionary *keyDic=@{@"viewKeyword":key};
    [NSDefaultArea whichViewKeywordToUserDefault:keyDic];

    // 由右到左選單->用動畫來做
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    SearchContainer1ViewController *vc=[storyBoard instantiateViewControllerWithIdentifier:@"MenuTableViewInViewController"];
//    
//    CATransition *animation = [CATransition animation];
//    [self.navigationController popViewControllerAnimated:YES];
//    [animation setDuration:0.5];
//    [animation setType:kCATransitionPush];
//    [animation setSubtype:kCATransitionFromRight];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
//    [[self.view layer] addAnimation:animation forKey:@"SwitchToView1"];
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.window.backgroundColor=[UIColor whiteColor];
//    appDelegate.window.tintColor=[UIColor whiteColor];
//    
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)pushToMenuTableViewInViewController:(id)sender{
    // 存下tag for search (for scroll view did scroll tag)
    NSString *key=@"";
    NSDictionary *keyDic=@{@"viewKeyword":key};
    [NSDefaultArea whichViewKeywordToUserDefault:keyDic];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    UIStoryboard *storyBoard=self.storyboard;
    SearchContainer1ViewController *vc=[storyBoard instantiateViewControllerWithIdentifier:@"MenuTableViewInViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

/*
-(void)pushToMenuTableViewInViewController:(id)sender{

    // 存下tag for search (for scroll view did scroll tag)
    NSString *key=@"";
    NSDictionary *keyDic=@{@"viewKeyword":key};
    [NSDefaultArea whichViewKeywordToUserDefault:keyDic];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchContainer1ViewController *vc=[storyBoard instantiateViewControllerWithIdentifier:@"MenuTableViewInViewController"];
    
    // 由左到右選單->用動畫來做
    CATransition *animation = [CATransition animation];
    [[self navigationController] pushViewController:vc animated:NO];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [[vc.view layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.backgroundColor=[UIColor whiteColor];
    appDelegate.window.tintColor=[UIColor whiteColor];

}
*/

-(void)search{
    NSLog(@"search pressed !!!");
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchContainer1ViewController *vc=[sb instantiateViewControllerWithIdentifier:@"container1VC"];
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)myfavorite{
    NSLog(@"my favorite pressed!");
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSArray *temp=[defaults objectForKey:@"FavoriteList"];
    
    
    if (temp.count==0) {
        NSString *err = @"您尚未選擇任何商品";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:err delegate:self cancelButtonTitle:@"關閉" otherButtonTitles:nil];
        [alert show];
        
    }else{
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Compare" bundle:nil];
        MyFavoriteViewController *vc=[storyBoard instantiateViewControllerWithIdentifier:@"MFVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
    // GA -- 我的最愛
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/collect"]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/collect"]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
    
}

-(void)myCarts{
    
    //push to webView
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Carts" bundle:nil];
    CartsVC *cartsVC=[sb instantiateViewControllerWithIdentifier:@"cartsVC"];
    [self.navigationController pushViewController:cartsVC animated:YES];
    
}

#pragma mark - Back  Button


// changeRightButtonImage
-(void)changeRightButtonImage {
    return;
    UIButton *rightButton1=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25.0f, 25.0f)];
    [rightButton1 setBackgroundImage:[UIImage imageNamed:@"bar_search_2"] forState:UIControlStateNormal];
    [rightButton1 addTarget:self action:@selector(noSearch) forControlEvents:UIControlEventTouchUpInside];
    searchBarBtn =[[UIBarButtonItem alloc]initWithCustomView:rightButton1];
    self.navigationItem.rightBarButtonItems =@[self.navigationItem.rightBarButtonItems[0],searchBarBtn,self.navigationItem.rightBarButtonItems[2],self.navigationItem.rightBarButtonItems[3]];
}

-(void)noSearch{
    
}

-(void)changeMenuActionToPushVC{

}

-(void)pushVC{

}


-(void)changeMenuActionToPushThemeVC{
    return;
    // menu button
    UIButton *leftButton1=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25.0f, 25.0f)];
    [leftButton1 setBackgroundImage:[UIImage imageNamed:@"list"]  forState:UIControlStateNormal];
    [leftButton1 addTarget:self action:@selector(pushThemeVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBarBtn = [[UIBarButtonItem alloc]initWithCustomView:leftButton1];
    self.navigationItem.leftBarButtonItems=@[menuBarBtn,self.navigationItem.leftBarButtonItems[1],self.navigationItem.leftBarButtonItems[2]];
    
}

-(void)pushThemeVC{
    // get date (YYYY-MM-dd)
    NSDate *date=[NSDate date];
    NSString *dateStrFormate=[IHouseUtility createDateFormat:date];
    
    NSString *intCategoryIDStr=[NSDefaultArea GetIntCategoryIDFromUserDefault];
    
    NSArray *tempArray;
    if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
        
        tempArray=[SQLiteManager getThemeData:intCategoryIDStr date:dateStrFormate];
    }
    else{
        tempArray=[SQLiteManager getThemeData:intCategoryIDStr];
        
    }
    
    // 小於1就進入產品頁，大於就進入熱門話題瀑布牆，當按下navigation menu
    if(tempArray.count<2)
    {
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ThemeProductListCollectionViewController *vc=[sb instantiateViewControllerWithIdentifier:@"ThemeProductListCollectionView"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        
        ThemeStyleViewController *vc=[[ThemeStyleViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
