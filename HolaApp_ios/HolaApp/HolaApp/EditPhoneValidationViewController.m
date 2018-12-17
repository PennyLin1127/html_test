//
//  EditPhoneValidationViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/30.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "EditPhoneValidationViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"

@interface EditPhoneValidationViewController () {
    NSUserDefaults *userDefaults;
}

@property (weak, nonatomic) IBOutlet UILabel *hiLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
- (IBAction)resendAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *phoneCodeTextField;
- (IBAction)sendAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraint;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIView *hiView;


@end

@implementation EditPhoneValidationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    
    //textfield delegate
    self.phoneTextField.delegate = self;
    self.phoneCodeTextField.delegate = self;
    
    //初始化Label
    //Name
    NSString *name = [userDefaults objectForKey:USER_NAME];
    self.hiLabel.text = [NSString stringWithFormat:@"Hi %@ 您好~\n驗證碼已發送至您設定的手機門號!驗證碼於發送後10分鐘內有效！若您尚未收到，或已逾有效期限，請重新發送驗證碼。", name];
    
    //init var
    self.phoneTextField.text = self.phoneStr;
    
    //退回鍵盤
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGesture];
    
    //back
    [self holaBackCus];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //加入監聽事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //移除監聽事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

- (IBAction)resendAction:(id)sender {
    //驗證手機
    NSString *cellPhone = self.phoneTextField.text;
    
    if (cellPhone == nil || [cellPhone isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請輸入正確的手機號碼" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    //組Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId, @"cellPhone":cellPhone};
    
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_PHONE_MODIFY] AndDic:dic];
        
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"訊息" message:@"重新發送成功" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                [alert show];
                
            }
        }
    }];

    
}

- (IBAction)sendAction:(id)sender {
    
    //驗證資料
    NSString *phoneCode = self.phoneCodeTextField.text;
    if (phoneCode == nil || [phoneCode isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請輸入正確的驗證碼" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
        return;

    }
    
    //組dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId, @"phoneCode":phoneCode};

    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_VERIFI_PHONE] AndDic:dic];
        
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
                NSString *msg = [returnDic objectForKey:@"msg"];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"訊息" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                [self.navigationController popToRootViewControllerAnimated:YES];
                return;
                
            }
        }
    }];

}
/*
 {
 "sessionId": "4af3e075eb912244cbd20347a462755c",
 "phoneCode": "6251"
 }
 */

#pragma mark - textField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

-(void)tap:(id)sender
{
    [self.view endEditing:YES];
    
}

//鍵盤升起
#pragma mark - 鍵盤 methord
-(void)keyboardWillShow {
    self.bottomViewConstraint.constant = -self.phoneView.frame.size.height-self.hiView.frame.size.height;
}

-(void)keyboardWillHide {
    self.bottomViewConstraint.constant = 0;
}

#pragma mark - Navigation Bar
// HOLA back button
- (void)holaBackCus {
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    
}

-(void) backAction {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
