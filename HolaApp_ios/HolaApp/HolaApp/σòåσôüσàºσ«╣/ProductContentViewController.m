//
//  ProductContentViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/21.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//  2015-05-01 Henry 應該做產品分享連結沒有做
//

#import "ProductContentViewController.h"
#import "SessionID.h"
#import "URLib.h"
#import "AFNetworking.h"
#import "AES.h"
#import "GetAndPostAPI.h"
#import "NSDefaultArea.h"
#import "AsyncImageView.h"
#import "RecommendCollectionViewCell.h"
#import "Model.h"
#import "Line.h"
#import "IHouseURLManager.h"
#import "getCartsData.h"


@interface ProductContentViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIWebViewDelegate>
{
    MBProgressHUD  *progressHUD;
    //    GetAndPostAPI *getProductList;
    AsyncImageView *imageView1;
    NSString *sku;
    NSString *htmlContent;
}

@end

@implementation ProductContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.productDescription setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f]];
    
    // for share sku
    if(self.sku !=nil){
        //Get product detail (async POST)
        NSDictionary *productListDic = @{@"sessionID": [SessionID getSessionID] , @"sku":self.sku};
        NSString *holaURL = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:@""]];
        [self asyncPostDetailContextForSku:holaURL path:HOLA_PRODUCTDETAIL_PATH dicBody:productListDic];
    }else{
        //Get product detail (async POST)
        NSDictionary *productListDic = @{@"sessionID": [SessionID getSessionID] , @"prdId":self.productID};
        NSString *holaURL = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:@""]];
        [self asyncPostDetailContext:holaURL path:HOLA_PRODUCTDETAIL_PATH dicBody:productListDic];
    }
    
    // init Mutable Array / Dic
    self.picArray=[[NSMutableArray alloc]initWithCapacity:0];
    self.recommendArray=[[NSMutableArray alloc]initWithCapacity:0];
    self.recommendPrdIdDataMuDic=[[NSMutableDictionary alloc]initWithCapacity:0];
    self.urlDic=[[NSMutableDictionary alloc]initWithCapacity:0];
    self.myFavoriteList=[[NSMutableArray alloc]initWithCapacity:0];
    
    // setting scrollView
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setScrollsToTop:NO];
    [self.scrollView setClipsToBounds:NO];
    [self.scrollView setDelegate:self];
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setBounces:YES];

    [self.o2oCouponButton setHidden:YES];
    [self.webShoppingButton setHidden:YES];
    
    self.webView.delegate=self;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // setting o2o button , web shopping button constraint
    CGSize size = self.view.frame.size;
    CGFloat width = (size.width -14)/2;
    
    self.disccountConstraint.constant = width;
    self.webShopping.constant = width;
  
    [self.o2oCouponButton setHidden:NO];
    [self.webShoppingButton setHidden:NO];
    
}


// 讓webView動態調整高度根據webView裡HTML高度
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    
    frame.size.height = 5.0f;
    
    webView.frame = frame;
}

// 讓webView動態調整高度根據webView裡HTML高度
- (void)webViewDidFinishLoad:(UIWebView *)webView

{
    CGSize mWebViewTextSize = [webView sizeThatFits:CGSizeMake(1.0f, 1.0f)];  // Pass about any size
    CGRect mWebViewFrame = webView.frame;

    mWebViewFrame.size.height = mWebViewTextSize.height;
    
    webView.frame = mWebViewFrame;
    
    NSLog(@"webView.frame -- %@", NSStringFromCGRect(webView.frame));
    
    self.webViewConstraintHeight.constant  = webView.frame.size.height;
    
    //Disable bouncing in webview
    for (id subview in webView.subviews)
    {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
        {
            [subview setBounces:NO];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)sharePressed:(UIBarButtonItem *)barButtonItem {
    NSLog(@"sharePressed!");
    
    NSMutableArray *sharingItems = [NSMutableArray new];

    UIImage *showImage = nil;
    
    // share first 1 image in picArray
    //2015-05-01 Henry 需判斷是否陣列長度大於0
    if ([self.picArray count]>0) {
        NSString *prdImgStr=self.picArray[0];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOLA_PIC_URL_STR,prdImgStr]];
        NSData *imageData=[NSData dataWithContentsOfURL:url];
        showImage = [UIImage imageWithData:imageData];
    }
    // share product name
    NSString *shareProductName=self.prdName.text;
    
    
    if (showImage) {
        [sharingItems addObject:showImage];
    }
    
    if (shareProductName) {
        [sharingItems addObject:shareProductName];
    }

        // 老闆amaon網址加sku
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOLA_PRODUCT_SHARE, sku]];
    
    // 0930 改成客戶的網址以及傳 prdId
