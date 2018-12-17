//
//  CompareWebViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/30.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CompareWebViewController.h"
#import "NSDefaultArea.h"
@interface CompareWebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CompareWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self holaBackCus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    // add web view
    NSURL *url=[NSURL URLWithString:[[NSDefaultArea GetBtoURLFromUserDefault] objectForKey:@"btoURL"]];
    NSLog(@"urlgod %@",url);
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.webView.scalesPageToFit=YES;
    self.webView.delegate=self;
    [self.webView loadRequest:requestObj];
}

// HOLA back button
- (void)holaBackCus {
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    
}

-(void) backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Load Finish");
    webView.hidden = NO;
}
@end
