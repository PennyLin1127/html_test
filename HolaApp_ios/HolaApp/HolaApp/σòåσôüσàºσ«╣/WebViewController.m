//
//  WebViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/26.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "WebViewController.h"
#import "NSDefaultArea.h"

@interface WebViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self holaBackCus];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // add web view
    NSURL *url=[NSURL URLWithString:[[NSDefaultArea GetBtoURLFromUserDefault]objectForKey:@"btoURL"]];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.webView.delegate=self;
    [self.webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Load Finish");
    webView.hidden = NO;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
