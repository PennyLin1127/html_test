//
//  LatestListCollectionVC.m
//  HOLA
//
//  Created by Howard Lui on 2015/9/30.
//  Copyright © 2015年 JimmyLiu. All rights reserved.
//

#import "CatalogueListViewController.h"
#import "LatestListCollectionVCell.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "LatestCatalogueViewController.h"
#import "LatestListCollectionVC.h"

static NSString *identifier = @"LatestListCollectionVCell";

@interface LatestListCollectionVC ()

{
    NSInteger currentPage;
    NSInteger totalPage;
    //CGRect viewRect;
    NSMutableDictionary *dataDic;//所有儲存的頁面資料
    NSInteger lastPage; //上一個
    UIView *tempView;
}


@end

@implementation LatestListCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //delegate
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    NSLog(@"共有幾筆 %zd", self.parentVC.dicArray.count);
    
    //*如果沒有任何的資料 要蓋掉原本的view
//    __weak LatestListCollectionVC *this = self;
//    if (self.dicData.count == 0 || nil) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"self.view.frame -- %@", NSStringFromCGRect(this.collectionView.frame));
//            tempView = [[UIView alloc] initWithFrame:this.collectionView.frame];
//            [tempView setBackgroundColor:[UIColor whiteColor]];
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
//            label.text = @"目前無任何資料";
//            label.textAlignment = NSTextAlignmentCenter;
//            label.center = this.collectionView.center;
//            [tempView addSubview:label];
//            [this.collectionView addSubview:tempView];
//        });
//    }else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (tempView != nil) {
//                [tempView removeFromSuperview];
//            }
//        });
//    }
    //如果沒有任何的資料 要蓋掉原本的view *//
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //    viewRect = self.view.frame;
    //    cellRect = CGRectMake(0, 0, viewRect.size.width/2, (viewRect.size.width/2)*1.5);
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

#pragma mark - collection delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(self.cellRect.size.width, self.cellRect.size.height);
    return size;
    //    return self.cellRect.size;
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.parentVC.dicArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LatestListCollectionVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *dic = [self.parentVC.dicArray objectAtIndex:indexPath.row];
    
    NSString *name = [dic objectForKey:@"catalogueTitle"];
    
    //set nameLabel view
    cell.nameLabel.text = name;
    //cell.nameLabel.textColor = [UIColor colorWithRed:1.0 green:102.0/255.0 blue:0.0 alpha:1.0];
    cell.nameLabel.font = [UIFont systemFontOfSize:14];
    
    //set containerView view
//    cell.containerView.layer.borderWidth = 0.5;
//    cell.containerView.layer.cornerRadius = 5.0;
    //cell.containerView.layer.borderColor = [UIColor colorWithRed:1.0 green:102.0/255.0 blue:0.0 alpha:0.5].CGColor;
    
    NSString *startTime = [dic objectForKey:@"startDate"];
    NSString *endTime = [dic objectForKey:@"endDate"];
    
    startTime = [startTime substringToIndex:10];
    endTime = [endTime substringToIndex:10];
    
    cell.timeLabel.text = [NSString stringWithFormat:@"%@~%@", startTime, endTime];
    
    NSString *imgURLString = [dic objectForKey:@"img"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", IMAGE_PREFIX_HOLA, imgURLString];
    NSURL *url = [NSURL URLWithString:urlString];
    cell.asyncImageView.imageURL = url;
    
    //    [cell.containerView.layer setCornerRadius:50.0f];
    [cell.layer setCornerRadius:5.0f];
    
    return cell;
    
}

//點選cell
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //先取得資料
    NSDictionary *dic = [self.parentVC.dicArray objectAtIndex:indexPath.row];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Catalogue" bundle:nil];
    LatestCatalogueViewController *vc = [sb instantiateViewControllerWithIdentifier:@"LatestCatalogueView"];
    vc.dicData = dic;
    
    //先撈資料
    [vc getFirstData];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    //NSInteger catalogueId = [[dic objectForKey:@"catalogueId"] integerValue];
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    LatestListCollectionVCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell1.asyncImageView.imageURL = nil;
}

#pragma mark - 取得資料
-(void) getData:(NSInteger)page {
    
    if ([dataDic objectForKey:[NSString stringWithFormat:@"page%zd", page-1]] != nil) {
        NSLog(@"已經有此筆資料");
        return;
    }else {
        NSLog(@"準備撈第幾頁 -- %zd", page);
        NSLog(@"第幾頁index -- %zd", page-1);
    }
    
    //組成Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSInteger catalogueId = [[self.dicData objectForKey:@"catalogueId"] integerValue];
    NSLog(@"Detail getData -- catalogueId -- %zd", catalogueId);
    NSDictionary *dic = @{@"sessionId": sessionId, @"catalogueId":[NSString stringWithFormat:@"%zd", catalogueId], @"page": [NSString stringWithFormat:@"%zd", page]};
    
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    [hud showAnimated:NO whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:CATALOGUE_DETAIL] AndDic:dic];
//        hud.yOffset = 100;
    } completionBlock:^{
        
//        [hud show:NO];
//        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            return;
            
        }else {
            //NSString *testStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            //NSLog(@"testStr -- %@", testStr);
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];
            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            //NSLog(@"returnDic -- %@", returnDic);
            
            if (returnDic == nil) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
            }
            
            // 0730 Joseph 先判斷系統有無在維修
            if (perfectAPIManager.isJSON) {
                
                NSString *startTime=[returnDic objectForKey:@"startTime"];
                NSString *endTime=[returnDic objectForKey:@"endTime"];
                NSString *msg=[returnDic objectForKey:@"msg"];
                
                if (startTime!=nil && endTime!=nil && msg!=nil) {
                    UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"關閉" otherButtonTitles:nil, nil];
                    [av show];
                }
                
                perfectAPIManager.isJSON=NO;
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
                
                
                totalPage = [[dic objectForKey:@"totalPage"] integerValue];
                //NSLog(@"totalPage -- %zd", totalPage);
                //NSLog(@"key -- %@", [NSString stringWithFormat:@"page%zd", page-1]);
                //                self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", currentPage,totalPage];
                //                [dataDic setObject:dic forKey:[NSString stringWithFormat:@"page%zd", page-1]];
                [self.collectionView reloadData];
                
                //[self getAllData];
                
            }
        }
    }];
    
}


//VC初始化時 先取得第一和第二頁
-(void) getFirstData {
    [self getData:1];
    //[self getData:2];
    //[self getData:3];
}

//欲先取得下一頁資料
-(void) getNextData {
    [self getData:currentPage];
}

-(void) getAllData {
    static BOOL canLoad = YES;
    if(canLoad == YES) {
        canLoad = NO;
        for (NSInteger i = 2; i<=totalPage; i++) {
            [self getData:i];
        }
        
    }
    
}


@end
