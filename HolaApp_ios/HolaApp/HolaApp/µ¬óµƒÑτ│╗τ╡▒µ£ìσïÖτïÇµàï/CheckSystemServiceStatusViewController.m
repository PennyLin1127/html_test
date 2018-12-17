//
//  CheckSystemServiceStatusViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/2/25.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CheckSystemServiceStatusViewController.h"
#import "SessionID.h"
#import "GetAndPostAPI.h"
#import "URLib.h"
#import "NSDefaultArea.h"
#import "IHouseURLManager.h"
#import "SQLiteManager.h"
#import "ZipArchive.h"
#import "AsyncImageView.h"
#import "IHouseUtility.h"

@interface CheckSystemServiceStatusViewController ()
{
    GetAndPostAPI *getAndPostAPI;
    BOOL canPushToMainView;
    UIImage *image;
    NSDictionary *flashData;

}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;



@end

@implementation CheckSystemServiceStatusViewController
#pragma mark - View生命週期
- (void)viewDidLoad {
    [super viewDidLoad];

    // init GetAndPostAPI for object access later
    getAndPostAPI=[[GetAndPostAPI alloc]init];
    
    //init activityIndicator
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator stopAnimating];

    
    //init var
    canPushToMainView = NO;
    
   
//    NSArray *testArray = [SQLiteManager getIndexViewData];
//    NSLog(@"testArray -- %@", testArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self getImageFormWeb];
    [self.activityIndicator startAnimating];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

//    [self getImageFormWeb];
//    self.activityIndicator.hidden = NO;
//    [self.activityIndicator startAnimating];
    
    //在背景執行
//    [self performSelectorInBackground:@selector(getDataFromWeb) withObject:nil];
    [self getDataFromWeb];
    
    while (canPushToMainView == NO) {

    }
    
    //自動登入
    [IHouseUtility autoLogin];
    
    //停止動畫
    [self.activityIndicator stopAnimating];
    
    
    BOOL connectStatus = [self checkSystemServiceStatus];
    
    if (!connectStatus) {
        
        if (flashData==nil) {
            UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:@"請檢查網路連線" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
            [av show];
        }else{
            
            UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:[flashData objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
            [av show];
        }
    }
    
    // Go to first VC
    UIStoryboard *mainStroyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.view.window.rootViewController = [mainStroyboard instantiateViewControllerWithIdentifier:@"firstVC"];
    
}

#pragma mark - 取得資料
-(void) getDataFromWeb {
    
    //取得DB
    [self checkAndUpdateDB];
    
    //預先更新資料
    [self preDownloadPorductList];
    
    canPushToMainView = YES;
}

#pragma mark - 取得圖片
//return - YES 為成功
-(BOOL) getImageFormWeb {

    BOOL result = YES;
    
    NSURL *url = [NSURL URLWithString:[IHouseURLManager getPerfectURLByAppName:LOADING_VIEW_IMAGE_URL]];
    NSError *error = nil;
    NSURLResponse *response;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = 10;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"error -- %@", error);
        result = NO;
        return result;
    }
    
    image = [UIImage imageWithData:data];
    self.photoImageView.image = image;
    
    return result;
}

//檢查DB有無更新
//return - YES 為成功
-(BOOL)checkAndUpdateDB {
    
    BOOL result = YES;
    NSArray *allDBName = [SQLiteManager getAllDBName];
    
    for (NSInteger i = 0; i < allDBName.count; i++) {
        CGFloat localVersion = [self getLocalDBVersion:i];
        CGFloat serverVersion = [self getServerDBVersion:i];
        
        NSLog(@"%@的localVersion -- %f; serverVersion -- %f", allDBName[i], localVersion, serverVersion);
//        if (YES) {
        if (serverVersion > localVersion) {
            //需要更新
            [self downloadDB:i];
        }
    }
    
    
    return result;
}

//取得本地資料庫版本號
-(CGFloat) getLocalDBVersion:(dbName)dbName {
    CGFloat version;
    
    NSString *verStr = [SQLiteManager getDBLocalVersion:dbName];

    version = [verStr floatValue];

    return version;
}

