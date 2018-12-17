//
//  PhoneValidationOfViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/18.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "PhoneValidationOfViewController.h"

@interface PhoneValidationOfViewController ()

@end

@implementation PhoneValidationOfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self holaBackCus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void) backAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// overwite parent method
-(void)changePhoneButtonText{
    //按下確認送出後，button title改為重新發送
    [self.phoneButton setTitle:@"重新發送" forState:UIControlStateNormal];
}

#pragma mark - 退回鍵盤
-(void)tap:(id)sender
{
    [self.view endEditing:YES];
    self.viewConstraint.constant=-20;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //for hola view height constraint tag
    if (self.validateTagConstraint) {
        self.viewConstraint.constant=-90;
    }
}
@end
