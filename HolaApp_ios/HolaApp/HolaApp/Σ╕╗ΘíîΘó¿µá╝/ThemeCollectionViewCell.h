//
//  ThemeCollectionViewCell.h
//  HOLA
//
//  Created by Joseph on 2015/4/28.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ThemeCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet AsyncImageView *prdImge;
@property (weak, nonatomic) IBOutlet UILabel *prdNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *origPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@end
