//
//  NSDefaultArea.h
//  HolaApp
//
//  Created by Joseph on 2015/2/26.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDefaultArea : NSObject

#pragma mark - For list API callling
//Save  ProductListToUserDefault
+(void) productListToUserDefault:(NSArray*)list;
//Get   ProductListFromUserDefault
+(NSArray*)GetProductListFromUserDefault;

////Save and get sub2Title
//+(void) sub2TitleToUserDefault:(NSDictionary*)sub2Title;
//+(NSDictionary*)GetSub2TitleFromUserDefault;

#pragma mark - For menu API callling
//Save  categoryId to user default
//+(void) categoryIdToUserDefault:(NSArray*)categoryID;
//Get   categoryId from user default
//+(NSArray*)GetCategoryIdFromUserDefault;

#pragma mark - For compare API callling
//Save  選擇的 prdIds to user default
+(void) prdIdsToUserDefault:(NSArray*)prdIds;
//Get   選擇的 prdIds from user default
+(NSArray*)GetprdIdsFromUserDefault;

////Save  prdImag to user default
//+(void) prdImagToUserDefault:(NSArray*)prdImag;
////Get   prdImag from user default
//+(NSArray*)GetPrdImagFromUserDefault;

////Save  prdName to user default
//+(void) prdNameToUserDefault:(NSArray*)prdName;
////Get   prdName from user default
//+(NSArray*)GetPrdNameFromUserDefault;


#pragma mark - For product detail content API callling
//2015-05-01 Henry 以下傳遞參數應該透過物件屬性，而非單例暫存

////Save  單一 prdId to user default
//+(void) prdIdToUserDefault1:(NSDictionary*)prdId;
////Get   單一 prdId from user default
//+(NSDictionary*)GetPrdIdFromUserDefault1;

//Save  btoURL to user default
+(void) btoURLToUserDefault:(NSDictionary*)btoURL;
//Get   btoURL from user default
+(NSDictionary*)GetBtoURLFromUserDefault;


#pragma mark - For compareCollectionView use
//Save  btoURLArray to user default
+(void) btoURLArrayToUserDefault:(NSArray*)btoURL;
//Get   btoURLArray from user default
+(NSArray*)GetBtoURLArrayFromUserDefault;


#pragma mark - For search API callling
//Save and get keyword from user default
+(void) keywordToUserDefault:(NSDictionary*)keyword;
+(NSDictionary*)GetKeywordFromUserDefault;

//Save and get ViewKeyword from user default
+(void) whichViewKeywordToUserDefault:(NSDictionary*)viewKeyword;
+(NSDictionary*)GetWhichViewKeywordFromUserDefault;

//Save and get clearArrayTag from user default
+(void) clearArrayTagToUserDefault:(NSDictionary*)viewKeyword;
+(NSDictionary*)GetClearArrayTagFromUserDefault;

//Save and get filter condition
+(void) filterConditionToUserDefault:(NSDictionary*)filterCondition;
+(NSDictionary*)GetFilterConditionTagFromUserDefault;

//Save and get asc or dsc tag
+(void) ascOrDscTagToUserDefault:(NSDictionary*)filterCondition;
+(NSDictionary*)GetAscOrDscTagFromUserDefault;

//Save and get parentCategoryId
+(void) parentCategoryIdToUserDefault:(NSString*)parentCategoryId;
+(NSString*)GetParentCategoryIdFromUserDefault;

//Save and get searchKeywords
+(void) searchKeywordsToUserDefault:(NSArray*)searchKeywords;
+(NSArray*)GetSearchKeywordsFromUserDefault;


#pragma mark - For theme SQL
//// Save and get themeID
//+(void) themeIDToUserDefault:(NSDictionary*)themeID;
//+(NSDictionary*)GetThemeIDFromUserDefault;

//// Save and get vchSKU
//+(void) vchSKUToUserDefault:(NSArray*)vchSKU;
//+(NSArray*)GetVchSKUFromUserDefault;

// Save and get intCategoryID
+(void) intCategoryIDToUserDefault:(NSString*)intCategoryID;
+(NSString*)GetIntCategoryIDFromUserDefault;


@end