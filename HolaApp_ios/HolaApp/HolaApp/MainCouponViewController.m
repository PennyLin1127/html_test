//
//  MainCouponViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/13.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//  Henry程序: 先讀取門市折價券->再讀取網路折價券->計算重複變成共用
//  2015-04-30 Henry 修改讀取方式
//  2015-04-30 Henry 修改物件結構，改善折價券分類無資料出現之問題

#import "MainCouponViewController.h"
#import "MainCouponTableViewCell.h"
#import "IHouseURLManager.h"
#import "IHouseUtility.h"
#import "CouponDetailViewController.h"
#import "MemberLoginViewController.h"

#import "CouponCategory.h"
#import "CommonWebViewController.h"

#import "CouponBigImageViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface MainCouponViewController () {
    CouponType currentType; //當前TableView的類型
    NSArray *webCouponList; //網站上的CouponList (索取折價劵-App購物折價劵)
    NSInteger section1Count;
    NSMutableArray *couponCategories; //折價券陣列
    //    NSMutableArray *couponList; //我的折價劵 - 限線上使用
    //    NSMutableArray *couponListByStore; //我的折價劵 - 限門市使用 (老闆的API)
    //    NSMutableArray *couponListByAll; //我的折價劵 - 門市線上適用 (老闆的API 與限門市使用同一隻撈回來)
    
    NSMutableArray *bothCouponList; // 暫時儲存的門市與線上共用Array
    
    UIView *noCouponView;
}

- (IBAction)takeCouponAction:(id)sender;
- (IBAction)myCouponAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *takeCouponButton;
@property (weak, nonatomic) IBOutlet UIButton *myCouponVutton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//更新折價券分類
-(void)updateCouponCategory:(CouponCategory *)couponCategory;

//依照類型取得折價券分類
-(CouponCategory *)getCouponCategoryByType:(CouponCategoryType)couponCategoryType;

@end

