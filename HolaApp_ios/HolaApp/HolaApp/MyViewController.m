//
//  MyViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "MyViewController.h"
#import "ManagentViewController.h"
#import "EinvoiceListViewController.h"
#import "QueryBonusViewController.h"
#import "ServiceViewController.h"
#import "ServiceSucessViewController.h"
#import "VipViewController.h"
#import "ServiceNotLoginViewController.h"
#import "MemberLoginViewController.h"
#import "IHouseURLManager.h"
#import "RSBarcodes.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface MyViewController (){
    
    //初始五個ViewController
    ManagentViewController *managentVC;
    EinvoiceListViewController *einvoiceVC;
    QueryBonusViewController *queryVC;
    ServiceViewController *serviceVC;
    VipViewController *vipVC;
    
    //完成聯絡客服的頁面
    ServiceSucessViewController *serviceSucessVC;
    
    //非會員的聯絡客服頁面
    ServiceNotLoginViewController *serviceNotLoginVC;
    
    //循環用的ViewController
    ManagentViewController *managentVC_Cycle;
    VipViewController *vipVC_Cycle;
    
    //上方ScrollView的Button名稱 NSString
    NSArray *topScrollViewButtonName;
    
    //上方5個Button
    UIButton *managentButton;
    UIButton *queryButton;
    UIButton *einvoiceButton;
    UIButton *serviceButton;
    UIButton *vipButton;
    
    //循環用的Button
    UIButton *managentButton_Cycle;
    UIButton *vipButton_Cycle;
    
    //計算位置用index
    NSInteger currentButtonIndex;
    
    //ViewDidAppear 只會初始化一次Flag
    BOOL hasInit;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // tag = 0;
@property (weak, nonatomic) IBOutlet UIScrollView *topButtonScrollView; //tag = 100
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftLabelConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLabelConstraint;

- (IBAction)managentAction:(id)sender;
- (IBAction)queryAction:(id)sender;
- (IBAction)einvoiceAction:(id)sender;
- (IBAction)serviceAction:(id)sender;
- (IBAction)vipAction:(id)sender;

@end

