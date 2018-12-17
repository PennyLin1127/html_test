//
//  RecommendCollectionViewCell.h
//  HolaApp
//
//  Created by Joseph on 2015/3/25.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *RImage;
@property (weak, nonatomic) IBOutlet UILabel *RName;
@property (weak, nonatomic) IBOutlet UILabel *RPrice;
@property (weak, nonatomic) IBOutlet UIView *cellBackGroungView;

@end
