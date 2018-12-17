//
//  ManagentViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ManagentViewController.h"
#import "EditEmailViewController.h"
#import "EditPhoneViewController.h"
#import "SubscribeViewController.h"
#import "IHouseUtility.h"
#import "IHouseURLManager.h"
#import "SubscribeTableViewController.h"
#import "RSBarcodes.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface ManagentViewController () {
    NSUserDefaults *userDefaults;
}

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *barCodeImageView;
@property (weak, nonatomic) IBOutlet UITableView *managentTableView;

@end

@implementation ManagentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //init TableView
    self.managentTableView.delegate = self;
    self.managentTableView.dataSource = self;

    //
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    //漸層圖片
    UIColor *beginColor = [UIColor blackColor];
    UIColor *endColor = [UIColor colorWithRed:116.0/255.0 green:79.0/255.0 blue:40.0/255.0 alpha:1.0f];
    
     NSArray *gradientColors = [NSArray arrayWithObjects:(id)beginColor.CGColor, (id)endColor.CGColor, nil];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.cardView.bounds;
    gradient.colors = gradientColors; // 由上到下的漸層顏色
    [self.cardView.layer insertSublayer:gradient atIndex:0];

}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //Barcode 圖片與Label
    NSString *cardNumber = [userDefaults objectForKey:USER_CARD_NUMBER];
    self.cardNumberLabel.text = cardNumber;
    self.barCodeImageView.image = [CodeGen genCodeWithContents:cardNumber machineReadableCodeObjectType:AVMetadataObjectTypeEAN13Code];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView delagete
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *identifier = @"ManagentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"修改電子郵件";
    }else if(indexPath.row == 1) {
        cell.textLabel.text = @"修改行動電話";
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"行銷訊息訂閱管理";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
    
    if (indexPath.row == 0) {
        
        //先撈出資料
        //組Dic
        NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
        NSDictionary *dic = @{@"sessionId": sessionId};
        //撈資料
        __block NSData *returnData;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud showAnimated:YES whileExecutingBlock:^{
            
            PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
            returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_MAIL] AndDic:dic];
            
        } completionBlock:^{
            
            [hud show:NO];
            [hud hide:YES];
            
            //資料為空
            if (returnData == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
                
            }else {
                NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                NSLog(@"testStr -- %@", testStr);
                PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];
                NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
                NSLog(@"returnDic -- %@", returnDic);
                
                if (returnDic == nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
                    [alert show];
                    
                    return;
                }
                
                //儲存sessionId
                NSString *sessionId = [returnDic objectForKey:@"sessionId"];
                [IHouseUtility saveSessionIDToUserDefaults:sessionId];
                
                BOOL status = [[returnDic objectForKey:@"status"] integerValue];
                
                NSLog(@"status -- %zd", status);
                
                if (status == NO) {
                    //狀態失敗 直接顯示回傳的訊息
                    NSString *msg = [returnDic objectForKey:@"msg"];
                    
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
                    [av show];
                    
                    return;
                    
                }else {
                    //成功
                    //push到其他頁面
                    EditEmailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EditEmailView"];
                    vc.dicData = [returnDic objectForKey:@"data"];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    
                    // GA -- 修改電子郵件
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    
                    // 記畫面
                    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/edit_email"]];
                    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
                    
                    // 記事件
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/edit_email"]
                                                                          action:@"button_press"
                                                                           label:nil
                                                                           value:nil] build]];
                }
            }
        }];

    }else if (indexPath.row == 1) {
        
        //先撈出資料
        //組Dic
        NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
        NSDictionary *dic = @{@"sessionId": sessionId};
        //撈資料
        __block NSData *returnData;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud showAnimated:YES whileExecutingBlock:^{
            
            PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
            returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_PHONE] AndDic:dic];
            
        } completionBlock:^{
            
            [hud show:NO];
            [hud hide:YES];
            
            //資料為空
            if (returnData == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
                
            }else {
                NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                NSLog(@"testStr -- %@", testStr);
                PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

                NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
                NSLog(@"returnDic -- %@", returnDic);
                
                if (returnDic == nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
                    [alert show];
                    
                    return;
                }
                
                //儲存sessionId
                NSString *sessionId = [returnDic objectForKey:@"sessionId"];
                [IHouseUtility saveSessionIDToUserDefaults:sessionId];
                
                BOOL status = [[returnDic objectForKey:@"status"] integerValue];
                
                NSLog(@"status -- %zd", status);
                
                if (status == NO) {
                    //狀態失敗 直接顯示回傳的訊息
                    NSString *msg = [returnDic objectForKey:@"msg"];
                    
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
                    [av show];
                    
                    return;
                    
                }else {
                    //成功
                    //push到其他頁面
                    EditPhoneViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EditPhoneView"];
                    vc.dicData = [returnDic objectForKey:@"data"];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    // GA -- 修改行動電話
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    
                    
                    // 記畫面
                    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/edit_phone"]];
                    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
                    
                    // 記事件
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/edit_phone"]
                                                                          action:@"button_press"
                                                                           label:nil
                                                                           value:nil] build]];
                }
            }
        }];

        
        
    }else if (indexPath.row == 2) {
        //先撈出資料
        //組Dic
        NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
        NSDictionary *dic = @{@"sessionId": sessionId};
        //撈資料
        __block NSData *returnData;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud showAnimated:YES whileExecutingBlock:^{
            
            PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
            returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_SUBSCRIBE] AndDic:dic];
            
        } completionBlock:^{
            
            [hud show:NO];
            [hud hide:YES];
            
            //資料為空
            if (returnData == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
                
            }else {
                NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                NSLog(@"testStr -- %@", testStr);
                PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

                NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
                NSLog(@"returnDic -- %@", returnDic);
                
                if (returnDic == nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
                    [alert show];
                    
                    return;
                }
                
                //儲存sessionId
                NSString *sessionId = [returnDic objectForKey:@"sessionId"];
                [IHouseUtility saveSessionIDToUserDefaults:sessionId];
                
                BOOL status = [[returnDic objectForKey:@"status"] integerValue];
                
                NSLog(@"status -- %zd", status);
                
                if (status == NO) {
                    //狀態失敗 直接顯示回傳的訊息
                    NSString *msg = [returnDic objectForKey:@"msg"];
                    
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
                    [av show];
                    
                    return;
                    
                }else {
                    //成功
                    //push到其他頁面
                    SubscribeTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"SubscribeView"];
                    vc.arrayData = [returnDic objectForKey:@"data"];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    // GA -- 修改行銷訂閱管理
                    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                    
                    // 記畫面
                    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/subscription"]];
                    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
                    
                    // 記事件
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/subscription"]
                                                                          action:@"button_press"
                                                                           label:nil
                                                                           value:nil] build]];
                }
            }
        }];
        
    }
}

//加入空白的FooterView
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    //加入Footer view
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    return footerView;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
