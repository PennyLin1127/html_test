//
//  QueryBonusViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "QueryBonusViewController.h"
#import "AsyncImageView.h"

#import "IHouseUtility.h"
#import "IHouseURLManager.h"
#import "PerfectAPIManager.h"

@interface QueryBonusViewController (){
    NSUserDefaults *userDefaults;
    
    //是否已經取得資料
    BOOL haveBounsData; // YES-已經成功取得資料
    BOOL haveProductData;
}
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPoint;

@property (weak, nonatomic) IBOutlet UILabel *openURLLabel;

// 左上4 右上1 左下2 右下3
@property (weak, nonatomic) IBOutlet AsyncImageView *product4ImageView;
@property (weak, nonatomic) IBOutlet AsyncImageView *product1ImageView;
@property (weak, nonatomic) IBOutlet AsyncImageView *product2ImageView;
@property (weak, nonatomic) IBOutlet AsyncImageView *product3ImageView;

@property (weak, nonatomic) IBOutlet UILabel *product4NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *product1NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *product2NameLabel;
@property (weak, nonatomic) IBOutlet UILabel *product3NameLabel;
@end

@implementation QueryBonusViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //init label
    userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *name = [userDefaults objectForKey:USER_REAL_NAME];
    NSString *name = [userDefaults objectForKey:USER_NAME];

    NSLog(@"name -- %@", name);
    self.nameLabel.text = name;
    
    //trihomelabel
    self.openURLLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openTrihomeURL)];
    [self.openURLLabel addGestureRecognizer:tap];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

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

#pragma mark - 取得資料

-(void) getData {
 
    haveBounsData = NO;
    if (haveBounsData == NO) {
        //撈出點數資料
        [self getBounsList];
    }
   
    if (haveProductData == NO) {
        //撈出商品資料
        [self performSelectorInBackground:@selector(getProductInfo) withObject:nil];
    }
}

-(void) getBounsList {
    //組成Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId, @"page": @"1"};
    
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_BOUNS_LIST] AndDic:dic];
        
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
                NSInteger pointUnusedTotal = [[dicData objectForKey:@"pointUnusedTotal"] integerValue];
                self.totalPoint.text = [NSString stringWithFormat:@"%zd", pointUnusedTotal];
                
                NSLog(@"成功 點數 -- %zd", pointUnusedTotal);
                haveBounsData = YES;//成功撈取資料 改變flag
            }
        }
    }];

}

//取得下方商品資訊
-(void) getProductInfo {
    //組Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId};
    
    //撈資料
    NSData *returnData;
    
    PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
    returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_BONUS] AndDic:dic];
    
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
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            //
            //            [alert show];
            
            return;
        }
        
        //儲存sessionId
        NSString *sessionId = [returnDic objectForKey:@"sessionId"];
        [IHouseUtility saveSessionIDToUserDefaults:sessionId];
        
        BOOL status = [[returnDic objectForKey:@"status"] integerValue];
        
        NSLog(@"status -- %zd", status);
        
        if (status == NO) {
            //狀態失敗 直接顯示回傳的訊息
            //NSString *msg = [returnDic objectForKey:@"msg"];
            //
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            //
            //            [alert show];
            
            return;
        }else {
            //成功
            NSArray *arrayData = [returnDic objectForKey:@"data"];
            
            for (NSInteger i = 0; i < arrayData.count; i++ ) {
                NSDictionary *dicData = arrayData[i];
                NSString *productName =  [dicData objectForKey:@"prdName"];
                NSString *url = [dicData objectForKey:@"img"];

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    
                    if (i == 0) {
                        self.product4NameLabel.text = productName;
                        self.product4ImageView.imageURL = [NSURL URLWithString:url];
                    }else if (i == 1) {
                        self.product1NameLabel.text = productName;
                        self.product1ImageView.imageURL = [NSURL URLWithString:url];
                    }else if (i == 2) {
                        self.product2NameLabel.text = productName;
                        self.product2ImageView.imageURL = [NSURL URLWithString:url];
                    }else if (i == 3) {
                        self.product3NameLabel.text = productName;
                        self.product3ImageView.imageURL = [NSURL URLWithString:url];
                    }
                });
                
                haveProductData = YES; //成功撈取資料 改變flag
            }
            
        }
    }
}
/*
 {
 "status": true,
 "code": "S001",
 "msg": "查詢成功",
 "sessionId": "4af3e075eb912244cbd20347a462755c",
 "data": [
 {
 "prdName": "南僑水晶肥皂3入",
 "img": "http://www.trihome.com.tw/pub/img/html/bonusgift_TLW-1.jpg"
 },
 {
 "prdName": "E-mark 6PCS 精密起子組",
 "img": "http://www.trihome.com.tw/pub/img/html/bonusgift_TLW-2.jpg"
 },
 {
 "prdName": "微笑吊籃-中(隨機混色)",
 "img": "http://www.trihome.com.tw/pub/img/html/bonusgift_TLW-3.jpg"
 },
 {
 "prdName": "Very超值3孔2座單切電源安全小壁插1入",
 "img": "http://www.trihome.com.tw/pub/img/html/bonusgift_TLW-4.jpg"
 }
 ]
 }
 */

#pragma mark - Open URL
-(void)openTrihomeURL {
    NSLog(@"openTrihomeURL");
    NSURL *url = [NSURL URLWithString:TRIHOME_URL];
    [[UIApplication sharedApplication] openURL:url];
}

@end

