//
//  RegisterViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/2.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "RegisterViewController.h"
#import "SessionID.h"
#import "GetAndPostAPI.h"
#import "URLib.h"
#import "NSDefaultArea.h"
#import "WebViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
//    GetAndPostAPI *registerPostAPI;
    
    BOOL clickAccount;
    
}


//@property (weak, nonatomic) IBOutlet UITextField *inputID;


@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // init registerPostAPI
//    registerPostAPI=[[GetAndPostAPI alloc]init];
    
    // hide keyboard
    UITapGestureRecognizer *gestureRecognizer= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    //
    clickAccount=YES;
    
    if (self.popToVCTagBOOL) {
        [self holaBackCus2];
        self.popToVCTagBOOL=NO;
    }
    else{
        [self holaBackCus];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)hideKeyboard{
    [self.view endEditing:YES];
}

// HOLA back button
- (void)holaBackCus {
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    
}

-(void)backAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)holaBackCus2 {
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction2)];
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    
}

-(void)backAction2{
    [self.navigationController popViewControllerAnimated:YES];
}

// 連結到 特力愛家卡會員條款
- (IBAction)openWebURL:(id)sender {
    
    NSString *URLStr=@"http://www.trihome.com.tw/service/rules";
    NSDictionary *urlDic= @{@"btoURL": URLStr};
    [NSDefaultArea btoURLToUserDefault:urlDic];
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
    WebViewController *vc=[sb instantiateViewControllerWithIdentifier:@"WebViewVC"];
    [self.navigationController pushViewController:vc animated:YES];
    
//    NSURL *url = [ [ NSURL alloc ] initWithString: @"http://www.trihome.com.tw/service/faq" ];
//    
//    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)readAndAgree:(id)sender {

    UIButton *button=sender;
    if (clickAccount==YES) {
        [button setImage:[UIImage imageNamed:@"Agree"] forState:UIControlStateNormal];
        clickAccount=NO;
    }else if(clickAccount==NO){
        [button setImage:[UIImage imageNamed:@"Agree_2"] forState:UIControlStateNormal];
        clickAccount=YES;
    }

}

//- (IBAction)sendID:(id)sender {
//    
//    NSDictionary *dic=@{@"sessionId":[SessionID getSessionID],@"personalIdentity":self.inputID.text};
//    NSData *getRawData=[registerPostAPI syncPostData:HOLA_JOINREGISTER dicBody:dic];
//    NSLog(@"raw data %@",getRawData);
//    
//    NSString *myString = [[NSString alloc] initWithData:getRawData encoding:NSUTF8StringEncoding];
//    NSLog(@"myString %@",myString);
//
//    if (getRawData) {
//        // set NSData to dictionary
//        NSDictionary *flashData = [registerPostAPI NSDataToDic:getRawData];
//        NSLog(@"status is : %@",[flashData valueForKey:@"memberStatus"]);
//        
//    }
//}


@end
