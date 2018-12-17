//
//  VipViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "VipViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"

@interface VipViewController () {
    //是否已經取得資料
    BOOL haveData; // YES-已經成功取得資料
}
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;
@property (weak, nonatomic) IBOutlet UILabel *culmPeriodLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vipViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vipViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *vipView;

@end

@implementation VipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //init var
    haveData = NO;
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

#pragma mark - 撈資料
-(void) getData {
    haveData = NO;
    if (haveData == NO) {
        
        //組成Dic
        NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
        NSDictionary *dic = @{@"sessionId": sessionId, @"page": @"1"};
        
        //撈資料
        __block NSData *returnData;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud showAnimated:YES whileExecutingBlock:^{
            
            PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
            returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_VIP] AndDic:dic];
            
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
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
                    [alert show];
                    
                    return;
                    
                }else {
                    //成功
                    NSDictionary *dicData = [returnDic objectForKey:@"data"];
                    BOOL isVip = [[dicData objectForKey:@"vipMember"] boolValue];
                    
                    if (isVip) {
                        self.vipViewHeightConstraint.constant = 524;
                        //                    self.vipViewHeightConstraint.constant = 0;
                    }else {
                        self.vipViewHeightConstraint.constant = 0;
                        self.vipView.hidden = YES;
                    }
                    
                    NSString *vipPeriod = [dicData objectForKey:@"vipPeriod"];
                    NSString *vipCulmPeriod = [dicData objectForKey:@"vipCulmPeriod"];
                    NSString *vipAmount = [dicData objectForKey:@"vipAmount"];
                    
                    self.periodLabel.text = vipPeriod;
                    self.culmPeriodLabel.text = vipCulmPeriod;
                    self.amountLabel.text = vipAmount;
                    
                    haveData = YES; //成功取得資料 變更flag
                }
            }
        }];
        
    }else {
        NSLog(@"已經有資料，不用再撈");
    }
}

@end