@implementation MainCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    section1Count=0;
    
    //init var
    currentType = CouponTypeTakeCoupon;
    webCouponList = [[NSArray alloc] init];
    
    //    couponList = [[NSMutableArray alloc] init];
    //    couponListByStore = [[NSMutableArray alloc] init];
    //    couponListByAll = [[NSMutableArray alloc] init];
    //    tempListAll = [[NSMutableArray alloc] init];
    
    //delegate
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.takeCouponButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
    
   
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.goToMyCoupon == YES) {
        [self myCouponAction:nil];
        return;
    }
    
    if (currentType == CouponTypeTakeCoupon) {
        [self getData_TakeCoupon];
    }else if (currentType == CouponTypeMyCoupon) {
        [couponCategories removeAllObjects]; // 清空所有資料
        [self getData_MyCoupon];
    }
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView delegate

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (currentType == CouponTypeTakeCoupon) {
        
        //        if (section == 0) {
        //                return @"門市折價劵";
        //        }else if (section == 1) {
        //            return @"網站購物折價券";
        //        }
        
        return @"網站購物折價券";
        
    }else {
        if (couponCategories != nil) {
            CouponCategory *couponCategory = [couponCategories objectAtIndex:section];
            if (couponCategory.categoryType == EC_COUPON) {
                return @"限網站購物使用";
            } else if (couponCategory.categoryType == STORE_COUPON) {
                return @"限門市使用";
            } else if (couponCategory.categoryType == BOTH_COUPON) {
                return @"限門市及網站購物使用";
            }
        }
    }
    
    return @"";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (currentType == CouponTypeTakeCoupon) {
        return section1Count;
    } else if (currentType == CouponTypeMyCoupon) {
        if (couponCategories != nil) {
            return [couponCategories count];
        }
    }
    return 0;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 索取折價卷
    if (currentType == CouponTypeTakeCoupon) {
        
        return webCouponList.count;
        
        //        if (section == 0) {
        //            return 0;
        //        }else if (section == 1) {
        //            return webCouponList.count;
        //        }
        
    // 我的折價卷
    }else if (currentType == CouponTypeMyCoupon) {
        if (couponCategories != nil) {
            CouponCategory *couponCategory = [couponCategories objectAtIndex:section];
            return [couponCategory.couponList count];
        }
    }
    
    return 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"CouponCell";
    MainCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[MainCouponTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    //清掉圖片
    cell.asyncImageView.image = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //清掉動作
    [cell.couponButton removeTarget:nil
                             action:NULL
                   forControlEvents:UIControlEventAllEvents];
    // 折價卷索取頁面
    if (currentType == CouponTypeTakeCoupon) {
        
        if (indexPath.section == 0) {
            
            //App購物折價劵
            NSDictionary *dicData = [webCouponList objectAtIndex:indexPath.row];
            NSString *couponTitle = [dicData objectForKey:@"couponTitle"];
            cell.couponNameLabel.text = couponTitle;
            
            //畫面圖片
            NSString *img = [dicData objectForKey:@"img"];
            img = img == nil ? @"" : img;
            if (img == nil || [img isEqualToString:@""]) {
                UIImage *couponImage = [UIImage imageNamed:@"myCouponUnused.jpg"];
                cell.asyncImageView.image = couponImage;
            }else {
                NSString *imgURL = [NSString stringWithFormat:@"%@%@", IMAGE_PREFIX_HOLA, img];
                NSURL *url = [NSURL URLWithString:imgURL];
                cell.asyncImageView.imageURL = url;
            }
            
            //日期格式
            NSString *startDate = [dicData objectForKey:@"startDate"];
            NSString *endDate = [dicData objectForKey:@"endDate"];
            
            // 0608 - Joseph block as below code , 因為沒顯示日期
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            [formatter setDateFormat:@"YYYY-MM-d HH:mm:ss"];
//            NSDate *stat = [formatter dateFromString:startDate];
//            NSDate *end = [formatter dateFromString:endDate];
//            
//            [formatter setDateFormat:@"YYYY-MM-d"];
//            NSString *formatterStatDate = [formatter stringFromDate:stat];
//            NSString *formatterEndDate = [formatter stringFromDate:end];
            
            cell.couponDateLabel.text = [NSString stringWithFormat:@"%@~%@", startDate, endDate];
            
            
            //換圖片
            UIImage *image = [UIImage imageNamed:@"button_8"];
            [cell.couponButton setImage:image forState:UIControlStateNormal];
            
            //加入事件
            cell.couponButton.tag = indexPath.row;
            NSString *couponCode = [dicData objectForKey:@"couponCode"];
            if (couponCode == nil || [couponCode isEqualToString:@""]) {
                [cell.couponButton addTarget:self action:@selector(buttonToWebView:) forControlEvents:UIControlEventTouchUpInside];
                //按鈕文字
                cell.buttonNameLabel.text = @"立即兌換";
            }else {
                [cell.couponButton addTarget:self action:@selector(changCouponAction:) forControlEvents:UIControlEventTouchUpInside];
                //按鈕文字
                cell.buttonNameLabel.text = @"立即索取";
            }
            
            
        }else if (indexPath.section == 1) {
            
            //App購物折價劵
            NSDictionary *dicData = [webCouponList objectAtIndex:indexPath.row];
            NSString *couponTitle = [dicData objectForKey:@"couponTitle"];
            cell.couponNameLabel.text = couponTitle;
            
            //畫面圖片
            NSString *img = [dicData objectForKey:@"img"];
            img = img == nil ? @"" : img;
            if (img == nil || [img isEqualToString:@""]) {
                UIImage *couponImage = [UIImage imageNamed:@"myCouponUnused.jpg"];
                cell.asyncImageView.image = couponImage;
            }else {
                NSString *imgURL = [NSString stringWithFormat:@"%@%@", IMAGE_PREFIX_HOLA, img];
                NSURL *url = [NSURL URLWithString:imgURL];
                cell.asyncImageView.imageURL = url;
            }
            
            NSString *startDate = [dicData objectForKey:@"startDate"];
            NSString *endDate = [dicData objectForKey:@"endDate"];
            cell.couponDateLabel.text = [NSString stringWithFormat:@"%@~%@", startDate, endDate];
            
            //換圖片
            UIImage *image = [UIImage imageNamed:@"button_8"];
            [cell.couponButton setImage:image forState:UIControlStateNormal];
            
            //加入事件
            cell.couponButton.tag = indexPath.row;
            NSString *couponCode = [dicData objectForKey:@"couponCode"];
            if (couponCode == nil || [couponCode isEqualToString:@""]) {
                [cell.couponButton addTarget:self action:@selector(buttonToWebView:) forControlEvents:UIControlEventTouchUpInside];
                //按鈕文字
                cell.buttonNameLabel.text = @"立即兌換";
            }else {
                [cell.couponButton addTarget:self action:@selector(changCouponAction:) forControlEvents:UIControlEventTouchUpInside];
                //按鈕文字
                cell.buttonNameLabel.text = @"立即索取";
            }
            
            
        }
    
    // 我的折價卷頁面
    }else if (currentType == CouponTypeMyCoupon) {
        
        CouponCategory *couponCategory = [couponCategories objectAtIndex:indexPath.section];
        
        if (couponCategory.categoryType == EC_COUPON) {
            //限網站購物使用
            NSDictionary *data = [couponCategory.couponList objectAtIndex:indexPath.row];
            cell.couponNameLabel.text = [data objectForKey:@"couponTitle"];
            cell.couponDateLabel.text = [data objectForKey:@"expireDate"];
            
            //按鈕狀態
            NSString *couponStatus = [data objectForKey:@"couponStatus"];
            
            if ([couponStatus isEqualToString:@"available"]) {
                cell.buttonNameLabel.text = @"未使用";
                cell.couponButton.tag = 2000+indexPath.row;
                [cell.couponButton addTarget:self action:@selector(goToHolaWeb:) forControlEvents:UIControlEventTouchUpInside];
                
                //換圖片
                UIImage *image = [UIImage imageNamed:@"button_8"];
                [cell.couponButton setImage:image forState:UIControlStateNormal];
                
                UIImage *couponImage = [UIImage imageNamed:@"myCouponUnused.jpg"];
                cell.asyncImageView.image = couponImage;
                
            }else if ([couponStatus isEqualToString:@"used"]) {
                cell.buttonNameLabel.text = @"已使用";
                //換圖片
                UIImage *image = [UIImage imageNamed:@"button_7"];
                [cell.couponButton setImage:image forState:UIControlStateNormal];
                
                UIImage *couponImage = [UIImage imageNamed:@"myCouponUsed.jpg"];
                cell.asyncImageView.image = couponImage;
            }else{
                cell.buttonNameLabel.text = @"過期";
                //換圖片
                UIImage *image = [UIImage imageNamed:@"button_7"];
                [cell.couponButton setImage:image forState:UIControlStateNormal];
            }
            
            //圖片
            id tempValue = [data objectForKey:@"img"];
            NSString *img = @"";
            if (tempValue != [NSNull null]) {
                img = (NSString *)tempValue;
            }
            
            img = img == nil ? @"" : img;
            
            if (img != nil  && ![img isEqualToString:@""]) {
                NSString *imgURL = [NSString stringWithFormat:@"%@%@", IMAGE_PREFIX_HOLA, img];
                NSURL *url = [NSURL URLWithString:imgURL];
                
                cell.asyncImageView.imageURL = url;
            }
            
        } else if (couponCategory.categoryType == STORE_COUPON) {
            //限門市使用
            NSDictionary *dicData = [couponCategory.couponList objectAtIndex:indexPath.row];
            cell.couponNameLabel.text = [dicData objectForKey:@"TITLE"];
            cell.couponDateLabel.text = [dicData objectForKey:@"DATE"];
            
            
            //圖片
            NSString *img = [dicData objectForKey:@"LISTIMG"];
            img = img == nil ? @"" : img;
            if (img == nil || [img isEqualToString:@""]) {
                
                NSArray *discountArray = [dicData objectForKey:@"DISCOUNTID"];
                UIImage *couponImage;
                if (discountArray > 0) {
                    couponImage = [UIImage imageNamed:@"myCouponUnused.jpg"];
                }else {
                    couponImage = [UIImage imageNamed:@"myCouponUsed.jpg"];
                }
                
                cell.asyncImageView.image = couponImage;
            }else {
                NSString *imgURLStr = [NSString stringWithFormat:@"%@%@", [IHouseURLManager getPerfectURLByAppName:COUPON_IMAGE_PREFIX], img];
                NSURL *url = [NSURL URLWithString:imgURLStr];
                cell.asyncImageView.imageURL = url;
            }
            
            //            NSString *startDate = [dicData objectForKey:@"STARTDATE"];
            //            NSString *endDate = [dicData objectForKey:@"ENDDATE"];
            
            //按鈕
            NSArray *discountArray = [dicData objectForKey:@"DISCOUNTID"];
            if (discountArray.count>0) {
                cell.buttonNameLabel.text = @"未使用";
                cell.couponButton.tag = indexPath.row;
                [cell.couponButton addTarget:self action:@selector(useCouponByMemberCard:) forControlEvents:UIControlEventTouchUpInside];
                //換圖片
                UIImage *image = [UIImage imageNamed:@"button_8"];
                [cell.couponButton setImage:image forState:UIControlStateNormal];
            }else {
                cell.buttonNameLabel.text = @"已使用";
                //換圖片
                UIImage *image = [UIImage imageNamed:@"button_7"];
                [cell.couponButton setImage:image forState:UIControlStateNormal];
            }
        } else if (couponCategory.categoryType == BOTH_COUPON) {
            //共用折價券（門市及網站購物使用)
            
            // sorting decending by date
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"DATE" ascending:NO];
            couponCategory.couponList=[couponCategory.couponList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

            NSDictionary *dicData = [couponCategory.couponList objectAtIndex:indexPath.row];
            cell.couponNameLabel.text = [dicData objectForKey:@"TITLE"];
            cell.couponDateLabel.text = [dicData objectForKey:@"DATE"];

            
            NSString *img = [dicData objectForKey:@"LISTIMG"];
            
            if (img == nil || [img isEqualToString:@""]) {
                
                NSArray *discountArray = [dicData objectForKey:@"DISCOUNTID"];
                UIImage *couponImage;
                if (discountArray > 0) {
                    couponImage = [UIImage imageNamed:@"myCouponUnused.jpg"];
                }else {
                    couponImage = [UIImage imageNamed:@"myCouponUsed.jpg"];
                }
                
                cell.asyncImageView.image = couponImage;
                
            }else {
                NSString *imgURLStr = [NSString stringWithFormat:@"%@%@", [IHouseURLManager getPerfectURLByAppName:COUPON_IMAGE_PREFIX], img];
                NSURL *url = [NSURL URLWithString:imgURLStr];
                cell.asyncImageView.imageURL = url;
            }
            
            //按鈕
            //            NSArray *discountArray = [dicData objectForKey:@"SerialNoList"];
            NSArray *discountArray = [dicData objectForKey:@"DISCOUNTID"]; //5/6修改
            
            if (discountArray.count>0) {
                cell.buttonNameLabel.text = @"未使用";
                cell.couponButton.tag = indexPath.row+1000;
                [cell.couponButton addTarget:self action:@selector(useCouponByMemberCard:) forControlEvents:UIControlEventTouchUpInside];
                //換圖片
                UIImage *image = [UIImage imageNamed:@"button_8"];
                [cell.couponButton setImage:image forState:UIControlStateNormal];
            }else {
                cell.buttonNameLabel.text = @"已使用";
                //換圖片
                UIImage *image = [UIImage imageNamed:@"button_7"];
                [cell.couponButton setImage:image forState:UIControlStateNormal];
            }
        }
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (currentType == CouponTypeTakeCoupon) {
        //索取折價劵
        
        if (indexPath.section == 0) {
            //couponLink
            
        }else if (indexPath.section == 1) {
            //couponLink
            
        }
        
        //Data
        NSDictionary *dic = [webCouponList objectAtIndex:indexPath.row];
        NSString *couponLink = [dic objectForKey:@"couponLink"];
        NSLog(@"couponLink -- %@", couponLink);
        
        //打開連結
        NSURL *url = [NSURL URLWithString:couponLink];
        [[UIApplication sharedApplication] openURL:url];
    
    }else if (currentType == CouponTypeMyCoupon) {
        //我的折價劵
        
        CouponCategory *couponCategory = [couponCategories objectAtIndex:indexPath.section];
        NSDictionary *data = [couponCategory.couponList objectAtIndex:indexPath.row];
        if (couponCategory.categoryType == EC_COUPON ) {
           
            
            NSString *urlStr = [data objectForKey:@"couponLink"];
            NSLog(@"didselect urlStr -- %@", urlStr);
            //    NSLog(@"goToHolaWeb");
            //    NSString *str = @"http://www.hola.com.tw";
            
//            if (urlStr == nil || [urlStr isEqualToString:@""]) {
//                urlStr = @"http://www.hola.com.tw";
//            }
            
            NSURL *url = [NSURL URLWithString:urlStr];
            [[UIApplication sharedApplication] openURL:url];
            
            
        }else {
            
            NSString *img = [data objectForKey:@"BIGIMG"];
            NSLog(@"Big Image url -- %@", img);
            if (![img isEqualToString:@""]) {
                NSString *imgURL = [NSString stringWithFormat:@"%@%@", [IHouseURLManager getPerfectURLByAppName:COUPON_IMAGE_PREFIX], img];
                
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coupon" bundle:nil];
                CouponBigImageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CouponBigImage"];
                vc.urlStr = imgURL;
                [self.navigationController pushViewController:vc animated:YES];
                
                
            }
            //        else if (couponCategory.categoryType == BOTH_COUPON) {
            //
            //        }
            
            //        NSDictionary *data = [couponCategory.couponList objectAtIndex:indexPath.row];
            //        NSString *img = [data objectForKey:@"BIGIMG"];
            //        NSLog(@"Big Image url -- %@", img);
            //        if (![img isEqualToString:@""]) {
            //            NSString *imgURL = [NSString stringWithFormat:@"%@%@", [IHouseURLManager getPerfectURLByAppName:COUPON_IMAGE_PREFIX], img];
            //
            //            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Coupon" bundle:nil];
            //            CouponBigImageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CouponBigImage"];
            //            vc.urlStr = imgURL;
            //            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - Button Event
- (IBAction)takeCouponAction:(id)sender {
    //移除無折價劵的畫面
    [self removeNoCoupon];
    
    
    //改變當前Type
    currentType = CouponTypeTakeCoupon;
    
    [self getData_TakeCoupon];

    
    //UI Change
    [self.takeCouponButton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
    [self.myCouponVutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    

    
    // GA -- 折價卷索取
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/coupon/get"]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/coupon/get"]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];

}

- (IBAction)myCouponAction:(id)sender {
    //移除無折價劵的畫面
    [self removeNoCoupon];
    
    
    //先檢查是否登入 無的話導向登入頁面
    NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
    NSString *isLogin = [userDefaults objectForKey:USER_IS_LOGIN];
    
    if (![isLogin isEqualToString:@"YES"]) {
        //顯示訊息
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請登入特力愛家卡會員" delegate:self cancelButtonTitle:@"稍後" otherButtonTitles:@"登入", nil];
        alert.tag = 100;
        [alert show];
        
        NSLog(@"請先登入會員");

        return;
    }
    
//    //移除無折價劵的畫面
//    [self removeNoCoupon];
    
    currentType = CouponTypeMyCoupon;
    
    if (couponCategories != nil) {
        [couponCategories removeAllObjects];
    }
    [self getData_MyCoupon];
    
    // 2015-04-30 Henry 這裡不需要重讀
//        [self.tableView reloadData];
    
    [self.myCouponVutton setTitleColor:BUTTON_SELECTED_COLOR forState:UIControlStateNormal];
    [self.takeCouponButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    // GA 我的折價卷
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/coupon/my"]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/coupon/my"]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
}

//網站折價劵 立即兌換
-(void)changCouponAction:(id)sender {
    
    //判斷是否登入
    NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
    NSString *isLogin = [userDefaults objectForKey:USER_IS_LOGIN];
    
    if (![isLogin isEqualToString:@"YES"]) {
        //顯示訊息
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請登入特力愛家卡會員" delegate:self cancelButtonTitle:@"稍後" otherButtonTitles:@"登入", nil];
        alert.tag = 100;
        [alert show];
        
        NSLog(@"請先登入會員");
        
        return;
    }

    
    //登入後索取
    UIButton *button = (UIButton*)sender;
    NSInteger index = button.tag;
    
    //取得coupon code
    NSDictionary *dicData = [webCouponList objectAtIndex:index];
    NSString *couponCode = [dicData objectForKey:@"couponCode"];
    NSLog(@"APP購物折價券 立即索取 couponCode -- %@", couponCode);
    [self changeCoupon:couponCode];
}

//我的折價劵 - 限門市使用
-(void)useCouponByMemberCard:(id)sender {
    
    UIButton *button = (UIButton*)sender;
    NSInteger index = button.tag;
    
    NSDictionary *dicData;
    BOOL isForStore = YES;
    if (index >= 1000) { //共用折價券
        CouponCategory *couponCategory = [self getCouponCategoryByType:BOTH_COUPON];
        dicData = [couponCategory.couponList objectAtIndex:index - 1000];
        isForStore = NO;
    }else { //門市折價券
        CouponCategory *couponCategory = [self getCouponCategoryByType:STORE_COUPON];
        dicData = [couponCategory.couponList objectAtIndex:index];
    }
    
    //資料
    //導向Detail 頁面
    UIStoryboard *sb = [self storyboard];
    CouponDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CouponDetailView"];
    vc.isForStore = isForStore;
    vc.dicData = dicData;
    [self.navigationController pushViewController:vc animated:YES];
    
}

//限線上使用
// 限線上使用的「未使用」，直接連結至www.hola.com.tw。
-(void)goToHolaWeb:(UIButton*)btn {
    NSInteger index = btn.tag - 2000;
    NSLog(@"index -- %zd", index);
    CouponCategory *couponCategory = [self getCouponCategoryByType:EC_COUPON];
    
    //網路折價券
    NSDictionary *data = [couponCategory.couponList objectAtIndex:index];
    NSString *urlStr = [data objectForKey:@"couponLink"];
    NSLog(@"urlStr -- %@", urlStr);
    //    NSLog(@"goToHolaWeb");
    //    NSString *str = @"http://www.hola.com.tw";
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Get Data
-(void) getData_TakeCoupon {
    //取得兩個API的資料
    
    //網站折價劵
    [self getWebCouponList];
    
}

-(void) getData_MyCoupon {
    //取得三個API的資料
    
    //門市使用 (老闆的API) 門市線上使用 (共用) (老闆的API)
    [self getCouponByMemeberCard];
    
    //    2015-04-30 Henry 改到讀取getCouponByMemberCard後
    //    //限線上使用 (User API)
    //    [self getCouponList];
}

//取得網站折價劵資料
-(void) getWebCouponList {
    //組成Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId};
    
    //傳送資料
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:COUPONS_WEBLIST] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            [self addNoCouponView:CouponTypeTakeCoupon];

            return;
            
        }else {
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];
            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"returnDic -- %@", returnDic);
            
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
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
                
            }else {
                
                //移除無折價劵的畫面
//                [self removeNoCoupon];

                self.tableView.scrollEnabled = YES;
                
                //成功 有資料
                NSArray *tempArray = [returnDic objectForKey:@"data"];
                
                //去除資料中沒有couponCode的資料
                NSMutableArray *tempCoupon = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in tempArray) {
                    NSString *couponCode = [dic objectForKey:@"couponCode"];
                    if (couponCode != nil && ![couponCode isEqualToString:@""]) {
                        [tempCoupon addObject:dic];
                    }
                }
                
                webCouponList = [tempCoupon copy];
                section1Count = 1;
                if (tempArray .count > 0) {
                    [self.tableView reloadData];
                    
                }else {
                    //判斷是否無資料 無資料顯示

                    [self addNoCouponView:currentType];
                }
                
                
                //0602 Joseph 沒資料會crush , 先block掉
                //2015-04-30 Henry 移至上方
//                NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
//                [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }];
    
}

//兌換折價劵
-(void) changeCoupon:(NSString*)couponCode {
    
    if (couponCode == nil || [couponCode isEqualToString:@""]) {
        return;
    }
    
    //組成Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId, @"couponCode":couponCode};
    
    //傳送資料
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:COUPON_CHANGE] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
            
            return;
            
        }else {
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"returnDic -- %@", returnDic);
            
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
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"訊息" message:msg delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
                return;
                
            }else {
                //成功
                //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"訊息" message:@"兌換成功" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"訊息" message:@"恭喜您兌換折價券成功!此張折價券已在我的折價券中，提醒您請於折價券有效期限內使用完畢，逾期失效!" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                
                [alert show];
                
            }
        }
    }];
}

