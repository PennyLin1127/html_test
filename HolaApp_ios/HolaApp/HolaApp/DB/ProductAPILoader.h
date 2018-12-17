//
//  ProductAPILoader.h
//  HOLA
//
//  Created by Henry on 2015/5/2.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductInfoData.h"

typedef enum {
    ProductByCategoryID,
    ProductBySKU,
    ProductByKeyword,
    ProductByPrdIds
} ProductAPIType;

typedef enum {
    SortOrderASC,
    SortOrderDESC,
    SortOrderNotSet
    
} SortOrder;

@interface ProductAPILoader : NSObject



//由api回傳產品列表資料
typedef void (^LoadCompletionBlock)(BOOL success, NSInteger totalCount, NSArray *productList,NSArray *catogorys, BOOL hasMore);
typedef void (^LoadErrorBlock)(NSString *message);
@property (strong) LoadCompletionBlock loadCompletionBlock;
@property (strong) LoadErrorBlock loadErrorBlock;

//產品清單
@property (nonatomic,strong) NSMutableArray *productList;

@property (nonatomic,strong) NSMutableArray *categorys;


//總頁面
@property (nonatomic) NSInteger totalPage;

//目前頁面
@property (nonatomic) NSInteger currentPage;

//總產品數量
@property (nonatomic) NSInteger totalCount;

//由api讀取產品列表資料
-(void)loadData :(ProductAPIType)productApiType data:(NSObject *)data sortColumn:(NSString *)sortColumn sort:(SortOrder)sort clearAll:(BOOL)clearAll;
-(void)loadMore;


@end
