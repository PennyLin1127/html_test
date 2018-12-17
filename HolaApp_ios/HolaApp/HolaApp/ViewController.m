//
//  ViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/2/2.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ViewController.h"
#import "SQLiteManager.h"
#import "AsyncImageView.h"
#import "URLib.h"
#import "NSDefaultArea.h"
#import "ThemeStyleViewController.h"
#import "SQLiteManager.h"
#import "NewsCategoryContainerViewController.h" //最新消息
#import "NewsCategoryListViewController.h"
#import "CatalogueContainerViewController.h" //線上型錄
#import "IHouseURLManager.h"
#import "MyViewController.h"//會員專區
#import "MemberLoginViewController.h" //登入頁面
#import "MainCouponViewController.h" //折價劵
#import "ThemeProductListCollectionViewController.h"
#import "AppDelegate.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "IHouseUtility.h"
#import "ProductCatalogueViewController.h"

#define BTNBACKCOLOR [UIColor colorWithRed:95.0/255.0 green:75.0/255.0 blue:57.0/255.0 alpha:1.0]

@interface ViewController ()
{
    AsyncImageView *imageView1;
    AsyncImageView *imageView2;
    AsyncImageView *imageView3;
    AsyncImageView *imageView4;
    AsyncImageView *imageView5;
    AsyncImageView *imageView6;
    AsyncImageView *imageView7;
    AsyncImageView *imageView8;
    AsyncImageView *imageView9;
    AsyncImageView *imageView10;
    
    NSUserDefaults *defaults;
    NSTimer *timer;
}



@property (weak, nonatomic) IBOutlet UIScrollView *pScrollview1;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set button's background color for press
    self.news.backgroundColor = BTNBACKCOLOR;
    self.member.backgroundColor = BTNBACKCOLOR;
    self.life.backgroundColor = BTNBACKCOLOR;
    self.coupon.backgroundColor = BTNBACKCOLOR;
    self.product.backgroundColor = BTNBACKCOLOR;
    self.catagory.backgroundColor = BTNBACKCOLOR;
    
    defaults=[NSUserDefaults standardUserDefaults];
    
    // get date (YYYY-MM-dd)
    NSDate *date=[NSDate date];
    NSString *dateStrFormate=[IHouseUtility createDateFormat:date];
    
    // init mutable and get SQL
    
    if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
        
        // 測試版
        self.sliderPicArray=[[NSMutableArray alloc]initWithArray:[SQLiteManager getIndexViewData:dateStrFormate]];
        
    }else{
        // 正式版
        self.sliderPicArray=[[NSMutableArray alloc]initWithArray:[SQLiteManager getIndexViewData]];
    }
    
    self.saveSkuArray=[[NSMutableArray alloc]init];
    
    // setting scrollView
    [self.pScrollview1 setPagingEnabled:YES];
    [self.pScrollview1 setShowsHorizontalScrollIndicator:NO];
    [self.pScrollview1 setShowsVerticalScrollIndicator:NO];
    [self.pScrollview1 setScrollsToTop:NO];
    [self.pScrollview1 setClipsToBounds:NO];
    [self.pScrollview1 setDelegate:self];
    [self.pScrollview1 setScrollEnabled:YES];
    [self.pScrollview1 setBounces:YES];
    
    // GA 進入頁
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/homepage"]];
    [tracker send : [ [ GAIDictionaryBuilder createScreenView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/homepage"]
                                                          action:@"tracker"
                                                           label:nil
                                                           value:nil] build]];

}

-(void)viewDidAppear:(BOOL)animated{
    // setup carts number
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *numStr = [userDefaults objectForKey:@"cartNumbers"];
    [self reflashMyCarts:numStr];
    
    [self setUpSlider];
    
    // GA 進入頁
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/homepage"]];
    [tracker send : [ [ GAIDictionaryBuilder createScreenView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/homepage"]
                                                          action:@"tracker"
                                                           label:nil
                                                           value:nil] build]];

    
    [userDefaults setObject:@"" forKey:@"NeedToIndex"];
    [userDefaults synchronize];

    //判斷是否要轉跳到其他頁面
//    NSLog(@"test123 -- %@", [userDefaults objectForKey:REMOTE_USER_INFO_KEY]);
    NSString *hasUserInfo = [userDefaults objectForKey:HAS_REMOTE_USER_INFO_KEY];
    if ([hasUserInfo isEqualToString:@"YES"]) {
        [userDefaults setObject:@"" forKey:HAS_REMOTE_USER_INFO_KEY];
        [userDefaults synchronize];
        
        NSDictionary *userInfo = [userDefaults objectForKey:REMOTE_USER_INFO_KEY];
        NSLog(@"在首頁收到的UserInfo -- %@", userInfo);
        NSString *url = [userInfo objectForKey:@"url"];
        if (url == nil || [url isEqualToString:@""]) {
            return;
        }else {
            [userDefaults setObject:url forKey:@"UserInfoURL"];
            [userDefaults synchronize];
        }
        
        NSDictionary *dic = [userInfo objectForKey:@"aps"];
        NSString *msg = [dic objectForKey:@"alert"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:@"取消", nil];
        alert.tag = 100;
        [alert show];
        
    }

}

