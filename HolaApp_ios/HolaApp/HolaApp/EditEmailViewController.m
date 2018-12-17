//
//  EditEmailViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "EditEmailViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"

@interface EditEmailViewController () {
    BOOL showEmail;//YES - 顯示詳細的Email
    NSUserDefaults *userDefaults;
}
@property (weak, nonatomic) IBOutlet UIView *hiView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twoLabelViewHeightsConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twoLabelViewTopCinstraint;

@property (weak, nonatomic) IBOutlet UILabel *hiLablel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UILabel *buttonLabel;
- (IBAction)sendAction:(id)sender;
- (IBAction)showAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *showButton;

@end

@implementation EditEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //TextField delegate
    self.emailTextField.delegate = self;
    
    //退回鍵盤
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGesture];
    
    //init var
    userDefaults = [NSUserDefaults standardUserDefaults];
    showEmail = YES;
    
    //初始化Label
    //Name
    NSString *name = [userDefaults objectForKey:USER_NAME];
    self.hiLablel.text = [NSString stringWithFormat:@"Hi %@ 您好\n提醒您，為避免您錯失電子發票中獎及會員重要權益通知，請確實填寫。",name];
    
    
    //account
    NSString *account = [self.dicData objectForKey:@"email"];
    self.accountLabel.text = [NSString stringWithFormat:@"目前留存:%@", account];
    
    //認證
    NSString *verificationDate = [self.dicData objectForKey:@"verificationDate"];
    if (verificationDate == nil || [verificationDate isEqualToString:@""]) {
        self.timeLabel.text = @"認證時間:未認證";
    }else {
        self.timeLabel.text = [NSString stringWithFormat:@"認證時間:%@", verificationDate];
    }
    
    //設置退回按鈕
//    [self setBackButton];
    
    //UI
    //[self.showButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button 事件
- (IBAction)sendAction:(id)sender {

    NSString *email = self.emailTextField.text;
    if (email == nil || [email isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Email必須輸入" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    if ([IHouseUtility stringIsValidEmail:email] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請輸入正確的Email" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        
        return;

    }
    
    
    
    //組成Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId, @"email": email};
    
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_MAILModify] AndDic:dic];
        
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"訊息" message:@"修改成功" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;

            }
        }
    }];

    
    [self changeLabel];
}

- (IBAction)showAction:(id)sender {
    if (showEmail == YES) {
    
        //account
        NSString *account = [self.dicData objectForKey:@"realEmail"];
        self.accountLabel.text = [NSString stringWithFormat:@"目前留存:%@", account];
        
        showEmail = NO;
        
        [self.showButton setTitle:@"(隱藏)" forState:UIControlStateNormal];
    }else {
        
        //account
        NSString *account = [self.dicData objectForKey:@"email"];
        self.accountLabel.text = [NSString stringWithFormat:@"目前留存:%@", account];
        
        showEmail = YES;
        [self.showButton setTitle:@"(顯示)" forState:UIControlStateNormal];
    }
}

//成功後改變UI與Label
-(void)changeLabel {
    //改變Button Label
    self.buttonLabel.text = @"重新發送";
    
    //Name
    NSString *name = [userDefaults objectForKey:USER_NAME];
    self.hiLablel.text = [NSString stringWithFormat:@"Hi %@ 您好\n認證信已發送至您的電子信箱!請至您指定之信箱收取驗證信函，依提示完成郵件確認。",name];
    
    //調整View
    self.twoLabelViewHeightsConstraint.constant = 0;
//    self.twoLabelViewHeightsConstraint.multiplier = 1.0;
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
    self.twoLabelViewTopCinstraint.constant = -self.hiView.frame.size.height;
}

-(void)keyboardWillHide {
    self.twoLabelViewTopCinstraint.constant = 0;
}


@end