//取得Server上版本號
-(CGFloat) getServerDBVersion:(dbName)dbName {
    CGFloat version;
    
    NSString *strURL = [SQLiteManager getDBVersionURL:dbName];
    
    //add random code to prevent cache issue happen ( ?rand=%@ 後接英數都可以)
    int random=arc4random()%100;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?rand=%d",strURL,random]];
    
    NSURLResponse *response;
    NSError *error;
    
    NSMutableURLRequest *reuqest = [[NSMutableURLRequest alloc] initWithURL:url];
    [reuqest setHTTPMethod:@"GET"];
    reuqest.timeoutInterval = 10;
    NSData *data = [NSURLConnection sendSynchronousRequest:reuqest returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"error -- %@", error);
        return version;
    }
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    version = [str floatValue];
    
    return version;
}

//下載DB到Document並解壓縮
-(BOOL)downloadDB:(dbName)dbName {
    BOOL result = YES;
    
    NSString *urlStr = [SQLiteManager getDBURL:dbName];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSError *error;
    NSURLResponse *response;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];

    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"error -- %@", error);
        result = NO;
        return result;
    }
    
    //path
    NSString *zipFileName = [NSString stringWithFormat:@"%@.zip", [SQLiteManager getAllDBName][dbName]];
    NSString *fileName = [NSString stringWithFormat:@"%@.sqlite", [SQLiteManager getAllDBName][dbName]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *zipSavedPath = [NSString stringWithFormat:@"%@/%@",
                             documentsDirectory,zipFileName];

    
    [data writeToFile:zipSavedPath atomically:YES];
    
    //然後解壓縮
    NSString *documentDirectory  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:fileName];
    
   // NSString *filepath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"OMRON.zip"];;
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    [zipArchive UnzipOpenFile:zipSavedPath];
    [zipArchive UnzipFileTo:documentDirectory overWrite:YES];
    [zipArchive UnzipCloseFile];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        NSLog(@"%@ -- 檔案存在", fileName);
    }else{
        NSLog(@"檔案不存在");
        NSLog(@"zipSavedPath -- %@", zipSavedPath);
        NSLog(@"dbPath -- %@", dbPath);
    }
    
    return result;
}

#pragma mark - 預先取得產品資訊
-(void) preDownloadPorductList {
    // check system status
    BOOL connectStatus = [self checkSystemServiceStatus];
    
    if(connectStatus){
        NSLog(@"System Service Status Connect Successful !");
        
    }else
    {
    
        NSLog(@"System Service Status Disconnect !");
    }
    
    // get product list and save to user default
    [self saveProductList];
}

#pragma mark - 取得網路狀態與商品列表
// check system status in first time launch app effect , so use sync POST API
 
-(BOOL)checkSystemServiceStatus{
    
    BOOL result;
//    NSString *sessionIDString = [NSString stringWithString:[SessionID getSessionID]];
    NSDictionary *dic = @{@"sessionID": [SessionID getSessionID]};

    NSString *indexStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:HOLA_INDEX]];
    NSData *getRawData=[getAndPostAPI syncPostData:indexStr dicBody:dic];
    
    if (getRawData) { 
//        NSLog(@"raw data %@",getRawData);
        flashData = [getAndPostAPI convertEncryptionNSDataToDic:getRawData];
        NSLog(@"flashData: %@",[flashData valueForKey:@"sessionId"]);
        
        //save sessionID
        NSString *sessionID = [flashData objectForKey:@"sessionId"];
        [SessionID saveSessionID:sessionID];
        
        result=YES;
        BOOL status=[flashData objectForKey:@"status"];
        
        if (status==NO) {
            result=NO;
        }
        
        
    }else{

        result=NO;
    }
    return result;
}

// save product list
-(void)saveProductList{
    NSArray *list=[GetAndPostAPI getProductList];
    [NSDefaultArea productListToUserDefault:list];

}



@end
