//
//  Model.m
//  HolaApp
//
//  Created by Joseph on 2015/3/26.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "Model.h"
#import <UIKit/UIKit.h>
#import "NSDefaultArea.h"

@implementation Model



#pragma mark - 加入追蹤清單Favorite
/**
 加入追蹤清單 並排除重複
 @param productId:產品Id
 @returns void
 @exception nil
 */
+(void)addToFavoriteList:(NSArray*)productIdArray {
    
    //排除資料
    if (productIdArray == nil || productIdArray.count == 0) {
        
        UIAlertView *av=[[UIAlertView alloc]initWithTitle:@"" message:@"最少選擇一件商品" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        
        [av show];
        return;
    }
    
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSString *item in productIdArray) {

//        if (item == nil || [item isEqualToString:@""]) {
//            continue;
//        }
//        
        [array addObject:item];
    }


    
    
    //取出先前的資料
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tempArray = [[userDefaults objectForKey:@"FavoriteList"] mutableCopy];
    
    NSLog(@"先前的追蹤清單 -- %@", tempArray);
    
    //放到Set
    NSMutableSet *set = [[NSMutableSet alloc] initWithArray:tempArray];
    [set addObjectsFromArray:array];
    //Set轉Aray
    NSMutableArray *saveArray = [[set allObjects] mutableCopy];
    NSLog(@"準備儲存的清單 -- %@", saveArray);

    /*
    //改成按順序加入
    NSMutableArray *saveArray = [[NSMutableArray alloc] init];
    
    for (NSString *str in array) {
        BOOL canAddToArray = YES;
        for (NSString *oldStr in tempArray) {
            if ([oldStr isEqualToString:str]) {
                canAddToArray = NO;
                break;
            }
        }
        
        if (canAddToArray == YES) {
            [saveArray addObject:str];
        }
    }
    
    NSLog(@"準備儲存的清單 -- %@", saveArray);
    */
    
    //儲存
    [userDefaults setObject:saveArray forKey:@"FavoriteList"];
    [userDefaults synchronize];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"已儲存至收藏清單" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
    [alert show];

}


@end
