//
//  LatestCatalogueViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CatalogueContainerViewController.h"
#import "NavigationViewController.h"
@interface LatestCatalogueViewController : NavigationViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSDictionary *dicData; // 個別的型錄資料
@property (nonatomic, strong) CatalogueContainerViewController *parentVC;

-(void) getData:(NSInteger)page;
-(void) getFirstData;


@end
