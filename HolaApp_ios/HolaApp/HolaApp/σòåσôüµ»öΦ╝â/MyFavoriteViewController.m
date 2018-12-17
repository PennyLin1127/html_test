//
//  MyFavoriteViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//  2015-05-01 Henry 產品圖片應該用非同步
//

#import "MyFavoriteViewController.h"
#import "MyFavoriteTableViewCell.h"
#import "SessionID.h"
#import "URLib.h"
#import "AFNetworking.h"
#import "AES.h"
#import "GetAndPostAPI.h"
#import "NSDefaultArea.h"
#import "ProductContentViewController.h"
#import "CompareWebViewController.h"

#import "ProductInfoData.h"
#import "IHouseURLManager.h"

@interface MyFavoriteViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSDictionary *productCompareDic;
    MBProgressHUD  *progressHUD;
    NSMutableArray *favoriteArray;
    GetAndPostAPI *getAndPostAPI;
    NSMutableArray *productList;
    
    
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MyFavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //註冊 CompareTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:@"MyFavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    //設定背景色
    [self.tableView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f]];
    
    // scrillToTop button
    [self.scrolToTop setHidden:YES];
    
    //已經儲存到我的清單的prdId
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    favoriteArray = [[defaults objectForKey:@"FavoriteList"] mutableCopy];
    
    //初始化產品陣列
    productList = [NSMutableArray new];
    
    getAndPostAPI=[[GetAndPostAPI alloc]init];
    [self SyncGetData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)myfavorite{
    // 不能再按
}


- (IBAction)scrolToTop:(id)sender {
    [self topButtonHideOrNot:NO];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)topButtonHideOrNot:(BOOL)topTag{
    
    if(topTag==YES){
        self.scrolToTop.hidden=NO;
    }
    else{
        self.scrolToTop.hidden=YES;
    }
}



-(void)removeAction:(UIButton*)sender{
    
    UIAlertView *alertConfirm=[[UIAlertView alloc]initWithTitle:nil message:@"確認刪除" delegate:self cancelButtonTitle:@"確定" otherButtonTitles:@"取消", nil];
    
    [alertConfirm show];
    
    UIButton *button=sender;
    
    // 儲存sender過來的tag (indexPath.row)
    self.indexTag=button.tag;
    
    
}

-(void)goToO2oWeb:(id)sender{
    
    UIButton *button=sender;
    
    
    ProductInfoData *product = [productList objectAtIndex:button.tag];
//    NSString *urlStr=[[NSDefaultArea GetBtoURLArrayFromUserDefault]objectAtIndex:button.tag];
    NSDictionary *urlDic= @{@"btoURL":product.url};
    [NSDefaultArea btoURLToUserDefault:urlDic ];

    // pushVC from container's navigation Controller
    UIStoryboard *compareSB=[UIStoryboard storyboardWithName:@"Compare" bundle:nil];
    
    CompareWebViewController *vc=[compareSB instantiateViewControllerWithIdentifier:@"webView"];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}


-(void)openWebURL:(id)sender{
    UIButton *button=sender;
    ProductInfoData *product = [productList objectAtIndex:button.tag];
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOLA_WEB_SHOPPING,product.prdId]];
    [[UIApplication sharedApplication]openURL:url];
}


#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(buttonIndex==0){
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [favoriteArray removeObjectAtIndex:self.indexTag];
        
        // 這邊也要同步刪除prdID array for 進入產品頁
        [productList removeObjectAtIndex:self.indexTag];
        
        [defaults setObject:favoriteArray forKey:@"FavoriteList"];
        [defaults synchronize];
        
        self.delete=YES;
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.indexTag inSection:0]]withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
        
        [self.tableView reloadData];
        
        if ([productList count]==0) {
            
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            UIView *noProductView = [[UIView alloc] initWithFrame:window.frame];
            
            UILabel *instructionLabel=[[UILabel alloc]initWithFrame:CGRectMake(0 ,0, 90, 50)];
            instructionLabel.text=@"無資料顯示";
            instructionLabel.textColor=[UIColor blackColor];
            [instructionLabel setCenter:noProductView.center];
            
            [noProductView addSubview:instructionLabel];
            [self.view addSubview:noProductView];
        }

        
        
    } else if(buttonIndex==1){
        NSLog(@"cancel delete");
    }
    
}


