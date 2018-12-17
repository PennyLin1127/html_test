//
//  CartsVC.m
//  HOLA
//
//  Created by Joseph on 2015/9/21.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CartsVC.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "SessionID.h"
#import "getCartsData.h"

@interface CartsVC ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (assign,nonatomic)BOOL isAuthed;
@property (strong,nonatomic)NSURLRequest *originRequest;

@end

@implementation CartsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate=self;
    [self setBackButton];
    self.navigationItem.rightBarButtonItems = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [self postData:HOLA_CART];

}

-(void)viewWillDisappear:(BOOL)animated{
    [self reflashCartNum];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.rightBarButtonItems = nil;
}

-(void)reflashCartNum{
    
    getCartsData *_getCartsData=[[getCartsData alloc]init];
    _getCartsData.completeBlock=^(NSString *msg,NSDictionary *dicData){
        
        BOOL status=[[dicData objectForKey:@"status"]integerValue];
        
        if (status) {
            // 為購物車數目
            NSNumber *cartNums=[[dicData objectForKey:@"data"]objectForKey:@"cartNums"];
            
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults setObject:[cartNums stringValue] forKey:@"cartNumbers"];
            
            [[NavigationViewController currentInstance] reflashMyCarts:[cartNums stringValue]];
            
       
            
//            dispatch_async(dispatch_get_main_queue(), ^{
////                [self reflashMyCarts:[cartNums stringValue]];
//            });

            
        }else{
            UIAlertView *av=[[UIAlertView alloc]initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"確定" otherButtonTitles:nil, nil];
            [av show];
        }
    };
    
    [_getCartsData reloadCartsNum];
}

#pragma mark - post sessionId , get shopping cart webView
-(void)postData:(NSString*)urlStr{
    
    //組成Dic
    NSString *sessionId = [SessionID getSessionID];
    NSDictionary *dic = @{@"sessionId": sessionId};
    
    //傳送資料
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:urlStr AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];

        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alert show];
            return;
            
        }else {
            // 無解密，直接拿NSData轉String via UTF8 encoding
            NSString *htmlStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
            NSString *webStr=urlStr;
            NSURL *url=[NSURL URLWithString:webStr];
            [self.webView loadHTMLString:htmlStr baseURL:url];

            
            //            NSURL *url=[NSURL URLWithString:webStr];
            //            [self.webView loadHTMLString:[NSString stringWithFormat:@" <meta name=\"viewport\" content=\"width=device-width; initial-scale=1.0;\"><style>img {max-width:100%%;}</style>%@ ",htmlStr] baseURL:url];
        }
        
    }];
    
}

#pragma mark - webViewDelegate
// webView 處理 HTML https 認證問題 1 , 5
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString* scheme = [[request URL] scheme];
    NSLog(@"scheme = %@",scheme);
    
    
    
    //需要在webview开始加载网页的时候首先判断判断该站点是不是https站点，如果是的话，先然他暂停加载，先用NSURLConnection 来访问改站点，然后再身份验证的时候，将该站点置为可信任站点。然后在用webview重新加载请求。
    
    
    if ([scheme isEqualToString:@"https"]) {
        //如果是https:的话，那么就用NSURLConnection来重发请求。从而在请求的过程当中吧要请求的URL做信任处理。
        if (!self.isAuthed) {
            self.originRequest = request;
            NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [conn start];
            [webView stopLoading];
            return NO;
        }
    }
    return YES;
}

// fetch html title to navigation title
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.title=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];

}

#pragma mark - NSURL delegate
//3. send to server trust anthentication
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    //在NSURLConnection 代理方法中处理信任问题
    if ([challenge previousFailureCount]== 0) {
        //NSURLCredential 这个类是表示身份验证凭据不可变对象。凭证的实际类型声明的类的构造函数来确定。
        NSURLCredential* cre = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        [challenge.sender useCredential:cre forAuthenticationChallenge:challenge];
    }
    
}

//2. send request
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    NSLog(@"NSURLRequest%@",request);
    return request;
    
}

//4.最后在NSURLConnection 代理方法中收到响应之后，再次使用web view加载https站点。
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    self.isAuthed= YES;
    //webview 重新加载请求。
    [self.webView loadRequest:self.originRequest];
    [connection cancel];
}


@end
