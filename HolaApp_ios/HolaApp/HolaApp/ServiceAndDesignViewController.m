//
//  ServiceAndDesignViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ServiceAndDesignViewController.h"
#import "SQLiteManager.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface ServiceAndDesignViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ServiceAndDesignViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //讀取資料庫內容
    NSDictionary *dicData = [SQLiteManager getServiceAndDesignHtmlString];
    NSString *content = [dicData objectForKey:@"Content"];
    //放到web view
    [self.webView loadHTMLString:content baseURL:nil];
    
    // GA -- 進入頁
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/HDD"]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/HDD"]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
