//
//  SearchContainer1ViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/4/1.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//  2015-05-01 Henry 搜尋結構調整
//  2015-05-01 Henry 搜尋結果有資料才加入
//

#import "SearchContainer1ViewController.h"
#import "MyFavoriteViewController.h"
#import "SearchContainer2ViewController.h"
#import "NSDefaultArea.h"
#import "ProductListContainerViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface SearchContainer1ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchResultsUpdating,UISearchDisplayDelegate>

@property (strong,nonatomic) NSMutableArray  *dataList;
@property (strong,nonatomic) NSMutableArray  *searchList;

@end



@implementation SearchContainer1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // temp data
    self.dataList=[NSMutableArray arrayWithCapacity:100];
    
    for (NSInteger i=0; i<100; i++) {
        [self.dataList addObject:[NSString stringWithFormat:@"%ld-FlyElephant",(long)i]];
    }
    
    // init search condition at first time
    NSDictionary *filter=@{@"filterCondition":@""};
    [NSDefaultArea filterConditionToUserDefault:filter];
    NSDictionary *ascOrDsc=@{@"ascOrDesc":@""};
    [NSDefaultArea ascOrDscTagToUserDefault:ascOrDsc];
    NSString *parentId=@"";
    [NSDefaultArea parentCategoryIdToUserDefault:parentId];
    
    
    //init mutable
    self.saveSearchWords =[[NSMutableArray alloc]initWithCapacity:0];
    self.saveAllSearchWords =[[NSMutableArray alloc]initWithCapacity:0];
    

    // 存下tag for search (for scroll view did scroll tag)
    NSString *key=@"GoToSearch";
    NSDictionary *keyDic=@{@"viewKeyword":key};
    [NSDefaultArea whichViewKeywordToUserDefault:keyDic];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //進入畫面直接Focus 搜尋框
    if (self.focusOnSearchBarAtStart == YES) {
        [self.searchDisplayController setActive:YES];
        [self.searchDisplayController.searchBar becomeFirstResponder];
    }
    
}

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];

//    if (self.needAutoSearch == YES) {
//        
//        self.searchBar.text = self.searchText;
//        [self searchBarSearchButtonClicked:self.searchBar];
//        
//        self.needAutoSearch = NO;
//        self.searchText = @"";
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.view endEditing:YES];
}


#pragma mark - UISearchDisplayController delegate
- (void)filterContentForSearchText:(NSString*)searchText
{

    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchText];
    
    if (self.searchList!= nil) {
        [self.searchList removeAllObjects];
    }
    
    //過濾數據
    self.searchList= [NSMutableArray arrayWithArray:[[NSDefaultArea GetSearchKeywordsFromUserDefault] filteredArrayUsingPredicate:preicate]];
    
    [self.tableView reloadData];
    
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    NSLog(@"searchDisplayController");
    if ([searchString length] > 0) {
        
        NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
        
        if (self.searchList!= nil) {
            [self.searchList removeAllObjects];
        }
        
        //過濾數據
        self.searchList= [NSMutableArray arrayWithArray:[[NSDefaultArea GetSearchKeywordsFromUserDefault] filteredArrayUsingPredicate:preicate]];

        return YES;
    }
    else {
        return NO;
    }
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller{
    NSLog(@"searchDisplayControllerDidBeginSearch");
}

-(void)search{
    
}



// HOLA back button
- (void)holaBackCus {
    
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
        
}

-(void) backAction {
    [self.navigationController popToRootViewControllerAnimated:YES];
}





#pragma mark - UISearchResultsUpdating

// Called when the search bar's text or scope has changed or when the search bar becomes first responder.
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    
}

#pragma mark- UISearchBarDelegate delegate


//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
//{
//    [self updateSearchResultsForSearchController:self.searchController];
//}


// 按下 search button
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{


    NSLog(@"searchBarSearchButtonClicked:%@",searchBar.text);
    
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
    
    SearchContainer2ViewController *searchContainer2ViewController= [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"container2"];
        
    searchContainer2ViewController.keyword = searchBar.text;
    
    // 傳第一個VC收尋的字到第二個VC
    searchContainer2ViewController.searchText = searchBar.text;
    searchContainer2ViewController.showTextTag =YES;
    
    [self.navigationController pushViewController:searchContainer2ViewController animated:YES];
    
    
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


//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
//    return YES;
//}
//
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
//    [self.searchController setActive:YES];
//    return YES;
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.tableView ==  self.searchDisplayController.searchResultsTableView) {
        return [self.searchList count];
    }else{
        return [[NSDefaultArea GetSearchKeywordsFromUserDefault]count];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *Identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    if (self.tableView ==  self.searchDisplayController.searchResultsTableView) {
        [cell.textLabel setText:self.searchList[indexPath.row]];
    }
    else{
        [cell.textLabel setText:[NSDefaultArea GetSearchKeywordsFromUserDefault][indexPath.row]];
    }
    
    // cell 外觀
    [self.tableView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f]];
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f]];
    
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *keyword = nil;
    if (self.tableView ==  self.searchDisplayController.searchResultsTableView) {
        keyword = self.searchList[indexPath.row];
    }
    else{
        // 存下tag for search or get product list
        keyword =[ [NSDefaultArea GetSearchKeywordsFromUserDefault] objectAtIndex:indexPath.row];
        SearchContainer2ViewController *searchContainer2ViewController= [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"container2"];
        searchContainer2ViewController.keyword=keyword;
        
        // 傳第一個VC收尋的字到第二個VC
        searchContainer2ViewController.searchText = keyword;
        searchContainer2ViewController.showTextTag =YES;

        [self.navigationController pushViewController:searchContainer2ViewController animated:YES];

    }
}


@end
