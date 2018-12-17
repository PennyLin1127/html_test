//
//  SettingsTableViewCell.h
//  HOLA
//
//  Created by Joseph on 2015/9/30.
//  Copyright © 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lableStrr;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLablee;
@property (weak, nonatomic) IBOutlet UIButton *arrowButtonn;
@property (weak, nonatomic) IBOutlet UILabel *versionLablee;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sectionCell0HeightConss;
@property (weak, nonatomic) IBOutlet UIButton *onoffButton;

@end
