//
//  ServiceNotLoginViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/6.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ServiceNotLoginViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "MemberLoginViewController.h"
#import "MyViewController.h"
@interface ServiceNotLoginViewController () {
    BOOL isMember; //YES - 是會員
    NSArray *classArray;
    
    BOOL haveData; //YES - 已經取得過資料
    
    //Pick View
    UIView *itemPickerView;
    UIPickerView *itemPicker;
    
    NSUserDefaults *userDefaults;
    
    NSArray *clssArray;
    
    BOOL isShowPicker;//當前是否顯示picker
}

@property (weak, nonatomic) IBOutlet UIButton *isMemberButton;
@property (weak, nonatomic) IBOutlet UIButton *notMemberButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;


- (IBAction)isMemberAction:(id)sender;
- (IBAction)notMemBerAction:(id)sender;
- (IBAction)choiceClassAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *classImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
- (IBAction)submitAction:(id)sender;
@end

@implementation ServiceNotLoginViewController

#pragma mark - View生命週期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
    
    //退回鍵盤
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGesture];
    
    //delegate
    self.nameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.phoneTextField.delegate = self;
    self.subjectTextField.delegate = self;
    self.questionTextView.delegate = self;
    
    //init other var
    userDefaults = [NSUserDefaults standardUserDefaults];
    classArray = [[NSArray alloc] init];
    
    //classImageView 加入整條事件
    self.classImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapClass = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choiceClassAction:)];
    [self.classImageView addGestureRecognizer:tapClass];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //非會員選項設置
    isMember = NO;
    
    UIImage *image_Check = [UIImage imageNamed:@"AutologinEnable"];
    UIImage *image_NotCheck = [UIImage imageNamed:@"AutologinDisable"];
    
    [self.isMemberButton setImage:image_NotCheck forState:UIControlStateNormal];
    [self.notMemberButton setImage:image_Check forState:UIControlStateNormal];
    
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

- (IBAction)isMemberAction:(id)sender {
    isMember = YES;
    
    UIImage *image_Check = [UIImage imageNamed:@"AutologinEnable"];
    UIImage *image_NotCheck = [UIImage imageNamed:@"AutologinDisable"];
    
    [self.isMemberButton setImage:image_Check forState:UIControlStateNormal];
    [self.notMemberButton setImage:image_NotCheck forState:UIControlStateNormal];
    
    //導向登入畫面
    //[self pushToLoginVC];
    MyViewController *vc = (MyViewController*)self.parentViewController;
    [vc pushToLoginVC];
}

- (IBAction)notMemBerAction:(id)sender {
    isMember = NO;
    
    UIImage *image_Check = [UIImage imageNamed:@"AutologinEnable"];
    UIImage *image_NotCheck = [UIImage imageNamed:@"AutologinDisable"];
    
    [self.isMemberButton setImage:image_NotCheck forState:UIControlStateNormal];
    [self.notMemberButton setImage:image_Check forState:UIControlStateNormal];
}

- (IBAction)choiceClassAction:(id)sender {
    
    if (isShowPicker == NO) {
        isShowPicker = YES;
        
        if (classArray.count > 0) {
            CGRect rect = self.view.frame;
            //PickerView
            itemPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height-194, rect.size.width, 194)];
            [itemPickerView setBackgroundColor:[UIColor whiteColor]];;
            
            UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 32)];
            [btnView setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
            
            UIButton *btnOK = [[UIButton alloc] initWithFrame:CGRectMake(btnView.frame.size.width-12-44, 6, 44, 20)];
            [btnOK setTitle:@"Done" forState:UIControlStateNormal];
            [btnOK addTarget:self action:@selector(okAction) forControlEvents:UIControlEventTouchUpInside];
            [btnOK setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
            [btnView addSubview:btnOK];
            
            UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(12, 6, 56, 20)];
            [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
            [btnCancel setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
            [btnCancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
            [btnView addSubview:btnCancel];
            
            itemPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 32, rect.size.width, 162)];
            itemPicker.delegate = self;
            
            //add subView
            
            [itemPickerView addSubview:itemPicker];
            [itemPickerView addSubview:btnView];
            [self.view addSubview:itemPickerView];
            
        }else {
            //無資料不給選擇
            isShowPicker = NO;
            return;
        }
    }
}


#pragma mark - 撈資料
-(void) getData {
    
    if (haveData == NO) {
        
        //組成Dic
        NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
        NSDictionary *dic = @{@"sessionId": sessionId};
        
        //撈資料
        __block NSData *returnData;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud showAnimated:YES whileExecutingBlock:^{
            
            PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
            returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:SERVICE_FAQ_CATEGORY] AndDic:dic];
            
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
                    NSArray *dicArray = [returnDic objectForKey:@"data"];
                    classArray = dicArray;
                    
                    if (classArray.count > 0) {
                        NSDictionary *temp = classArray[0];
                        NSString *categoryName = [temp objectForKey:@"categoryName"];
                        self.classLabel.text = categoryName;
                        
                        haveData = YES;//成功取得資料 變更flag
                    }
                }
            }
        }];
        
    }else {
        NSLog(@"已經有資料，不用再撈");
    }
    
    
}
#pragma mark - 設置UI
-(void)configUI {
    //TextField
    //TextField
    self.nameTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.nameTextField.layer.borderWidth = 1.5;
    self.nameTextField.layer.cornerRadius = 8;
    
    self.emailTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.emailTextField.layer.borderWidth = 1.5;
    self.emailTextField.layer.cornerRadius = 8;
    
    self.phoneTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.phoneTextField.layer.borderWidth = 1.5;
    self.phoneTextField.layer.cornerRadius = 8;
    
    self.subjectTextField.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.subjectTextField.layer.borderWidth = 1.5;
    self.subjectTextField.layer.cornerRadius = 8;
    
    self.questionTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.questionTextView.layer.borderWidth = 1.5;
    self.questionTextView.layer.cornerRadius = 8;
    
}

