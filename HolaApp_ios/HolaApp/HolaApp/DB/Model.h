//
//  Model.h
//  HolaApp
//
//  Created by Joseph on 2015/3/26.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

#pragma mark - 加入追蹤清單Favorite
+(void)addToFavoriteList:(NSArray*)productIdArray;

@end
