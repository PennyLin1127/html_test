////
////  SettingsWebViewController.m
////  HolaApp
////
////  Created by Joseph on 2015/4/14.
////  Copyright (c) 2015年 JimmyLiu. All rights reserved.
////
//
//#import "SettingsWebViewController.h"
//#import "NSDefaultArea.h"
//
//@interface SettingsWebViewController ()<UIWebViewDelegate>
//
//@end
//
//@implementation SettingsWebViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    [self holaBackCus];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//
//-(void)viewDidAppear:(BOOL)animated{
//    // add web view
//    NSURL *url=[NSURL URLWithString:[[NSDefaultArea GetBtoURLFromUserDefault]objectForKey:@"settingURL"]];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    self.webView.delegate=self;
//    [self.webView loadRequest:requestObj];
//}
//
//
//// HOLA back button
//- (void)holaBackCus {
//    
//    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    
//    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:@""
//                                                                   style:UIBarButtonItemStylePlain
//                                                                  target:self
//                                                                  action:@selector(backAction)];
//    [barBtnItem setImage:image1];
//    self.navigationItem.leftBarButtonItem = barBtnItem;
//    
//}
//
//-(void) backAction {
//    [self.navigationController popViewControllerAnimated:YES];
//}
//
//
//@end
