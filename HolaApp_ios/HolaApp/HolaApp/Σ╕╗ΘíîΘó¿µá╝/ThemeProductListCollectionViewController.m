//
//  ThemeProductListCollectionViewController.m
//  HOLA
//
//  Created by Joseph on 2015/4/28.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ThemeProductListCollectionViewController.h"
#import "ThemeCollectionViewCell.h"
#import "NSDefaultArea.h"
#import "SessionID.h"
#import "GetAndPostAPI.h"
#import "URLib.h"
#import "ProductInfoData.h"
#import "AsyncImageView.h"
#import "ProductContentViewController.h"
#import "SQLiteManager.h"
#import "CatagoryInfoData.h"
#import "Model.h"
#import "CompareViewController.h"
#import "ProductAPILoader.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "getCartsData.h"

@interface ThemeProductListCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    
    NSDictionary *productListDic;
    GetAndPostAPI *getAndPostAPI;
    CGRect cellRect;
    MBProgressHUD  *progressHUD;
    ThemeCollectionViewCell *themeCollectionViewCell;
    ProductAPILoader *productAPILoader;
    BOOL hasMoreProduct;
    BOOL hasKeywordLoaded;
    NSMutableArray *productIDs;

}


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ThemeProductListCollectionViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init getAndPostAPI
    getAndPostAPI=[[GetAndPostAPI alloc]init];
    
    // init search condition at first time
    NSDictionary *filter=@{@"filterCondition":@""};
    [NSDefaultArea filterConditionToUserDefault:filter];
    NSDictionary *ascOrDsc=@{@"ascOrDesc":@""};
    [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
    NSString *parentId=@"";
    [NSDefaultArea parentCategoryIdToUserDefault:parentId];
    
    // register for footer and header
    [self.collectionView registerClass:[ThemeCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ThemeCollectionReusableView"];
    
    [self.collectionView registerClass:[ThemeCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ThemeCollectionReusableView"];
    
    hasMoreProduct = NO;
    hasKeywordLoaded = NO;
    
    productIDs=[[NSMutableArray alloc]initWithCapacity:0];

    
    // 設定列表內容只能按一次，之後push到內容
    self.clickStatus=YES;
    
    // clear up array
    [self.prdIdDataArray removeAllObjects];
    [self.prdIdsSelectedDataArray removeAllObjects];
    
    // get date (YYYY-MM-dd)
    NSDate *date=[NSDate date];
    NSString *dateStrFormate=[IHouseUtility createDateFormat:date];

    // set up data and init
    if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
        NSArray *tempArray=[SQLiteManager getThemeDataDetail:self.themeID date:dateStrFormate];
        self.productDataSourceArray=[[NSMutableArray alloc]initWithArray:tempArray];
    }else{
        NSArray *tempArray=[SQLiteManager getThemeDataDetail:self.themeID];
        self.productDataSourceArray=[[NSMutableArray alloc]initWithArray:tempArray];
    }
  
    
    [self loadThemeProducts];
    
}

-(void)loadThemeProducts {
    if (productAPILoader == nil) {
        productAPILoader = [ProductAPILoader new];
    }
    
    __weak ThemeProductListCollectionViewController *this = self;
    
    //撈資料
    productAPILoader.loadCompletionBlock = ^(BOOL success , NSInteger totalCount, NSArray *productList ,NSArray *catogorys, BOOL hasMore) {
        NSLog(@"查詢產品結果 :%ld",[productList count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新下層顯示之產品資料
            this.productList = productList;
            [this.collectionView reloadData];
            [MBProgressHUD hideHUDForView:this.view animated:YES];
            
        });
        
    };
    // 0529 [IOS]熱門話題沒有輸入商品時不要跳出 0 訊息視窗
    productAPILoader.loadErrorBlock = ^(NSString *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:this.view animated:YES];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                         message:message delegate:this cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [av show];
        });
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSArray *skus = [SQLiteManager getThemeProduct:self.themeID];
    [productAPILoader loadData:ProductBySKU data:skus sortColumn:nil sort:SortOrderNotSet clearAll:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    // 設定列表內容只能按一次，之後push到內容之後再給他tag
    self.clickStatus=YES;
}

-(IBAction)addCarts:(id)sender
{
    NSMutableArray *skuArray=[[NSMutableArray alloc]init];
    
    self.productIDs = [NSMutableArray new];
    for (ProductInfoData *product in self.productList) {
        if (product.isSelected) {
            [skuArray addObject:product.sku];
        }
    }
    
    NSString *alertStr;
    if (skuArray.count==0) {
        alertStr=@"請選擇商品";
    }else{
        alertStr=@"已加入購物車";
    }
    
    UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:alertStr delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
    [av show];
    
    [self addToCarts:skuArray];
}


-(void)addToCarts:(NSArray*)SkuArray {
    
    getCartsData *_getCartsData=[[getCartsData alloc]init];
    _getCartsData.completeBlock=^(NSString *msg,NSDictionary *dicData){
        
        BOOL status=[[dicData objectForKey:@"status"]integerValue];
        
        if (status) {
            // 為購物車數目
            NSNumber *cartNums=[[dicData objectForKey:@"data"]objectForKey:@"cartNums"];
            //            [[NavigationViewController currentInstance] reflashMyCarts:[cartNums stringValue]];
            [self reflashMyCarts:[cartNums stringValue]];
            
        }else{
            UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
            [av show];
        }
    };
    [_getCartsData getDataViaAPI:SkuArray];
}

#pragma mark - DidSelectButton

- (void)DidSelectButton:(UIButton*)sender {
    
    UIButton *button= (UIButton *)sender;
    ProductInfoData *product = [self.productList objectAtIndex:button.tag];
    product.isSelected = !product.isSelected;
    
    
    if (product.isSelected) {
        NSLog(@"product is Selected");
        [button setImage:[UIImage imageNamed:@"Compare_2"] forState:UIControlStateNormal];
        [productIDs addObject:product.prdId];
        
        
    } else {
        NSLog(@"product is not Selected");
        [button setImage:[UIImage imageNamed:@"Compare_1"] forState:UIControlStateNormal];
        [productIDs removeObject:product.prdId];
    }
    
    
    if (productIDs.count==7) {
        
        NSString *err = @"您最多可以選擇六件商品";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:err delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (IBAction)compareList:(id)sender
{


    self.productIDs = [NSMutableArray new];
    for (ProductInfoData *product in self.productList) {
        if (product.isSelected) {
            [self.productIDs addObject:product.prdId];
        }
    }
    
    if(self.productIDs.count>6)
    {
        NSString *err = @"您最多可以選擇六件商品";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:err delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        
    }else if(self.productIDs.count<=1){
        NSString *err = @"最少選擇兩件商品";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:err delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
        
    }else{
        
        UIStoryboard *compareStoryBoard=[UIStoryboard storyboardWithName:@"Compare" bundle:nil];
        CompareViewController *compareVC=[compareStoryBoard instantiateViewControllerWithIdentifier:@"CompareVC"];
        compareVC.productList = self.productIDs;
        [self.navigationController pushViewController:compareVC animated:YES  ];
        
    }
    
    NSLog(@"self.productIDs %@",self.productIDs);
    
  
}

- (IBAction)storeList:(id)sender
{
    self.productIDs = [NSMutableArray new];
    for (ProductInfoData *product in self.productList) {
        if (product.isSelected) {
            [self.productIDs addObject:product.prdId];
        }
    }
    
    if (self.productIDs.count==0) {
        
        UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:@"最少選擇一件商品" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        
        [av show];
    }
    else
    {
        //加入我的最愛清單
        [Model addToFavoriteList:self.productIDs];
        NSLog(@"Press store list button");
    }
    
}

- (IBAction)goToTop:(id)sender
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

-(void)searchMore:(UIButton*)sender{
    
    // 存SQL keyword (只能一個keyword)
    NSString *sKeyword=[self.productDataSourceArray[0] objectForKey:@"vchKeyword"];
    
    if (productAPILoader == nil) {
        productAPILoader = [ProductAPILoader new];
    }
    
    __weak ThemeProductListCollectionViewController *this = self;
    
    //撈資料
    productAPILoader.loadCompletionBlock = ^(BOOL success , NSInteger totalCount, NSArray *productList ,NSArray *catogorys, BOOL hasMore) {
        NSLog(@"查詢產品結果 :%ld",[productList count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新下層顯示之產品資料
            this.productList = productList;
            hasMoreProduct = hasMore;
            [this.collectionView reloadData];
            
            //已經搜尋過且無更多頁數，則隱藏更多按鈕
            if (hasKeywordLoaded == YES && hasMoreProduct == NO) {
                this.supplementaryViewFooter.searchMore.hidden = YES;
            }
            [MBProgressHUD hideHUDForView:this.view animated:YES];
            
        });
        
    };
    productAPILoader.loadErrorBlock = ^(NSString *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:this.view animated:YES];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:message delegate:this cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [av show];
        });
    };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (hasKeywordLoaded == NO) {
        hasKeywordLoaded = YES;
        [productAPILoader loadData:ProductByKeyword data:sKeyword sortColumn:nil sort:SortOrderNotSet clearAll:NO];
    } else if (hasMoreProduct) {
        [productAPILoader loadMore];
    }
}


#pragma mark - SyncGetSearchData - for search
// 搜尋keyword
-(void)SyncGetData {
}


#pragma mark - CollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
//    NSLog(@"search count %lu",(unsigned long)self.productInfoArray.count);
    return [self.productList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"Cell";
    ThemeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // Configure the cell
    if (cell == nil) {
        cell = [[ThemeCollectionViewCell alloc] initWithFrame:cellRect];
        NSLog(@"cellRect -- %@", NSStringFromCGRect(cellRect));
    }
    
    
    ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];
    
    cell.prdNameLabel.text=product.prdName;
    
    NSURL *url1 =nil;
    cell.prdImge.imageURL = url1;
    [cell.prdImge setShowActivityIndicator:YES];
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.prdImge.imageURL];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOLA_PIC_URL_STR, product.prdImg]];
    cell.prdImge.imageURL = url;
    
    cell.origPriceLabel.text=[NSString stringWithFormat:@"售價 $%ld",product.origPrice];
    cell.salePriceLabel.text=[NSString stringWithFormat:@"網購價 $%ld",product.salePrice];
    
    //NSLog(@"self.productListCollectionViewController.clickButtonStatus3 %@",self.clickButtonStatus);
    
    if (product.isSelected) {
        // 選取
        [cell.selectButton setImage:[UIImage imageNamed:@"Compare_2"] forState:UIControlStateNormal];
    }else {
        // 無選取
        [cell.selectButton setImage:[UIImage imageNamed:@"Compare_1"] forState:UIControlStateNormal];
    }
    
    // selectButton indexPath.row=0,1,2,3.....
    cell.selectButton.tag = indexPath.row;
    [cell.selectButton addTarget:self action:@selector(DidSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundColor=[UIColor whiteColor];
    [cell.layer setCornerRadius:5.0f];
    
    return cell;
}


-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        ThemeCollectionReusableView *supplementaryViewHeader =[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"RV" forIndexPath:indexPath];
        
        if (supplementaryViewHeader == nil)
        {
            supplementaryViewHeader = [[ThemeCollectionReusableView alloc] init];
        }
        
        NSDictionary *dic=self.productDataSourceArray[0];
        NSString *themePathURL=[NSString stringWithFormat:@"%@",[IHouseURLManager getPerfectURLByAppName:HOLA_THEME_PATH]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",themePathURL,[dic objectForKey:@"vchImage2"]]];
        
        supplementaryViewHeader.headerImageView.imageURL=url;
        supplementaryViewHeader.mainLabel.text =[dic objectForKey:@"vchThemeName"];
        supplementaryViewHeader.subLabel.text=[dic objectForKey:@"vchDescription"];
        return supplementaryViewHeader;
    }
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        self.supplementaryViewFooter =[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SVF" forIndexPath:indexPath];
        
        if (self.supplementaryViewFooter == nil)
        {
            self.supplementaryViewFooter = [[ThemeCollectionReusableView alloc]init];
        }
        
        // 無keyword就不顯示load more button
        NSString *Keyword=[self.productDataSourceArray[0] objectForKey:@"vchKeyword"];
        if (Keyword==nil||[Keyword isEqual:@""]) {
            [self.supplementaryViewFooter.searchMore setHidden:YES];
        }
        
        [self.supplementaryViewFooter.searchMore addTarget:self action:@selector(searchMore:) forControlEvents:UIControlEventTouchUpInside];
        
        
        return self.supplementaryViewFooter;
    }
    
    return nil;
}