#pragma mark - SyncGetData
-(void)SyncGetData{
    
    
    
    
    NSDictionary *dic = @{@"sessionID": [SessionID getSessionID], @"prdIds":favoriteArray};
    
    
    __block NSData *getRawData;
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        
        NSString *productCompareUrl = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:HOLA_PRODUCTCOMPARE_PATH1]];

        getRawData=[getAndPostAPI syncPostData:productCompareUrl dicBody:dic];
        
    } completionBlock:^{
        
        if (getRawData) {
            NSLog(@"raw data %@",getRawData);
            NSDictionary *flashData = [getAndPostAPI convertEncryptionNSDataToDic:getRawData];
            
            
            // 取product compare API
            // result(dic)再進到responseArray裡面，再把responseArray裡dic的key:prdName取出來給新的prdNameDataArray
            NSArray *responseArray= [flashData objectForKey:@"data"];
            NSLog(@"data11%@",responseArray);
            //            NSDictionary *onShelf=[result objectForKey:@"data"];
            
            
            for (NSDictionary *dic in responseArray) {
                
                //判斷是否上架，有上架商品才顯示在我的最愛
                if ([[dic objectForKey:@"onShelf"] boolValue]){
                    
                    ProductInfoData *product = [ProductInfoData new];
                    product.prdId = [dic objectForKey:@"prdId"];
                    product.prdName = [dic objectForKey:@"prdName"];
                    if ([dic objectForKey:@"prdImg"] != nil) {
                        //NSString *urlStr=@"http://cdn.i-house.com.tw/pub/img/"; // for i house
                        product.prdImg = [NSString stringWithFormat:@"http://cdn.hola.com.tw/pub/img/%@",[dic objectForKey:@"prdImg"]];
                    }
                    product.origPrice = [[dic objectForKey:@"origPrice"]integerValue];
                    product.salePrice = [[dic objectForKey:@"salePrice"]integerValue];
                    
                    NSDictionary *btnO2oCoupon= [dic objectForKey:@"btnO2oCoupon"];
                    
                    //判斷有無 o2oCoupon
                    if ([[btnO2oCoupon objectForKey:@"available"] boolValue] == YES && [btnO2oCoupon objectForKey:@"discountPrice"] != nil) {
                        
                        product.available=[btnO2oCoupon objectForKey:@"available"];
                        product.discountPrice=[[btnO2oCoupon objectForKey:@"discountPrice"]integerValue];
                        product.url=[btnO2oCoupon objectForKey:@"url"];
                        
                    }
                    
                    [productList addObject:product];
                }
                //下架商品數量
                else{
                    int shelfCount;
                    shelfCount ++;
                    NSLog(@"%d件已下架",shelfCount);
                    [favoriteArray removeObject:[dic objectForKey:@"prdId"]];
                    NSLog(@"godDameCout%lu",(unsigned long)favoriteArray.count);
                }
            }
            
             [self.tableView reloadData];
            
            
        }
        
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [productList count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   //contect view 高度這邊設120 背景與背景色一樣 , 裡面的cellView 高度設110,白色圓角
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{   // 因有上層有title高度，所以微調header高度
    return 6.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{   // 加一個透明view到 header
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor =[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"Cell";
    MyFavoriteTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:Identifier forIndexPath:indexPath];
    // cell 外觀
    [cell.cellView.layer setCornerRadius:10.0f];
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f]];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f]];
    
    if ([productList count]>0) {
        ProductInfoData *product = [productList objectAtIndex:indexPath.row];
        
        cell.prdName.text= product.prdName;
        [cell.prdImage setImageURL:[NSURL URLWithString:product.prdImg]];

        cell.salePrice.text= [NSString stringWithFormat:@"網購價 $%ld",product.salePrice];
        NSLog(@"PRICE %ld",(long)product.discountPrice);
        
        if (product.discountPrice>0) {
            cell.o2oPrice.text = [NSString stringWithFormat:@"到店折扣價 $%ld",product.discountPrice];
            [cell.o2oCoupon setBackgroundImage:[UIImage imageNamed:@"button_8"] forState:UIControlStateNormal];
        } else {
            cell.o2oPrice.text = @"";
            [cell.o2oCoupon setHidden:YES];
        }
        
    }

    
    // 刪除我的最愛商品 button action
    cell.removeList.tag=indexPath.row;
    [cell.removeList addTarget:self action:@selector(removeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //設定o2oCoupon tag for url purpose
    cell.o2oCoupon.tag=indexPath.row;
    [cell.o2oCoupon addTarget:self action:@selector(goToO2oWeb:) forControlEvents:UIControlEventTouchUpInside];
    
    
    cell.webShopping.tag=indexPath.row;
    [cell.webShopping addTarget:self action:@selector(openWebURL:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}



#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //進入產品頁面
    //存單一prdId from prdID Array
    ProductInfoData *product = [productList objectAtIndex:indexPath.row];
    
    // pushVC from container's navigation Controller
    UIStoryboard *contentSB=[UIStoryboard storyboardWithName:@"ProductContent" bundle:nil];
    ProductContentViewController *vc=[contentSB instantiateViewControllerWithIdentifier:@"contentVC"];
    vc.productID = product.prdId;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - scrollViewDidScroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint origin = [scrollView contentOffset];
    [scrollView setContentOffset:CGPointMake(0.0, origin.y)];
    
    if ([scrollView.panGestureRecognizer translationInView:scrollView].y >= 0)
    {
        if(origin.y<350){
            [self topButtonHideOrNot:NO];
        }
        
    }
    else
    {
        if(origin.y>350){
            
            [self topButtonHideOrNot:YES];
            
        }
    }
    
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
    progressHUD.removeFromSuperViewOnHide = YES;
    [progressHUD show:YES];
}


@end
