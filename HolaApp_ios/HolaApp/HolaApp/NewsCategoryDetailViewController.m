//
//  NewsCategoryDetailViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/14.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "NewsCategoryDetailViewController.h"

@interface NewsCategoryDetailViewController ()
//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation NewsCategoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (self.isLife2 == YES) {
        self.topLabel.text = @"生活提案";
    }else{
        self.topLabel.text = @"最新消息";
    }
    //Navigation
//    [self setBackButton];
    
    //Data
//    NSString *subject = [self.dicData objectForKey:@"Subject"];
//    self.titleLabel.text = subject;
//    
//    NSString *startDate = [self.dicData objectForKey:@"StartDate"];
//    NSString *endDate = [self.dicData objectForKey:@"EndDate"];
//    self.dateLabel.text = [NSString stringWithFormat:@"%@~%@", startDate, endDate];

    NSString *webString = [self.dicData objectForKey:@"Content"];
    webString = [NSString stringWithFormat:@" <meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0;\"><style>.IMG {width:100%%}</style>%@ ",webString];
    
  
    //NSLog(@"webString -- %@", webString);
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.webView loadHTMLString:webString baseURL:nil];
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
