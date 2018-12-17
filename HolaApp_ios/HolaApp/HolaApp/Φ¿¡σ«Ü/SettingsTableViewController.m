////
////  SettingsTableViewController.m
////  HolaApp
////
////  Created by Joseph on 2015/4/14.
////  Copyright (c) 2015年 JimmyLiu. All rights reserved.
////
//
//#import "SettingsTableViewController.h"
//#import "MenuTableViewInViewController.h"
//#import "MyFavoriteViewController.h"
//#import "SearchContainer1ViewController.h"
//#import "NSDefaultArea.h"
//#import "IHouseURLManager.h"
//#import "PerfectAPIManager.h"
//#import "PerfectPushManager.h"
//
//
//
//@interface SettingsTableViewController ()
//{
//    BOOL turnOnOff;
//    NSUserDefaults *remeberOnOffState;
//    NSUserDefaults *deafualts;
//}
//
//@end
//
//@implementation SettingsTableViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    //無法繼承navigationVC,所以直接寫
//    // set navigationbar color
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:116.0/255.0 green:79.0/255.0 blue:40.0/255.0 alpha:1.0f];
//    
//    
//    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    //2015-05-01 Henry 應該用initWithImage ,因為用 initWithTitle有時會造成系統重繪向下偏移
//    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
//                                                                  target:self
//                                                                  action:@selector(backAction)];
//    self.navigationItem.leftBarButtonItem = barBtnItem;
//
//    
//    // search bar button
//    UIButton *rightButton1=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25.0f, 25.0f)];
//    [rightButton1 setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
//    [rightButton1 addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *searchBarBtn =[[UIBarButtonItem alloc]initWithCustomView:rightButton1];
//    
//    // my favorite bar button  (need change pic)
//    UIButton *rightButton2=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30.0f, 25.0f)];
//    [rightButton2 setBackgroundImage:[UIImage imageNamed:@"Collect"] forState:UIControlStateNormal];
//    [rightButton2 addTarget:self action:@selector(myfavorite) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *myFavoriteBarBtn =[[UIBarButtonItem alloc]initWithCustomView:rightButton2];
//    
//    // right bar button 間距
//    UIBarButtonItem *rightFixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    rightFixedItem.width = 8.0f;
//    
//    // add to button item
//    self.navigationItem.rightBarButtonItems =@[myFavoriteBarBtn,rightFixedItem,searchBarBtn];
//    
//    // on off button settings
//    turnOnOff=YES;
//    remeberOnOffState=[NSUserDefaults standardUserDefaults];
//    [self remeberState];
//    
//    // setting current version
//    //CFBundleShortVersionString
//    //CFBundleVersion
//    NSString *version=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    self.currentVersion.text=version;
//    NSLog(@"currentVersion is %@",version);
//
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//-(void)backAction{
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//-(void) remeberState{
//    
//    NSString *stateStr=[remeberOnOffState objectForKey:@"onOffState"];
//    
//    // 一開始沒值顯示on.png
//    if ([stateStr isEqualToString:@"on"]||stateStr==nil) {
//        [self.notifyButton setBackgroundImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
//        
//        deafualts=[NSUserDefaults standardUserDefaults];
//        [deafualts setObject:@1 forKey:@"turnOnOff"];
//        [deafualts synchronize];
//    }else
//    {
//        [self.notifyButton setBackgroundImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
//        deafualts=[NSUserDefaults standardUserDefaults];
//        [deafualts setObject:@0 forKey:@"turnOnOff"];
//        [deafualts synchronize];
//    }
//    
//}
//
//- (IBAction)notifyButton:(id)sender {
//    
//    if (turnOnOff==YES) {
//        //關起
//        [self.notifyButton setBackgroundImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        turnOnOff=NO;
//        [remeberOnOffState setObject:@"off" forKey:@"onOffState"];
//        
//        deafualts=[NSUserDefaults standardUserDefaults];
//        [deafualts setObject:@0 forKey:@"turnOnOff"];
//        [deafualts synchronize];
//        
//        //不收到推播，傳status = 0 給server
//        [self sendStatusEqualZeroToServerInBackground];
//
//    }
//    else
//    {
//        //打開
//        [self.notifyButton setBackgroundImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        turnOnOff=YES;
//        [remeberOnOffState setObject:@"on" forKey:@"onOffState"];
//        
//  
//        deafualts=[NSUserDefaults standardUserDefaults];
//        [deafualts setObject:@1 forKey:@"turnOnOff"];
//        [deafualts synchronize];
//        
//        
//        //拿token，send token to server
//        NSString *token = [PerfectPushManager getDeviceToken];
//        NSLog(@"notifyButton turn on -- 解析後token -- %@", token);
//        [PerfectPushManager sendDeviceTokenToServer];
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//
//        
//    }
//}
//
//
//-(void)sendStatusEqualZeroToServerInBackground
//{
//    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:DeviceTokenKey];
//
//    //組成GET參數
//    
//    NSString *memberCard = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CRM_MEMBER_ID];
//    memberCard = memberCard == nil ? @"" : memberCard;
//    NSString *statusCode=[[NSUserDefaults standardUserDefaults]objectForKey:@"turnOnOff"];
//    NSDictionary *arguments = @{@"MemberCardID"      :memberCard,
//                                @"Token"    :[token stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
//                                @"Source"   :@"iOS"  , //IOS
//                                @"Status"   :statusCode
//                                };
//    
//    
//    PerfectAPIManager *apiManager = [[PerfectAPIManager alloc] init];
//    NSString *urlStr=[IHouseURLManager getPerfectURLByAppName:PerfectServerURL];
//    NSData *data = [apiManager getDataByPostMethodUseEncryptionSync:urlStr AndDic:arguments];
//    NSString *test = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"test -- %@", test);
//    //將回傳的Data轉換成NSString
//    PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];
//
//    NSDictionary *dicData = [perfectAPIManager convertEncryptionNSDataToDic:data];
//    
//    NSString *status = [dicData objectForKey:@"Status"];
//    if ([status isEqualToString:@"OK"]) {
//        NSLog(@"成功傳送Status等於0給Server");
//    }else {
//        NSString *msg = [dicData objectForKey:@"Msg"];
//        NSLog(@"傳送Token失敗 msg -- %@", msg);
//    }
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//}
//
//-(void)pushToMenuTableViewInViewController:(id)sender{
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    //    UIStoryboard *storyBoard=self.storyboard;
//    SearchContainer1ViewController *vc=[storyBoard instantiateViewControllerWithIdentifier:@"MenuTableViewInViewController"];
//    [self.navigationController pushViewController:vc animated:YES];
//    
//}
//
//-(void)search{
//    NSLog(@"search pressed!");
//    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    SearchContainer1ViewController *vc=[sb instantiateViewControllerWithIdentifier:@"container1VC"];
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//
//-(void)myfavorite{
//    NSLog(@"my favorite pressed!");
//    
//    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
//    NSArray *temp=[defaults objectForKey:@"FavoriteList"];
//    
//    
//    if (temp.count==0) {
//        NSString *err = @"您尚未選擇任何商品";
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:err delegate:self cancelButtonTitle:@"關閉" otherButtonTitles:nil];
//        [alert show];
//        
//    }else{
//        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Compare" bundle:nil];
//        MyFavoriteViewController *vc=[storyBoard instantiateViewControllerWithIdentifier:@"MFVC"];
//        [self.navigationController pushViewController:vc animated:YES];
//        
//    }
//    
//}
//
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    return 4;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section==1) {
//        UIView *headerView=[[UIView alloc]init];
//        UILabel *headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(14.0f, 0.0f, 70.0f, 24.0f)];
//        headerLabel.textColor=[UIColor lightGrayColor];
//        headerLabel.text=@"訊息通知";
//        headerView.backgroundColor=[UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f];
//        [headerView addSubview:headerLabel];
//        return headerView;
//    }
//    else if (section==2) {
//        UIView *headerView=[[UIView alloc]init];
//        UILabel *headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(14.0f, 0.0f, 70.0f, 24.0f)];
//        headerLabel.textColor=[UIColor lightGrayColor];
//        headerLabel.text=@"會員權益";
//        headerView.backgroundColor=[UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f];
//        [headerView addSubview:headerLabel];
//        return headerView;
//    }
//    else if (section==3) {
//        UIView *headerView=[[UIView alloc]init];
//        UILabel *headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(14.0f, 0.0f, 150.0f, 24.0f)];
//        headerLabel.textColor=[UIColor lightGrayColor];
//        headerLabel.text=@"關於 HOLA";
//        headerView.backgroundColor=[UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0f];
//        [headerView addSubview:headerLabel];
//        return headerView;
//    }
//    
//    return nil;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    
//    if (section==0) {
//        return 1;
//    }else if (section==1){
//        return 1;
//    }else if (section==2){
//        return 3;
//    }else if (section==3){
//        return 3;
//    }
//    return 0;
//}
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    NSLog(@"section%ld,row%ld",(long)indexPath.section ,(long)indexPath.row);
//    
//    // section2=>會員權益
//    if (indexPath.section==2) {
//        if (indexPath.row==0)
//        {   //會員條款
//            NSString *url=@"http://www.hola.com.tw/memberterms/";
//            NSDictionary *urlDic= @{@"settingURL": url};
//            [NSDefaultArea btoURLToUserDefault:urlDic ];
//        }
//        else if (indexPath.row==1)
//        {   //隱私權保護
//            NSString *url=@"http://www.hola.com.tw/private/";
//            NSDictionary *urlDic= @{@"settingURL": url};
//            [NSDefaultArea btoURLToUserDefault:urlDic ];
//        }
//        else if (indexPath.row==2)
//        {   //交易安全
//            NSString *url=@"http://www.hola.com.tw/security/";
//            NSDictionary *urlDic= @{@"settingURL": url};
//            [NSDefaultArea btoURLToUserDefault:urlDic ];
//        }
//    }
//    // section3=>關於 HOLA
//    else if (indexPath.section==3)
//    {
//        if (indexPath.row==0)
//        {   //品牌簡介
//            NSString *url=@"http://www.hola.com.tw/about/";
//            NSDictionary *urlDic= @{@"settingURL": url};
//            [NSDefaultArea btoURLToUserDefault:urlDic ];
//        }
//        else if (indexPath.row==1)
//        {
//            //給我們評價
//            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/hola-te-li-he-le/id999693342?l=zh&ls=1&mt=8"]];
//            [[UIApplication sharedApplication]openURL:url];
//        }
//    }
//}
//
//
///*
// webView
// 1. 活動訊息通知(for 推播 on/off)。
// 2. 會員條款:http://www.hola.com.tw/memberterms/
// 3. 隱私權保護:http://www.hola.com.tw/private/
// 4. 交易安全:http://www.hola.com.tw/security/
// 5. 品牌簡介:http://www.hola.com.tw/about/
// */
//
//@end
