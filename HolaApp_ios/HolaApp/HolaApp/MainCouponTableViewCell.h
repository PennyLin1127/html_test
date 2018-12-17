//
//  MainCouponTableViewCell.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/13.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface MainCouponTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *asyncImageView;
@property (weak, nonatomic) IBOutlet UILabel *couponNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *buttonNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *couponButton;


@end
