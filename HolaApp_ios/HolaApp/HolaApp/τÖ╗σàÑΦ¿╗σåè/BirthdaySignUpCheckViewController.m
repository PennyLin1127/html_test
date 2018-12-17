//
//  BirthdaySignUpCheckViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/12.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "BirthdaySignUpCheckViewController.h"

@interface BirthdaySignUpCheckViewController ()

@end

@implementation BirthdaySignUpCheckViewController

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


@end