//button導到WebView
-(void)buttonToWebView:(UIButton*)btn {
    NSLog(@"btn.tag -- %zd", btn.tag);
    
    //Data
    NSDictionary *dic = [webCouponList objectAtIndex:btn.tag];
    NSString *couponLink = [dic objectForKey:@"couponLink"];
    NSLog(@"couponLink -- %@", couponLink);
    
    if (couponLink == nil || [couponLink isEqualToString:@""]) {
        return;
    }
    
    
    //打開連結
    NSURL *url = [NSURL URLWithString:couponLink];
    [[UIApplication sharedApplication] openURL:url];
    //[self pushToWebView:couponLink]; //導向其他頁面
    
    
}

//取得折價劵蒐集本(user 提供資料)
-(void) getCouponList {
    NSLog(@"getCouponList");
    
    //組成Dic
    NSString *sessionId = [IHouseUtility getSessionIDFromUserDefaults];
    NSDictionary *dic = @{@"sessionId": sessionId};
    
    //傳送資料
    //撈資料
    __block NSData *returnData;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    Henry 2015-05-18 Henry added
    //    hud.hidden = YES; //hidden的話 沒跑完會直接拉Table會crash jimmy
    
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getURLByAppName:COUPON_LIST] AndDic:dic];
        
    } completionBlock:^{
        
        [hud show:NO];
        [hud hide:YES];
        
        //資料為空
        if (returnData == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            
            [alert show];
        
            [self addNoCouponView:CouponTypeMyCoupon];

            
            return;
            
        }else {
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"getCouponList -- %@", returnDic);
            
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
                
                [self addNoCouponView:CouponTypeMyCoupon];

                return;
                
            }else {
                //成功  1.門市 2.共用 3.EC
                NSArray *dataArray = [returnDic objectForKey:@"data"];
                
                NSMutableArray *couponListBoth = [NSMutableArray new]; //門市線上適用(共用)
                NSMutableArray *couponListEC = [NSMutableArray new]; //線上折價券(線上)
                
//                if (dataArray.count==0) {
//                    [self addNoCouponView:CouponTypeMyCoupon];
//
//                }
                
                
                for (NSDictionary *dict1 in dataArray) { //User撈回來的資料
                    NSMutableDictionary *dict3 = nil; //共用折價劵資料
                    if (bothCouponList != nil) {
                        for (NSDictionary *dict2 in bothCouponList) {
                            NSString *sku1 = [dict1 objectForKey:@"sku"];
                            NSString *sku2 = [dict2 objectForKey:@"COUPONID"];//等同USER那邊的SKU
                            if ([sku1 isEqualToString:sku2]) {
                                dict3 = [NSMutableDictionary dictionaryWithDictionary:dict2];
                                break;
                            }
                        }
                    }
                    
                    if (dict3 != nil) {//找到加入共用折價券
                        
                        NSString *couponStatus = [dict1 objectForKey:@"couponStatus"];
                        NSLog(@"couponStatus");
                        if ([couponStatus isEqualToString:@"available"]) { //加入暫存折價券
                            //                            NSLog(@"dict3 :%@",[dict3 objectForKey:@"TITLE"]);
                            [dict3 setValue:[dict1 objectForKey:@"couponId"] forKey:@"serialNo"];//加入折價券序號
                            [couponListBoth addObject:dict3];
                            
                        } else { //不能使用加入到要EC折價券顯示的結果
                            //改成跟Bill 一樣
                            [dict3 setValue:[dict1 objectForKey:@"couponId"] forKey:@"serialNo"];//加入折價券序號
                            [couponListBoth addObject:dict3];
                            //0601 Joseph
//                            [couponListEC addObject:dict1];
                        }
                        
                    } else { // 加入到要EC折價券顯示的結果
                        [couponListEC addObject:dict1];
                    }
                }
                
                //線上與門市共用折價券有資料，則加入分類
                if ([couponListBoth count]>0) {
                    NSLog(@"共用折價劵共有幾筆 -- %zd", couponListBoth.count);
                    //進行排序合併相同SKU
                    //排序
                    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"COUPONID" ascending:YES];
                    NSArray *sortResultArray = [couponListBoth sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]; //老闆傳回來共用的折價劵
//                    NSLog(@"排序後的sortResultArray -- %@", sortResultArray);
                    NSMutableArray *couponArray = [NSMutableArray new];//合併後的共用折價券陣列
                    
                    NSString *lastSKU = @"";
                    
                    NSMutableArray *couponSerialNoList = [NSMutableArray new];
                    
                    NSDictionary *dict = nil;
                    
                    for (NSInteger i=0;i<[sortResultArray count];i++) {

                        dict = [sortResultArray objectAtIndex:i];
//                        NSLog(@"整理中的dict -- %@", dict);
                        //SKU不同
                        if (![[dict objectForKey:@"COUPONID"] isEqualToString:lastSKU]) {
                            //判斷並加入couponId
                            //[couponSerialNoList addObject:[dict objectForKey:@"serialNo"]];
                            for (NSDictionary *couponListData in dataArray) {
                                
                                NSString *sku = [couponListData objectForKey:@"sku"];
                                if ([sku isEqualToString:[dict objectForKey:@"COUPONID"]]) {
                                    
                                    NSString *status = [couponListData objectForKey:@"couponStatus"];
                                    if ([status isEqualToString:@"available"]) {
                                        NSString *couponId = [couponListData objectForKey:@"couponId"];
                                        [couponSerialNoList addObject:couponId];
                                    }
                                }
                            }
                            
//                            if (couponSerialNoList != nil) {
                        
                                NSDictionary *dictNew = @{@"COUPONID":[dict objectForKey:@"COUPONID"],@"TITLE": [dict objectForKey:@"TITLE"],@"DATE":[dict objectForKey:@"DATE"],@"DETAILIMG":[dict objectForKey:@"DETAILIMG"],@"DISCOUNTID":[couponSerialNoList mutableCopy], @"BIGIMG": [dict objectForKey:@"BIGIMG"], @"LISTIMG":[dict objectForKey:@"LISTIMG"]};
                                [couponArray addObject:dictNew];
//                            }
                            lastSKU = [NSString stringWithString:[dict objectForKey:@"COUPONID"]];
                            
                            //清空 可用的編號
                            couponSerialNoList = [NSMutableArray new];

                        }
//                        NSLog(@"最後的lastSKU -- %@", lastSKU);
                    }
                    
                    NSLog(@"整理後的couponArray -- %@", couponArray);
                    
//                    if (dict != nil) {
//                        if (couponSerialNoList != nil) {
//                            NSLog(@"couponSerialNoList -- %@", couponSerialNoList);
//                            NSDictionary *dictNew = @{@"COUPONID":[dict objectForKey:@"COUPONID"],@"TITLE": [dict objectForKey:@"TITLE"],@"DATE":[dict objectForKey:@"DATE"],@"DETAILIMG":[dict objectForKey:@"DETAILIMG"],@"DISCOUNTID":couponSerialNoList};
//                            [couponArray addObject:dictNew];
//                            //                            NSLog(@"dictNew -- %@", dictNew);
//                            //                            NSLog(@"couponSerialNoList :%li",[couponSerialNoList count]);
//                            
//                        }
//                    }
                    
                    //更新到EC與門市共用折價劵
                    if ([couponArray count]>0) {
                        NSLog(@"couponArray -- %@", couponArray);
                        CouponCategory *couponCategoryBoth = [CouponCategory new];
                        couponCategoryBoth.categoryType = BOTH_COUPON;
                        couponCategoryBoth.couponList = [NSArray arrayWithArray:couponArray];
                        [self updateCouponCategory:couponCategoryBoth];
                    }
                }
                
                //線上折價券有資料，則加入分類
                if ([couponListEC count]>0) {
                    NSLog(@"線上折價劵共有多少筆 -- %zd", couponListEC.count);
                    CouponCategory *couponCategoryEC = [CouponCategory new];
                    couponCategoryEC.categoryType = EC_COUPON;
                    couponCategoryEC.couponList = [NSArray arrayWithArray:couponListEC];
                    [self updateCouponCategory:couponCategoryEC];
                }
                
                //清除設定
                [bothCouponList removeAllObjects];
                bothCouponList = nil;
                
                [self.tableView reloadData];
                
                //2015-04-30 Henry 移至上方
                
                if (couponCategories!=nil) {
                    NSIndexPath* top = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
                    [self.tableView scrollToRowAtIndexPath:top atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
                                //判斷是否有無資料
                //                NSInteger count = 0;
                //
                //                for (CouponCategory *c in couponCategories) {
                //                    if (c.couponList == 0) {
                //                        count = count +1;
                //                    }
                //                }
                
                if (couponCategories.count == 0) {
                    [self addNoCouponView:currentType];
                }
            }
        }
    }];
    
}


