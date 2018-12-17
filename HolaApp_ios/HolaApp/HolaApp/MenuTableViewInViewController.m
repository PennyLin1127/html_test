//
//  MenuTableViewInViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/2/11.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "MenuTableViewInViewController.h"
#import "ViewController.h"
#import "ThemeStyleViewController.h" // 主題風格
#import "pinCollectionViewCell.h"
#import "ProductCatalogueViewController.h"
#import "MemberLoginViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "MyViewController.h" //會員專區
#import "MenuTableViewInViewController.h"
#import "ServiceAndDesignViewController.h" // 居家服務設計
#import "CatalogueContainerViewController.h" //線上型錄
#import "RetailnfoViewController.h" // 門市資訊
#import "MainCouponViewController.h" //折價劵
#import "NewsCategoryContainerViewController.h" // 最新消息
#import "SettingsTableViewController.h" // 設定
#import "RSBarcodes.h" //QRCode
#import "CommonWebViewController.h" //內部開啟網頁
#import "SQLiteManager.h"
#import "ThemeProductListViewController.h"
#import "NSDefaultArea.h"
#import "LatestCatalogueViewController.h" //線上型錄內頁
#import "NewsCategoryDetailViewController.h" //最新消息內頁
#import "ProductContentViewController.h" //產品內頁
#import "SearchContainer2ViewController.h" // 搜尋產品頁面
#import "AppDelegate.h"
#import "MessageViewController.h"
#import "PerfectPushManager.h"
#import "WebViewController.h"
#import "GAIFields.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "MyFavoriteViewController.h"
#import "CartsVC.h"
#import "orderVC.h"
#import "SettingsVC.h"

@interface MenuTableViewInViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSUserDefaults *userDefaults;
    
}
@end

