//
//  CompareViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/15.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CompareViewController.h"
#import "CompareCollectionViewController.h"
#import "ProductAPILoader.h"
#import "ProductListContainerViewController.h"
#import "ProductContentViewController.h"
#import "ProductInfoData.h"


@interface CompareViewController ()
{
    BOOL tag;
    NSTimer *timer;
    UIView *opacityView;
    ProductAPILoader *productAPILoader;
}


@end

@implementation CompareViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // init productListCollectionViewController
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Compare" bundle:nil];
    self.compareCollectionViewController=[storyboard instantiateViewControllerWithIdentifier:@"CompareCollectionVC"];
    self.compareCollectionViewController.delegate=self;
    
    // init compareTableViewController
    UIStoryboard *storyboard2 = [UIStoryboard storyboardWithName:@"Compare" bundle:nil];
    self.compareTableViewController=[storyboard2 instantiateViewControllerWithIdentifier:@"CompareTableVC"];

    
    // show compare colletion view
    [self.showCompareVC addSubview:self.compareCollectionViewController.view];
    self.compareCollectionViewController.view.frame=self.showCompareVC.frame;
    
    self.compareCollectionViewController.compareViewController=self;
    
    [self compareData];
    
    // for iphone 4 constraint
    int iphoneSize=[[UIScreen mainScreen ]bounds].size.height;
    if (iphoneSize==480) {
        self.heightCons.constant=1.0f;
    }
   
}


-(void)startTimer{
    float theInterval = 3.0;
    timer = [NSTimer scheduledTimerWithTimeInterval:theInterval target:self selector:@selector(closeView) userInfo:nil repeats:NO];
}

-(void)closeView{
    [timer invalidate];
    [opacityView removeFromSuperview];
}

-(void)viewDidAppear:(BOOL)animated{
    // for iphone 4 constraint
    int iphoneSize=[[UIScreen mainScreen ]bounds].size.height;
    if (iphoneSize==480) {
        self.heightCons.constant=1.0f;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editProductOrder:(id)sender {
    
    if(tag){
        
        [self.showCompareVC addSubview:self.compareCollectionViewController.view];
        tag=NO;
        
        //change button text
        [self.editOrder setTitle:@"編輯" forState:UIControlStateNormal];

        //reloadData after press editProductOrder button
        self.compareCollectionViewController.productList = [[NSArray alloc] initWithArray:self.compareTableViewController.productMuArray1];;
        [self.compareCollectionViewController.collectionView reloadData];
        
    }else{
        
        // show instruction view once
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            opacityView = [[UIView alloc] initWithFrame:window.frame];
            opacityView.backgroundColor = [UIColor blackColor];
            opacityView.alpha=0.8f;
            
            // label
            UILabel *instructionLabel=[[UILabel alloc]initWithFrame:CGRectMake(0 ,0, 160, 50)];
            
            [instructionLabel setCenter:opacityView.center];

            instructionLabel.text=@"請長按需要變更順序的產品並將商品拖曳至你想放置的位置";
            instructionLabel.textColor=[UIColor whiteColor];
            [instructionLabel setFont:[UIFont systemFontOfSize:12.0f]];
            instructionLabel.numberOfLines=2;
            instructionLabel.lineBreakMode = NSLineBreakByCharWrapping;
            
            // image
            UIImageView *instructionImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
            [instructionImage setCenter:CGPointMake(opacityView.frame.size.width / 2, opacityView.frame.size.width / 1.5)];

            instructionImage.image=[UIImage imageNamed:@"icon_hand-o-up"];
            instructionImage.contentMode=UIViewContentModeScaleAspectFit;
            
            [opacityView addSubview:instructionImage];
            [opacityView addSubview:instructionLabel];
            [window addSubview:opacityView];
            [self startTimer];
        });

        [self.showCompareVC addSubview:self.compareTableViewController.view];
        tag=YES;
        
        //change button text
        [self.editOrder setTitle:@"儲存" forState:UIControlStateNormal];
        
        //reloadData after press editProductOrder button
        self.compareTableViewController.productList = [[NSArray alloc] initWithArray:self.compareCollectionViewController.productList];;
        [self.compareTableViewController.tableView reloadData];
    }

    
}


-(void)compareData {
    NSLog(@"==取得分類下產品列表!");
    
    if (productAPILoader == nil) {
        productAPILoader = [ProductAPILoader new];
    }

    __weak CompareViewController *this = self;
    
    //撈資料
    productAPILoader.loadCompletionBlock = ^(BOOL success , NSInteger totalCount, NSArray *productList ,NSArray *catogorys, BOOL hasMore) {
        NSLog(@"Henry 查詢產品結果 :%ld",(unsigned long)[productList count]);

        dispatch_async(dispatch_get_main_queue(), ^{
            //更新下層顯示之產品資料
            this.productList = productList;
            [this.compareCollectionViewController updateProductList:productList];
            [this.compareTableViewController updateProductList:productList];
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
    [productAPILoader loadData:ProductByPrdIds data:self.productList sortColumn:nil sort:SortOrderNotSet clearAll:YES];
    
}

-(void)productSelected:(NSString *)productID {
    NSLog(@"select product :%@",productID);
    UIStoryboard *contentSB=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
    ProductContentViewController *vc=[contentSB instantiateViewControllerWithIdentifier:@"contentVC"];
    vc.productID = productID;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