@implementation MyViewController
#pragma mark - View生命週期
- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //scrollView delegate
    self.scrollView.delegate = self;
    
    //初始化上面五個Controller 並加入到ScrollView和Controller
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
    //資料管理
    managentVC = [sb instantiateViewControllerWithIdentifier:@"ManagentView"];
    [self addChildViewController:managentVC];
    
    //查詢點數
    queryVC = [sb instantiateViewControllerWithIdentifier:@"QueryBonusView"];
    [self addChildViewController:queryVC];
    
    //電子發票
    einvoiceVC = [sb instantiateViewControllerWithIdentifier:@"EinvoiceView"];
    [self addChildViewController:einvoiceVC];
    
    //客服
    //if (self.isMember == NO) {
        serviceNotLoginVC = [sb instantiateViewControllerWithIdentifier:@"ServiceNotLoginView"];
        serviceNotLoginVC.delegate = self;
        [self addChildViewController:serviceNotLoginVC];
    //}else {
        serviceVC = [sb instantiateViewControllerWithIdentifier:@"ServiceView"];
        serviceVC.delegate = self;
        [self addChildViewController:serviceVC];
    //}
    
    //Vip
    vipVC = [sb instantiateViewControllerWithIdentifier:@"VipView"];
    [self addChildViewController:vipVC];
    
    //循環用的ViewController
    managentVC_Cycle = [sb instantiateViewControllerWithIdentifier:@"ManagentView"];
    vipVC_Cycle = [sb instantiateViewControllerWithIdentifier:@"VipView"];
    [self addChildViewController:managentVC_Cycle];
    [self addChildViewController:vipVC_Cycle];
    
    //init var
    topScrollViewButtonName = [[NSArray alloc] initWithObjects:@"VIP效期查詢", @"資料管理", @"點數查詢", @"電子發票", @"聯絡客服", @"VIP效期查詢", @"資料管理", nil];
    currentButtonIndex = 1;
    
    //init scroll
    self.topButtonScrollView.delegate = self;
    self.topButtonScrollView.pagingEnabled = YES;
    self.topButtonScrollView.showsHorizontalScrollIndicator = NO;
    self.topButtonScrollView.showsVerticalScrollIndicator = NO;
    
    //init label
    self.leftLabel.text = @"VIP效期查詢";
    self.rightLabel.text = @"點數查詢";
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (hasInit == NO) {
        hasInit = YES;
        
        //初始化ScrollView Frame
        CGRect rect = self.scrollView.frame;
        self.scrollView.contentSize = CGSizeMake(rect.size.width*7, rect.size.height);
        
        //加入各ViewController到ScrollView
        
        //循環用的vipVC_Cycle
        vipVC_Cycle.view.frame = rect;
        [self.scrollView addSubview:vipVC_Cycle.view];
        
        //資料管理
        managentVC.view.frame = CGRectMake(rect.size.width*1, 0, rect.size.width, rect.size.height);
        [self.scrollView addSubview:managentVC.view];
        
        //查詢點數
        queryVC.view.frame = CGRectMake(rect.size.width*2, 0, rect.size.width, rect.size.height);
        [self.scrollView addSubview:queryVC.view];
        
        //電子發票
        einvoiceVC.view.frame = CGRectMake(rect.size.width*3, 0, rect.size.width, rect.size.height);
        [self.scrollView addSubview:einvoiceVC.view];
        
        //聯絡客服
        if (self.isMember == NO) {
            serviceNotLoginVC.view.frame = CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height);
            [self.scrollView addSubview:serviceNotLoginVC.view];
        }else {
            serviceVC.view.frame = CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height);
            [self.scrollView addSubview:serviceVC.view];
        }
        
        //Vip
        vipVC.view.frame = CGRectMake(rect.size.width*5, 0, rect.size.width, rect.size.height);
        [self.scrollView addSubview:vipVC.view];
        
        //循環用的managentVC_Cycle
        managentVC_Cycle.view.frame = CGRectMake(rect.size.width*6, 0, rect.size.width, rect.size.height);
        [self.scrollView addSubview:managentVC_Cycle.view];
        
        //一開始下方ScrollView的位移
        [self.scrollView scrollRectToVisible:CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height) animated:NO];
        
        
        //init topButtonScrollView
        CGRect topRect = self.topButtonScrollView.frame;
        self.topButtonScrollView.contentSize = CGSizeMake(topRect.size.width*7, topRect.size.height);
        
        //初始化5個Button 2個循環用的Button
        //vipButton_Cycle
        vipButton_Cycle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, topRect.size.width, topRect.size.height)];
        [vipButton_Cycle setTitle:@"VIP效期查詢" forState:UIControlStateNormal];
        [vipButton_Cycle setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
        [self.topButtonScrollView addSubview:vipButton_Cycle];
        
        //managentButton
        managentButton = [[UIButton alloc] initWithFrame:CGRectMake(topRect.size.width, 0, topRect.size.width, topRect.size.height)];
        [managentButton setTitle:@"資料管理" forState:UIControlStateNormal];
        [managentButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
        [self.topButtonScrollView addSubview:managentButton];
        
        //queryButton
        queryButton = [[UIButton alloc] initWithFrame:CGRectMake(topRect.size.width*2, 0, topRect.size.width, topRect.size.height)];
        [queryButton setTitle:@"點數查詢" forState:UIControlStateNormal];
        [queryButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
        [self.topButtonScrollView addSubview:queryButton];
        
        //einvoiceButton
        einvoiceButton = [[UIButton alloc] initWithFrame:CGRectMake(topRect.size.width*3, 0, topRect.size.width, topRect.size.height)];
        [einvoiceButton setTitle:@"電子發票" forState:UIControlStateNormal];
        [einvoiceButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
        [self.topButtonScrollView addSubview:einvoiceButton];
        
        //serviceButton
        serviceButton = [[UIButton alloc] initWithFrame:CGRectMake(topRect.size.width*4, 0, topRect.size.width, topRect.size.height)];
        [serviceButton setTitle:@"聯絡客服" forState:UIControlStateNormal];
        [serviceButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
        [self.topButtonScrollView addSubview:serviceButton];
        
        //vipButton
        vipButton = [[UIButton alloc] initWithFrame:CGRectMake(topRect.size.width*5, 0, topRect.size.width, topRect.size.height)];
        [vipButton setTitle:@"VIP效期查詢" forState:UIControlStateNormal];
        [vipButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
        [self.topButtonScrollView addSubview:vipButton];
        
        //vipButton_Cycle
        managentButton_Cycle = [[UIButton alloc] initWithFrame:CGRectMake(topRect.size.width*6, 0, topRect.size.width, topRect.size.height)];
        [managentButton_Cycle setTitle:@"資料管理" forState:UIControlStateNormal];
        [managentButton_Cycle setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
        [self.topButtonScrollView addSubview:managentButton_Cycle];
        
        //一開始的位移
        [self.topButtonScrollView scrollRectToVisible:CGRectMake(topRect.size.width, 0, topRect.size.width, topRect.size.height) animated:NO];
        
        
        //非會員位移
        if (self.isMember == NO) {
            //一開始下方ScrollView的位移
            [self.scrollView scrollRectToVisible:CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height) animated:NO];
            [self.topButtonScrollView scrollRectToVisible:CGRectMake(topRect.size.width*4, 0, topRect.size.width, topRect.size.height) animated:NO];
            
            self.leftLabel.text = @"電子發票";
            self.rightLabel.text = @"VIP效期查詢";
            
            //取得資料
//            [serviceNotLoginVC getData];
        }
        
        //會立即跳到客服頁面
        if (self.needJumpToService) {
            [self.scrollView scrollRectToVisible:CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height) animated:NO];
            [self.topButtonScrollView scrollRectToVisible:CGRectMake(topRect.size.width*4, 0, topRect.size.width, topRect.size.height) animated:NO];
            
            //取得資料
            if (self.isMember == NO) {
                [serviceNotLoginVC getData];
            }else {
                [serviceVC getData];
            }
        }
        
        if (self.goToPoint) {
            currentButtonIndex = 2;
            self.leftLabel.text = @"資料管理";
            self.rightLabel.text = @"電子發票";
            
            [self.topButtonScrollView scrollRectToVisible:CGRectMake(topRect.size.width*2, 0, topRect.size.width, topRect.size.height) animated:NO];
            
            //一開始下方ScrollView的位移
            [self.scrollView scrollRectToVisible:CGRectMake(rect.size.width*2, 0, rect.size.width, rect.size.height) animated:NO];
            [queryVC getData];
        }
        
    }
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

#pragma mark - ScrollView Delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat width = scrollView.frame.size.width;
    NSInteger currentPage = ((scrollView.contentOffset.x - width / 2) / width) + 1;
    
    if (self.isMember == NO) {
        if (currentPage != 4) {
            [self pushToLoginVC];
        }
    }
    
    if (scrollView.tag == 100) {
        NSLog(@"變換Button");
        //上方Button ScrollView
        CGRect rect = self.topButtonScrollView.frame;
        
        //切換ButtonView 做循環
        if (scrollView.contentOffset.x == 0) {
            [scrollView scrollRectToVisible:CGRectMake(rect.size.width*5, 0, rect.size.width, rect.size.height) animated:NO];
        }else if(scrollView.contentOffset.x == rect.size.width*6) {
            [scrollView scrollRectToVisible:CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height) animated:NO];
        }
        
        //換文字 and index
        //@"VIP效期查詢", @"資料管理", @"點數查詢", @"電子發票", @"聯絡客服", @"VIP效期查詢", @"資料管理"
        if (scrollView.contentOffset.x == 0) {
            NSLog(@"%@", topScrollViewButtonName[0]);
            currentButtonIndex = 5;
            self.leftLabel.text = @"聯絡客服";
            self.rightLabel.text = @"資料管理";
            //[vipVC_Cycle getData];
        }else if (scrollView.contentOffset.x == rect.size.width*1) {
            NSLog(@"%@", topScrollViewButtonName[1]);
            currentButtonIndex = 1;
            self.leftLabel.text = @"VIP效期查詢";
            self.rightLabel.text = @"點數查詢";
        }else if (scrollView.contentOffset.x == rect.size.width*2) {
            NSLog(@"%@", topScrollViewButtonName[2]);
            currentButtonIndex = 2;
            self.leftLabel.text = @"資料管理";
            self.rightLabel.text = @"電子發票";
            //[queryVC getData];
        }else if (scrollView.contentOffset.x == rect.size.width*3) {
            NSLog(@"%@", topScrollViewButtonName[3]);
            currentButtonIndex = 3;
            self.leftLabel.text = @"點數查詢";
            self.rightLabel.text = @"聯絡客服";
            //[einvoiceVC getData];

        }else if (scrollView.contentOffset.x == rect.size.width*4) {
            NSLog(@"%@", topScrollViewButtonName[4]);
            currentButtonIndex = 4;
            self.leftLabel.text = @"電子發票";
            self.rightLabel.text = @"VIP效期查詢";
            //[serviceVC getData];
        }else if (scrollView.contentOffset.x == rect.size.width*5) {
            NSLog(@"%@", topScrollViewButtonName[5]);
            currentButtonIndex = 5;
            self.leftLabel.text = @"聯絡客服";
            self.rightLabel.text = @"資料管理";
            //[vipVC getData];

        }else if (scrollView.contentOffset.x == rect.size.width*6) {
            NSLog(@"%@", topScrollViewButtonName[6]);
            currentButtonIndex = 1;
            self.leftLabel.text = @"VIP效期查詢";
            self.rightLabel.text = @"點數管理";
        }
        
        //撈資料
        if (self.isMember) {
            [self getVCDataByIndex:currentButtonIndex];
        }
        
        //連動下方scrollView
        CGRect bottomRect = self.scrollView.frame;
        [self.scrollView scrollRectToVisible:CGRectMake(bottomRect.size.width*currentButtonIndex, 0, bottomRect.size.width, bottomRect.size.height) animated:NO];
        
        
    }else {
        //下方ScrollView
        //撈取資料

        
        NSLog(@"當前的頁數 -- %zd", currentPage);
        if (currentPage == 0 ) {
            NSLog(@"循環的Vip查詢");
            //[vipVC getData];
            //[vipVC_Cycle getData];
            currentButtonIndex = 5;
            self.leftLabel.text = @"聯絡客服";
            self.rightLabel.text = @"資料管理";
          
        }else if (currentPage == 1) {
            NSLog(@"資料管理");
            currentButtonIndex = 1;
            self.leftLabel.text = @"VIP效期查詢";
            self.rightLabel.text = @"點數查詢";
            
            // GA -- 資料管理
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            // 記畫面
            [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/data"]];
            [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
            
            // 記事件
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/data"]
                                                                  action:@"button_press"
                                                                   label:nil
                                                                   value:nil] build]];
            
        }else if (currentPage == 2) {
            NSLog(@"點數查詢");
//            [queryVC getData];
            currentButtonIndex = 2;
            self.leftLabel.text = @"資料管理";
            self.rightLabel.text = @"電子發票";
            
            
            // GA -- 點數查詢
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            // 記畫面
            [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/point"]];
            [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
            
            // 記事件
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/point"]
                                                                  action:@"button_press"
                                                                   label:nil
                                                                   value:nil] build]];
            
        }else if (currentPage == 3) {
            NSLog(@"電子發票");
//            [einvoiceVC getData];
            currentButtonIndex = 3;
            self.leftLabel.text = @"點數查詢";
            self.rightLabel.text = @"聯絡客服";
            
            // GA -- 電子發票
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            // 記畫面
            [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/invoice"]];
            [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
            
            // 記事件
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/invoice"]
                                                                  action:@"button_press"
                                                                   label:nil
                                                                   value:nil] build]];
            
        }else if (currentPage == 4) {
            NSLog(@"聯絡客服");
//            [serviceVC getData];
            currentButtonIndex = 4;
            self.leftLabel.text = @"電子發票";
            self.rightLabel.text = @"VIP效期查詢";
            
            // GA -- 聯絡客服
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            // 記畫面
            [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/service"]];
            [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
            
            // 記事件
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/service"]
                                                                  action:@"button_press"
                                                                   label:nil
                                                                   value:nil] build]];
            
        }else if (currentPage == 5) {
            NSLog(@"Vip查詢");
//            [vipVC getData];
//            [vipVC_Cycle getData];
            currentButtonIndex = 5;
            self.leftLabel.text = @"聯絡客服";
            self.rightLabel.text = @"資料管理";
        }else if (currentPage == 6) {
            NSLog(@"資料管理");
            currentButtonIndex = 1;
            self.leftLabel.text = @"VIP效期查詢";
            self.rightLabel.text = @"點數管理";
            
            // GA -- 資料管理
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            
            // 記畫面
            [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/data"]];
            [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
            
            // 記事件
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/data"]
                                                                  action:@"button_press"
                                                                   label:nil
                                                                   value:nil] build]];
        }
        
        //撈資料
        if (self.isMember) {
            [self getVCDataByIndex:currentButtonIndex];
        }
        
        //切換ScrollView 做循環
        CGRect rect = self.scrollView.frame;
        if (scrollView.contentOffset.x == 0) {
            [scrollView scrollRectToVisible:CGRectMake(rect.size.width*5, 0, rect.size.width, rect.size.height) animated:NO];
        }else if(scrollView.contentOffset.x == rect.size.width*6) {
            [scrollView scrollRectToVisible:CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height) animated:NO];
        }
        
        //連動上方按鈕ScrollView
        //連動下方scrollView
        CGRect topRect = self.topButtonScrollView.frame;
        [self.topButtonScrollView scrollRectToVisible:CGRectMake(topRect.size.width*currentButtonIndex, 0, topRect.size.width, topRect.size.height) animated:NO];
    }
                [serviceVC closeInput];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isMember == NO) {
        //回到原來的位置
        
//        if (scrollView.tag == 100) {
//            //上方Button ScrollView
//            CGRect rect = self.scrollView.frame;
//            [self.scrollView scrollRectToVisible:CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height) animated:NO];
//            
//        }else {
//            CGRect topRect = self.topButtonScrollView.frame;
//            [self.topButtonScrollView scrollRectToVisible:CGRectMake(topRect.size.width*4, 0, topRect.size.width, topRect.size.height) animated:NO];
//        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請登入特力愛家卡會員" delegate:self cancelButtonTitle:@"稍後" otherButtonTitles:@"登入",nil];
        [alert show];

    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    if (self.isMember == NO) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"訊息" message:@"123" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    
    if (scrollView.tag == 100) {
        //為上方Button ScrollView
        //算出位移量
        CGRect rect = self.topButtonScrollView.frame;
        CGFloat offset = rect.size.width*currentButtonIndex - scrollView.contentOffset.x;
        //NSLog(@"位移量 -- (%f)", offset);
        
        //開始位移
        self.rightLabelConstraint.constant = 20 - offset;
        self.leftLabelConstraint.constant = 20 + offset;
        
        //位移大出畫面一半大就回到原點
        if (fabs(offset) >= rect.size.width/2) {
            self.rightLabelConstraint.constant = 20;
            self.leftLabelConstraint.constant = 20;
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        NSLog(@"稍後");

        CGRect rect = self.scrollView.frame;
        [self.scrollView scrollRectToVisible:CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height) animated:NO];
        CGRect topRect = self.topButtonScrollView.frame;
        [self.topButtonScrollView scrollRectToVisible:CGRectMake(topRect.size.width*4, 0, topRect.size.width, topRect.size.height) animated:NO];

    }else if (buttonIndex == 1) {
        NSLog(@"登入");
        [self pushToLoginVC];
    }
}