#warning check 網址correct or not
     NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOLA_PRODUCT_SHARE1, self.prdId]];
    
    [sharingItems addObject:url];
 
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:avc animated:YES completion:nil];
        
}


- (IBAction)openWebURL:(id)sender {
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOLA_WEB_SHOPPING,self.productID]];
    [[UIApplication sharedApplication]openURL:url];
    
}

- (IBAction)addList:(id)sender {
    
    //產品Id
    [Model addToFavoriteList:@[self.productID]];
}


-(IBAction)addCarts:(id)sender
{
    NSArray *skuArray=[NSArray arrayWithObjects:self.productSKU, nil];
    
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


-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)slideProductPic{
    
    if (self.picArray.count >0) {
        NSInteger picLength = [self.picArray count]; //當前筆數
        self.pageControl.numberOfPages=picLength;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        
        self.scrollView.contentSize = CGSizeMake(screenWidth*picLength, 150);
        CGRect rect = self.scrollView.frame;
        int viewIndex;
        
        for (viewIndex = 0 ; viewIndex < picLength ; viewIndex++) {
            CGRect currentRect = CGRectMake(rect.size.width*viewIndex, 0, rect.size.width, rect.size.height);
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOLA_PIC_URL_STR,self.picArray[viewIndex]]];
            
            imageView1 = [[AsyncImageView alloc] initWithFrame:currentRect];
            imageView1.userInteractionEnabled = YES;
            imageView1.contentMode = UIViewContentModeScaleAspectFit;
            imageView1.imageURL = url;
            [self.scrollView addSubview:imageView1];
        }
        
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat width = self.scrollView.frame.size.width;
    NSInteger currentPage = ((self.scrollView.contentOffset.x - width / 2) / width) + 1;
    [self.pageControl setCurrentPage:currentPage];
}


