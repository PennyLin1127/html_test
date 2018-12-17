//
//  MyFavoriteViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/3/27.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//  2015-05-01 Henry 既然有ProductInfoData物件, 為何要將資料分開存放再Array?
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"


@interface MyFavoriteViewController : NavigationViewController

@property (weak, nonatomic) IBOutlet UIButton *scrolToTop;

// for delete tag for tableView update
@property (assign,nonatomic) BOOL delete;
// for delete indexTag for tableView update(indexPath.row)
@property (assign,nonatomic) NSInteger indexTag;

@end
