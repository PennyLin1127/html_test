//
//  ServiceNotLoginViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/6.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServiceNotLoginViewControllerDelegate <NSObject>

-(void)suceccToAskQuestionNotMember:(NSDictionary*)dic;

@end

@interface ServiceNotLoginViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate>

-(void) getData;

@property (nonatomic) id<ServiceNotLoginViewControllerDelegate> delegate;


@end
