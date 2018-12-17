//
//  MemberAcountRegisterViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/2/16.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "MemberLoginViewController.h"
#import "PerfectPushManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"


@interface MemberLoginViewController ()<UITextFieldDelegate,UIGestureRecognizerDelegate>
{
//    BOOL clickAccount;
}

@end

@implementation MemberLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
//    clickAccount=YES;
    
    // set navigationbar color
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:116.0/255.0 green:79.0/255.0 blue:40.0/255.0 alpha:1.0f];
    
    // set TextField border color
    [self.accountTextField.layer setCornerRadius:5];
    [self.accountTextField.layer setBorderWidth:1.5];
    [self.accountTextField.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.passwordTextField.layer setCornerRadius:5];
    [self.passwordTextField.layer setBorderWidth:1.5];
    [self.passwordTextField.layer setBorderColor:[UIColor grayColor].CGColor];
    
    // hide keyboard
    UITapGestureRecognizer *gestureRecognizer= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:gestureRecognizer];
    // hola back
    [self holaBackCus];
    
//    [PerfectPushManager sendDeviceTokenToServer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)hideKeyboard{
    [self.view endEditing:YES];
}



-(void)loginSuccess:(BOOL)isSuccess {
//    [super loginSuccess:isSuccess];

    if (isSuccess) {
        [PerfectPushManager sendDeviceTokenToServer];
    }else{
        return;
    }
}


//// HOLA back button
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    // replace pic to backIndicator
//    NSString *back = @"Back";
//    if ([UINavigationBar instancesRespondToSelector:@selector(setBackIndicatorImage:)]) {
//        UIImage *image = [[UIImage imageNamed:@"LOGO_2"] imageWithAlignmentRectInsets:UIEdgeInsetsMake(10, 0, 8, 0)];
//        
//        [self.navigationController.navigationBar setBackIndicatorImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:image];
//        back = @"";
//    }
//    
//    // set empty string to title (hide back string)
//    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:back
//                                                                   style:UIBarButtonItemStyleBordered
//                                                                  target:self
//                                                                  action:nil];
//    self.navigationItem.backBarButtonItem = barBtnItem;
//    
//}


// HOLA back button
- (void)holaBackCus {
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;

}


//- (IBAction)rememberAccount:(id)sender {
//    
//    UIButton *button=sender;
//    if (clickAccount==YES) {
//        [button setImage:[UIImage imageNamed:@"arrow_1"] forState:UIControlStateNormal];
//        clickAccount=NO;
//    }else if(clickAccount==NO){
//        [button setImage:[UIImage imageNamed:@"arrow_2"] forState:UIControlStateNormal];
//        clickAccount=YES;
//    }
//    
//}

-(void)backAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"mem");
}

-(void)loginForHOLA{
    // GA -- 登入
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/login"]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/login"]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
}

- (IBAction)registerAction:(id)sender{
    
    // GA -- 註冊
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/register"]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/register"]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
}


@end
