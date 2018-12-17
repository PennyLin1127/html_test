//
//  EditPhoneViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "EditPhoneViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "EditPhoneValidationViewController.h"
@interface EditPhoneViewController () {
    BOOL showPhone; //YES - 為顯示完整電話
    NSUserDefaults *userDefaults;
}

@property (weak, nonatomic) IBOutlet UILabel *hiLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UIView *topView;

- (IBAction)sendAction:(id)sender;
- (IBAction)showAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *showButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldViewTopConstraint;

@end

@implementation EditPhoneViewController

#pragma mark - View生命週期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //init var
    userDefaults = [NSUserDefaults standardUserDefaults];
    showPhone = NO;
    
    //init hiLabel
    NSString *name = [userDefaults objectForKey:USER_NAME];
    self.hiLabel.text = [NSString stringWithFormat:@"Hi %@ 您好\n提醒您，為避免您錯失電子發票中獎及會員重要權益通知，請確實填寫。",name];

    //phone label
    NSString *phone = [self.dicData objectForKey:@"cellPhone"];
    self.phoneLabel.text = [NSString stringWithFormat:@"目前留存:%@",phone];
    
    //verificationDate
    NSString *verificationDate = [self.dicData objectForKey:@"verificationDate"];
    self.timeLabel.text = verificationDate;
    
    //delegate
    self.phoneTextField.delegate = self;
    
    //退回鍵盤
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGesture];
    
//    //設置退回按鈕
//    [self setBackButton];
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

- (IBAction)sendAction:(id)sender {
    
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
                //成功導向另外頁面
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
                EditPhoneValidationViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EditPhoneValidationView"];
                vc.phoneStr = self.phoneTextField.text;
//                NSDictionary *dicData = [returnDic objectForKey:@""];
                
                [self.navigationController pushViewController:vc animated:YES];
                
            }
        }
    }];

    
}

/*
 送的資料
 {
 "sessionId": "4af3e075eb912244cbd20347a462755c",
 "cellPhone": "0977360953"
 }
 */

- (IBAction)showAction:(id)sender {
    
    if (showPhone == YES) {
        NSString *phone = [self.dicData objectForKey:@"cellPhone"];
        self.phoneLabel.text = [NSString stringWithFormat:@"目前留存:%@",phone];
        showPhone = NO;
        [self.showButton setTitle:@"(顯示)" forState:UIControlStateNormal];
    }else {
        NSString *phone = [self.dicData objectForKey:@"realCellPhone"];
        self.phoneLabel.text = [NSString stringWithFormat:@"目前留存:%@",phone];
        showPhone = YES;
        [self.showButton setTitle:@"(隱藏)" forState:UIControlStateNormal];
    }
}


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
    self.textFieldViewTopConstraint.constant = -self.topView.frame.size.height;
}

-(void)keyboardWillHide {
    self.textFieldViewTopConstraint.constant = 0;
}

@end
