//
//  SearchContainer2ViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/4/1.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "SearchContainer2ViewController.h"
#import "ProductListCollectionViewController.h"
#import "SearchContainer1ViewController.h"
#import "NSDefaultArea.h"
#import "CatagoryInfoData.h"
#import "ProductListTableViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface SearchContainer2ViewController ()<UISearchBarDelegate,UISearchResultsUpdating,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>

{
    ProductListContainerViewController *productListContainerViewController;
    ProductListTableViewController  *productListTableViewController;
    UIButton *rightButton0;
    BOOL show;
    WhichFilter filterType;
    
}

@property (strong,nonatomic) NSArray *pickerRightArray;
@property (strong,nonatomic) NSString *showkeyWordStr;
@property (assign,nonatomic) BOOL pressSearchButtonTag;

@end

@implementation SearchContainer2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // hidden inherit leftBar
    self.navigationItem.leftBarButtonItems=nil;
    
    // for customize back
    if (self.popToViewTagBOOL) {
        [self holaBackCus2];
        self.popToViewTagBOOL=NO;
    }else{
    // add hola back button
        [self holaBackCus];
    }
    
    // init search condition at first time
    NSDictionary *filter=@{@"filterCondition":@""};
    [NSDefaultArea filterConditionToUserDefault:filter];
    NSDictionary *ascOrDsc=@{@"ascOrDesc":@""};
    [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
    NSString *parentId=@"";
    [NSDefaultArea parentCategoryIdToUserDefault:parentId];
    
    
    // picker data
    self.pickerRightArray=@[@"精準度由高到低",@"精準度由低到高",@"暢銷度由高到低",@"暢銷度由低到高",@"價格由高到低",@"價格由低到高",@"上架時間由新到舊",@"上架時間由舊到新"];
    [self.pickerView setHidden:YES];
    [self.toolBar setHidden:YES];
    show=YES;
    
    // init filterType
    filterType=conditionFilter;
    
    // init mutable
    self.mainCatagorysArray=[[NSMutableArray alloc]initWithCapacity:0];
    [self unarchiveObject];
    self.saveYouSearchWords=[[NSMutableArray alloc]initWithCapacity:0];
    
    self.saveAllSearchWords =[[NSMutableArray alloc]initWithCapacity:0];
    self.saveSearchWords=[[NSMutableArray alloc]initWithCapacity:0];

    
    self.pickerView.delegate = self;
    
    //KVO for reload pickerView data --> [self.pickerView reloadAllComponents];
    [self addObserver:self forKeyPath:@"catagoryInfoArray" options:NSKeyValueObservingOptionNew context:nil];
    
    // hide keyboard
    [self hideKeyboardViaGesture];

}

-(void)viewDidDisappear:(BOOL)animated{
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    // 存下tag for search (for scroll view did scroll tag)
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.needAutoSearch == YES) {
        
        self.searchBar.text = self.searchText;
        [self searchBarSearchButtonClicked:self.searchBar];
        
        self.needAutoSearch = NO;
        self.searchText = @"";
    }    
    // show 前一個view 搜尋的字show在第二個view
    if (self.showTextTag || self.pressSearchButtonTag==NO) {
        self.searchBar.text = self.searchText;
        self.showTextTag=NO;
    }else{
        self.pressSearchButtonTag=YES;
        self.searchBar.text=self.showkeyWordStr;
    }
}

-(void)hideKeyboardViaGesture{
    // hide keyboard
    UITapGestureRecognizer *gestureRecognizer= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizer setDelegate:self];
    
    // 因為加了gesture，所以setCancelsTouchesInView:NO，不然collectionView de-select 會無法辨識
    [gestureRecognizer setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:gestureRecognizer];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"catagoryInfoArray"]) {
        NSLog(@"catagoryInfoArraycatagoryInfoArraycatagoryInfoArraycatagoryInfoArraycatagoryInfoArray");
        NSLog(@"catagoryInfoArray%@", self.catagoryInfoArray);
        [self.pickerView reloadAllComponents];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// HOLA back button
- (void)holaBackCus {
        
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];
    
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    
}

-(void) backAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


// HOLA back button
- (void)holaBackCus2 {
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithImage:image1 style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction2)];
    
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    
}