-(void)viewDidDisappear:(BOOL)animated {
    [timer invalidate];
    [self.saveSkuArray removeAllObjects];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)newsAction:(id)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NewsCategory" bundle:nil];
    NewsCategoryContainerViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NewsCategoryContainerView"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(IBAction)catagorysAction:(id)sender{
    //線上型錄
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Catalogue" bundle:nil];
    CatalogueContainerViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CatalogueContainerVie"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)memberAction:(id)sender{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *isLogin = [userDefaults objectForKey:USER_IS_LOGIN];
    
    if (![isLogin isEqualToString:@"YES"]) {
        NSLog(@"請先登入會員");
        [self pushToLogin:nil];
        return;
    }
    
    //可以導向畫面
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
    MyViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MyView"];
    vc.isMember = YES;
    [self.navigationController pushViewController:vc animated:YES];

}

-(IBAction)couponAction:(id)sender{
    //折價劵
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coupon" bundle:nil];
    MainCouponViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MainCouponView"];
    [self.navigationController pushViewController:vc animated:YES];

}

-(IBAction)productList:(id)sender{
    //商品分類
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ProductCatalogueViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ProductCatalogueVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)lifePropose:(id)sender{
    //生活提案
    NSArray *tempArray = [SQLiteManager getNewsListDataByCategoryId:@"3"];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"NewsCategory" bundle:nil];
    NewsCategoryListViewController *vc = [sb instantiateViewControllerWithIdentifier:@"NewsCategoryListView"];
    vc.arrayData = tempArray;
    BOOL isLife = YES;
    vc.isLife1 = isLife;
    [self.navigationController pushViewController:vc animated:YES];
}

// push到登入畫面
- (IBAction)pushToLogin:(id)sender {
    
    // push to login screen
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    MemberLoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MemberLogin"];
    
    
    UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
    
    vc.isDismissViewController=YES;
    vc.dontJumpToIndex = YES;
    
    [self presentViewController:myNavigation animated:YES completion:nil];
    
    
}

#pragma mark - set up slider
-(void)setUpSlider{
    // set up slider
    if (self.sliderPicArray.count >0) {
        NSInteger picLength = [self.sliderPicArray count]; //當前筆數
        self.pageControl1.numberOfPages=picLength;
        
        
        CGFloat width, height;
        width = self.pScrollview1.frame.size.width;
        height = self.pScrollview1.frame.size.height;
        NSLog(@"width %f",width);
        NSLog(@"height %f",height);
        
        self.pScrollview1.contentSize = CGSizeMake(width*picLength,height*0.8f);
        int viewIndex;
        
        // 每兩秒換scroll畫面

        timer = [NSTimer scheduledTimerWithTimeInterval: 4
                                                 target: self
                                               selector: @selector(handleTimer)
                                               userInfo: nil
                                                repeats: YES];
        
        for (viewIndex = 0 ; viewIndex < picLength ; viewIndex++) {
            CGRect currentRect = CGRectMake(width*viewIndex,-64,width,height);
            
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToThemeStyleVC:)];
            
            if (viewIndex == 0) {
                imageView1 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView1.imageURL = url;
                imageView1.tag=viewIndex;
                imageView1.userInteractionEnabled = YES;
                imageView1.contentMode = UIViewContentModeScaleToFill;
                [imageView1 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView1];
                
            } else if (viewIndex ==1){
                imageView2 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView2.imageURL = url;
                imageView2.tag=viewIndex;
                imageView2.userInteractionEnabled = YES;
                imageView2.contentMode = UIViewContentModeScaleToFill;
                [imageView2 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView2];
                
            } else if (viewIndex ==2){
                imageView3 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView3.imageURL = url;
                imageView3.tag=viewIndex;
                imageView3.userInteractionEnabled = YES;
                imageView3.contentMode = UIViewContentModeScaleToFill;
                [imageView3 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView3];
                
            } else if (viewIndex ==3){
                imageView4 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView4.imageURL = url;
                imageView4.tag=viewIndex;
                imageView4.userInteractionEnabled = YES;
                imageView4.contentMode = UIViewContentModeScaleToFill;
                [imageView4 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView4];
                
            } else if (viewIndex ==4){
                imageView5 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView5.imageURL = url;
                imageView5.tag=viewIndex;
                imageView5.userInteractionEnabled = YES;
                imageView5.contentMode = UIViewContentModeScaleToFill;
                [imageView5 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView5];
                
            } else if (viewIndex ==5){
                imageView6 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView6.imageURL = url;
                imageView6.tag=viewIndex;
                imageView6.userInteractionEnabled = YES;
                imageView6.contentMode = UIViewContentModeScaleToFill;
                [imageView6 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView6];
                
            } else if (viewIndex ==6){
                imageView7 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView7.imageURL = url;
                imageView7.tag=viewIndex;
                imageView7.userInteractionEnabled = YES;
                imageView7.contentMode = UIViewContentModeScaleToFill;
                [imageView7 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView7];
                
            } else if (viewIndex ==7){
                imageView8 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView8.imageURL = url;
                imageView8.tag=viewIndex;
                imageView8.userInteractionEnabled = YES;
                imageView8.contentMode = UIViewContentModeScaleToFill;
                [imageView8 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView8];
                
            } else if (viewIndex ==8){
                imageView9 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView9.imageURL = url;
                imageView9.tag=viewIndex;
                imageView9.userInteractionEnabled = YES;
                imageView9.contentMode = UIViewContentModeScaleToFill;
                [imageView9 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView9];
                
            } else if (viewIndex ==9){
                imageView10 = [[AsyncImageView alloc] initWithFrame:currentRect];
                NSString *imgStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:HOLA_THEME_CATEGORY_PATH]];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",imgStr,[self.sliderPicArray[viewIndex] objectForKey:@"CategoryImage"]]];
                imageView10.imageURL = url;
                imageView10.tag=viewIndex;
                imageView10.userInteractionEnabled = YES;
                imageView10.contentMode = UIViewContentModeScaleToFill;
                [imageView10 addGestureRecognizer:tapGesture];
                [self.pScrollview1 addSubview:imageView10];
            }
            
        }
        
    }
}


