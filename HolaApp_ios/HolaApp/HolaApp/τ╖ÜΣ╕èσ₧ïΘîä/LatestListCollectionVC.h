//
//  LatestListCollectionVC.h
//  HOLA
//
//  Created by Howard Lui on 2015/9/30.
//  Copyright © 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
#import "CatalogueContainerViewController.h"

@interface LatestListCollectionVC : NavigationViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) CatalogueContainerViewController *parentVC;

@property (nonatomic) CGRect viewRect;
@property (nonatomic) CGRect cellRect;

@property (nonatomic, strong) NSDictionary *dicData;

-(void)getData:(NSInteger)page;
-(void)getFirstData;
//-(void) getAllData;

@end
