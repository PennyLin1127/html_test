//
//  EinvoiceListViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "EinvoiceListViewController.h"
#import "InvoiceTableViewCell.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "EinvoiceDetailTableViewController.h"
#import "EinvoiceWinTableViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "GAIFields.h"

@interface EinvoiceListViewController () {
    NSInteger totalPage; //總頁數
    NSInteger currentPage; //當前頁數
    BOOL needToGetData; //YES - 需要繼續更新資料
    NSMutableArray *dataArray; //資料
    
    //是否已經取得資料
    BOOL haveData; // YES-已經成功取得資料
    
    //無資料時 遮蓋用的View
    UIView *tempView;
}

@property (weak, nonatomic) IBOutlet UITableView *invoiceTableView;

@end

@implementation EinvoiceListViewController

#pragma mark - View生命週期
- (void)viewDidLoad {
    [super viewDidLoad];

    //0625 Joseph set hidden firstly
    //self.defineLabel.hidden=YES;
    
    //init vat
    dataArray = [[NSMutableArray alloc] init];
    totalPage = 1;
    currentPage = 0;
    
    //tableview delegate
    self.invoiceTableView.delegate = self;
    self.invoiceTableView.dataSource = self;
    
    __weak EinvoiceListViewController *this = self;
    
    //*如果沒有任何的資料 要蓋掉原本的view
    if (dataArray.count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"self.view.frame -- %@", NSStringFromCGRect(this.invoiceTableView.frame));
            tempView = [[UIView alloc] initWithFrame:this.invoiceTableView.frame];
            [tempView setBackgroundColor:[UIColor whiteColor]];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
            label.text = @"目前無任何資料";
            label.textAlignment = NSTextAlignmentCenter;
            label.center = this.invoiceTableView.center;
            [tempView addSubview:label];
            [this.invoiceTableView addSubview:tempView];
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tempView != nil) {
                [tempView removeFromSuperview];
            }
        });
    }
    //如果沒有任何的資料 要蓋掉原本的view *//
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //0625 Joseph 一開始沒資料時顯示
    //[self getAndReloadData];
    
    NSLog(@"電子發票 -- viewDidAppear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"EinvoiceCell";
    
    InvoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[InvoiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
    
    //invoiceLabel
    NSString *invoiceNo = [dic objectForKey:@"invoiceNo"];

    cell.invoiceLabel.text = invoiceNo;
    //storeNameLabel
    NSString *storeName = [dic objectForKey:@"storeName"];
    cell.storeNameLabel.text = storeName;

    //dateLabel
    NSString *date = [dic objectForKey:@"date"];
    cell.dateLabel.text = date;
    
    BOOL isWin = [[dic objectForKey:@"invoiceWin"] boolValue];
    if (isWin == YES) {
        //打開Button Label
        cell.winButton.tag = indexPath.row;
        cell.winButton.hidden = NO;
        cell.winLabel.hidden = NO;
        
        [cell.winButton addTarget:self action:@selector(winAction:) forControlEvents:UIControlEventTouchUpInside];

        
        
    }else {
        //隱藏Button Label
        cell.winButton.hidden = YES;
        cell.winLabel.hidden = YES;
    }
    
    return cell;

}
/*
 {
 "invoiceId": "32065",
 "invoiceNo": "VD20917***",
 "date": "2013-07-07",
 "storeName": "特力屋 南崁店",
 "amount": 859,
 "status": "正常",
 "isDonate": "否",
 "isPrint": "是",
 "debitnoteIds": null,
 "invoiceWin": false,
 "questionnaire": "out_of_date"
 },
 */

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //先撈資料
    //組Dic
    NSDictionary *tempDic = [dataArray objectAtIndex:indexPath.row];
    NSString *invoiceId = [tempDic objectForKey:@"invoiceId"];
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    
    NSDictionary *dic = @{@"sessionId": sessionId, @"invoiceId":invoiceId};
    
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_EINVOICE_SHOP_ITEM] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            return;
            
        }else {
            //NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            //NSLog(@"testStr -- %@", testStr);
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
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
                
            }else {
                //成功
                NSDictionary *dic = [returnDic objectForKey:@"data"];
                
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
                EinvoiceDetailTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EinvoiceDetailTableView"];
                vc.dicData = dic;
                [self.navigationController pushViewController:vc animated:YES];
                
                // GA -- 發票細節
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                
                // 記畫面
                [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/invoice_detail"]];
                [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
                
                // 記事件
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/invoice_detail"]
                                                                      action:@"button_press"
                                                                       label:nil
                                                                       value:nil] build]];
            }
        }
    }];

    
    //EinvoiceDetailTableViewController.h
}
/*
 輸入範例
 {
 "sessionId": "4af3e075eb912244cbd20347a462755c",
 "invoiceId": 32133
 }
 */


