//
//  LatestListCollectionVCell.h
//  HOLA
//
//  Created by Howard Lui on 2015/9/30.
//  Copyright © 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface LatestListCollectionVCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *asyncImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
