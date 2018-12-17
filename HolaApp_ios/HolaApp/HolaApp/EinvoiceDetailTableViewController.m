//
//  EinvoiceDetailTableViewController.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/31.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "EinvoiceDetailTableViewController.h"
#import "EinvoiceDetailTableViewCell.h"
#import "MyFavoriteViewController.h"
#import "SearchContainer1ViewController.h"

@interface EinvoiceDetailTableViewController () {
    NSArray *dataArray; //細項
}
@property (weak, nonatomic) IBOutlet UILabel *invoiceNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@end

@implementation EinvoiceDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //解析dic
    
    if (self.dicData != nil) {
        //發票號碼
        NSString *invoiceNo = [self.dicData objectForKey:@"invoiceNo"];
        NSLog(@"invoiceNo -- %@", invoiceNo);
        self.invoiceNoLabel.text = [NSString stringWithFormat:@"發票號碼:%@",invoiceNo];
        
        //幾項產品
        NSString *totalCount = [NSString stringWithFormat:@"%@", [self.dicData objectForKey:@"totalCount"]];
        NSLog(@"totalCount -- %@", totalCount);
        self.totalCountLabel.text = totalCount;
        
        //總計
        NSString *amount = [NSString stringWithFormat:@"%@", [self.dicData objectForKey:@"amount"]];
        NSLog(@"amount -- %@", amount);
        if (amount != nil) {
            NSInteger integer = [amount integerValue];
            NSNumber *num = [NSNumber numberWithInteger:integer];
            NSString *numStr = [NSNumberFormatter localizedStringFromNumber:num numberStyle:NSNumberFormatterDecimalStyle];
            self.amountLabel.text= [NSString stringWithFormat:@"%@%@", @"$", numStr];
        }else {
            self.amountLabel.text = @"";
        }
        
        //細項
        dataArray = [self.dicData objectForKey:@"items"];
        NSLog(@"共有幾項 -- %zd", dataArray.count);
        
    }
    
    //view init
    [self.tableView.layer setBorderWidth:1];
//    [self.footerView.layer setBorderWidth:1];
    
    //[self holaBackCus];
    [self setNavigationButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"EinvoiceDetailCell";

    EinvoiceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[EinvoiceDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    NSDictionary *dic = [dataArray objectAtIndex:indexPath.row];
    
    //商品名稱
    NSString *prdName = [dic objectForKey:@"prdName"];
    cell.prdNameLabel.text = prdName;
    
    //單價
    NSString *salePrice = [dic objectForKey:@"salePrice"];
    if (salePrice != nil) {
        NSInteger integer = [salePrice integerValue];
        NSNumber *num = [NSNumber numberWithInteger:integer];
        NSString *numStr = [NSNumberFormatter localizedStringFromNumber:num numberStyle:NSNumberFormatterDecimalStyle];
        cell.salePriceLabel.text= [NSString stringWithFormat:@"%@%@", @"單價:", numStr];
    }else {
        cell.salePriceLabel.text = @"";
    }
    
    //數量
    NSString *quantity = [NSString stringWithFormat:@"數量%@件", [dic objectForKey:@"quantity"]];
    cell.quantityLabel.text = quantity;
    
    //總金額
    NSString *subTotal = [dic objectForKey:@"subTotal"];
    if (subTotal != nil) {
        NSInteger integer = [subTotal integerValue];
        NSNumber *num = [NSNumber numberWithInteger:integer];
        NSString *numStr = [NSNumberFormatter localizedStringFromNumber:num numberStyle:NSNumberFormatterDecimalStyle];
        cell.subTotalLabel.text= [NSString stringWithFormat:@"%@%@", @"$", numStr];
    }else {
        cell.subTotalLabel.text = @"";
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - 設置Navigation 按鈕
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
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setNavigationButton {

    //Back Button
    UIImage *image1 = [[UIImage imageNamed:@"LOGO_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(backAction)];
    [barBtnItem setImage:image1];
    self.navigationItem.leftBarButtonItem = barBtnItem;
    
    // search bar button
    UIButton *rightButton1=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25.0f, 25.0f)];
    [rightButton1 setBackgroundImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [rightButton1 addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
   UIBarButtonItem *searchBarBtn =[[UIBarButtonItem alloc]initWithCustomView:rightButton1];
    
    // my favorite bar button  (need change pic)
    UIButton *rightButton2=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30.0f, 25.0f)];
    [rightButton2 setBackgroundImage:[UIImage imageNamed:@"Collect"] forState:UIControlStateNormal];
    [rightButton2 addTarget:self action:@selector(myfavorite) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *myFavoriteBarBtn =[[UIBarButtonItem alloc]initWithCustomView:rightButton2];
    
    // right bar button 間距
    UIBarButtonItem *rightFixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightFixedItem.width = 20.0f;
    
    // add to button item
    self.navigationItem.rightBarButtonItems =@[myFavoriteBarBtn,rightFixedItem,searchBarBtn];
//    self.navigationItem.leftBarButtonItems =@[menuBarBtn,leftFixedItem,holaLogo];

}

-(void)search{
    NSLog(@"search pressed!");
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchContainer1ViewController *vc=[sb instantiateViewControllerWithIdentifier:@"container1VC"];
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)myfavorite{
    NSLog(@"my favorite pressed!");
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSArray *temp=[defaults objectForKey:@"FavoriteList"];
    
    
    if (temp.count==0) {
        NSString *err = @"您尚未選擇任何商品";
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:err delegate:self cancelButtonTitle:@"關閉" otherButtonTitles:nil];
//        [alert show];
//        return;
    }else{
        UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Compare" bundle:nil];
        MyFavoriteViewController *vc=[storyBoard instantiateViewControllerWithIdentifier:@"MFVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

@end
