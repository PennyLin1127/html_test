//
//  SQLiteManager.h
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/8.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

typedef enum : NSUInteger {
    webSQLite,
    
} dbName;

//zip url
//#define WEB_SQLITE_ZIP @"http://172.17.120.189/DB/web.zip"


//txt url
//#define WEB_SQLITE_TXT @"http://172.17.120.189/DB/web.txt"


@interface SQLiteManager : NSObject

#pragma mark - DB細節
//所有DB名稱
+(NSArray*) getAllDBName;
//local db version
+(NSString*)getDBLocalVersion:(dbName)dbName;
//取得DB的DB URL
+(NSString*)getDBURL:(dbName)dbName;
//取得DB得版號 URL
+(NSString*)getDBVersionURL:(dbName)dbName;

#pragma mark - 取得資料方法
/**
  取得首頁資料
 @param nil
 @returns NSArray 裡面包含NSDictionary key值:CategoryId CategoryName CategoryImage
 @exception nil
 */
+(NSArray*)getIndexViewData; //正式版
+(NSArray*)getIndexViewData:(NSString*)date;//測試版

// 取得熱門話題主題列表
+(NSArray*)getThemeData:(NSInteger)categoryID; //正式版
+(NSArray*)getThemeData:(NSInteger)categoryID date:(NSString*)date; //測試版
// 取得主題風格詳細
+(NSArray*)getThemeDataDetail:(NSInteger)themeID; //正式版
+(NSArray*)getThemeDataDetail:(NSInteger)themeID date:(NSString*)date;//測試版
// 取得主題風格產品
+(NSArray*)getThemeProduct:(NSInteger)themeID;

/**
 取得居家服務設計(裝修諮詢服務)html 資料
 @param nil
 @returns NSDictionary key值:Title, Content
 @exception nil
 */
+(NSDictionary*)getServiceAndDesignHtmlString;

// 取得店面分區
+(NSArray*)getRegionData;
// 取得分區下的店面，傳入regionId
+(NSArray*)getStoreData:(NSString*)whichOne;
// 取得單一店面 , 傳入 _Id
+(NSArray*)getSingleStoreData:(NSString*)whichOne;
// 取得全部離目前位置最近的店面 , 傳入全部由近到遠的_Id
+(NSArray*)getShortestDistanceStoreData:(NSArray*)allStore;
// 取得全部店面經緯度
+(NSArray*)getPositionData;


// 取得分區下所有的店面(北中南東) , 傳入regionId
+(NSArray*)getAllStoreData:(NSArray*)regionId;

#pragma mark - 取得最新消息資料
/**
 取得分類名稱
 @param nil
 @returns NSArray 裡面包含NSDictionary key值:CategoryId, CategoryName
 @exception nil
 */
+(NSArray*)getNewsCategoryName;
/**
 取得新聞列表
 @param 分類Id
 @returns NSArray 裡面包含NSDictionary key值:Subject, Image, Summary, StartDate, EndDate
 @exception nil
 */
+(NSArray*)getNewsListDataByCategoryId:(NSString*)categoryId; // 正式版
+(NSArray*)getNewsListDataByCategoryId:(NSString*)categoryId date:(NSString*)date; // 測試版
/**
 取得新聞詳細資料
 @param 新聞Id
 @returns NSArray 裡面包含NSDictionary key值: Subject, Image, Content, StartDate, EndDate
 @exception nil
 */
+(NSArray*)getNewsDetailDataByNewsId:(NSString*)newsId;
@end
