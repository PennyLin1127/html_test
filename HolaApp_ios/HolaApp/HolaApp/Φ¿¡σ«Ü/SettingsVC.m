//
//  SettingsVC.m
//  HOLA
//
//  Created by Joseph on 2015/9/30.
//  Copyright © 2015年 JimmyLiu. All rights reserved.
//

#import "SettingsVC.h"
#import "SettingsTableViewCell.h"
#import "PerfectPushManager.h"
#import "IHouseURLManager.h"
#import "GetAndPostAPI.h"
#import "getSettingsAPI.h"
#import "PerfectAPIManager.h"
#import "CommonWebViewController.h"


@interface SettingsVC ()
{
    NSUserDefaults *deafualts;
    NSUserDefaults *remeberOnOffState;
    BOOL turnOnOff;
    getSettingsAPI *_gettingSetAPI;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSArray *aboutArray;

//會員權益data array
@property (strong,nonatomic) NSArray *menuArray;
@property (strong,nonatomic) NSString *htmlStr;

@property (assign,nonatomic) BOOL brandIntroTag;

@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setBackButton];
    
    
    // init user default
    deafualts=[NSUserDefaults standardUserDefaults];
    remeberOnOffState=[NSUserDefaults standardUserDefaults];
    
    // on off button settings
    turnOnOff=YES;
    
    self.aboutArray=[NSArray arrayWithObjects:@"品牌簡介",@"給我們評價",@"目前版本",nil];
    
    
    //註冊Cell
    [self.tableView registerNib:[UINib nibWithNibName:@"SettingsTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    // remember on/off button settings
    [self remeberState];
    
    //getData
    [self AsyncGetMenuArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    NSString *statusCode=[deafualts objectForKey:@"turnOnOff"];
    NSLog(@"push status code is -- %@",statusCode);
}

-(void) remeberState{
    
    NSString *stateStr=[remeberOnOffState objectForKey:@"onOffState"];
    
    // 一開始沒值顯示on.png
    if ([stateStr isEqualToString:@"on"]||stateStr==nil) {
        [deafualts setObject:@1 forKey:@"turnOnOff"];
        [deafualts synchronize];
    }else
    {
        [deafualts setObject:@0 forKey:@"turnOnOff"];
        [deafualts synchronize];
    }
    
}

// 傳push on/off tag to boss
-(void)pushButtonAction:(id)sender{
    
    UIButton *btn=(UIButton*)[sender viewWithTag:100];
    
    if (turnOnOff==YES) {
        //關起
        [btn setBackgroundImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        turnOnOff=NO;
        [remeberOnOffState setObject:@"off" forKey:@"onOffState"];
        
        deafualts=[NSUserDefaults standardUserDefaults];
        [deafualts setObject:@0 forKey:@"turnOnOff"];
        [deafualts synchronize];
        
        //不收到推播，傳status = 0 給server
        [self sendStatusEqualZeroToServerInBackground];
        
    }
    else
    {
        //打開
        [btn setBackgroundImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        turnOnOff=YES;
        [remeberOnOffState setObject:@"on" forKey:@"onOffState"];
        
        
        deafualts=[NSUserDefaults standardUserDefaults];
        [deafualts setObject:@1 forKey:@"turnOnOff"];
        [deafualts synchronize];
        
        
        //拿token，send token to server
        NSString *token = [PerfectPushManager getDeviceToken];
        NSLog(@"notifyButton turn on -- 解析後token -- %@", token);
        [PerfectPushManager sendDeviceTokenToServer];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        
    }

}

-(void)sendStatusEqualZeroToServerInBackground
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:DeviceTokenKey];

    //組成GET參數
    
    NSString *memberCard = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CRM_MEMBER_ID];
    memberCard = memberCard == nil ? @"" : memberCard;
    NSString *statusCode=[[NSUserDefaults standardUserDefaults]objectForKey:@"turnOnOff"];
    NSDictionary *arguments = @{@"MemberCardID"      :memberCard,
                                @"Token"    :[token stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                                @"Source"   :@"iOS"  , //IOS
                                @"Status"   :statusCode
                                };
    
    
    PerfectAPIManager *apiManager = [[PerfectAPIManager alloc] init];
    NSString *urlStr=[IHouseURLManager getPerfectURLByAppName:PerfectServerURL];
    NSData *data = [apiManager getDataByPostMethodUseEncryptionSync:urlStr AndDic:arguments];
    NSString *test = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"test -- %@", test);
    //將回傳的Data轉換成NSString
    PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];
    
    NSDictionary *dicData = [perfectAPIManager convertEncryptionNSDataToDic:data];
    
    NSString *status = [dicData objectForKey:@"Status"];
    if ([status isEqualToString:@"OK"]) {
        NSLog(@"成功傳送Status等於0給Server");
    }else {
        NSString *msg = [dicData objectForKey:@"Msg"];
        NSLog(@"傳送Token失敗 msg -- %@", msg);
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}


#pragma mark - get settings menu data

-(void)AsyncGetMenuArray {
    
    if (_gettingSetAPI ==nil) {
        _gettingSetAPI=[getSettingsAPI new];
    }
    
    __block SettingsVC *this=self;
    //撈資料
    _gettingSetAPI.loadCompleteBlock = ^(BOOL success , NSArray *menuArray , NSString *htmlStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                //獲得設定資料
                this.menuArray=menuArray;
                [this.tableView reloadData];
            }
            
            [MBProgressHUD hideHUDForView:this.view animated:YES];
        });
        
    };
    
    _gettingSetAPI.loadErrorBlock=^(NSString *message){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
            [av show];
            [MBProgressHUD hideHUDForView:this.view animated:YES];
        });
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // 呼叫settingsAPI 讀取資料
    [_gettingSetAPI retrieveFromAPI:GetMenu path:nil];
}


