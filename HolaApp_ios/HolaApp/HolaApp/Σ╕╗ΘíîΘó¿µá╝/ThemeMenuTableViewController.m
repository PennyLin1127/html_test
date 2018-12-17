//
//  ThemeMenuTableViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/4/8.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ThemeMenuTableViewController.h"
#import "SQLiteManager.h"
#import "ThemeStyleViewController.h"
#import "NSDefaultArea.h"
#import "ThemeProductListCollectionViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "IHouseUtility.h"

@interface ThemeMenuTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ThemeMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // get date (YYYY-MM-dd)
    NSDate *date=[NSDate date];
    NSString *dateStrFormate=[IHouseUtility createDateFormat:date];
    
    if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
        
        // get tbl_theme_category data from SQLite (主題目錄)
        self.catagory = [[NSMutableArray alloc]initWithArray:[SQLiteManager getIndexViewData:dateStrFormate]];
    }else{
        self.catagory = [[NSMutableArray alloc]initWithArray:[SQLiteManager getIndexViewData]];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 返回選單button
- (IBAction)back2MenuBotton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.catagory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identify];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *dic= [self.catagory objectAtIndex:indexPath.row];
    cell.textLabel.text=[dic objectForKey:@"CategoryName"];
    cell.textLabel.textColor=[UIColor colorWithRed:116.0/255.0 green:79.0/255.0 blue:40.0/255.0 alpha:1.0f];
    return cell;
}


#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 存下使用者按下哪一個照片的目錄ID
    NSDictionary *dic=[self.catagory objectAtIndex:indexPath.row];
    NSInteger themeID = [[dic objectForKey:@"CategoryId"] integerValue];

    // get date (YYYY-MM-dd)
    NSDate *date=[NSDate date];
    NSString *dateStrFormate=[IHouseUtility createDateFormat:date];
    NSArray *subCategories;
    
    if ([HOLA_PERFECT_URL isEqualToString:HOLA_PERFECT_TEST]) {
        
        subCategories =[SQLiteManager getThemeData:themeID date:dateStrFormate];
    }
    else
    {
        subCategories =[SQLiteManager getThemeData:themeID];
    }

    // GA -- 選擇哪一個熱門話題
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    
    // 記畫面
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/theme/category/%ld",(long)themeID]];
    [tracker send : [ [ GAIDictionaryBuilder createAppView ] build ] ] ;
    
    // 記事件
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:[NSString stringWithFormat:@"/theme/category/%ld",(long)themeID]
                                                          action:@"button_press"
                                                           label:nil
                                                           value:nil] build]];
    
    if(subCategories.count<2)
        // 數量太少就不顯示瀑布牆，直接到熱門話題商品列表
    {
        NSInteger subThemeId = [[[subCategories objectAtIndex:0]objectForKey:@"themeId"] integerValue];
        
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ThemeProductListCollectionViewController *vc=[sb instantiateViewControllerWithIdentifier:@"ThemeProductListCollectionView"];
        vc.themeID = subThemeId;
        [self.navigationController pushViewController:vc animated:YES];

    }
    else
    {   // 數量大於2，顯示瀑布牆

        ThemeStyleViewController *vc=[[ThemeStyleViewController alloc]init];
        vc.themeID = themeID;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
@end
