//
//  MessageViewController.h
//  HOLA
//
//  Created by Jimmy Liu on 2015/4/20.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"

typedef enum {
    commonMessage,
    personalMessage
    
}noDataOrNot;


@interface MessageViewController : NavigationViewController <UITableViewDataSource, UITableViewDelegate>

@end
