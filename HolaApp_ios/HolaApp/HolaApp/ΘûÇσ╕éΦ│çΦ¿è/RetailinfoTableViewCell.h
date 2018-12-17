//
//  RetailinfoTableViewCell.h
//  HolaApp
//
//  Created by Joseph on 2015/4/13.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RetailinfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *openTime;

@property (weak, nonatomic) IBOutlet UIButton *openLINE;
@property (weak, nonatomic) IBOutlet UIButton *reviewMap;

@property (weak, nonatomic) IBOutlet UILabel *openTimeStrLabel;
@property (weak, nonatomic) IBOutlet UIButton *telButton;

@end
