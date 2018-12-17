//
//  ProductAPILoader.m
//  HOLA
//
//  Created by Henry on 2015/5/2.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "ProductAPILoader.h"
#import "SessionID.h"
#import "GetAndPostAPI.h"
#import "URLib.h"
#import "CatagoryInfoData.h"
#import "NSDefaultArea.h"
#import "ProductListCollectionViewController.h"
#import "IHouseURLManager.h"
#import "ProductListTableViewController.h"

@interface ProductAPILoader()
-(void) retrieveFromAPI:(NSObject *)data page:(NSInteger)page;
@end

@implementation ProductAPILoader {
    GetAndPostAPI *getAndPostAPI;
    
    ProductAPIType _productAPIType;
    NSObject *_data;
    NSString *_sortColumn;
    SortOrder _sortOrder;
}

-(void)loadMore {
    _currentPage++;
    [self retrieveFromAPI:_data page:_currentPage];
}

//由api讀取產品列表資料
-(void)loadData :(ProductAPIType)productApiType data:(NSObject *)data sortColumn:(NSString *)sortColumn sort:(SortOrder)sort clearAll:(BOOL)clearAll {
 
    _productAPIType = productApiType;
    _data = data;
    _sortColumn = sortColumn;
    _sortOrder = sort;
    
    if (clearAll == YES) {
        if (self.productList != nil) {
            self.productList = nil;
        }
    }
    
    if (self.productList == nil || clearAll == YES) {
        self.productList = [NSMutableArray new];
        self.categorys = [NSMutableArray new];
    }
    
    [self retrieveFromAPI: data page:self.currentPage];
}