//取得 我的折價劵 - 限門市使用 與 門市線上適用
-(void) getCouponByMemeberCard {
    NSLog(@"getCouponByMemeberCard");
    //組成Dic
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *crmMemberCard = [userDefaults objectForKey:USER_CRM_MEMBER_ID];
//    NSString *crmMemberCard = @"2082766430015";

    //NSString *crmMemberCard = [userDefaults objectForKey:USER_CARD_NUMBER];
    NSDictionary *dic = @{@"MemberCardID": crmMemberCard, @"Source":@"iOS"};
    
    //傳送資料
    //撈資料
    __block NSData *returnData;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [hud showAnimated:YES whileExecutingBlock:^{
        
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getPerfectURLByAppName:COUPON_BY_MEMBER_CARD] AndDic:dic];
        
    } completionBlock:^{
        
        
        //資料為空
        if (returnData == nil) {
            [hud show:NO];
            [hud hide:YES];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"請檢查網路連線" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alert show];
            

            //判斷是否無資料 無資料顯示
            [self addNoCouponView:CouponTypeMyCoupon];

            
            return;
            
        }else {
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];

            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"getCouponByMemeberCard -- %@", returnDic);
            //成功
            NSArray *dataArray = [returnDic objectForKey:@"COUPONS"];
            
            //先移除資料
            //            [tempListAll removeAllObjects];
            
            
            NSMutableArray *couponListByStore = [NSMutableArray new];
            //加入資料
            for (NSDictionary *dic in dataArray) {
                NSInteger type = [[dic objectForKey:@"COUPONTYPE"] integerValue];
                if (type == STORE_COUPON) {
                    //                    NSLog(@"dic :%ld",[[dic objectForKey:@"DISCOUNTID"] count]);
                    [couponListByStore addObject:dic];
                }else if (type == BOTH_COUPON) {
                    if (bothCouponList == nil) {
                        bothCouponList = [NSMutableArray new];
                    }
                    [bothCouponList addObject:dic];
                }
            }
            
            //數量大於0才加入
            if ([couponListByStore count]>0) {
                //初始化分類
                CouponCategory *couponCategory = [CouponCategory new];
                couponCategory.categoryType = STORE_COUPON; //設定為門市折價券
                couponCategory.couponList = couponListByStore;
                
                [self updateCouponCategory:couponCategory];
            }
            
            //讀取折價券蒐集本
            [self getCouponList];
            
        }
    }];
    
}

