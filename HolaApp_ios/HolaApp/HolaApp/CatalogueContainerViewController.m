//
//  CatalogueContainerViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CatalogueContainerViewController.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "LatestListCollectionVC.h"
#import "LatestCatalogueViewController.h"
#import "CatalogueListViewController.h"

@interface CatalogueContainerViewController () {
    LatestListCollectionVC *latestVC;
    CatalogueListViewController *listVC;
    BOOL isInit;
}
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *latestButton;
- (IBAction)latestAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *listButton;
- (IBAction)listAction:(id)sender;

@end

@implementation CatalogueContainerViewController

#pragma mark - View 生命週期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //init VC
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Catalogue" bundle:nil];
    latestVC = [sb instantiateViewControllerWithIdentifier:@"LatestListView"];
    latestVC.parentVC = self;
    [self addChildViewController:latestVC];
    
    listVC = [sb instantiateViewControllerWithIdentifier:@"CatalogueListView"];
    listVC.parentVC = self;
    [self addChildViewController:listVC];
    
    isInit = NO;

    //UI Color
    [self.latestButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated {
    
    //只執行一次
    if (isInit == NO) {
        
        [super viewDidAppear:animated];
//        CGRect rect = self.containerView.frame;
//        latestVC.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
//        NSLog(@"ContainerView -- %@", NSStringFromCGRect(rect));
//        [self.containerView addSubview:latestVC.view];
//        
//        listVC.view.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
//        listVC.viewRect = self.containerView.frame;
//        NSLog(@"listVC.view.frame -- %@", NSStringFromCGRect(listVC.view.frame));
        
        latestVC.viewRect = self.containerView.frame;
        
        latestVC.cellRect = CGRectMake(0, 0, latestVC.viewRect.size.width/2-15,
                                       (latestVC.viewRect.size.width/2)*1.25);
        [self.containerView addSubview:latestVC.view];
        
        //先取得資料
        [self getData];
        
        isInit = YES;
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

#pragma mark - Button Event
- (IBAction)latestAction:(id)sender {
//    [listVC.view removeFromSuperview];
//    [self.containerView addSubview:latestVC.view];
    
    [listVC.view removeFromSuperview];
    latestVC.viewRect = self.containerView.frame;
    
    latestVC.cellRect = CGRectMake(0, 0, latestVC.viewRect.size.width/2-15,
                                   (latestVC.viewRect.size.width/2)*1.25);
    [self.containerView addSubview:latestVC.view];
    
    //重新讀取資料
    [latestVC.collectionView reloadData];
    
    //UI
    [self.latestButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
    [self.listButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}
- (IBAction)listAction:(id)sender {
    NSLog(@"listAction");

    [latestVC.view removeFromSuperview];
    //預先算出collection cell size
    listVC.viewRect = self.containerView.frame;
    
    //NSLog(@"listVC.viewRect -- %@", NSStringFromCGRect(listVC.viewRect));
    
    listVC.cellRect = CGRectMake(0, 0, listVC.viewRect.size.width/2-15, (listVC.viewRect.size.width/2)*1.25);
    //加入畫面
    [self.containerView addSubview:listVC.view];
    //重新讀取資料
    //[listVC.collectionView reloadData];
    
    [self.listButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
    [self.latestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - 取得資料
-(void) getData {
    
    //組成Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *strDate = [formatter stringFromDate:date];
    
    NSDictionary *dic = @{@"sessionId": sessionId, @"year":strDate};
    
    //傳送資料
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:CATALOGUE_LIST] AndDic:dic];
//        hud.yOffset = 300;
//        hud.graceTime = 0;
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            return;
            
        }else {
            NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSLog(@"testStr -- %@", testStr);
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];
            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"returnDic -- %@", returnDic);
            
            if (returnDic == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
            }
            
            //儲存sessionId
            NSString *sessionId = [returnDic objectForKey:@"sessionId"];
            [IHouseUtility saveSessionIDToUserDefaults:sessionId];
            
            BOOL status = [[returnDic objectForKey:@"status"] integerValue];
            
            NSLog(@"status -- %zd", status);
            
            if (status == NO) {
                //狀態失敗 直接顯示回傳的訊息
                NSString *msg = [returnDic objectForKey:@"msg"];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
                
            }else {
                //成功
                NSArray *dicArray = [returnDic objectForKey:@"data"];
                self.dicArrayList = dicArray;
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                
                for (NSDictionary *dict in dicArray) {
                    self.strDate = dict[@"startDate"];
                    self.endDate = dict[@"endDate"];
                    
                    NSDate *date = [NSDate date];
                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate * strDateNs = [dateFormatter dateFromString:self.strDate];
                    
                    NSDateFormatter * dateFormatter1 = [[NSDateFormatter alloc]init];
                    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate * endDateNs = [dateFormatter1 dateFromString:self.endDate];
                    NSDate *dateAhead8 = [endDateNs dateByAddingTimeInterval:(24 * 60 * 60)- 1];
                    
                    if ([self isDate:date inRangeFirstDate:strDateNs lastDate:dateAhead8]) {
                        [tempArray addObject:dict];
                    }
                }
                self.dicArray = tempArray;
                latestVC.dicData = [dicArray objectAtIndex:0];
                //到第一頁
                //                [latestVC getData:1];
                [latestVC getFirstData];
            }
        }
    }];
}

- (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    return [date compare:firstDate] == NSOrderedDescending &&
    [date compare:lastDate] == NSOrderedAscending;
}

@end
