//
//  ProductListContainerViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/4.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
// 2015-05-01 Henry 上方選單應該由NavigationBar統一操作
// 2015-05-02 Henry 讀取產品統一改由ProductAPILoader
//


#import "CompareViewController.h"
#import "NSDefaultArea.h"
#import "Model.h"
#import "SessionID.h"
#import "ProductInfoData.h"
#import "URLib.h"
#import "CatagoryInfoData.h"
#import "ProductAPILoader.h"
#import "ProductContentViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "getCartsData.h"
#import "CartsVC.h"


@interface ProductListContainerViewController ()
{
    ProductAPILoader *productAPILoader;
}
@property (strong,nonatomic) NSMutableArray *SkuArray;
//@property (assign,nonatomic) NSInteger tag4Push;

@end

@implementation ProductListContainerViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.sub2ProductCatalogueTitle setTitle:self.titleName forState:UIControlStateNormal];
    
    // init productListCollectionViewController
    UIStoryboard *storyboard1 = self.storyboard;
    self.productListCollectionViewController =[storyboard1 instantiateViewControllerWithIdentifier:@"ProductListCollectionViewController"];
    self.productListCollectionViewController.delegate = self;
    self.productListCollectionViewController.containerController = self;
    
    // init productListTableViewController
    UIStoryboard *storyboard2 = self.storyboard;
    self.productListTableViewController =[storyboard2 instantiateViewControllerWithIdentifier:@"ProductListTableViewController"];
    self.productListTableViewController.delegate=self;
    self.productListTableViewController.containerController2 = self;
    
    
    NSLog(@"self.keyword%@",self.keyword);
    NSLog(@"self.categoryID--%@",self.categoryID);
    if (self.categoryID>0) {
        [self SyncGetProductListData];
    } else if (self.keyword.length >0) {
        [self SyncGetData];
    }
    
    // show first view in container view
    [self.showCollectionViewOrTableView addSubview:self.productListCollectionViewController.view];
    self.productListCollectionViewController.view.frame = self.showCollectionViewOrTableView.frame;
    //    productListTableViewController.view.frame=self.showCollectionViewOrTableView.frame;
    
    // init mutable
    self.productInfoArray=[[NSMutableArray alloc]initWithCapacity:0];
    self.AddArray=[[NSMutableArray alloc]initWithCapacity:0];
    self.catagoryInfoArray=[[NSMutableArray alloc]initWithCapacity:0];
    
    self.productIDs=[[NSMutableArray alloc]initWithCapacity:0];
    
    [self.scrolToTop setHidden:YES];
    
    [self.catagoryInfoArray setValue:[NSArray array] forKey:@"catagoryInfoArray"];
    
    
    // GA -- 選擇哪一個商品分類的子目錄
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/product/category/%@",self.categoryID]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/product/category/%@",self.categoryID]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];

    
}


//上方選單切換Delegate
-(void)listSwitchChanged:(PRODUCT_LIST_MODE)product_list_mode {
    if(product_list_mode == TWO_COLUMN){
        // show collection view
        [self.showCollectionViewOrTableView addSubview:self.productListCollectionViewController.view];
        [self.productListCollectionViewController.collectionView reloadData];
        self.scrolToTop.hidden=YES;
        //同步產品id --> 選取/取消
        self.productListCollectionViewController.productIDs=[NSMutableArray arrayWithArray:self.productListTableViewController.productIDs];
        
    }else{
        // show table view
        [self.showCollectionViewOrTableView addSubview:self.productListTableViewController.view];
        [self.productListTableViewController.tableView reloadData];
        self.scrolToTop.hidden=YES;
        //同步產品id --> 選取/取消
        self.productListTableViewController.productIDs=[NSMutableArray arrayWithArray:self.productListCollectionViewController.productIDs];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)popToPreviousView{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)scrollToTop:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(toTop)])
    {
        [self.delegate toTop];
        
    }
    
    if ([self.delegate2 respondsToSelector:@selector(toTop2)]) {
        [self.delegate2 toTop2];
    }
}



-(void)topButtonHideOrNot:(BOOL)topTag{
    
    if(topTag==YES){
        self.scrolToTop.hidden=NO;
    }
    else{
        self.scrolToTop.hidden=YES;
    }
}