-(void) backAction2 {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)category:(id)sender {
    
    filterType=categoryFilter;
    [self.pickerView reloadAllComponents];
    
    if (show==YES) {
        [self.pickerView setHidden:NO];
        [self.toolBar setHidden:NO];
        show=NO;
    }else{
        [self.pickerView setHidden:YES];
        [self.toolBar setHidden:YES];
        show=YES;
    }
  
}



- (IBAction)filterCondition:(id)sender {
    
    filterType=conditionFilter;
    [self.pickerView reloadAllComponents];
    
    if (show==YES) {
        [self.pickerView setHidden:NO];
        [self.toolBar setHidden:NO];
        show=NO;
    }else{
        [self.pickerView setHidden:YES];
        [self.toolBar setHidden:YES];
        show=YES;
    }
    
}


- (IBAction)cancelButton:(id)sender {
    
    [self.pickerView setHidden:YES];
    [self.toolBar setHidden:YES];
}




- (IBAction)doneButton:(id)sender {
    
    [self.pickerView setHidden:YES];
    [self.toolBar setHidden:YES];

    // 清掉第一次的搜尋array
    NSString *str=@"clearArrayTag";
    NSDictionary *temp=@{@"clearArrayTag":str};
    [NSDefaultArea clearArrayTagToUserDefault:temp];
    
    // 開始搜尋第二次當按下搜尋按鈕
    [self.delegate toTop];
    [self.delegate2 toTop2];
    [self SyncGetData];
}

-(void) unarchiveObject{
    
NSData *catagorysData = [[NSUserDefaults standardUserDefaults] objectForKey:@"catagoryArray"];
NSArray *catagorysDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:catagorysData];

    self.MainCatagorysArray = [NSMutableArray arrayWithArray:catagorysDataArray];
    NSLog(@"catagoryInfoArraycatagoryInfoArraycatagoryInfoArraycatagoryInfoArraycatagoryInfoArray");
    
}

#pragma mark - UISearchResultsUpdating
// 更新searchBar的變化
// Called when the search bar's text or scope has changed or when the search bar becomes first responder.
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {

}

#pragma mark- UISearchBarDelegate delegate

//// 更新searchBar的變化
//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
//{
//    [self updateSearchResultsForSearchController:self.searchController1];
//}

// 按下 search button
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    NSLog(@"searchBarText %@",searchBar.text);
    self.showkeyWordStr=searchBar.text;
    self.pressSearchButtonTag=YES;
    
    if (searchBar.text.length == 0) {
        return;
    }
  
    // 存下搜尋過的字，顯示在tableView
    if (self.saveAllSearchWords!=nil) {
        self.saveAllSearchWords=[NSMutableArray arrayWithArray:[NSDefaultArea GetSearchKeywordsFromUserDefault]];
        // 有存過的字就不存了(無分辨大小寫)
        if (![self.saveAllSearchWords containsObject:searchBar.text]) {
            [self.saveSearchWords addObject:searchBar.text];
            [self.saveAllSearchWords addObjectsFromArray:self.saveSearchWords];
            [NSDefaultArea searchKeywordsToUserDefault:self.saveAllSearchWords];
        }
    }else{
        [self.saveSearchWords addObject:searchBar.text];
        [self.saveAllSearchWords addObjectsFromArray:self.saveSearchWords];
        [NSDefaultArea searchKeywordsToUserDefault:self.saveAllSearchWords];
    }
 
    self.keyword = searchBar.text;
    // 開始搜尋第二次當按下搜尋按鈕
    [self.delegate toTop];
    [self.delegate2 toTop2];
    [self SyncGetData];
    
    // GA -- 搜尋哪一個商品
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/product/search/%@",searchBar.text]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/product/search/%@",searchBar.text]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
    

}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}


