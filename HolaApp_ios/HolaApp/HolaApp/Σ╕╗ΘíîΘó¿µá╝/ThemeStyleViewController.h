//
//  ThemeStyleViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/2/12.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"
#import "NavigationViewController.h"

// follow 第三方瀑布牆 CHT delegate
@interface ThemeStyleViewController : NavigationViewController<UICollectionViewDataSource,UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout,NSURLConnectionDataDelegate>

@property (nonatomic) NSInteger themeID;
@property (strong,nonatomic) UICollectionView *collectionView;

// 存主題風格(圖,文)
@property (strong,nonatomic) NSMutableArray *themeDataSourceArray;

// 存圖片
@property (strong,nonatomic)NSMutableArray *picArray;


@end