-(void)retrieveFromAPI: (NSObject *)data page:(NSInteger)page {

    __weak ProductAPILoader *this = self;
    
    getAndPostAPI = [GetAndPostAPI new];
    
    //回傳成功Block
    getAndPostAPI.loadCompletionBlock = ^(BOOL success, NSDictionary *dictData){
        BOOL status = [[dictData objectForKey:@"status"] integerValue];
        if (status == NO) {
            this.loadErrorBlock(@"查詢錯誤!");
        } else {
            NSArray *productDictList = nil;
            NSArray *productCatagory = nil;
            
            if (_productAPIType == ProductByCategoryID) {
#warning 測試版多了一個prdList key , 正式版沒有這欄位
//                productDictList = [[dictData objectForKey:@"data"]objectForKey:@"prdList"];
//                
//                if (productDictList != nil) {
//                    for (NSDictionary *dictProduct in productDictList) {
//                        ProductInfoData *product = [ProductInfoData initWithDictionary:dictProduct];
//                        [this.productList addObject:product];
//                    }
//                    if ([this.productList count]>0) {
//                        _totalCount = [productDictList count];
//                        _totalPage = 1;
//                        _currentPage = 1;
//                    } else {
//                        _totalCount = 0;
//                        _totalPage = 0;
//                        _currentPage = 0;
//                    }
                productDictList = [[dictData objectForKey:@"data"]objectForKey:@"prdList"];
                if (productDictList == nil) {
                    NSLog(@"productDictList -- is nil");
                }else{
                    for (NSDictionary *dictProduct in productDictList) {
                        ProductInfoData *product=[ProductInfoData initWithDictionary:dictProduct];
                        [this.productList addObject:product];
                    }
                    
                    _currentPage = [[[dictData objectForKey:@"data"] objectForKey:@"page"] integerValue];
                    _totalPage = [[[dictData objectForKey:@"data"] objectForKey:@"totalPage"] integerValue];
                    
                    if (_currentPage == 0) {
                        _currentPage = _currentPage + 1;
                    }
                    
                    NSLog(@"current page is %ld",(long)this.currentPage);
                    NSLog(@"total page is %ld",(long)this.totalPage);
                    
                    if ([ProductListCollectionViewController class]) {
                        ProductListCollectionViewController *productListCollectionVC= [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProductListCollectionViewController"];
                        productListCollectionVC.currentPage=this.currentPage;
                        productListCollectionVC.totalPage=this.totalPage;
                        
                    }else if ([ProductListTableViewController class]) {
                        ProductListTableViewController *productListVC= [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProductListTableViewController"];
                        productListVC.currentPage=this.currentPage;
                        productListVC.totalPage=this.totalPage;
                    }
                }
            } else if (_productAPIType == ProductBySKU) {
                productDictList = [dictData objectForKey:@"data"];
                NSLog(@"productDictList :%ld",[productDictList count]);
                if (productDictList != nil) {
                    for (NSDictionary *dictProduct in productDictList) {
                        ProductInfoData *product = [ProductInfoData initWithDictionary:dictProduct];
                        if (product.onShelf) {
                            [this.productList addObject:product];
                        }
                    }
                    if ([this.productList count]>0) {
                        _totalCount = [productDictList count];
                        _totalPage = 1;
                        _currentPage = 1;
                    } else {
                        _totalCount = 0;
                        _totalPage = 0;
                        _currentPage = 0;
                    }
                }
            } else if (_productAPIType == ProductByKeyword) {
                
    
                _totalCount = [[[dictData objectForKey:@"data"] objectForKey:@"totalCount"] integerValue];
                _currentPage = [[[dictData objectForKey:@"data"] objectForKey:@"page"] integerValue];
                _totalPage = [[[dictData objectForKey:@"data"] objectForKey:@"totalPage"] integerValue];
                
                
                
                ProductListCollectionViewController *productListCollectionViewController= [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProductListCollectionViewController"];
                productListCollectionViewController.currentPage=this.currentPage;
                productListCollectionViewController.totalPage=this.totalPage;

                
                productDictList = [[dictData objectForKey:@"data"] objectForKey:@"prdList"];
                if (productDictList != nil) {
                    for (NSDictionary *dictProduct in productDictList) {
                        ProductInfoData *product = [ProductInfoData initWithDictionary:dictProduct];
                        [this.productList addObject:product];
                    }
                }
                
                productCatagory =[[dictData objectForKey:@"data"]objectForKey:@"categorys"];
                if (productCatagory !=nil) {
                    for (NSDictionary *dictCatogory in productCatagory) {
                        CatagoryInfoData *catogory = [[CatagoryInfoData alloc]initWithCategorysDic:dictCatogory];
                        [this.categorys addObject:catogory];
                    }
                }
            
                
            }
            
            else if (_productAPIType == ProductByPrdIds) {
                productDictList = [dictData objectForKey:@"data"];
                if (productDictList != nil) {
                    for (NSDictionary *dictProduct in productDictList) {
                        ProductInfoData *product = [ProductInfoData initWithDictionary:dictProduct];
                        [this.productList addObject:product];
                    }
                    if ([this.productList count]>0) {
                        _totalCount = [productDictList count];
                        _totalPage = 1;
                        _currentPage = 1;
                    } else {
                        _totalCount = 0;
                        _totalPage = 0;
                        _currentPage = 0;
                    }
                }
            }

            this.loadCompletionBlock(YES, this.totalCount, this.productList,this.categorys, (_currentPage<_totalPage)?YES:NO);
        }
    };
    getAndPostAPI.loadErrorBlock = ^(NSString *message) {
        this.loadErrorBlock(message);
    };
    
    //傳sessionID,categoryId
    NSDictionary *dictData = nil;
    
    //非同步呼叫
    if (_productAPIType == ProductByCategoryID) {
        dictData = @{@"sessionID": [SessionID getSessionID],@"categoryId":data, @"page":[NSString stringWithFormat:@"%ld",(long)self.currentPage]};
        NSString *holaURL = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:@""]];
        [getAndPostAPI asyncPostData:holaURL path:HOLA_PRODUCTMENU_PATH dicBody:dictData];
    } else if (_productAPIType == ProductBySKU) {
        NSLog(@"skusku!");
        dictData = @{@"sessionID": [SessionID getSessionID],@"skus":data};
        NSString *holaURL = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:@""]];
        [getAndPostAPI asyncPostData:holaURL path:HOLA_PRODUCTCOMPARE_PATH dicBody:dictData];
    } else if (_productAPIType == ProductByKeyword)
    
    {
        dictData = @{@"sessionID": [SessionID getSessionID] , @"keyword":data, @"page": [NSString stringWithFormat:@"%ld",self.currentPage] ,@"sortColumn":[[NSDefaultArea GetFilterConditionTagFromUserDefault]objectForKey:@"filterCondition"],@"sortOrder":[[NSDefaultArea GetAscOrDscTagFromUserDefault]objectForKey:@"ascOrDesc"],@"categoryId":[NSDefaultArea GetParentCategoryIdFromUserDefault]};
        NSLog(@"load ProductByKeyword");
        NSString *holaURL = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:@""]];
        [getAndPostAPI asyncPostData:holaURL path:HOLA_PRODUCTSEARCH_PATH dicBody:dictData];
        
        
    }else if (_productAPIType == ProductByPrdIds) {
        NSLog(@"PrdIds!");
        dictData = @{@"sessionID": [SessionID getSessionID],@"prdIds":data};
        NSString *holaURL = [NSString stringWithFormat:@"%@", [IHouseURLManager getURLByAppName:@""]];
        [getAndPostAPI asyncPostData:holaURL path:HOLA_PRODUCTCOMPARE_PATH dicBody:dictData];
    }

}


@end