#pragma mark - CollectionView Delegate

// called when the user taps on an already-selected item in multi-select mode
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // 判斷只能按一次push到內容
    if (self.clickStatus==YES) {
        ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];
 
        //pushVC from container's navigation Controller
        UIStoryboard *contentSB=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
        ProductContentViewController *vc=[contentSB instantiateViewControllerWithIdentifier:@"contentVC"];
        vc.productID = product.prdId;
        [self.navigationController pushViewController:vc animated:YES];
        
        
        NSLog(@"Did select row: %lu",(long)indexPath.row);
        
        self.clickStatus=NO;
    }
   
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"Did deselect row: %lu",(long)indexPath.row);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    CGFloat width=self.view.frame.size.width;
    CGSize headerSize=CGSizeMake(width, 360);

    
    if (self.view.frame.size.height<=568){
        // i4,i5
        CGSize headerSize=CGSizeMake(width, 300);
        return headerSize;
    }else if(self.view.frame.size.height==667){
        // i6
        CGSize headerSize=CGSizeMake(width, 330);
        return headerSize;
    }else if (self.view.frame.size.height>=736){
        // i6+
        CGSize headerSize=CGSizeMake(width, 360);
        return headerSize;
    }
    return headerSize;
}

#pragma mark - cell size
// controll cell size via itemSize property
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGRect rect=self.view.frame;
    NSLog(@"self.view.frame -- %@", NSStringFromCGRect(rect));
    cellRect = CGRectMake(0, 0, (rect.size.width/2-15), (rect.size.width/2)*1.45);
    
    NSLog(@"rect1 %@",NSStringFromCGRect(cellRect));
    
    return cellRect.size;
}

#pragma mark - initializeProgressHUD
- (void)initializeProgressHUD:(NSString *)msg
{
    if (progressHUD)
        [progressHUD removeFromSuperview];
    
    progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUD];
    progressHUD.dimBackground = NO;
    // progressHUD.delegate = self;
    progressHUD.labelText = msg;
    progressHUD.margin = 20.f;
    
    // -100為5S
    //    progressHUD.yOffset = -(HUDsize.height/4);
    progressHUD.removeFromSuperViewOnHide = YES;
    [progressHUD show:YES];
}

@end