#pragma mark - 轉到登入頁面
- (IBAction)pushToLogin:(id)sender {
    
    // push to login screen
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    MemberLoginViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MemberLogin"];
    vc.dontJumpToIndex = YES;
    
    UINavigationController *myNavigation = [[UINavigationController alloc] initWithRootViewController:vc];
    
    vc.isDismissViewController=YES;
    
    [self presentViewController:myNavigation animated:YES completion:nil];
    
    
}

//更新折價券分類陣列
-(void)updateCouponCategory:(CouponCategory *)couponCategory {
    NSLog(@"更新折價券分類陣列");
    if (couponCategories == nil) {
        couponCategories = [NSMutableArray new];
    }
    
    NSUInteger foundIndex = -1;
    if ([couponCategories count]>0) {
        for (NSInteger i=0;i<[couponCategories count];i++) {
            CouponCategory *_couponCategory = [couponCategories objectAtIndex:i];
            //比對分類是否相同
            if (_couponCategory.categoryType == couponCategory.categoryType) {
                foundIndex = i;
                break;
            }
        }
    }else {
        NSLog(@"目前無資料");
    }
    
    
    if (foundIndex > -1) { //找到則取代
        NSLog(@"找到並取代 -- %zd", couponCategory.categoryType);
        [couponCategories replaceObjectAtIndex:foundIndex withObject:couponCategory];
    } else { //找不到則加入
        NSLog(@"找不到則加入 -- %zd", couponCategory.categoryType);
        [couponCategories addObject:couponCategory];
    }
}

