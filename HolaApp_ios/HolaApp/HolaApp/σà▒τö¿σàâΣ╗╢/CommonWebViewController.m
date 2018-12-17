//
//  CommonWebViewController.m
//  HOLA
//
//  Created by Jimmy Liu on 2015/4/16.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CommonWebViewController.h"

@interface CommonWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation CommonWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isHtmlStrTag) {
        // load html str
        [self loadHTMLString];
    }
    else{
        // load url
        NSURL *url = [NSURL URLWithString:self.urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadHTMLString{
    NSURL *url=[NSURL URLWithString:self.baseUrlStr];
    [self.webView loadHTMLString:[NSString stringWithFormat:@" <meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0;\"> <style>img {max-width:100%%;}</style>%@ ",self.urlStr] baseURL:url];
}

@end
