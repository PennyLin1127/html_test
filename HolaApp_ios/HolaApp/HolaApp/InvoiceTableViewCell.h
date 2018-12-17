//
//  InvoiceTableViewCell.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/30.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvoiceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *invoiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *winButton;
@property (weak, nonatomic) IBOutlet UILabel *winLabel;

@end
