//
//  CompareTableViewCell.h
//  HolaApp
//
//  Created by Joseph on 2015/3/20.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompareTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *onlinePrice;
@property (weak, nonatomic) IBOutlet UIView *cellView;

@end
