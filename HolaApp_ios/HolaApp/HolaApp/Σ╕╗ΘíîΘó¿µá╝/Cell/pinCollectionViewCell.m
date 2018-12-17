//
//  pinCollectionViewCell.m
//  pinCollection
//
//  Created by Joseph on 2015/2/8.
//  Copyright (c) 2015年 dosomethingq. All rights reserved.
//

#import "pinCollectionViewCell.h"


@implementation pinCollectionViewCell


- (void)awakeFromNib {
    // Initialization code
}



- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        
        NSString *xibName = @"pinCollectionViewCell";
        NSArray *arrayOfCellView = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
        
        self = [arrayOfCellView objectAtIndex:0];

        // init imageView
        _showImageView1= [UIImageView new];
        _showImageView1.contentMode = UIViewContentModeScaleAspectFill;

        CGRect imageViewFrame = CGRectMake(0.f, 0.f, CGRectGetMaxX(self.contentView.bounds), CGRectGetMaxY(self.contentView.bounds)*0.6);
        _showImageView1.frame = imageViewFrame;
        _showImageView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _showImageView1.clipsToBounds = YES;
        
        
//        CGRect labelFrame = CGRectMake(0.f, 0.f ,self.contentView.bounds.size.width ,self.contentView.bounds.size.height/3.0f);
//        _showLable1.frame=labelFrame;
    
        [self.contentView addSubview:_showImageView1];
        [self.contentView addSubview:_showLable1];
        [self.contentView addSubview:_showSecondLabel];

        
    }
    return self;

}

@end