- (IBAction)productCompare:(id)sender {
    
    self.productIDs = [NSMutableArray new];
    for (ProductInfoData *product in self.productList) {
        if (product.isSelected) {
            [self.productIDs addObject:product.prdId];
        }
    }
    
    if(self.productIDs.count>6)
    {
        NSString *err = @"您最多選擇比較六件商品";
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
    
    
}

- (IBAction)storeList:(id)sender {
    
    NSMutableArray *productIDs = [NSMutableArray new];
    for (ProductInfoData *product in self.productList) {
        if (product.isSelected) {
            [productIDs addObject:product.prdId];
        }
    }
    
    if (productIDs.count==0) {
        
        UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:@"最少選擇一件商品" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        
        [av show];
    }
    else
    {
        //加入我的最愛清單
        [Model addToFavoriteList:productIDs];
        NSLog(@"Press store list button");
    }
    
}

-(IBAction)addCarts:(id)sender
{
    self.SkuArray=[[NSMutableArray alloc]init];
    
    

    for (ProductInfoData *product in self.productList) {
        if (product.isSelected) {
            [self.SkuArray addObject:product.sku];
        }
    }
    
    NSString *alertStr;
    if (self.SkuArray.count==0) {
        alertStr=@"請選擇商品";
    }else{
        alertStr=@"已加入購物車";
    }
    
    UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:alertStr delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
    [av show];
   
    [self addToCarts:self.SkuArray];

}


-(void)addToCarts:(NSArray*)SkuArry {
    
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
    
    [_getCartsData getDataViaAPI:SkuArry];

}


#pragma mark - SyncGet product list data

-(void)SyncGetProductListData {
    NSLog(@"==取得分類下產品列表!");
    
    if (productAPILoader == nil) {
        productAPILoader = [ProductAPILoader new];
    }
    
    __weak ProductListContainerViewController *this = self;
    
    //撈資料
    productAPILoader.loadCompletionBlock = ^(BOOL success , NSInteger totalCount, NSArray *productList,NSArray *catogorys , BOOL hasMore) {
        NSLog(@"查詢產品結果 :%ld",(unsigned long)[productList count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新下層顯示之產品資料
            this.productList = productList;
            this.hasMore = hasMore;
            NSLog(@"=====hasmore:%d", hasMore);
            [this.productListCollectionViewController updateProductList:productList];
            [this.productListTableViewController updateProductList:productList];
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
    
    //    呼叫Product Loader 讀取資料
    [productAPILoader loadData:ProductByCategoryID data:self.categoryID sortColumn:nil sort:SortOrderNotSet clearAll:YES];
    
}





#pragma mark - SyncGetSearchData
// 搜尋keyword
-(void)loadMore {
    [productAPILoader loadMore];
}

-(void)SyncGetData {
    
    NSLog(@"==取得分類下產品列表!");
    
    if (productAPILoader == nil) {
        productAPILoader = [ProductAPILoader new];
    }
    
    __weak ProductListContainerViewController *this = self;
    
    //撈資料
    productAPILoader.loadCompletionBlock = ^(BOOL success , NSInteger totalCount, NSArray *productList ,NSArray *catogorys, BOOL hasMore) {
        NSLog(@"查詢產品結果 :%ld",(unsigned long)[productList count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新下層顯示之產品資料
            this.productList = productList;
            this.productCatagory = catogorys;
            [this.productListCollectionViewController updateProductList:productList];
            [this.productListTableViewController updateProductList:productList];
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
    
    //    呼叫Product Loader 讀取資料
    [productAPILoader loadData:ProductByKeyword data:self.keyword sortColumn:nil sort:SortOrderNotSet clearAll:YES];
    
}

//#pragma mark - SyncGet product compare data - for theme style

-(void)productSelected:(NSString *)productID SKU:(NSString*)skuStr{
    NSLog(@"select product :%@",productID);
    UIStoryboard *contentSB=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
    ProductContentViewController *vc=[contentSB instantiateViewControllerWithIdentifier:@"contentVC"];
    vc.productID = productID;
    vc.productSKU = skuStr;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
