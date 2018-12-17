//
//  LatestCatalogueViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "LatestCatalogueViewController.h"
#import "IHouseUtility.h"
#import "IHouseURLManager.h"
#import "LatestCatalogueCollectionViewCell.h"

static NSString *identifier = @"LatestCatalogueCell";

@interface LatestCatalogueViewController () {
    NSInteger currentPage;
    NSInteger totalPage;
    CGRect viewRect;
    NSMutableDictionary *dataDic;//所有儲存的頁面資料
    NSInteger lastPage; //上一個
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
- (IBAction)backAction:(id)sender;
- (IBAction)fowardAction:(id)sender;

@end

@implementation LatestCatalogueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //init var
    currentPage = 1;
    totalPage = 0;
    dataDic = [[NSMutableDictionary alloc] init];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //BACK 
    [self setBackButton];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //如果有ContainerView 用自己的Frame
    if (self.parentVC) {
        viewRect = self.view.frame;
    }else {
        viewRect = self.collectionView.frame;
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


#pragma mark - collection delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return totalPage;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LatestCatalogueCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //清除圖片
    cell.asyncImageView.image = nil;
    
    //設定內容
    NSDictionary *dic = [dataDic objectForKey:[NSString stringWithFormat:@"page%zd", indexPath.row]];
    NSString *img = [dic objectForKey:@"img"];
    NSString *imgURLStr = [NSString stringWithFormat:@"%@%@", IMAGE_PREFIX_HOLA, img];
    NSURL *url = [NSURL URLWithString:imgURLStr];

    cell.asyncImageView.imageURL = url;
    //cell.asyncImageView.showActivityIndicator = NO;
    cell.scorllView.zoomScale = 1.0;
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"%@", NSStringFromCGRect(viewRect));
    CGSize size = CGSizeMake(viewRect.size.width, viewRect.size.height-40);
    return size;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    LatestCatalogueCollectionViewCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell1.asyncImageView.imageURL = nil;
}

#pragma mark - scroll viewe delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat width = scrollView.frame.size.width;
    NSInteger page = ((scrollView.contentOffset.x - width / 2) / width) + 1;
    
    NSLog(@"滑到第幾頁(index) -- %zd", page);
    
    currentPage = page+1;
    
    [self changeCountLabel];
    
    
    [self getNextData];
    
//    if (page > lastPage && [dataDic objectForKey:[NSString stringWithFormat:@"page%zd", currentPage] ] == nil) {
//        [self getNextData];
//    }
//    
//    //記錄上次滑的頁面
//    lastPage = page;
}




#pragma mark - Button Event
- (IBAction)backAction:(id)sender {
    NSLog(@"backAction");
    currentPage = currentPage -1;
    if (currentPage -1 < 1) {
        currentPage = 1;
    }
    [self scrollToCell];
    [self changeCountLabel];
}

- (IBAction)fowardAction:(id)sender {
    NSLog(@"fowardAction");
    currentPage = currentPage +1;
    if (currentPage > totalPage) {
        currentPage = totalPage;
    }
    [self scrollToCell];
    [self changeCountLabel];
    [self getNextData];    
}


-(void)scrollToCell {
    NSIndexPath *path = [NSIndexPath indexPathForRow:currentPage-1 inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
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
//    [hud hide:YES afterDelay:10];
    [hud showAnimated:NO whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:CATALOGUE_DETAIL] AndDic:dic];
        
    } completionBlock:^{
        
//        [hud show:NO];
//        [hud hide:YES];
        
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
            //NSLog(@"returnDic -- %@", returnDic);
            
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
                
                totalPage = [[dic objectForKey:@"totalPage"] integerValue];
                //NSLog(@"totalPage -- %zd", totalPage);
                //NSLog(@"key -- %@", [NSString stringWithFormat:@"page%zd", page-1]);
                self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", currentPage,totalPage];
                [dataDic setObject:dic forKey:[NSString stringWithFormat:@"page%zd", page-1]];
                [self.collectionView reloadData];
                
                //[self getAllData];
            }
        }
    }];
    
}

//VC初始化時 先取得第一和第二頁
-(void) getFirstData {
    [self getData:1];
    [self getData:2];
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

#pragma mark - other
-(void)changeCountLabel {
   
    self.countLabel.text = [NSString stringWithFormat:@"%zd/%zd", currentPage,totalPage];

}


#pragma mark - 設置Navigation
-(void)initNavigation {
    
}

@end
