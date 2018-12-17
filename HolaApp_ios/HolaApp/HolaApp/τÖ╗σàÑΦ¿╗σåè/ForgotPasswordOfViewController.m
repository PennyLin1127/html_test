//
//  ForgotPasswordOfViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/19.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ForgotPasswordOfViewController.h"

@interface ForgotPasswordOfViewController ()

@end

@implementation ForgotPasswordOfViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self holaBackCus];
    [self setTitle:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// HOLA back button
- (void)holaBackCus {
 
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //2015-05-01 Henry 應該用initWithImage ,因為用 initWithTitle有時會造成系統重繪向下偏移
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = barBtnItem;

    
}

-(void) backAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