#pragma mark - asyncPostData product detail context
// 一次全load,效率差,之後優化可能要先load 10 筆，往下捲再繼續 load
-(void)asyncPostDetailContext:(NSString*)httpClientURL path:(NSString*)BasePath dicBody:(NSDictionary*)dicBody{
    
    [self initializeProgressHUD:@"載入中..."];
    // Prepare the HTTP Client
    AFHTTPClient *httpClient =
    [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:httpClientURL]];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:BasePath
                                                      parameters:nil];
    
    //set json data from dictionary
    NSError *dicError;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dicBody options:NSJSONWritingPrettyPrinted error:&dicError];
    
    //set json string from json data (in order to add inputData=jsonStr in http post body)
    NSString *jsonStr;
    if (!dicError) {
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"POST to JSON string is : %@",jsonStr);
    }else{
        NSLog(@"JSON to String is error : %@", dicError.localizedDescription);
        //        return nil;
    }
    
    //加密
    //再把JSON Str轉換成加密後字串
    NSString *encodeStr = [AES aesEncryptionWithString:jsonStr];
    
    //傳過去前8碼亂數，加密內容，固定8碼辦視來源
    //傳過來的加密後字串的尾端再加上固定的八個字元” jDEo8S0P” 這八個字元是辦視來源用的

    
    // for ihouse -->jDEo8S0P 尾巴要再加上這行
    // for HOLA --> GqmnTisl
    
    encodeStr = [NSString stringWithFormat:@"%@%@", encodeStr, [GetAndPostAPI suffix]];
    
    
    //再把JSON 轉換成POST BODY
    NSData *requestPostBodyData = [[NSString stringWithFormat:@"inputData=%@",encodeStr] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    /*無加密
     //setting URL request POST http body's data (inputData=jsonStr that is follow HOLA spec)
     NSData *requestPostBodyData = [[NSString stringWithFormat:@"inputData=%@",jsonStr] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
     */
    
    //set Content-Length
    NSString *postLength = [NSString stringWithFormat:@"%zd",[requestPostBodyData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //set HTTP Body
    [request setHTTPBody:requestPostBodyData];
    
    
    // Set the opration
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    
    // Set the callback block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        // Test Log
        //        NSLog(@"Response: %@", tmp);
        
        [progressHUD hide:YES];
        
        // JSON轉Dic 解密
        NSDictionary *result;
        GetAndPostAPI *getAndPostAPI=[[GetAndPostAPI alloc]init];
        if (responseObject) {
            result=[getAndPostAPI convertEncryptionNSDataToDic:responseObject];
            NSLog(@"product list colletion dictionary :%@",result);
        }else{
            NSLog(@"no responseObject in ProductListCollectionViewController -- asyncPostData");
        }
        
        if (!request) {
            NSLog(@"no request in ProductListCollectionViewController -- asyncPostData");
        }
        else{
            
            NSLog(@"datais %@",result);
            
            if (![result objectForKey:@"status"]) {
                NSLog(@"msg --- %@",[result objectForKey:@"msg"]);
            }
            else{
            //取product detail API
            NSDictionary *detailPath=[[result objectForKey:@"data"]objectForKey:@"detail"];
            self.prdId=[detailPath objectForKey:@"prdId"];
            NSString *prdNameString= [detailPath objectForKey:@"prdName"];
            NSString *origPriceString= [detailPath objectForKey:@"origPrice"];
            NSString *salePriceString= [detailPath objectForKey:@"salePrice"];
            NSDictionary *btnO2oCoupon= [detailPath objectForKey:@"btnO2oCoupon"];
            htmlContent = [NSString stringWithString:[detailPath objectForKey:@"prdDescription"]];
            
            sku = [NSString stringWithString:[detailPath objectForKey:@"sku"]];
       
            //取recommend Array
            NSArray *tempArray=[[result objectForKey:@"data"] objectForKey:@"recommend"];
            for (NSArray *RArray in tempArray) {
                [self.recommendArray addObject:RArray];
                NSLog(@"count count%lu",self.recommendArray.count);
            }
            
            //取prdName
            self.prdName.text=prdNameString;
            //取origPrice
            NSString *priceText1=@"售價$";
            self.origPrice.text=[priceText1 stringByAppendingString:origPriceString];
            //取salePrice
            NSString *priceText2=@"網購價$";
            self.salePrice.text=[priceText2 stringByAppendingString:salePriceString];
            //o2oCoupon
            NSString *priceText3=@"到店折扣價$";
            if ([[btnO2oCoupon objectForKey:@"available"]boolValue]) {
                // 有到店折扣卷
                self.o2oDiscountPrice.text=[priceText3 stringByAppendingString:[[btnO2oCoupon objectForKey:@"discountPrice"]stringValue]];
                [self.urlDic setObject:[btnO2oCoupon objectForKey:@"url"] forKey:@"btoURL"];
                [NSDefaultArea btoURLToUserDefault:self.urlDic];
                
            }else{
                // 無到店折扣卷
                // 到店折扣價字設空字串
                self.o2oDiscountPrice.text=@"";

                // 設置contraint
                self.disccountConstraint.constant=0;
                self.gapConstraint.constant=0;
                self.o2oCouponButton.hidden = YES;
                
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat screenWidth = screenRect.size.width-10;
                self.webShopping.constant = screenWidth;
                
            }
            //商品詳細說明 prdDescription
            
            NSString *prdFeature=[detailPath objectForKey:@"prdFeature"];
            
            //2015-05-01 Henry 加入設定圖片不要超過100%;
            [self.webView loadHTMLString:[prdFeature stringByAppendingString:[NSString stringWithFormat:@"<style>img {max-width:100%%;}</style>%@",htmlContent]] baseURL:nil];

            
            // 檢查pic count
            if ([detailPath objectForKey:@"prdImg1"]!=(id)[NSNull null]) {
                [self.picArray addObject:[detailPath objectForKey:@"prdImg1"]];
            }
            if ([detailPath objectForKey:@"prdImg2"]!=(id)[NSNull null]) {
                [self.picArray addObject:[detailPath objectForKey:@"prdImg2"]];
            }
            if ([detailPath objectForKey:@"prdImg3"]!=(id)[NSNull null]) {
                [self.picArray addObject:[detailPath objectForKey:@"prdImg3"]];
            }
            if ([detailPath objectForKey:@"prdImg4"]!=(id)[NSNull null]) {
                [self.picArray addObject:[detailPath objectForKey:@"prdImg4"]];
            }
            NSLog(@"pic count %lu",self.picArray.count);
            // load pic
            [self slideProductPic];
            [self.collectionView reloadData];
            
        }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [progressHUD hide:YES];
        NSString *err = @"請檢查網路連接狀態";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"伺服器連線錯誤" message:err delegate:self cancelButtonTitle:@"關閉" otherButtonTitles:nil];
        [alert show];
        NSLog(@"asyncPostData callback block error is: %@",error);
    }];
    // Start the opration
    [operation start];
}



