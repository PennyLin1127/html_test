//
//  MessageViewController.m
//  HOLA
//
//  Created by Jimmy Liu on 2015/4/20.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "MessageViewController.h"
#import "PerfectAPIManager.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "AppDelegate.h"
#import "MemberLoginViewController.h"
#import "MenuTableViewInViewController.h"
#import "MessageTableViewCell.h"

////
#import "MainCouponViewController.h"
#import "SQLiteManager.h"
#import "ThemeProductListCollectionViewController.h"
#import "ThemeStyleViewController.h"
#import "ProductListContainerViewController.h"
#import "ProductContentViewController.h"
#import "ThemeProductListViewController.h"
#import "SearchContainer1ViewController.h"
#import "MyViewController.h"
#import "LatestCatalogueViewController.h"
#import "NewsCategoryContainerViewController.h"
#import "CommonWebViewController.h"
#import "RetailnfoViewController.h"
#import "NewsCategoryDetailViewController.h"
#import "SearchContainer2ViewController.h"
#import "RegisterViewController.h"


@interface MessageViewController () {
    BOOL isCommonMsg;
    NSMutableArray *commonMsgArray;
    NSMutableArray *personalMsgArray;
    UIView *noDataView;
    
    noDataOrNot noDataEnumTag;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *commonMsgButton;
@property (weak, nonatomic) IBOutlet UIButton *personalMsgButton;
- (IBAction)commonMsgAction:(id)sender;
- (IBAction)personalMsgAction:(id)sender;

@end

@implementation MessageViewController

#pragma mark - View生命週期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //init Var
    isCommonMsg = YES;
    commonMsgArray = [[NSMutableArray alloc] init];
    personalMsgArray = [[NSMutableArray alloc] init];
    
    //tableview delegate
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.commonMsgButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
    
