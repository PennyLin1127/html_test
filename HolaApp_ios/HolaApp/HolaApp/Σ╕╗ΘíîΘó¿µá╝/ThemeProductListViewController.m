////
////  ThemeProductListViewController.m
////  HolaApp
////
////  Created by Joseph on 2015/4/9.
////  Copyright (c) 2015年 JimmyLiu. All rights reserved.
////
//
//#import "ThemeProductListViewController.h"
//#import "NSDefaultArea.h"
//#import "SQLiteManager.h"
//#import "AsyncImageView.h"
//#import "URLib.h"
//
//
//@interface ThemeProductListViewController ()
//
//@end
//
//@implementation ThemeProductListViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//        
//    // hidden inherit leftBar
////    self.navigationItem.leftBarButtonItems=nil;
//    // add hola back button
////    [self holaBackCus];
//    
//    // set up data and init
//
//    NSArray *tempArray=[SQLiteManager getThemeDataDetail:self.themeID];
//    
//    self.productDataSourceArray=[[NSMutableArray alloc]initWithArray:tempArray];
//    
//    [self setupPicAndTitle];
//    
//    //NavigationBar change
////    NSArray *rightButtonsArray = self.navigationItem.rightBarButtonItems;
////    self.navigationItem.rightBarButtonItems = @[rightButtonsArray[0],rightButtonsArray[2],rightButtonsArray[1]];
//    
//    // scroll view delegate
//    self.scrollView.delegate=self;
//    
//    [self.searchMore setHidden:YES];
//    
//    self.scrollView.scrollsToTop = YES;
//    
//    
//    // init search condition at first time
////    2015-05-02 Henry 以下這段目的是?
////    NSDictionary *filter=@{@"filterCondition":@""};
////    [NSDefaultArea filterConditionToUserDefault:filter];
////    NSDictionary *ascOrDsc=@{@"ascOrDesc":@""};
////    [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
////    NSString *parentId=@"";
////    [NSDefaultArea parentCategoryIdToUserDefault:parentId];
//    
//    
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//
//-(void)viewDidAppear:(BOOL)animated{
//    
//    // For iphone6+ scroll view -> appear search more button 判斷
////    [self searchMoreButtonShowForI6Plus];
//    
//}
//
//
////-(void)searchMoreButtonShowForI6Plus{
////    // For iphone6+ scroll view 判斷
////    if (self.scrollView.contentSize.height<self.scrollView.frame.size.height && self.scrollView.frame.size.height>=692)
////    {
////        [self.searchMore setHidden:NO];
////    }
////    
////    NSLog(@"contentSize height %f",self.scrollView.contentSize.height);
////    NSLog(@"frame height %f",self.scrollView.frame.size.height);
////}
//
//
////// HOLA back button
////- (void)holaBackCus {
////    
////    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
////    
////    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:@""
////                                                                   style:UIBarButtonItemStylePlain
////                                                                  target:self
////                                                                  action:@selector(backAction)];
////    [barBtnItem setImage:image1];
////    self.navigationItem.leftBarButtonItem = barBtnItem;
////    
////}
//
////-(void) backAction {
////    [self.navigationController popViewControllerAnimated:YES];
////}
//
//-(void)setupPicAndTitle{
//    NSDictionary *dic=self.productDataSourceArray[0];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOLA_THEME_PATH,[dic objectForKey:@"vchImage2"]]];
//    self.themePic.imageURL=url;
//    self.themeTitle.text=[dic objectForKey:@"vchThemeName"];
//    self.themeDescription.text=[dic objectForKey:@"vchDescription"];
//}
//
//- (IBAction)searchMore:(id)sender {
//
//    // remove searchMore button after press
//    [self.searchMore removeFromSuperview];
//    
//    // 存SQL keyword (只能一個keyword)
//    NSString *searchKeyWord=[self.productDataSourceArray[0] objectForKey:@"vchKeyword"];
//    if (searchKeyWord.length == 0) {
//        return;
//    }
////    NSDictionary *searchKeywordDic=@{@"keyword":searchKeyWord};
////    [NSDefaultArea keywordToUserDefault:searchKeywordDic];
//    
//    // 存tag，去撈搜尋的方法
////    NSString *goToSearch=@"GoToSearch";
////    NSDictionary *goSearch=@{@"viewKeyword":goToSearch};
////    [NSDefaultArea whichViewKeywordToUserDefault:goSearch];
//    
////    2015-05-02 Henry: 這部份應該使用ProductAPILoader取得資料，再用參數傳給下層productListCollectionViewController
//    [self.productListCollectionViewController viewDidLoad];
//    
////    [self.supplementaryViewFooter.searchMore setHidden:YES];
//
//}
//
//#pragma mark - scroll view delegate
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    
//    // 偵測滑到底部
//    float scrollViewHeight = scrollView.frame.size.height; // 內容高度
//    float scrollContentSizeHeight = scrollView.contentSize.height; //內容總高度
//    float scrollOffset = scrollView.contentOffset.y; //從內容高度底部開始算y offset
// 
//    // 滑到最底部
//    if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)
//    {
////        self.containerHeightConstraint.constant=-200;
////        [self.searchMore setHidden:NO];
//        
//    // 往上拉
//    }else if (scrollOffset + scrollViewHeight < scrollContentSizeHeight)
//    {
////        [self.searchMore setHidden:YES];
////        self.containerHeightConstraint.constant=150;
//
//    }
//    
//
//}
//
//@end
