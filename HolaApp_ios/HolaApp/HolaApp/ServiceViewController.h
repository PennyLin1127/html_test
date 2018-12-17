//
//  ServiceViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//



#import <UIKit/UIKit.h>
@protocol ServiceViewControllerDelegate <NSObject>

-(void)suceccToAskQuestion:(NSDictionary*)dic;

@end

@interface ServiceViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, UITextFieldDelegate, UITextViewDelegate>

-(void) getData;

-(void)closeInput;

@property (nonatomic) id<ServiceViewControllerDelegate> delegate;

//@property (nonatomic) BOOL needToGetData;

@end