#pragma mark - Button 事件
- (IBAction)managentAction:(id)sender {
}

- (IBAction)queryAction:(id)sender {
}

- (IBAction)einvoiceAction:(id)sender {
}

- (IBAction)serviceAction:(id)sender {
}

- (IBAction)vipAction:(id)sender {
}

#pragma mark - 聯絡客服 delegate
-(void)suceccToAskQuestion:(NSDictionary *)dic {
    //先移除controller與view
    [serviceVC.view removeFromSuperview];
    [serviceVC removeFromParentViewController];
    
    //加入controller與view
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
    serviceSucessVC = [sb instantiateViewControllerWithIdentifier:@"ServiceSucessView"];
    serviceSucessVC.delegate = self;
    serviceSucessVC.dicData = dic;
    
    [self addChildViewController:serviceSucessVC];
    CGRect rect = self.scrollView.frame;
    serviceSucessVC.view.frame = CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height);
    [self.scrollView addSubview:serviceSucessVC.view];
}

-(void)suceccToAskQuestionNotMember:(NSDictionary *)dic {
    //先移除controller與view
    [serviceNotLoginVC.view removeFromSuperview];
    [serviceNotLoginVC removeFromParentViewController];
    
    //加入controller與view
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
    serviceSucessVC = [sb instantiateViewControllerWithIdentifier:@"ServiceSucessView"];
    serviceSucessVC.delegate = self;
    serviceSucessVC.dicData = dic;
    
    [self addChildViewController:serviceSucessVC];
    CGRect rect = self.scrollView.frame;
    serviceSucessVC.view.frame = CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height);
    [self.scrollView addSubview:serviceSucessVC.view];
    
}

