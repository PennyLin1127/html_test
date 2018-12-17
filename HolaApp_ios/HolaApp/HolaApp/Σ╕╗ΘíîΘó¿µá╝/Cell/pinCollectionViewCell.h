//
//  pinCollectionViewCell.h
//  pinCollection
//
//  Created by Joseph on 2015/2/8.
//  Copyright (c) 2015年 dosomethingq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface pinCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *showImageView1;
@property (weak, nonatomic) IBOutlet UILabel *showLable1;
@property (weak, nonatomic) IBOutlet UILabel *showSecondLabel;

@end
