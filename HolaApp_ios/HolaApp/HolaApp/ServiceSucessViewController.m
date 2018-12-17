//
//  ServiceSucessViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/6.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ServiceSucessViewController.h"

@interface ServiceSucessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceContentLabel;

- (IBAction)completeAction:(id)sender;
@end

@implementation ServiceSucessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //字串
    NSString *name = [self.dicData objectForKey:@"name"];
    self.nameLabel.text = name;
    
    NSString *email = [self.dicData objectForKey:@"email"];
    self.emailLabel.text = email;
    
    NSString *phone = [self.dicData objectForKey:@"phone"];
    self.phoneLabel.text = phone;
    
    NSString *category = [self.dicData objectForKey:@"category"];
    self.categoryLabel.text = category;
    
    NSString *serviceTitle = [self.dicData objectForKey:@"serviceTitle"];
    self.serviceTitleLabel.text = serviceTitle;
    
    NSString *serviceContent = [self.dicData objectForKey:@"serviceContent"];
    self.serviceContentLabel.text = serviceContent;
}

/*
    當初傳過去的資料
    NSDictionary *dic = @{@"sessionId": sessionId, @"name":name, @"email":email, @"phone":phone, @"categoryId":[NSString stringWithFormat:@"%zd", categoryId], @"serviceTitle":subject, @"serviceContent":question, @"orderNumber":@""};
 */


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

- (IBAction)completeAction:(id)sender {
    NSLog(@"completeAction");
    
    if ([self.delegate respondsToSelector:@selector(completeSucess:)]) {
        
        BOOL notLogin = NO;
        
        NSString *notLoginStr = [self.dicData objectForKey:@"NotLogin"];
        
        if (notLoginStr == nil || [notLoginStr isEqualToString:@""] || [notLoginStr isEqualToString:@"YES"]) {
            notLogin = NO;
        }else {
            notLogin = YES;
        }
        
        [self.delegate completeSucess:notLogin];
    }
    
}
@end
