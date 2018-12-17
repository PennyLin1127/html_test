//
//  ThemeStyleViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/2/12.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//  2015-05-01 Henry Collection View 高度計算邏輯有問題
//  2015-05-03 Henry 因要計算圖片高度，流程應該寫 1->載入所有圖片 2->重新顯示CollectionView
//

#import "ThemeStyleViewController.h"
#import "pinCollectionViewCell.h"
#import "SQLiteManager.h"
#import "NSDefaultArea.h"
#import "AsyncImageView.h"
#import "URLib.h"
#import "ThemeProductListCollectionViewController.h"
#import "IHouseURLManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "IHouseUtility.h"

#define CELL_IDENTIFIER @"WaterfallCell"
#define THUMBNAIL_WIDTH 100

@interface ThemeStyleViewController () {
    BOOL isImageLoaded;
}

@property (strong,nonatomic) NSMutableArray *cellSizes;
@property(strong,nonatomic) NSMutableArray *dataSource;
@property(strong,nonatomic) NSMutableArray *dataString;

@end


@implementation ThemeStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isImageLoaded=NO;
    
    // get date (YYYY-MM-dd)
    NSDate *date=[NSDate date];
    NSString *dateStrFormate=[IHouseUtility createDateFormat:date];
    NSArray *tempArray;
    
    if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
        
        tempArray= [SQLiteManager getThemeData:self.themeID date:dateStrFormate];
    }
    else{
        tempArray= [SQLiteManager getThemeData:self.themeID];
    }
    
    // 初始，取得主題風格(圖,文)
    self.themeDataSourceArray=[[NSMutableArray alloc]initWithArray:tempArray];
    
    // 加入客制的collectionView
    [self.view addSubview:self.collectionView];
    
    // init mutable
    self.picArray =[[NSMutableArray alloc]initWithCapacity:0];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self beginDownload];
    });
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 下載主圖風格圖
-(void)beginDownload
{
    for (NSDictionary *dic in self.themeDataSourceArray ) {
        NSString *themePathURL=[NSString stringWithFormat:@"%@",[IHouseURLManager getPerfectURLByAppName:HOLA_THEME_PATH]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",themePathURL,[dic objectForKey:@"vchImage1"]]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        
        if (connection) {
            NSData *imageData=[NSData dataWithContentsOfURL:url];
            UIImage *image=[UIImage imageWithData:imageData];
            
            if (image!=nil) {
                [self.picArray addObject:image];
            }
            
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"連線失敗" message:@"無法建立連線" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
     dispatch_async(dispatch_get_main_queue(), ^{
         isImageLoaded = YES;
         [self.collectionView reloadData];
         ////    2015-05-03 Henry重新更新Layout
         [self.collectionView.collectionViewLayout invalidateLayout];
//         self.collectionView.hidden = NO;
         [MBProgressHUD hideHUDForView:self.view animated:YES];

     });

}

#pragma mark - NSURLConnectionDataDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //    self.label.text = @"接收到回應";
    //    [self.data setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    self.label.text = @"下載中";
    //    [self.data appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //    self.label.text = @"下載完成";
    //    UIImage *image = [UIImage imageWithData:self.data];
    //    [self.imageView setImage:image];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"連線失敗"
                                                 message:@"無法順利完成連線"
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil, nil];
    [av show];
}


#pragma mark - collectionView
// 客製化colletionView
-(UICollectionView*)collectionView {
    if(!_collectionView){
        
        // init layout
        CHTCollectionViewWaterfallLayout *layout=[[CHTCollectionViewWaterfallLayout alloc]init];
        
        // setting layout
        layout.sectionInset=UIEdgeInsetsMake(10, 10, 10, 10);
        layout.headerHeight=10;
        layout.footerHeight=30;
        layout.minimumColumnSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.columnCount =2;
        
        // init collectionView
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f];
        
        // register cell
        [_collectionView registerClass:[pinCollectionViewCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    }
    return _collectionView;
}


#pragma mark - CollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"self.themeDataSourceArray.count %lu",self.themeDataSourceArray.count);
    if (isImageLoaded == NO) {
        return 0;
    } else {
        return self.themeDataSourceArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    pinCollectionViewCell *cell =(pinCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                                    forIndexPath:indexPath];

    // Configure the cell
    if (cell == nil) {
        cell = [[pinCollectionViewCell alloc]init];
    }
    
    [cell.layer setCornerRadius:5.0f];
    
    NSDictionary *dic=self.themeDataSourceArray[indexPath.row];
    
    // 圖片
    [cell.showImageView1 setImage:[self.picArray objectAtIndex:indexPath.row]];
    
    //2015-05-01 Henry 調整不變形 UIViewContentModeScaleAspectFit
    
    //0611 增加圖片周圍白色border及拉長圖片高度
    cell.showImageView1.frame=CGRectMake(0,0,cell.showImageView1.frame.size.width,cell.showImageView1.frame.size.width*1.5);
    cell.showImageView1.contentMode = UIViewContentModeScaleToFill;
    [cell.showImageView1.layer setBorderColor:[[UIColor whiteColor]CGColor]];
    [cell.showImageView1.layer setBorderWidth:10];
    
    
    // 大標
    cell.showLable1.text=[dic objectForKey:@"vchThemeName"];
    
    // 小標
    cell.showSecondLabel.text=[dic objectForKey:@"vchSummary"];
    
    return cell;
}


#pragma mark - CollectionView Delegate
// called when the user taps on an already-selected item in multi-select mode
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    // 存下使用者按下哪一個照片的目錄ID
    NSDictionary *dic=[self.themeDataSourceArray objectAtIndex:indexPath.row];
    self.themeID = [[dic objectForKey:@"themeId"] integerValue];
    
    
    // GA -- 選擇哪一個熱門話題底下的瀑布牆 - 待測試 themeID
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/theme/item/%ld",(long)self.themeID]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/theme/item/%ld",(long)self.themeID]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
    
    
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ThemeProductListCollectionViewController *vc=[sb instantiateViewControllerWithIdentifier:@"ThemeProductListCollectionView"];
    vc.themeID = self.themeID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Did deselect row: %lu",indexPath.row);
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"godDamnSizee %lu",(unsigned long)self.picArray.count);
    
    if ([self.picArray count]>0) {
        
        UIImage *image=[self.picArray objectAtIndex:indexPath.row];
        
        //2015-05-01 Henry 兩個不同物件可以比較?
        if (image != nil) {
            // 有圖片
            //2015-05-01 這裡尺寸有問題，應該UIIMAGEVIEW與實際圖片尺寸
            float ratio  = THUMBNAIL_WIDTH / image.size.width;
            CGSize size=CGSizeMake(THUMBNAIL_WIDTH, (image.size.height)* ratio);
            return size;
        }else {
            // 若沒圖片，傳以下size回去
            CGSize nonSize=CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_WIDTH);
            return nonSize;
        }
    } else {
        return CGSizeMake(SIZE_MAX, SIZE_MAX);
    }
    
    
}



@end
