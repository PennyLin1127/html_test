//
//  LatestCatalogueCollectionViewCell.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "LatestCatalogueCollectionViewCell.h"

@implementation LatestCatalogueCollectionViewCell
-(void)awakeFromNib {

    self.scorllView.delegate = self;
}
-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.asyncImageView;
}
@end