    //把TableView的線拿掉
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //取得資料
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - TableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (isCommonMsg == YES) {
        return commonMsgArray.count;
    }else {
        
        return personalMsgArray.count;
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"MsgCell";
    
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    //Data
    NSDictionary *dicData;
    if (isCommonMsg == YES) {
        dicData = [commonMsgArray objectAtIndex:indexPath.row];
    }else {
        dicData = [personalMsgArray objectAtIndex:indexPath.row];
    }
    
    // setting arrowImage show or hide base on url
    NSString *url = [dicData objectForKey:@"url"];
    if ([url isEqualToString:nil] || [url isEqualToString:@""]) {
        [cell.arrrowImage setHidden:YES];
    }else{
        [cell.arrrowImage setHidden:NO];
    }
    
    NSString *alert = [dicData objectForKey:@"Alert"];
    cell.titleLabel.text = alert;
    
    NSString *date = [dicData objectForKey:@"DATE"];
    NSLog(@"");
    cell.dateLabel.text = date;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //取資料
    NSDictionary *dicData;
    if (isCommonMsg == YES) {
        dicData = [commonMsgArray objectAtIndex:indexPath.row];
    }else {
        dicData = [personalMsgArray objectAtIndex:indexPath.row];
    }
    
    NSString *url = [dicData objectForKey:@"url"];
    
    [self pushToAnotherViewByURL:url];
    
    return;
    //5/20Elaine要我改成從裡面push
    //    NSLog(@"end of Msg");
    //
    //    for (UIViewController *vc in self.navigationController.viewControllers) {
    //        if ([vc isKindOfClass:[MenuTableViewInViewController class]]) {
    //            MenuTableViewInViewController *tempVc = (MenuTableViewInViewController*)vc;
    //            tempVc.url = url;
    //            tempVc.needToJumpToOtherVC = YES;
    //        }
    //    }
    //
    //    NSString *ver = [[UIDevice currentDevice] systemVersion];
    //    float ver_float = [ver floatValue];
    //
    //    //關掉自己
    //    if (ver_float >= 8.0) {
    //        [self.navigationController popViewControllerAnimated:NO];
    //    }else {
    //        [self.navigationController popViewControllerAnimated:YES];
    //    }
}

#pragma mark - Button Event
- (IBAction)commonMsgAction:(id)sender {
    
    noDataEnumTag=commonMessage;
    
    [self getData];
    isCommonMsg = YES;
    [self.tableView reloadData];
    
    [self.commonMsgButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
    [self.personalMsgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    
}

- (IBAction)personalMsgAction:(id)sender {
    
    noDataEnumTag=personalMessage;
    
    //判斷是否登入
    NSString *isLogin = [[NSUserDefaults standardUserDefaults] objectForKey:USER_IS_LOGIN];
    if (![isLogin isEqualToString:@"YES"]) {
        //未登入 導向登入頁面
        NSLog(@"未登入");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請登入特力愛家卡會員" delegate:self cancelButtonTitle:@"稍後" otherButtonTitles:@"登入", nil];
        alert.tag = 100;
        [alert show];
        return;
        
    }else {
        NSLog(@"已經登入");
    }
    
    [self getData];
    
    isCommonMsg = NO;
    [self.tableView reloadData];
    
    [self.personalMsgButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
    [self.commonMsgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}

// push到登入畫面
- (IBAction)pushToLogin:(id)sender {
    
    // push to login screen
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    MemberLoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MemberLogin"];
    vc.dontJumpToIndex = YES;
    
    UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
    
    vc.isDismissViewController=YES;
    
    [self presentViewController:myNavigation animated:YES completion:nil];
    
    
}

#pragma mark - 撈資料方法
-(void) getData {
    //組成Dic
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *memberCard = [userDefaults objectForKey:USER_CRM_MEMBER_ID];
    memberCard = memberCard == nil ? @"" : memberCard;
    NSString *deviceToken = [userDefaults objectForKey:DEVICE_TOKEN_UUID];
    NSDictionary *dic = @{@"MemberCardID": memberCard, @"Source":@"iOS", @"Token": deviceToken};
    
    //傳送資料
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getPerfectURLByAppName:MESSAGE_API] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            //判斷是否無資料 無資料顯示
            UIView *noDataView = [[UIView alloc] initWithFrame:self.tableView.frame];
            noDataView.backgroundColor = [UIColor clearColor];
            UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.frame];
            label.text = @"無資料顯示";
            label.textAlignment = NSTextAlignmentCenter;
            [noDataView addSubview:label];
            [self.tableView addSubview:noDataView];
            self.tableView.scrollEnabled = NO;
            
            return;
            
        }else {
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"returnDic -- %@", returnDic);
            
            if(returnDic==nil)
            {
                UIWindow* window = [UIApplication sharedApplication].keyWindow;
                UIView *noProductView = [[UIView alloc] initWithFrame:window.frame];

                UILabel *noDataLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 90, 50)];
                noDataLabel.text=@"無資料顯示";
                noDataLabel.textColor=[UIColor blackColor];
                [noDataLabel setCenter:self.tableView.center];
                [noProductView addSubview:noDataLabel];
                [self.tableView addSubview:noProductView];
                
                
            }else
            {
                NSString *status = [returnDic objectForKey:@"Status"];
                if ([status isEqualToString:@"OK"]) {
                    //成功
                    
                    [commonMsgArray removeAllObjects];
                    [personalMsgArray removeAllObjects];
                    
                    //加入資料
                    
                    NSArray *tempArray = [returnDic objectForKey:@"Msg"];
                    
                    for (NSDictionary *dic in tempArray) {
                        NSInteger type = [[dic objectForKey:@"Type"] integerValue];
                        if (type == 0 ) {
                            //一般訊息
                            [commonMsgArray addObject:dic];
                            
                        }else  {
                            //會員訊息
                            [personalMsgArray addObject:dic];
                        }
                    }
                    
                    if (noDataEnumTag==commonMessage&&commonMsgArray.count==0) {
                        //判斷是否無資料 無資料顯示
                        noDataView = [[UIView alloc] initWithFrame:self.tableView.frame];
                        noDataView.backgroundColor = [UIColor clearColor];
                        UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.frame];
                        label.text = @"無資料顯示";
                        label.textAlignment = NSTextAlignmentCenter;
                        [noDataView addSubview:label];
                        [self.tableView addSubview:noDataView];
                        self.tableView.scrollEnabled = NO;
                        [self.personalMsgButton setEnabled:YES];
                        [self.commonMsgButton setEnabled:NO];

                        
                    }else if(noDataEnumTag==commonMessage&&commonMsgArray.count!=0){
                        [noDataView removeFromSuperview];
                        [self.commonMsgButton setEnabled:NO];
                        [self.personalMsgButton setEnabled:YES];
                    }
                    
                    
                    if (noDataEnumTag==personalMessage&&personalMsgArray.count==0) {
                        
                        //判斷是否無資料 無資料顯示
                        noDataView = [[UIView alloc] initWithFrame:self.tableView.frame];
                        noDataView.backgroundColor = [UIColor clearColor];
                        UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.frame];
                        label.text = @"無資料顯示";
                        label.textAlignment = NSTextAlignmentCenter;
                        [noDataView addSubview:label];
                        [self.tableView addSubview:noDataView];
                        self.tableView.scrollEnabled = NO;
                        [self.personalMsgButton setEnabled:NO];
                        [self.commonMsgButton setEnabled:YES];

                        
                    }else if(noDataEnumTag==personalMessage&&personalMsgArray.count!=0){
                        [noDataView removeFromSuperview];
                        [self.personalMsgButton setEnabled:NO];
                        [self.commonMsgButton setEnabled:YES];

                    }
                  
