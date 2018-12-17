//
//  CatalogueListViewController.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/9.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CatalogueContainerViewController.h"
#import "NavigationViewController.h"

@interface CatalogueListViewController : NavigationViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) CatalogueContainerViewController *parentVC;

@property (nonatomic) CGRect viewRect;
@property (nonatomic) CGRect cellRect;


@end
