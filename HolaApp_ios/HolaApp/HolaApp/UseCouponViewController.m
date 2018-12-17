//
//  UseCouponViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/14.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "UseCouponViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "PerfectAPIManager.h"

@interface UseCouponViewController ()
@property (weak, nonatomic) IBOutlet UILabel *cardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *useCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *submitLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cancelLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertLabel;

- (IBAction)submitAction:(id)sender;
- (IBAction)closeAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

@implementation UseCouponViewController
#pragma mark - View生命週期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init
    //使用張數
    self.useCountLabel.text = [NSString stringWithFormat:@"%zd", self.useCount];
    
    //總金額
    NSInteger price = [[self.dicData objectForKey:@"Price"] integerValue];
    NSInteger totalPrice = price * self.useCount;
    self.moneyLabel.text = [NSString stringWithFormat:@"%zd", totalPrice];
    
    //共有幾張
    NSArray *tempArray = [self.dicData objectForKey:@"DISCOUNTID"];
    self.totalCountLabel.text = [NSString stringWithFormat:@"%zd", tempArray.count];
    
    //會員編號
    NSString *cardNumber = [[NSUserDefaults standardUserDefaults] objectForKey:USER_CARD_NUMBER];
    self.cardNumberLabel.text = [NSString stringWithFormat:@"會員卡號:%@", cardNumber];
    
    //一開始先隱藏關閉按鈕
    self.closeButton.hidden = YES;
    self.closeLabel.hidden = YES;
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
#pragma mark - Button Event
- (IBAction)submitAction:(id)sender {
    
    [self useCoupon];
    
}

- (IBAction)closeAction:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if (self.finishCallBack) {
        
        self.finishCallBack ();
        NSLog(@"finishCallBack");
    }else {
        NSLog(@"call back為空");
    }

}

- (IBAction)cancelAction:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - send data
//取得 我的折價劵 - 限門市使用
-(void) useCoupon {
    
    if (self.isForStore == YES) {
        //組成Dic
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //2015-05-25 Henry -> USER_CARD_NUMBER to USER_CRM_MEMBER_ID
        NSString *memberCard = [userDefaults objectForKey:USER_CRM_MEMBER_ID];
        
        //DISCOUNTID
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        NSArray *temp = [self.dicData objectForKey:@"DISCOUNTID"];
        for (NSInteger i=0; i<self.useCount; i++) {
            [tempArray addObject:[temp objectAtIndex:i]];
        }
        
        NSDictionary *dic = @{@"MemberCardID": memberCard, @"Source":@"iOS", @"DISCOUNTID":tempArray};
        
        
        //傳送資料
        //撈資料 - 撈老闆後台
        __block NSData *returnData;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud showAnimated:YES whileExecutingBlock:^{
            
            PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
            returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getPerfectURLByAppName:USE_COUPON_BY_MEMBER_CARD] AndDic:dic];
            
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
                
                if (returnDic == nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"折價劵使用失敗" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
                    [alert show];
                    return;
                }
                
                NSString *status = [returnDic objectForKey:@"Status"];
                
                if ([status isEqualToString:@"OK"]) {
                    //成功
                    self.submitButton.hidden = YES;
                    self.submitLabel.hidden = YES;
                    
                    self.cancelLabel.hidden = YES;
                    self.cancelButton.hidden = YES;
                    
                    self.alertLabel.hidden = YES;
                    
                    self.closeButton.hidden = NO;
                    self.closeLabel.hidden = NO;
                    
                  
                    
                }else {
                    NSLog(@"失敗");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"折價劵使用失敗" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
                    [alert show];
                    return;
                }
                
            }
        }];
        
    }else {
        
        //傳送使用共用折價劵--撈hola api
        
        //組成Dic
        NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
#warning Henry there is a crash with CountArray nil
//        NSArray *couponIdArray = [self.dicData objectForKey:@"CountArray"];
    
        NSArray *couponIdArray = [self.dicData objectForKey:@"DISCOUNTID"];
//        NSLog(@"DICDATA %@",self.dicData);

        if (couponIdArray != nil) {
            NSMutableArray *sendArray = [[NSMutableArray alloc] init];
            for (NSInteger i=0; i<self.useCount; i++) {
                [sendArray addObject:couponIdArray[i]];
            }
      
            NSDictionary *dic = @{@"sessionId":sessionId, @"couponIds":couponIdArray};
            
            //傳送資料
            __block NSData *returnData;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [hud showAnimated:YES whileExecutingBlock:^{
                
                PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
                returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_COUPON_SET_USED] AndDic:dic];
                
            } completionBlock:^{
                
                [hud show:NO];
                [hud hide:YES];
                PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

                NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
                NSLog(@"returnDic -- %@", returnDic);
                
                
                if (returnDic == nil) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    
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
                    
                    [self removeFromParentViewController];
                    [self.view removeFromSuperview];
                    
                    return;
                    
                }else {
                    //成功
                    PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

                    NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
                    NSLog(@"returnDic -- %@", returnDic);
                    
                    
                    //成功
                    self.submitButton.hidden = YES;
                    self.submitLabel.hidden = YES;
                    
                    self.cancelLabel.hidden = YES;
                    self.cancelButton.hidden = YES;
                    
                    self.alertLabel.hidden = YES;
                    
                    self.closeButton.hidden = NO;
                    self.closeLabel.hidden = NO;
                    
                    
                    
                }
            }];
        }
        
        
    }
    
    
}

@end