@implementation MenuTableViewInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //init other var
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    //設定字體按鈕
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"DFHeiStd-W5" size:15.0];
    
    //檢查是否已經登入
    NSString *isLogin = [userDefaults objectForKey:USER_IS_LOGIN];
    if (isLogin != nil && [isLogin isEqualToString:@"YES"]) {
        NSString *userName = [userDefaults objectForKey:USER_NAME];
        [self.loginButton setTitle:userName forState:UIControlStateNormal];
        [self.loginButton setUserInteractionEnabled:NO];
        
        [self.logoutButton setHidden:NO];
    }else {
        [self.loginButton setTitle:@"登入｜註冊" forState:UIControlStateNormal];
        [self.loginButton setUserInteractionEnabled:YES];
        [self.logoutButton setHidden:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //檢查是否已經登入
    NSString *isLogin = [userDefaults objectForKey:USER_IS_LOGIN];
    if ([isLogin isEqualToString:@"YES"]) {
        NSString *userName = [userDefaults objectForKey:USER_NAME];
        [self.loginButton setTitle:userName forState:UIControlStateNormal];
        [self.loginButton setUserInteractionEnabled:NO];
        
        [self.logoutButton setHidden:NO];
    }else
    {
        [self.loginButton setTitle:@"登入｜註冊" forState:UIControlStateNormal];
        [self.loginButton setUserInteractionEnabled:YES];
        [self.logoutButton setHidden:YES];
    }
    
    //導向其他頁面
    NSString *indexFlag = [userDefaults objectForKey:@"NeedToIndex"];
    if (indexFlag != nil && [indexFlag isEqualToString:@"YES"]) {
        [userDefaults setObject:@"NO" forKey:@"NeedToIndex"];
        [userDefaults synchronize];
        
        //跳到首頁
        [self.navigationController popToRootViewControllerAnimated:NO];
        //        NSString *loginNoAlert = [userDefaults objectForKey:@"LoginNoAlert"];
        //        loginNoAlert = loginNoAlert == nil ? @"" : loginNoAlert;
        //客戶又說不要登入成功的訊息WTF
        //        if ( ![loginNoAlert isEqualToString:@"YES"]) {
        //
        //            UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:@"登入成功" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
        //            [av show];
        //
        //        }else {
        //
        //            [userDefaults setObject:@"" forKey:@"LoginNoAlert"];
        //            [userDefaults synchronize];
        //        }
        
        
        return;
    }
    
    if (self.needToJumpToOtherVC == YES) {
        NSLog(@"Menu頁面的URL");
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate pushToAnotherViewByURL:self.url];
        
        //還原成Default;
        self.needToJumpToOtherVC = NO;
        self.url = @"";
    }
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 17;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:cellIdentifier];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    
    
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"home"];
                    cell.textLabel.text = @"首頁";
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"Topic"];
                    cell.textLabel.text = @"熱門話題";
                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"news"];
                    cell.textLabel.text = @"最新消息";
                    break;
                case 3:
                    cell.imageView.image = [UIImage imageNamed:@"Catalog"];
                    cell.textLabel.text=@"線上型錄";
                    break;
                case 4:
                    cell.imageView.image = [UIImage imageNamed:@"Message"];
                    cell.textLabel.text=@"訊息通知";
                    break;
                case 5:
                    cell.imageView.image = [UIImage imageNamed:@"Classification"];
                    cell.textLabel.text=@"商品分類";
                    break;
                case 6:
                    cell.imageView.image = [UIImage imageNamed:@"Setup"];
                    cell.textLabel.text=@"購物車";
                    break;
                case 7:
                    cell.imageView.image = [UIImage imageNamed:@"Setup"];
                    cell.textLabel.text=@"收藏清單";
                    break;
                case 8:
                    cell.imageView.image = [UIImage imageNamed:@"Setup"];
                    cell.textLabel.text=@"訂單查詢";
                    break;
                case 9:
                    cell.imageView.image = [UIImage imageNamed:@"Coupons"];
                    cell.textLabel.text=@"折價券專區";
                    break;
                case 10:
                    cell.imageView.image = [UIImage imageNamed:@"member"];
                    cell.textLabel.text=@"會員專區";
                    break;
                case 11:
                    cell.imageView.image = [UIImage imageNamed:@"facebook"];
                    cell.textLabel.text=@"特力和樂愛生活粉絲團";
                    break;
                case 12:
                    cell.imageView.image = [UIImage imageNamed:@"decorating"];
                    cell.textLabel.text=@"居家佈置設計服務";
                    break;
                case 13:
                    cell.imageView.image = [UIImage imageNamed:@"Retail"];
                    cell.textLabel.text=@"門市資訊";
                    break;
                case 14:
                    cell.imageView.image = [UIImage imageNamed:@"Contact"];
                    cell.textLabel.text=@"聯絡客服";
                    break;
                case 15:
                    cell.imageView.image = [UIImage imageNamed:@"QRCODE"];
                    cell.textLabel.text=@"掃描 QRCODE";
                    break;
                case 16:
                    cell.imageView.image = [UIImage imageNamed:@"Setup"];
                    cell.textLabel.text=@"設定";
                    break;
                default:
                    break;
            }
            break;
        }
            
    }
    
    
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"user tap in section:%ld, row :%ld",(long)indexPath.section,(long)indexPath.row);
    
    if (indexPath.section == 0 && indexPath.row==0)
    {
        // GA 進入頁
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        
        // 記畫面
        [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/homepage"]];
        [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
        
        // 記事件
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/homepage"]
                                                              action:@"tracker"
                                                               label:nil
                                                               value:nil] build]];
        
        //2015-05-01 Henry 首頁應直接PoptoRoot
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } else if (indexPath.section == 0 && indexPath.row==1)
    {
        //熱門話題
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MenuTableViewInViewController *vc=[sb instantiateViewControllerWithIdentifier:@"themeMenuTableVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row == 2) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NewsCategory" bundle:nil];
        NewsCategoryContainerViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NewsCategoryContainerView"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row == 3) {
        //線上型錄
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Catalogue" bundle:nil];
        CatalogueContainerViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CatalogueContainerVie"];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.section == 0 && indexPath.row==4)
        
    {
        //訊息通知
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Message" bundle:nil];
        MessageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MessageView"];
        [self.navigationController pushViewController:vc animated:YES];
        
        
    }else if(indexPath.row == 5){
        //商品分類
        UIStoryboard *storyBoard=self.storyboard;
        ProductCatalogueViewController *vc=[storyBoard instantiateViewControllerWithIdentifier:@"ProductCatalogueVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row == 6) {
        // 購物車
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Carts" bundle:nil];
        CartsVC *cartsVC=[sb instantiateViewControllerWithIdentifier:@"cartsVC"];
        [self.navigationController pushViewController:cartsVC animated:YES];
        
    } else if (indexPath.row == 7){
        // 追蹤清單
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
        
        
    } else if (indexPath.row == 8){
        // 訂單查詢
        NSString *isLogin = [userDefaults objectForKey:USER_IS_LOGIN];
        
        if (![isLogin isEqualToString:@"YES"]) {
            NSLog(@"請先登入會員");
            [self pushToLogin:nil];
            return;
        }
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
        orderVC *vc = [sb instantiateViewControllerWithIdentifier:@"orderVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    else if (indexPath.row == 9 ) {
        //折價劵
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coupon" bundle:nil];
        MainCouponViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MainCouponView"];
        [self.navigationController pushViewController:vc animated:YES];
        
        
    }else if (indexPath.row == 10) {
        //會員專區
        //先判斷是否登入會員
        NSString *isLogin = [userDefaults objectForKey:USER_IS_LOGIN];
        
        if (![isLogin isEqualToString:@"YES"]) {
            NSLog(@"請先登入會員");
            [self pushToLogin:nil];
            return;
        }
        //可以導向畫面
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
        MyViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MyView"];
        vc.isMember = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (indexPath.row == 11) {
        // facebook
        NSString *faceBookURLStr=@"https://www.facebook.com/HOLA.taiwan";
        NSDictionary *urlDic= @{@"btoURL": faceBookURLStr};
        [NSDefaultArea btoURLToUserDefault:urlDic];
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
        WebViewController *vc=[sb instantiateViewControllerWithIdentifier:@"WebViewVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row == 12) {
        //居家佈置服務
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ServiceAndDesign" bundle:nil];
        ServiceAndDesignViewController * vc = [sb instantiateViewControllerWithIdentifier:@"ServiceAndDesignView"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row == 13) {
        // 門市資訊
        UIStoryboard *sb =[UIStoryboard storyboardWithName:@"RetailInfo" bundle:nil];
        RetailnfoViewController *vc=[sb instantiateViewControllerWithIdentifier:@"RetailInfo"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (indexPath.row == 14) {
        //聯絡客服
        //非會員
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
        MyViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MyView"];
        NSString *isLogin = [userDefaults objectForKey:USER_IS_LOGIN];
        
        if (![isLogin isEqualToString:@"YES"]) {
            vc.isMember = NO;
            
        }else {
            vc.isMember = YES;
        }
        
        vc.needJumpToService = YES;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (indexPath.row == 15) {
        RSScannerViewController *scanner = [[RSScannerViewController alloc] initWithCornerView:YES
                                                                                   controlView:YES
                                                                               barcodesHandler:^(NSArray *barcodeObjects) {
                                                                                   [self qrcodeEvent:scanner andData:barcodeObjects];
                                                                                   
                                                                               }
                                                                       preferredCameraPosition:AVCaptureDevicePositionBack];
        
        [scanner.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [scanner.flipButton setTitle:@"切換" forState:UIControlStateNormal];
        [scanner.torchButton setTitle:@"閃光燈" forState:UIControlStateNormal];
        [scanner setStopOnFirst:YES];
        [self presentViewController:scanner animated:YES completion:nil];
    }
    else if (indexPath.row == 16) {
        // 設定
//        UIStoryboard *sb =[UIStoryboard storyboardWithName:@"Settings" bundle:nil];
//        SettingsTableViewController *vc=[sb instantiateViewControllerWithIdentifier:@"Settings"];
//        [self.navigationController pushViewController:vc animated:YES];
        
        UIStoryboard *sb =[UIStoryboard storyboardWithName:@"Settings" bundle:nil];
        SettingsVC *vc=[sb instantiateViewControllerWithIdentifier:@"SettingsVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - push to Login Screen
// push到登入畫面
- (IBAction)pushToLogin:(id)sender {
    
    // push to login screen
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    MemberLoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MemberLogin"];
    
    
    UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
    
    vc.isDismissViewController=YES;
    
    [self presentViewController:myNavigation animated:YES completion:nil];
    
    
}

#pragma -mark logout
- (IBAction)logoutAction:(id)sender {
    NSLog(@"logoutAction");
    
    //呼叫登出的API 如果呼叫失敗 告訴他稍後再試
    
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    
    //組成Dic
    NSDictionary *dic = @{@"sessionId": sessionId};
    
    
    __block NSData *returnData; //回傳的資料
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MEMBER_LOGOUT] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            return;
            
        }else {
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];
            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"returnDic -- %@", returnDic);
            
            //儲存sessionId
            NSString *sessionId = [returnDic objectForKey:@"sessionId"];
            [IHouseUtility saveSessionIDToUserDefaults:sessionId];
            
            BOOL status = [[returnDic objectForKey:@"status"] integerValue];
            
            NSLog(@"status -- %zd", status);
            
            //登出則需要取消關連（MemberCardID給空值)
            NSString *crmMemberId=@"";
            [userDefaults setObject:crmMemberId forKey:USER_CRM_MEMBER_ID];
            [userDefaults synchronize];
            [PerfectPushManager sendDeviceTokenToServer];
            
            //顯示訊息
            NSString *msg = [returnDic objectForKey:@"msg"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            
        }
        
    }];
    
    
    //改變畫面UI
    [self.loginButton setTitle:@"登入｜註冊" forState:UIControlStateNormal];
    [self.loginButton setUserInteractionEnabled:YES];
    [self.logoutButton setHidden:YES];
    
    //清除UserDefaults裡面的資料
    [userDefaults setObject:@"" forKey:USER_NAME];
    [userDefaults setObject:@"" forKey:USER_REAL_NAME];
    [userDefaults setObject:@"" forKey:USER_EMAIL];
    [userDefaults setObject:@"" forKey:USER_REAL_EMAIL];
    [userDefaults setObject:@"" forKey:USER_CELL_PHONE];
    [userDefaults setObject:@"" forKey:USER_REAL_CELL_PHONE];
    [userDefaults setObject:@"" forKey:USER_CARD_TYPE];
    [userDefaults setObject:@"" forKey:USER_CARD_NUMBER];
    
    //記錄使用者密碼到UserDefaults
    [userDefaults setObject:@"" forKey:USER_ACCOUNT];
    [userDefaults setObject:@"" forKey:USER_PASSWORD];
    [userDefaults setObject:@"NO" forKey:USER_IS_LOGIN];
    
    [userDefaults synchronize];
    
    /*
     傳入範例
     {
     "sessionId": "4af3e075eb912244cbd20347a462755c"
     }
     */
}

#pragma mark - Barcode 掃描程式
-(void)qrcodeEvent:(RSScannerViewController*)controller andData:(NSArray*)array {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        static BOOL isLock;
        
        if (isLock == NO) {
            isLock = YES;
            
            //關閉掃描畫面
            [self dismissViewControllerAnimated:YES completion:nil];
            
            AVMetadataMachineReadableCodeObject *codeObject = array.lastObject;
            NSLog(@"strValue -- %@", codeObject.stringValue);
            
            NSString *strValue = codeObject.stringValue;
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate pushToAnotherViewByURL:strValue];
            
            isLock = NO;
        }
        
    });
}

@end
