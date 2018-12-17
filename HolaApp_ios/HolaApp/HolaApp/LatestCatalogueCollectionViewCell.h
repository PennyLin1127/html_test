//
//  LatestCatalogueCollectionViewCell.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@interface LatestCatalogueCollectionViewCell : UICollectionViewCell<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scorllView;
@property (weak, nonatomic) IBOutlet AsyncImageView *asyncImageView;

@end
