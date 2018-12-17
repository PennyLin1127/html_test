//
//  NSDefaultArea.m
//  HolaApp
//
//  Created by Joseph on 2015/2/26.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "NSDefaultArea.h"

@implementation NSDefaultArea

#pragma mark - Save productListToUserDefault
+(void) productListToUserDefault:(NSArray*)list{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:list forKey:@"productList"];
    [userDefaults synchronize];
}


#pragma mark - Get ProductListFromUserDefault
+(NSArray*) GetProductListFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSArray *result=[userDefaults objectForKey:@"productList"];
    
    return result;
}

#pragma mark - Save categoryIdToUserDefault
+(void) categoryIdToUserDefault:(NSArray*)categoryID{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:categoryID forKey:@"categoryId"];
    [userDefaults synchronize];
}


#pragma mark - Get categoryIdFromUserDefault
+(NSArray*) GetCategoryIdFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray *result=[userDefaults objectForKey:@"categoryId"];
    return result;
}



#pragma mark - Save 選擇的 prdIds to user default for compare API calling
+(void) prdIdsToUserDefault:(NSArray*)prdIds{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:prdIds forKey:@"prdIds"];
    [userDefaults synchronize];
}


#pragma mark - Get 選擇的 prdIds from user default
+(NSArray*)GetprdIdsFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray *result=[userDefaults objectForKey:@"prdIds"];
    return result;
}

//#pragma mark - Save  prdImag to user default for compare API calling
//+(void) prdImagToUserDefault:(NSArray*)prdImag{
//    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:prdImag forKey:@"prdImags"];
//    [userDefaults synchronize];
//}
//
//#pragma mark - Get   prdImag from user default
//+(NSArray*)GetPrdImagFromUserDefault{
//    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
//    NSArray *result=[userDefaults objectForKey:@"prdImags"];
//    return result;
//}


#pragma mark - Save  prdName to user default for compare API calling
+(void) prdNameToUserDefault:(NSArray*)prdName{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:prdName forKey:@"prdName"];
    [userDefaults synchronize];
}

#pragma mark - Get   prdName from user default
+(NSArray*)GetPrdNameFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray *result=[userDefaults objectForKey:@"prdName"];
    return result;
}


#pragma mark - Save  單一 prdId to user default for product detail API calling
+(void) prdIdToUserDefault1:(NSDictionary*)prdId{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:prdId forKey:@"prdId"];
    [userDefaults synchronize];
}

#pragma mark - Get  單一 prdId from user default
+(NSDictionary*)GetPrdIdFromUserDefault1{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *result=[userDefaults objectForKey:@"prdId"];
    return result;
}


#pragma mark - Save  sub2Title name
+(void) sub2TitleToUserDefault:(NSDictionary*)sub2Title{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:sub2Title forKey:@"sub2Title"];
    [userDefaults synchronize];
}

#pragma mark - Get   sub2Title name from user default
+(NSDictionary*)GetSub2TitleFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *result=[userDefaults objectForKey:@"sub2Title"];
    return result;
}


#pragma mark - Save  btoURL to user default for product content API calling
+(void) btoURLToUserDefault:(NSDictionary*)btoURL{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:btoURL forKey:@"btoURL"];
    [userDefaults synchronize];
}

#pragma mark - Get   btoURL from user default
+(NSDictionary*)GetBtoURLFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *result=[userDefaults objectForKey:@"btoURL"];
    return result;
}

#pragma mark - Save  btoURLArray to user default for compareCollectionView use
+(void) btoURLArrayToUserDefault:(NSArray*)btoURL{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:btoURL forKey:@"btoURLArray"];
    [userDefaults synchronize];
}
#pragma mark - Get   btoURLArray from user default
+(NSArray*)GetBtoURLArrayFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray *result=[userDefaults objectForKey:@"btoURLArray"];
    return result;
}


#pragma mark - Save  Keyword to user default for goods/index search API calling
+(void) keywordToUserDefault:(NSDictionary*)keyword{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:keyword forKey:@"keyword"];
    [userDefaults synchronize];
}

