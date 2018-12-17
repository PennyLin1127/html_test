//
//  CompareCollectionViewCell.h
//  HolaApp
//
//  Created by Joseph on 2015/3/17.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompareCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *prdImg;
@property (weak, nonatomic) IBOutlet UILabel *prdName;

@property (weak, nonatomic) IBOutlet UITextView *prdFeature;

@property (weak, nonatomic) IBOutlet UILabel *heigh;
@property (weak, nonatomic) IBOutlet UILabel *width;
@property (weak, nonatomic) IBOutlet UILabel *deep;




@property (weak, nonatomic) IBOutlet UILabel *origPrice;
@property (weak, nonatomic) IBOutlet UILabel *salePrice;

@property (weak, nonatomic) IBOutlet UIButton *btnO2oCouponAvailable;

@property (weak, nonatomic) IBOutlet UILabel *btnPriceTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnPriceOutline;
@property (weak, nonatomic) IBOutlet UIButton *MyfavoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *outLine;
@property (weak, nonatomic) IBOutlet UIButton *addCarts;

// for iphone 4 constriant
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeightcons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeLableHeightCons;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeHightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeWidthCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeDeepCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeLabelGapHeighCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeLabelGapHeigh2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deepGapCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthCap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *salePriceGap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myFavoriteGap;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *myFavoriteButtonHeighCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *couponHeightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *framHeightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *justGap;

@end