#pragma mark - 鍵盤 methord
-(void)keyboardWillShow {
    self.scrollViewBottomConstraint.constant = 260;
}

-(void)keyboardWillHide {
    self.scrollViewBottomConstraint.constant = 20;
}

-(void)tap:(id)sender
{
    [self.view endEditing:YES];
    [itemPickerView removeFromSuperview];
    isShowPicker = NO;
}

//pickView 按鈕事件
-(void)cancelAction {
    NSLog(@"cancelAction");
    [itemPickerView removeFromSuperview];
    isShowPicker = NO;
}

-(void)okAction {
    NSLog(@"okAction");
    NSInteger index =  [itemPicker selectedRowInComponent:0];
    
    if (index == -1) { // nothing selected
        NSDictionary *dic = [classArray objectAtIndex:0];
        NSString *categoryName = [dic objectForKey:@"categoryName"];
        self.classLabel.text = categoryName;
    }else {
        NSDictionary *dic = [classArray objectAtIndex:index];
        NSString *categoryName = [dic objectForKey:@"categoryName"];
        NSLog(@"categoryName -- %@", categoryName);
        self.classLabel.text = categoryName;
    }
    
    [itemPickerView removeFromSuperview];
    isShowPicker = NO;    
}

#pragma mark - UIPickerView delegate
//幾個轉軸
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
//轉軸有多少個資料
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return classArray.count;
}

//每個row的資料
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSDictionary *dic = [classArray objectAtIndex:row];
    NSString *categoryName = [dic objectForKey:@"categoryName"];
    
    return categoryName;
}

//選擇資料
//-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    NSDictionary *dic = [classArray objectAtIndex:row];
//    NSString *categoryName = [dic objectForKey:@"categoryName"];
//    self.classLabel.text = categoryName;
//}

#pragma mark - 按鍵事件
- (IBAction)submitAction:(id)sender {
    //檢查資料
    NSString *name = self.nameTextField.text;
    if (name == nil || [name isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請輸入姓名" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *email = self.emailTextField.text;
    if (email == nil || [email isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請輸入電子郵件" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    BOOL isCorrectEmail = [IHouseUtility stringIsValidEmail:email];
    if (isCorrectEmail == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"輸入的電子郵件不正確" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *phone = self.phoneTextField.text;
    if (phone == nil || [phone isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請輸入聯絡電話" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *className = self.classLabel.text;
    if (className == nil || [className isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請輸入詢問類別" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *subject = self.subjectTextField.text;
    if (subject == nil || [subject isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請輸入詢問主旨" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *question = self.questionTextView.text;
    if (question == nil || [question isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請輸入問題內容" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //組成Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    
    NSInteger categoryId = 1;
    for (NSDictionary *tempDic in classArray ) {
        NSString *tempStr = [tempDic objectForKey:@"categoryName"];
        if ([className isEqualToString:tempStr]) {
            categoryId = [[tempDic objectForKey:@"categoryId"] integerValue];
            break;
        }
    }
    
    NSDictionary *dic = @{@"sessionId": sessionId, @"name":name, @"email":email, @"phone":phone, @"categoryId":[NSString stringWithFormat:@"%zd", categoryId], @"serviceTitle":subject, @"serviceContent":question, @"orderNumber":@"", @"category":className, @"NotLogin": @"YES"};
    
    //發送資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:SERVICE_FORM] AndDic:dic];
        
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
                NSLog(@"成功提出問題");
                if ([self.delegate respondsToSelector:@selector(suceccToAskQuestionNotMember:)]) {
                    //把資料傳過去 成功頁面可以顯示
                    [self.delegate suceccToAskQuestionNotMember:dic];
                }
            }
        }
    }];
    
    
}

-(void)pushToLoginVC {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    MemberLoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MemberLogin"];
    
    UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
    
    vc.isDismissViewController=YES;
    vc.dontJumpToIndex = YES;
    vc.needToChangeMemberServiceVC = YES;
    [self presentViewController:myNavigation animated:YES completion:nil];
}

/*
 {
 "sessionId": "4af3e075eb912244cbd20347a462755c",
 "name": "許願貓",
 "email": "john.chang@testritegroup.com",
 "phone": "0287916668",
 "categoryId": 8,
 "serviceTitle": "測試主指",
 "serviceContent": "測試內容",
 "orderNumber": ""
 }
 */

@end