-(CouponCategory *)getCouponCategoryByType:(CouponCategoryType)couponCategoryType {
    if (couponCategories != nil) {
        for (CouponCategory *_couponCategory in couponCategories) {
            if (_couponCategory.categoryType == couponCategoryType) {
                return _couponCategory;
                break;
            }
        }
    }
    return nil;
}

#pragma mark - 轉跳到webview畫面
-(void)pushToWebView:(NSString*)urlStr {
    
    NSLog(@"urlStr -- %@", urlStr);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Common" bundle:nil];
    CommonWebViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CommonWebView"];
    vc.urlStr = urlStr;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 其他方法
//加入無資料畫面
-(void)addNoCouponView:(CouponType)type {
    //判斷是否無資料 無資料顯示
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.tableView.frame];

    if (noCouponView != nil) {
        label = (UILabel *) [noCouponView viewWithTag:1];

    } else {
        noCouponView = [[UIView alloc] initWithFrame:self.tableView.frame];
        noCouponView.backgroundColor = [UIColor whiteColor];
        label.tag = 1;
        label.textAlignment = NSTextAlignmentCenter;
        [noCouponView addSubview:label];
    }
    
    
    if (type == CouponTypeTakeCoupon) {
        label.text = @"目前無折價券優惠可供索取！";
    }else if (type == CouponTypeMyCoupon) {
        label.text = @"目前無折價券";
    }
 
    [self.tableView addSubview:noCouponView];
    
    self.tableView.scrollEnabled = NO;
    
}

-(void)removeNoCoupon {
    if (noCouponView != nil) {
        [noCouponView removeFromSuperview];
    }
}

#pragma mark - Alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //提示登入視窗
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            //前往登入
            [self pushToLogin:nil];
        }
    }
}

@end
