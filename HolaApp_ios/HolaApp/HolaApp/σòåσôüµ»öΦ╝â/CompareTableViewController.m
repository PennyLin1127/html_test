//
//  CompareTableViewController.m
//  HolaApp
//
//  Created by Joseph on 2015/3/20.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "CompareTableViewController.h"
#import "NSDefaultArea.h"
#import "CompareTableViewCell.h"
#import "ProductInfoData.h"
#import "AsyncImageView.h"
#import "URLib.h"

@interface CompareTableViewController ()<UITableViewDataSource,UITableViewDelegate>
{

}

@end

@implementation CompareTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //註冊 CompareTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:@"CompareTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell Identifier"];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
    
    self.productMuArray1=[[NSMutableArray alloc]initWithArray:self.productList];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateProductList:(NSArray *)productList {
    self.productList = productList;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.productList != nil) {
        return [self.productList count];
    }
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{   //contect view 高度這邊設105 背景與背景色一樣 , 裡面的cellView 高度設95,白色圓角
    return 105;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{   //設定footer高度
    return 40;
}


- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    //設定footerView 顏色
    view.tintColor = [UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{   // 因有上層有title高度，所以微調header高度
    return 15.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{   // 加一個透明view到 header
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor =[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f];
    return headerView;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kIdentifier = @"Cell Identifier";
    CompareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier forIndexPath:indexPath];
    
    
    // cell 外觀
    [cell.cellView.layer setCornerRadius:10.0f];
    [self.tableView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f]];
    
    
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:246.0/255.0 blue:240.0/255.0 alpha:1.0f]];
    
    if ([self.productList count]>0) {
        
        ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];

        
        cell.productName.text = product.prdName;
        cell.price.text=[NSString stringWithFormat:@"售價$ %ld",product.origPrice];
        cell.onlinePrice.text=[NSString stringWithFormat:@"網購價$ %ld",product.salePrice];
        
        NSURL *url1 =nil;
        cell.productImage.imageURL = url1;
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.productImage.imageURL];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOLA_PIC_URL_STR, product.prdImg]];
        [cell.productImage setImageURL:url];


    }
    
    return cell;
}



#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];
//    [product delete:product.prdName];
//
//    
    
    [self.compareCollectionViewController.prdNameDataArray removeObjectAtIndex:indexPath.row];
    [self.compareCollectionViewController.origPriceDataArray removeObjectAtIndex:indexPath.row];
    [self.compareCollectionViewController.salePriceDataArray removeObjectAtIndex:indexPath.row];
    [self.compareCollectionViewController.prdImgDataArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - long press action
- (IBAction)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
//                ProductInfoData *product = [self.productList objectAtIndex:indexPath.row];
                
                NSLog(@"change 123");
                [self.productMuArray1 exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                
                // 從tableView裡變換了順序，要在下面做 update data source順序
                [self.compareCollectionViewController.prdNameDataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                [self.compareCollectionViewController.origPriceDataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                [self.compareCollectionViewController.salePriceDataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                [self.compareCollectionViewController.prdImgDataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                //                [self.compareCollectionViewController.prdFeatureDataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                [self.compareCollectionViewController.prdHeight exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                [self.compareCollectionViewController.prdWidth exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                
                [self.compareCollectionViewController.prdDepth exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                
                [self.compareCollectionViewController.btnO2oCouponAvailableArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                [self.compareCollectionViewController.btnO2oCouponDiscountPrice exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                [self.compareCollectionViewController.myFavoriteTag exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // o2o url -> open webView
                [self.compareCollectionViewController.urlArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [NSDefaultArea btoURLArrayToUserDefault:self.compareCollectionViewController.urlArray];
                
                // go to product detail
                [self.compareCollectionViewController.prdIdDataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                [self.compareCollectionViewController.prdIdForProductDetail1 setObject:self.compareCollectionViewController.prdIdDataArray[indexPath.row] forKey:@"prdId"];
//                [NSDefaultArea prdIdToUserDefault1:self.compareCollectionViewController.prdIdForProductDetail1];
                
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            
            break;
        }
    }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}


@end
