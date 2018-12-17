//
//  ProductListTableViewCell.h
//  HolaApp
//
//  Created by Joseph on 2015/3/10.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ProductListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *prdNameLabel1;
@property (weak, nonatomic) IBOutlet AsyncImageView *prdImge1;
@property (weak, nonatomic) IBOutlet UILabel *origPriceLabel1;
@property (weak, nonatomic) IBOutlet UILabel *salePriceLabel1;
// 白色圓角的view
@property (weak, nonatomic) IBOutlet UIView *cellView;


@property (weak, nonatomic) IBOutlet UIButton *clickButton;

@end