-(void)asyncPostDetailContextForSku:(NSString*)httpClientURL path:(NSString*)BasePath dicBody:(NSDictionary*)dicBody{
    
    [self initializeProgressHUD:@"載入中..."];
    // Prepare the HTTP Client
    AFHTTPClient *httpClient =
    [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:httpClientURL]];
    
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                            path:BasePath
                                                      parameters:nil];
    
    //set json data from dictionary
    NSError *dicError;
    NSData *jsonData=[NSJSONSerialization dataWithJSONObject:dicBody options:NSJSONWritingPrettyPrinted error:&dicError];
    
    //set json string from json data (in order to add inputData=jsonStr in http post body)
    NSString *jsonStr;
    if (!dicError) {
        jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"POST to JSON string is : %@",jsonStr);
    }else{
        NSLog(@"JSON to String is error : %@", dicError.localizedDescription);
        //        return nil;
    }
    
    //加密
    //再把JSON Str轉換成加密後字串
    NSString *encodeStr = [AES aesEncryptionWithString:jsonStr];
    
    //傳過去前8碼亂數，加密內容，固定8碼辦視來源
    //傳過來的加密後字串的尾端再加上固定的八個字元” jDEo8S0P” 這八個字元是辦視來源用的
    
    
    // for ihouse -->jDEo8S0P 尾巴要再加上這行
    // for HOLA --> GqmnTisl
    
    encodeStr = [NSString stringWithFormat:@"%@%@", encodeStr, [GetAndPostAPI suffix]];
    
    
    //再把JSON 轉換成POST BODY
    NSData *requestPostBodyData = [[NSString stringWithFormat:@"inputData=%@",encodeStr] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    /*無加密
     //setting URL request POST http body's data (inputData=jsonStr that is follow HOLA spec)
     NSData *requestPostBodyData = [[NSString stringWithFormat:@"inputData=%@",jsonStr] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
     */
    
    //set Content-Length
    NSString *postLength = [NSString stringWithFormat:@"%zd",[requestPostBodyData length]];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //set HTTP Body
    [request setHTTPBody:requestPostBodyData];
    
    
    // Set the opration
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    
    
    // Set the callback block
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //        NSString *tmp = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        // Test Log
        //        NSLog(@"Response: %@", tmp);
        
        [progressHUD hide:YES];
        
        // JSON轉Dic 解密
        NSDictionary *result;
        GetAndPostAPI *getAndPostAPI=[[GetAndPostAPI alloc]init];
        if (responseObject) {
            result=[getAndPostAPI convertEncryptionNSDataToDic:responseObject];
            NSLog(@"product list colletion dictionary :%@",result);
        }else{
            NSLog(@"no responseObject in ProductListCollectionViewController -- asyncPostData");
        }
        
        if (!request) {
            NSLog(@"no request in ProductListCollectionViewController -- asyncPostData");
        }
        else{
            
            NSLog(@"datais %@",result);
            
            //取product detail API
            NSDictionary *detailPath=[[result objectForKey:@"data"]objectForKey:@"detail"];
            NSString *prdNameString= [detailPath objectForKey:@"prdName"];
            NSString *origPriceString= [detailPath objectForKey:@"origPrice"];
            NSString *salePriceString= [detailPath objectForKey:@"salePrice"];
            NSDictionary *btnO2oCoupon= [detailPath objectForKey:@"btnO2oCoupon"];
            htmlContent = [NSString stringWithString:[detailPath objectForKey:@"prdDescription"]];
            
            
            //取recommend Array
            NSArray *tempArray=[[result objectForKey:@"data"] objectForKey:@"recommend"];
            for (NSArray *RArray in tempArray) {
                [self.recommendArray addObject:RArray];
                NSLog(@"count count%lu",self.recommendArray.count);
            }
            
            //取prdName
            self.prdName.text=prdNameString;
            //取origPrice
            NSString *priceText1=@"售價$";
            self.origPrice.text=[priceText1 stringByAppendingString:origPriceString];
            //取salePrice
            NSString *priceText2=@"網購價$";
            self.salePrice.text=[priceText2 stringByAppendingString:salePriceString];
            //o2oCoupon
            NSString *priceText3=@"到店折扣價$";
            if ([[btnO2oCoupon objectForKey:@"available"]boolValue]) {
                // 有到店折扣卷
                self.o2oDiscountPrice.text=[priceText3 stringByAppendingString:[[btnO2oCoupon objectForKey:@"discountPrice"]stringValue]];
                [self.urlDic setObject:[btnO2oCoupon objectForKey:@"url"] forKey:@"btoURL"];
                [NSDefaultArea btoURLToUserDefault:self.urlDic];
                
            }else{
                // 無到店折扣卷
                // 到店折扣價字設空字串
                self.o2oDiscountPrice.text=@"";
                // 到店折扣卷設置圖變灰
                //                [self.o2oCouponButton setBackgroundImage:[UIImage imageNamed:@"button_7" ] forState:UIControlStateNormal];
                //                [self.o2oCouponButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                
                // 設置contraint
                self.disccountConstraint.constant=0;
                self.gapConstraint.constant=0;
                self.o2oCouponButton.hidden = YES;
                
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat screenWidth = screenRect.size.width-10;
                self.webShopping.constant = screenWidth;
                
            }
            //商品詳細說明 prdDescription
            
            NSString *prdFeature=[detailPath objectForKey:@"prdFeature"];
            //            self.productDescription.text=[prdFeature stringByAppendingString:prdDescription];
            //            [self.productDescription setFont:[UIFont systemFontOfSize:16.0f]];
            
            //2015-05-01 Henry 加入設定圖片不要超過100%;
            [self.webView loadHTMLString:[prdFeature stringByAppendingString:[NSString stringWithFormat:@"<style>img {max-width:100%%;}</style>%@",htmlContent]] baseURL:nil];
            
            
            // 檢查pic count
            if ([detailPath objectForKey:@"prdImg1"]!=(id)[NSNull null]) {
                [self.picArray addObject:[detailPath objectForKey:@"prdImg1"]];
            }
            if ([detailPath objectForKey:@"prdImg2"]!=(id)[NSNull null]) {
                [self.picArray addObject:[detailPath objectForKey:@"prdImg2"]];
            }
            if ([detailPath objectForKey:@"prdImg3"]!=(id)[NSNull null]) {
                [self.picArray addObject:[detailPath objectForKey:@"prdImg3"]];
            }
            if ([detailPath objectForKey:@"prdImg4"]!=(id)[NSNull null]) {
                [self.picArray addObject:[detailPath objectForKey:@"prdImg4"]];
            }
            NSLog(@"pic count %lu",self.picArray.count);
            // load pic
            [self slideProductPic];
            [self.collectionView reloadData];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [progressHUD hide:YES];
        NSString *err = @"請檢查網路連接狀態";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"伺服器連線錯誤" message:err delegate:self cancelButtonTitle:@"關閉" otherButtonTitles:nil];
        [alert show];
        NSLog(@"asyncPostData callback block error is: %@",error);
    }];
    // Start the opration
    [operation start];
}




