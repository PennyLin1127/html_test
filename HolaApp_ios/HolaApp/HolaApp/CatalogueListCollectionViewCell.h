//
//  CatalogueListCollectionViewCell.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface CatalogueListCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *asyncImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
