//
//  PhoneValidationOfViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/18.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneValidationViewController.h"

//@interface PhoneValidationOfViewController : UIViewController

//繼承iHouse PhoneValidationViewController
@interface PhoneValidationOfViewController : PhoneValidationViewController



// 還沒加@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraint;
// 還沒加@property (weak, nonatomic) IBOutlet UIView *topContainerView;

// for view height constraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewConstraint;

@end