#pragma mark - CollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"recommendArray count1 %lu",(unsigned long)self.recommendArray.count);
    return self.recommendArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify=@"Cell";
    RecommendCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    NSString *prdImgStr=[self.recommendArray[indexPath.row] objectForKey:@"prdImg"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOLA_PIC_URL_STR,prdImgStr]];
    cell.RImage.imageURL=url;
    cell.RName.text=[self.recommendArray[indexPath.row] objectForKey:@"prdName"];
    NSString *priceStr=@"網購價";
    cell.RPrice.text=[priceStr stringByAppendingString:[[self.recommendArray[indexPath.row] objectForKey:@"salePrice"] stringValue]];
    [cell.layer setCornerRadius:5.0f];
    return cell;
}


#pragma mark - CollectionView Delegate

// called when the user taps on an already-selected item in multi-select mode
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"Did select row: %lu",(long)indexPath.row);
    
    // for recommend product
    NSString *_recommendProductID = [[self.recommendArray objectAtIndex:indexPath.row] objectForKey:@"prdId"];

    // pushVC from ProductContentViewController Controller
    UIStoryboard *contentSB=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
    ProductContentViewController *vc=[contentSB instantiateViewControllerWithIdentifier:@"contentVC"];
    vc.productID = _recommendProductID;
    [self.navigationController pushViewController:vc animated:YES];
    
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
//    progressHUD.yOffset = -100.0f;
    progressHUD.removeFromSuperViewOnHide = YES;
    [progressHUD show:YES];
}



@end
