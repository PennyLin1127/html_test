//
//  SubProductCatalogueViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/3.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "SubProductCatalogueViewController.h"
#import "NSDefaultArea.h"
#import "ProductCatalogueViewController.h"
#import "ProductListContainerViewController.h"


@interface SubProductCatalogueViewController ()<UITableViewDelegate,UITableViewDataSource>

// 儲存User按到哪個列的子目錄字串
@property (strong,nonatomic) NSString *lableText;


@end

@implementation SubProductCatalogueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // change subProductCatalogueTitle label text
    self.subProductCatalogueTitle.text=self.titleName;
    
    // customise menu action
    [self changeMenuActionToPushVC];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.subProductCatalogueArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:cellIdentifier];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Product Catalogue裡的第二層array
    NSDictionary *dict = [self.subProductCatalogueArray objectAtIndex:indexPath.row];
    cell.textLabel.text=dict[@"subCategoryName"];


    return cell;
}



#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"user tap in section:%ld, row :%ld",(long)indexPath.section,(long)indexPath.row);
    
    UIStoryboard *storyBoard=self.storyboard;
    ProductListContainerViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ProductListContainer"];
    NSDictionary *dict = [self.subProductCatalogueArray objectAtIndex:indexPath.row];
    vc.categoryID = dict[@"subCategoryId"];
    vc.titleName=dict[@"subCategoryName"];
    
    [self.navigationController pushViewController:vc animated:YES ];
}

#pragma mark - backToProductCatalogueMenu button
- (IBAction)backToProductCatalogueMenu:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];

}

@end