#pragma mark - Button Action
-(void)winAction:(UIButton*)button {
    NSInteger tag = button.tag;
    NSLog(@"%zd", tag);
    
    //組Dic
    NSDictionary *tempDic = [dataArray objectAtIndex:tag];
    NSString *invoiceId = [tempDic objectForKey:@"invoiceId"];
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId, @"invoiceId":invoiceId};
    
    //送出資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_EINVOICE_WIN] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            return;
            
        }else {
            //NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            //NSLog(@"testStr -- %@", testStr);
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
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
                
            }else {
                //成功
                NSDictionary *dic = [returnDic objectForKey:@"data"];
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"My" bundle:nil];
                EinvoiceWinTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"EinvoiceWinTableView"];
                vc.dicData = dic;
                [self.navigationController pushViewController:vc animated:YES];
                
                // GA -- 中獎頁面
                id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                
                // 記畫面
                [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/member/invoice_winning"]];
                [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
                
                // 記事件
                [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/member/invoice_winning"]
                                                                      action:@"button_press"
                                                                       label:nil
                                                                       value:nil] build]];
            }
        }
    }];

    
    //EinvoiceWinTableView
}

/*
 傳入範例
 {
 "sessionId": "4af3e075eb912244cbd20347a462755c",
 "invoiceId": 32133
 }
 */

#pragma mark - 重撈資料方法
-(void)getAndReloadData {
    
    
    [self getDataFromWebApi:currentPage+1];
}

-(void)getDataFromWebApi:(NSInteger)page {
    
    if (page  > totalPage) {
        NSLog(@"沒有頁數了");
        return;
    }
    
    //組成Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId, @"page": [NSString stringWithFormat:@"%zd", page]};
    
    //發送資料
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:MY_EINVOICE_LIST] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            return;
            
        }else {
            //NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            //NSLog(@"testStr -- %@", testStr);
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
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
                
            }else {
                //成功
                NSDictionary *dic = [returnDic objectForKey:@"data"];
                //NSDictionary *dic = [tempDic objectForKey:@"invoices"];
                NSString *pageStr = [dic objectForKey:@"page"];
                currentPage = pageStr.integerValue;
                NSString *totalPageStr = [dic objectForKey:@"totalPage"];
                totalPage = totalPageStr.integerValue;
//                NSString *totalCountStr = [dic objectForKey:@"totalCount"];
                
                NSArray *tempArray = [dic objectForKey:@"invoices"];
                [self appendDataToArray:tempArray];
                NSLog(@"總頁數 -- %@", totalPageStr);
                NSLog(@"當前頁數 -- %@", pageStr);
                if (currentPage < totalPage) {
                    [self getDataFromWebApi:currentPage+1];
                }else {
                    NSLog(@"讀取完畢 reload tableview，共幾筆 -- %zd", dataArray.count);
                    [self.invoiceTableView reloadData];
                    
                }
            }
        }
    }];
    
}

-(void)appendDataToArray:(NSArray*)array {
    
    if (array.count == 0) {
        return;
    }else {
        [dataArray addObjectsFromArray:array];
    }
    
}

//#pragma mark - Navigation Bar
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

-(void)getData {
    
//    haveData = NO;
    if (haveData == NO) {
        
        [self getDataFromWebApi:currentPage+1];
        //haveData = YES;//成功取得資料 變更flag
    }else {
        NSLog(@"已經有資料，不用再撈");
    }}

@end

/*
 傳入範例
 {
 "sessionId": "4af3e075eb912244cbd20347a462755c",
 "page": 1
 }
 */