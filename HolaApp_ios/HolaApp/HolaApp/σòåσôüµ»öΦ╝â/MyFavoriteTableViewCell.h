//
//  MyFavoriteTableViewCell.h
//  HolaApp
//
//  Created by Joseph on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface MyFavoriteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet AsyncImageView *prdImage;
@property (weak, nonatomic) IBOutlet UILabel *prdName;
@property (weak, nonatomic) IBOutlet UILabel *salePrice;
@property (weak, nonatomic) IBOutlet UILabel *o2oPrice;
@property (weak, nonatomic) IBOutlet UIButton *o2oCoupon;
@property (weak, nonatomic) IBOutlet UIButton *webShopping;
@property (weak, nonatomic) IBOutlet UIButton *removeList;

@end