-(void)handleTimer{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    int page = self.pScrollview1.contentOffset.x /screenWidth;
    
    if ( page +1 < [self.sliderPicArray count] )
    {
        page++;
        self.pageControl1.currentPage = page++;
    }
    else
    {
        page = 0;
        self.pageControl1.currentPage = page;
    }
    [self changePage];
}


- (void)changePage
{
    CGRect rect = self.pScrollview1.frame;
    NSInteger page = self.pageControl1.currentPage;
    
    // 讓最後一張不會快速跑到第一張,animated -> no
    if (page==0) {
        [self.pScrollview1 scrollRectToVisible:CGRectMake(rect.size.width*page, 0, rect.size.width, rect.size.height) animated:NO];
    }
    else{
        [self.pScrollview1 scrollRectToVisible:CGRectMake(rect.size.width*page, 0, rect.size.width, rect.size.height) animated:YES];
    }
    
}



- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat width = self.pScrollview1.frame.size.width;
    NSInteger currentPage = ((self.pScrollview1.contentOffset.x - width / 2) / width) + 1;
    [self.pageControl1 setCurrentPage:currentPage];
}

- (IBAction)changeCurrentPageShow1:(id)sender {
    
    NSInteger page = self.pageControl1.currentPage;
    
    CGFloat width, height;
    width = self.pScrollview1.frame.size.width;
    height = self.pScrollview1.frame.size.height;
    CGRect frame = CGRectMake(width*page, 0, width, height);
    
    [self.pScrollview1 scrollRectToVisible:frame animated:YES];
    
}

#pragma mark - 判斷顯示瀑布牆或是到商品列表

-(void)goToThemeStyleVC:(UIGestureRecognizer *)recognizer{
    
    AsyncImageView *imageView = (AsyncImageView*) recognizer.view;
    NSDictionary *dic=[self.sliderPicArray objectAtIndex:imageView.tag];
    NSInteger themeID = [[dic objectForKey:@"CategoryId"] integerValue];
    
    // get date (YYYY-MM-dd)
    NSDate *date=[NSDate date];
    NSString *dateStrFormate=[IHouseUtility createDateFormat:date];
    
    NSArray *subCategories;
    if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
        // 測試版 , 老闆SQL 加入dtStart,end date
        subCategories =[SQLiteManager getThemeData:themeID date:dateStrFormate];
    }
    else{
        subCategories =[SQLiteManager getThemeData:themeID];
    }

    // GA -- 選擇哪一個熱門話題
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/theme/category/%ld",(long)themeID]];
    [tracker send : [ [ GAIDictionaryBuilder createScreenView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/theme/category/%ld",(long)themeID]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
    
    
    if(subCategories.count<2)
        // 數量太少就不顯示瀑布牆，直接到熱門話題商品列表
    {
        NSInteger subThemeId = [[[subCategories objectAtIndex:0]objectForKey:@"themeId"] integerValue];
        
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ThemeProductListCollectionViewController *vc=[sb instantiateViewControllerWithIdentifier:@"ThemeProductListCollectionView"];
        vc.themeID = subThemeId;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else
    {   // 數量大於2，顯示瀑布牆
        ThemeStyleViewController *vc=[[ThemeStyleViewController alloc]init];
        vc.themeID = themeID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIAlert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *urlValue = [userDefaults objectForKey:@"UserInfoURL"];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate pushToAnotherViewByURL:urlValue];

        }
    }
}


@end