                    [self.tableView reloadData];
                }else {
                    NSLog(@"失敗");
                }
            }
        }
    }];
    
}

#pragma mark - 轉跳方法
#pragma mark - 根據不同的url的 轉跳方法
-(void) pushToAnotherViewByURL:(NSString*)urlStr {
    
    NSLog(@"pushToAnotherViewByURL -- %@", urlStr);
    UINavigationController *navigationController =self.navigationController;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([urlStr rangeOfString:@"homepage"].location != NSNotFound) {
        //首頁
        
        [navigationController popToRootViewControllerAnimated:YES];
        
        
    }else if ([urlStr rangeOfString:@"coupon/get"].location != NSNotFound) {
        //折價券專區 - 折價券索取
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coupon" bundle:nil];
        MainCouponViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MainCouponView"];
        [navigationController pushViewController:vc animated:YES];
        
    }else if ([urlStr rangeOfString:@"/coupon/my"].location != NSNotFound) {
        //折價券專區 - 我的折價券
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coupon" bundle:nil];
        MainCouponViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MainCouponView"];
        vc.goToMyCoupon = YES;
        [navigationController pushViewController:vc animated:YES];
        
    }else if ([urlStr rangeOfString:@"/theme/category/"].location != NSNotFound) {
        //熱門話題 - 某個分類
        //熱門話題
        
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/theme/category/"];
        urlStr = startArray[1];
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
        
        
        
    }else if ([urlStr rangeOfString:@"/theme/item/"].location != NSNotFound) {
        //熱門話題 - 某個分類 - 某個風格
        NSLog(@"熱門話題 - 某個分類 - 某個風格");
        
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/theme/item/"];
        urlStr = startArray[1];
        
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
        
        //        ThemeProductListViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeProductListVC"];
        //        vc.themeID = [urlStr integerValue];
        //        [navigationController pushViewController:vc animated:YES];
        
    }else if ([urlStr rangeOfString:@"/product/category/"].location != NSNotFound) {
        //商品分類 - 某個分類
        NSLog(@"商品分類 - 某個分類");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/product/category/"];
        urlStr = startArray[1];
        
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ProductListContainerViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ProductListContainer"];
        
        vc.categoryID = urlStr;
        
        [navigationController pushViewController:vc animated:YES];
        
    }else if ([urlStr rangeOfString:@"/product/item/"].location != NSNotFound) {
        //商品分類 - 某個商品
        NSLog(@"商品分類 - 某個商品");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/product/item/"];
        urlStr = startArray[1];
        
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        //導向頁面
        UIStoryboard *contentSB=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
        ProductContentViewController *vc = [contentSB instantiateViewControllerWithIdentifier:@"contentVC"];
        vc.productID = urlStr;
        vc.sku=urlStr;
        [navigationController pushViewController:vc animated:YES];
        
        
    }else if ([urlStr rangeOfString:@"/product/search/"].location != NSNotFound) {
        //商品分類 - 某些關鍵字
        NSLog(@"商品分類 - 某些關鍵字");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/product/search/"];
        urlStr = startArray[1];
        
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SearchContainer2ViewController *vc = [sb instantiateViewControllerWithIdentifier:@"container2"];
        vc.searchText = urlStr;
        vc.needAutoSearch = YES;
        vc.popToViewTagBOOL =YES;
        [navigationController pushViewController:vc animated:YES];
        
        
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
        
    }else if ([urlStr rangeOfString:@"/member/register"].location != NSNotFound) {
        //會員專區 - 註冊

        //判斷是否登入
        NSString *isLogin = [[NSUserDefaults standardUserDefaults] objectForKey:USER_IS_LOGIN];
        if ([isLogin isEqualToString:@"YES"]) {
            //已登入
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:nil message:@"已登入特力愛家卡會員" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
            
            [alert show];
            return;
            
        }else {
            //未登入，直接跳註冊畫面
            NSLog(@"未登入");
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            
            RegisterViewController *vc = [sb instantiateViewControllerWithIdentifier:@"registerVC"];
//            vc.needGoToRegister = YES; //需要直接去登入頁面
            
//            UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
            
//            vc.isDismissViewController=YES;
            
            vc.popToVCTagBOOL=YES;
            [navigationController pushViewController:vc animated:YES];
            
        }
        
        
        
        
    }else if ([urlStr rangeOfString:@"/catalog/item/"].location != NSNotFound) {
        //線上型錄 - 型錄編號
        
        NSLog(@"線上型錄 - 型錄編號");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/catalog/item/"];
        urlStr = startArray[1];
        
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        //線上型錄
        NSDictionary *dicData = @{@"catalogueId": urlStr};
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Catalogue" bundle:nil];
        LatestCatalogueViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LatestCatalogueView"];
        vc.dicData = dicData;
        
        //先撈資料
        [vc getFirstData];
        
        [navigationController pushViewController:vc animated:YES];
        
    }else if ([urlStr rangeOfString:@"/news/category/"].location != NSNotFound) {
        //最新消息 - 某個分類
        NSLog(@"//最新消息 - 某個分類");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"/news/category/"];
        urlStr = startArray[1];
        
        NSLog(@"整理後的strValue -- %@", urlStr);
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NewsCategory" bundle:nil];
        NewsCategoryContainerViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NewsCategoryContainerView"];
        
        vc.needToGoSpecialCategory = YES;
        vc.specialCategory = urlStr;
        
        [navigationController pushViewController:vc animated:YES];
        
    }else if ([urlStr rangeOfString:@"/news/item/"].location != NSNotFound) {
        //最新消息 - 某個分類 - 某個訊息
        
        NSLog(@"最新消息 - 某個分類 - 某個訊息");
        NSArray *startArray = [urlStr componentsSeparatedByString:@"news/item/"];
        urlStr = startArray[1];
        
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
        
    }else if ([urlStr rangeOfString:@"/store"].location != NSNotFound) {
        //門市資訊
        NSLog(@"門市資訊");
        UIStoryboard *sb =[UIStoryboard storyboardWithName:@"RetailInfo" bundle:nil];
        RetailnfoViewController *vc=[sb instantiateViewControllerWithIdentifier:@"RetailInfo"];
        [navigationController pushViewController:vc animated:YES];
        
    }else if ([urlStr rangeOfString:@"http"].location != NSNotFound) {
        //HTTP開頭
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
        CommonWebViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CommonWebView"];
        vc.urlStr = urlStr;
        [navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //提示登入視窗
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            //前往登入
            [self pushToLogin:nil];
        }
    }
}


@end
