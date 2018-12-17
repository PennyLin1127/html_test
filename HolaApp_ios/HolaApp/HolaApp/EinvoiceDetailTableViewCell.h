//
//  EinvoiceDetailTableViewCell.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/31.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EinvoiceDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *prdNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTotalLabel;

@end