#pragma mark - Get   Keyword from user default
+(NSDictionary*)GetKeywordFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *result=[userDefaults objectForKey:@"keyword"];
    return result;
}


#pragma mark - Save  search or product list keyword to user default for goods/index search or product list API calling
+(void) whichViewKeywordToUserDefault:(NSDictionary*)viewKeyword{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:viewKeyword forKey:@"viewKeyword"];
    [userDefaults synchronize];
}

#pragma mark - Get   search or product list keyword from user default
+(NSDictionary*)GetWhichViewKeywordFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *result=[userDefaults objectForKey:@"viewKeyword"];
    return result;
}


#pragma mark - Save  clearArrayTag to user default for goods/index search API calling
+(void) clearArrayTagToUserDefault:(NSDictionary*)viewKeyword{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:viewKeyword forKey:@"clearArrayTag"];
    [userDefaults synchronize];
}

#pragma mark - Get   clearArrayTag from user default
+(NSDictionary*)GetClearArrayTagFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *result=[userDefaults objectForKey:@"clearArrayTag"];
    return result;
}



#pragma mark - Save  filterConditionKeyword to user default for goods/index search API calling
+(void) filterConditionToUserDefault:(NSDictionary*)filterCondition{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:filterCondition forKey:@"filterCondition"];
    [userDefaults synchronize];
}

#pragma mark - Get   filterConditionKeyword from user default
+(NSDictionary*)GetFilterConditionTagFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *result=[userDefaults objectForKey:@"filterCondition"];
    return result;
}

#pragma mark - Save  ascOrDscKeyword to user default for goods/index search API calling
+(void) ascOrDscTagToUserDefault:(NSDictionary*)filterCondition{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:filterCondition forKey:@"ascOrDesc"];
    [userDefaults synchronize];
}

#pragma mark - Get   ascOrDscKeyword from user default
+(NSDictionary*)GetAscOrDscTagFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *result=[userDefaults objectForKey:@"ascOrDesc"];
    return result;
}


#pragma mark - Save  parentCategoryId to user default for goods/index search API calling
+(void) parentCategoryIdToUserDefault:(NSString*)parentCategoryId{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:parentCategoryId forKey:@"parentCategoryId"];
    [userDefaults synchronize];
}

#pragma mark - Get   parentCategoryId from user default
+(NSString*)GetParentCategoryIdFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *result=[userDefaults objectForKey:@"parentCategoryId"];
    return result;
}


#pragma mark - Save  searchKeywords to user default for search use
+(void) searchKeywordsToUserDefault:(NSArray*)searchKeywords{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searchKeywords forKey:@"searchKeywords"];
    [userDefaults synchronize];
}
#pragma mark - Get   searchKeywords from user default
+(NSArray*)GetSearchKeywordsFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray *result=[userDefaults objectForKey:@"searchKeywords"];
    return result;
}


//#pragma mark - Save  themeID to user default for theme SQL
//+(void) themeIDToUserDefault:(NSDictionary*)themeID{
//    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:themeID forKey:@"themeID"];
//    [userDefaults synchronize];
//}
//
//#pragma mark - Get   themeID from user default
//+(NSDictionary*)GetThemeIDFromUserDefault{
//    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
//    NSDictionary *result=[userDefaults objectForKey:@"themeID"];
//    return result;
//}

#pragma mark - Save  vchSKU to user default for theme SQL
+(void) vchSKUToUserDefault:(NSArray*)vchSKU{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:vchSKU forKey:@"vchSKU"];
    [userDefaults synchronize];
}
#pragma mark - Get   vchSKU from user default
+(NSArray*)GetVchSKUFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray *result=[userDefaults objectForKey:@"vchSKU"];
    return result;
}


#pragma mark - Save  intCategoryID to user default for theme SQL
+(void) intCategoryIDToUserDefault:(NSString*)intCategoryID{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:intCategoryID forKey:@"intCategoryID"];
    [userDefaults synchronize];
}
#pragma mark - Get   intCategoryID from user default
+(NSString*)GetIntCategoryIDFromUserDefault{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *result=[userDefaults objectForKey:@"intCategoryID"];
    return result;
}




@end
