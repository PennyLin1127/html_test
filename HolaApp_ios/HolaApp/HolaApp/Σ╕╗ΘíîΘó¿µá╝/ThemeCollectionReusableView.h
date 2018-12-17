//
//  ThemeCollectionReusableView.h
//  HOLA
//
//  Created by Joseph on 2015/4/28.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ThemeCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet AsyncImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchMore;

@end
