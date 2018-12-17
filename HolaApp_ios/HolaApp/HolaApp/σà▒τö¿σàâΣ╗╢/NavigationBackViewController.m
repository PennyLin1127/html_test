//
//  NavigationBackViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/2/11.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
// 2015-05-01 Henry 修正左上方選單圖示
//

#import "NavigationBackViewController.h"
#import "MenuTableViewInViewController.h"

@interface NavigationBackViewController ()

@end

@implementation NavigationBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(back)];
    
    
    [barBtnItem setImage:image1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back{
    // pop to root
     [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