#pragma mark - pickView data source

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (filterType==categoryFilter)
    {
//    
//        CatagoryInfoData *data = [self.catagoryInfoArray objectAtIndex:self.tagForRow];
//        CatagoryInfoData *data1 ;
//        if (data.subCategorys!=nil) {
//            
//            [self.catagoryInfoArray addObjectsFromArray:data1.subTitle];
//            
//            return self.catagoryInfoArray.count;
//
//        }else{
//        
        
        
        NSLog(@"catagoryInfoArray.count %lu",self.productCatagory.count);
        
        return self.productCatagory.count;
//        }
        
    }else if (filterType==conditionFilter)
        
    {
        
        return self.pickerRightArray.count;
        
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (filterType==categoryFilter)
    {
        CatagoryInfoData *data = [self.productCatagory objectAtIndex:row];
        return data.categoryName;
        
    }else if (filterType==conditionFilter)
    {
        
        return [self.pickerRightArray objectAtIndex:row];
        
    }
    return nil;
}

#pragma mark - pickView delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    self.tagForRow =row;
    
    if (filterType==categoryFilter)
    {
        CatagoryInfoData *data = [self.productCatagory objectAtIndex:row];
        NSString *temp=data.parentCategoryId ;
        NSLog(@"temp %@",temp);
        [NSDefaultArea parentCategoryIdToUserDefault:temp];
        
    }else if (filterType==conditionFilter)
    {
        NSString *conStr=[self.pickerRightArray objectAtIndex:row];
        if ([conStr isEqualToString:@"精準度由高到低"])
        {
            // save user selected filter keyword
            NSDictionary *filter=@{@"filterCondition":@"weight"};
            [NSDefaultArea filterConditionToUserDefault:filter];
            NSDictionary *ascOrDsc=@{@"ascOrDesc":@"desc"};
            [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
            
        } else if ([conStr isEqualToString:@"精準度由低到高" ])
        {
            // save user selected filter keyword
            NSDictionary *filter=@{@"filterCondition":@"weight"};
            [NSDefaultArea filterConditionToUserDefault:filter];
            NSDictionary *ascOrDsc=@{@"ascOrDesc":@"asc"};
            [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
            
        } else if ([conStr isEqualToString:@"暢銷度由高到低"])
        {
            // save user selected filter keyword
            NSDictionary *filter=@{@"filterCondition":@"clickCounts"};
            [NSDefaultArea filterConditionToUserDefault:filter];
            NSDictionary *ascOrDsc=@{@"ascOrDesc":@"desc"};
            [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
            
        } else if ([conStr isEqualToString:@"暢銷度由低到高"])
        {
            // save user selected filter keyword
            NSDictionary *filter=@{@"filterCondition":@"clickCounts"};
            [NSDefaultArea filterConditionToUserDefault:filter];
            NSDictionary *ascOrDsc=@{@"ascOrDesc":@"asc"};
            [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
            
        } else if ([conStr isEqualToString:@"價格由高到低"])
        {
            // save user selected filter keyword
            NSDictionary *filter=@{@"filterCondition":@"price"};
            [NSDefaultArea filterConditionToUserDefault:filter];
            NSDictionary *ascOrDsc=@{@"ascOrDesc":@"desc"};
            [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
            
        } else if ([conStr isEqualToString:@"價格由低到高"])
        {
            // save user selected filter keyword
            NSDictionary *filter=@{@"filterCondition":@"price"};
            [NSDefaultArea filterConditionToUserDefault:filter];
            NSDictionary *ascOrDsc=@{@"ascOrDesc":@"asc"};
            [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
            
        } else if ([conStr isEqualToString:@"上架時間由新到舊"])
        {
            // save user selected filter keyword
            NSDictionary *filter=@{@"filterCondition":@"pubDate"};
            [NSDefaultArea filterConditionToUserDefault:filter];
            NSDictionary *ascOrDsc=@{@"ascOrDesc":@"desc"};
            [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
            
        } else if ([conStr isEqualToString:@"上架時間由舊到新"])
        {
            // save user selected filter keyword
            NSDictionary *filter=@{@"filterCondition":@"pubDate"};
            [NSDefaultArea filterConditionToUserDefault:filter];
            NSDictionary *ascOrDsc=@{@"ascOrDesc":@"asc"};
            [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
        }
        
        
        NSLog(@"Selected %@",[self.pickerRightArray objectAtIndex:row]);
    }
    
    
}

/*
 search API 排序
 
 sortColumn
 weight:精準度
 price:價格
 clickCounts:暢銷度
 pubDate:上架時間
 
 sortOrder
 asc:由小到大
 desc:由大到小
 
 */


@end