-(void)completeSucess:(BOOL)isNotLogin {
    NSLog(@"completeSucess in MyViewController");
    //先移除controller與view
    [serviceSucessVC.view removeFromSuperview];
    [serviceSucessVC removeFromParentViewController];
    
    //加入controller與view
    if (isNotLogin == NO) {
        //沒有登入
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
        serviceNotLoginVC = [sb instantiateViewControllerWithIdentifier:@"ServiceNotLoginView"];
        serviceNotLoginVC.delegate = self;
        [self addChildViewController:serviceNotLoginVC];
        
        CGRect rect = self.scrollView.frame;
        serviceNotLoginVC.view.frame = CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height);
        [self.scrollView addSubview:serviceNotLoginVC.view];
        
        //取得資料
        [serviceNotLoginVC getData];
        
    }else {
        //有登入
        //客服
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
        serviceVC = [sb instantiateViewControllerWithIdentifier:@"ServiceView"];
        serviceVC.delegate = self;
        [self addChildViewController:serviceVC];
        
        CGRect rect = self.scrollView.frame;
        serviceVC.view.frame = CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height);
        [self.scrollView addSubview:serviceVC.view];
        
        //取得資料
        [serviceVC getData];
        
    }
    
}

#pragma mark - 登入方法
-(void)pushToLoginVC {
    NSLog(@"MyView的登入方法");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    MemberLoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MemberLogin"];
    
    UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
    
    vc.isDismissViewController=YES;
    vc.dontJumpToIndex = YES;
    vc.needToChangeMemberServiceVC = YES;
    
    //Block Method
//    __weak MyViewController *tempVC = self;
    vc.changeServiceVC = ^(){
        NSLog(@"changeServiceVC");
        
        self.isMember = YES;
        
        //移除
        [serviceNotLoginVC removeFromParentViewController];
        [serviceNotLoginVC.view removeFromSuperview];
        
        //讀取資料
        [serviceVC getData];
        
        //加入
        CGRect rect = self.scrollView.frame;
        serviceVC.view.frame = CGRectMake(rect.size.width*4, 0, rect.size.width, rect.size.height);
        [self.scrollView addSubview:serviceVC.view];
        
        //撈資料
        if (self.isMember) {
            [self getVCDataByIndex:currentButtonIndex];
        }
        
    };
    
    [self presentViewController:myNavigation animated:YES completion:nil];
}

#pragma mark - 根據不同當前的頁面去撈資料
-(void)getVCDataByIndex:(NSInteger)index {
    
    if (index == 0) {
        
    }else if (index == 1) {
        
    }else if (index == 2) {
        [queryVC getData];
    }else if (index == 3) {
        [einvoiceVC getData];
    }else if (index == 4) {
        [serviceVC getData];
    }else if (index == 5) {
        
        [vipVC_Cycle getData];
        [vipVC getData];
    }
    
}

@end
