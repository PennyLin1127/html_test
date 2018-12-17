//
//  ProductCatalogueViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/3.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ProductCatalogueViewController.h"
#import "NSDefaultArea.h"
#import "SubProductCatalogueViewController.h"
@interface ProductCatalogueViewController ()<UITableViewDataSource,UITableViewDelegate>

// Product Catalogue裡的第一層array
@property (strong,nonatomic) NSArray *productCatalogueArray;

// 儲存User按到哪個列的子目錄字串
@property (strong,nonatomic) NSString *lableText;


@end

@implementation ProductCatalogueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productCatalogueArray=[NSDefaultArea GetProductListFromUserDefault];
    
    // customise menu action
    [self changeMenuActionToPushVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back2MenuButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productCatalogueArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:cellIdentifier];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }

    NSDictionary *productCatalogueDic = self.productCatalogueArray[indexPath.row];
    cell.textLabel.text=[productCatalogueDic objectForKey:@"categoryName"];
        
    return cell;
}



#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIStoryboard *storyBoard=self.storyboard;
    SubProductCatalogueViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"SubProductCatalogueVC"];
    
    // 把User按到哪個列的值傳到vc.subProductCatalogueArray
    NSDictionary *dict = self.productCatalogueArray[indexPath.row];

    vc.subProductCatalogueArray = [dict objectForKey:@"subCategorys"];
    
    // 把User按到哪個列的子目錄字串title傳到vc.titleName
    NSDictionary *productCatalogueDic=self.productCatalogueArray[indexPath.row];
    vc.titleName = [productCatalogueDic objectForKey:@"categoryName"];
    vc.categoryID = [productCatalogueDic objectForKey:@"categoryId"];
    
    [self.navigationController pushViewController:vc animated:YES ];
    
}

@end
