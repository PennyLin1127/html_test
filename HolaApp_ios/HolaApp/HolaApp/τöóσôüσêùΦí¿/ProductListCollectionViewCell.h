//
//  ProductListCollectionViewCell.h
//  HolaApp
//
//  Created by Joseph on 2015/3/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ProductListCollectionViewCell : UICollectionViewCell

// setting product list outlet information in cell
@property (weak, nonatomic) IBOutlet UILabel *prdNameLabel;
@property (weak, nonatomic) IBOutlet AsyncImageView *prdImge;
@property (weak, nonatomic) IBOutlet UILabel *origPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *salePriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@end