-(void)getHtmlStrArray:(NSInteger)row realPath:(NSString*)path{
    if (_gettingSetAPI ==nil) {
        _gettingSetAPI=[getSettingsAPI new];
    }
    
    __block SettingsVC *this=self;
    //撈資料
    _gettingSetAPI.loadCompleteBlock = ^(BOOL success , NSArray *menuArray , NSString *htmlStr) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                //獲得設定 單筆 HTML str
                this.htmlStr=htmlStr;
                
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
                CommonWebViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CommonWebView"];
                
                NSString *path=[this.menuArray[row] objectForKey:@"docApiUrl"];
                vc.isHtmlStrTag=YES;
                vc.baseUrlStr=[NSString stringWithFormat:IHOUSE_URL"%@",path];
                vc.urlStr=this.htmlStr;
                
                [this.navigationController pushViewController:vc animated:YES];
            }
            
            [MBProgressHUD hideHUDForView:this.view animated:YES];
        });
        
    };
    
    _gettingSetAPI.loadErrorBlock=^(NSString *message){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
            [av show];
            [MBProgressHUD hideHUDForView:this.view animated:YES];
        });
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (self.brandIntroTag) {
        // 抓品牌介紹資料 ->呼叫settingsAPI 讀取資料
        [_gettingSetAPI retrieveFromAPI:GetHTML path:path];
        self.brandIntroTag=NO;
    }else{
        // 抓會員權益資料 ->呼叫settingsAPI 讀取資料
        [_gettingSetAPI retrieveFromAPI:GetHTML path:[self.menuArray[row] objectForKey:@"docApiUrl"]];
    }
    
}


#pragma mark - tableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section==0) {
        return 1;
    }else if (section==1){
        return self.menuArray.count;
    }else if (section==2){
        return self.aboutArray.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (section==0) {
        return @"訊息通知";
    }else if (section==1){
        return @"會員權益";
    }else if (section==2){
        return @"關於HOLA";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify=@"Cell";
    
    SettingsTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    
    if (cell==nil){
        cell=[[SettingsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        
    }
    
    //    cell.pushButton.tag=1;
    cell.lableStrr.font=[UIFont fontWithName:@"DFHeiStd-W3" size:16.0f];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.section){
        case 0:
            if ([[deafualts objectForKey:@"turnOnOff"] isEqual:@1]) {
                [cell.onoffButton setBackgroundImage:[UIImage imageNamed:@"on.png"] forState:UIControlStateNormal];
            }else{
                [cell.onoffButton setBackgroundImage:[UIImage imageNamed:@"off.png"] forState:UIControlStateNormal];
            }

            cell.lableStrr.text=@"活動訊息通知";
            [cell.subTitleLablee setHidden:NO];
            cell.sectionCell0HeightConss.constant=6;
            cell.accessoryType=UITableViewCellAccessoryNone;
            [cell.onoffButton setHidden:NO];
            [cell.onoffButton addTarget:self action:@selector(pushButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.versionLablee setHidden:YES];
            break;
        case 1:
            [cell.onoffButton setHidden:YES];
            [cell.subTitleLablee setHidden:YES];
            cell.lableStrr.text=[self.menuArray[indexPath.row]objectForKey:@"docName"];
            [cell.versionLablee setHidden:YES];
            break;
        case 2:
            [cell.onoffButton setHidden:YES];
            [cell.subTitleLablee setHidden:YES];
            cell.lableStrr.text=self.aboutArray[indexPath.row];
            
            if (indexPath.row==2) {
                [cell.versionLablee setHidden:NO];
                //setting current version,CFBundleShortVersionString,CFBundleVersion
                NSString *version=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                cell.versionLablee.text=version;
                NSLog(@"currentVersion is %@",version);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType=UITableViewCellAccessoryNone;
            }else{
                [cell.versionLablee setHidden:YES];
            }
            break;
        default:
            break;
    }
    
    cell.backgroundColor=[UIColor clearColor];
    self.tableView.backgroundColor=[UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        //會員權益
        [self getHtmlStrArray:indexPath.row realPath:nil];
    }
    else if (indexPath.section==2 && indexPath.row==0) {
        //品牌簡介
        self.brandIntroTag=YES;
        [self getHtmlStrArray:nil realPath:BRANDING_INTRO];
    }
    else if (indexPath.section==2 && indexPath.row==1){
        //給我們評價
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/hola-te-li-he-le/id999693342?l=zh&ls=1&mt=8"]];
        [[UIApplication sharedApplication]openURL:url];
    }
}

@end
