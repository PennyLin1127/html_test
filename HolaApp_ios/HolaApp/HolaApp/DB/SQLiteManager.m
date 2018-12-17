//
//  SQLiteManager.m
//  HolaApp
//
//  Created by Jimmy Liu on 2015/4/8.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import "SQLiteManager.h"
#import "IHouseURLManager.h"

@implementation SQLiteManager

#pragma mark - DB config
//回傳db於Document的路徑 並檢查有無資料庫 若無 複製bundle到Document
+(NSString *)getDBPath:(dbName)dbName{
    //paths
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    //dbPath
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", [self getDBRealName:dbName]]];
    
    //檢查資料庫是否存在,若無則自 bundle 複製
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        NSString * resourcePath = [[NSBundle mainBundle] pathForResource:[self getDBRealName:dbName] ofType:@"sqlite"];
        [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:dbPath error:nil];
    }
    
    return dbPath;
}

//無副檔名 檔案名稱
+(NSString*)getDBRealName:(dbName)dbName {
    if (dbName == webSQLite) {
        return @"web";
    }
    
    return @"";
}

//取得FMDatabase物件 透過enum
+(FMDatabase *)dbConnection :(dbName)dbName
{
    NSString *dbFilePath = dbFilePath = [self getDBPath:dbName];;
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbFilePath];
    
    return db;
}

#pragma mark - DB細節
//所有DB名稱
+(NSArray*) getAllDBName {
    return @[@"web"];
}

//local db version
+(NSString*)getDBLocalVersion:(dbName)dbName {
    NSString *result;
    
    FMDatabase *db = [self dbConnection:dbName];
    [db open];
    
    FMResultSet *rs = [db executeQuery:@"SELECT ver FROM system"];
    
    while ([rs next]) {
        NSString *ver = [rs stringForColumn:@"ver"];
        result = ver;
    }
    
    [db close];
    [rs close];
    
    return result;
}

//取得DB的DB URL
+(NSString*)getDBURL:(dbName)dbName {
    
    if (dbName == webSQLite) {
        
        NSString *urlStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:PERFECT_DB]];
        return urlStr;
        
//        return @"http://172.17.120.189/DB/web.zip";
//        return  @"http://i-house.perfect.tw/db/web.zip";
    }
    
    return @"";
}

//取得DB得版號 URL
+(NSString*)getDBVersionURL:(dbName)dbName {
    
    if (dbName == webSQLite) {
        
        NSString *urlStr = [NSString stringWithFormat:@"%@", [IHouseURLManager getPerfectURLByAppName:PERFECT_DB_TXT]];
        return urlStr;
        
//        return @"http://172.17.120.189/DB/web.txt";
//        return  @"http://i-house.perfect.tw/db/web.txt";
    }
    
    return @"";
}

#pragma mark - 取得資料方法

/**
 取得首頁資料
 @param nil
 @returns NSArray 裡面包含NSDictionary key值:CategoryId CategoryName CategoryImage
 @exception nil
 */

+(NSArray*)getIndexViewData{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQueryWithFormat:@"SELECT _id,vchCategoryName,vchCategoryImage from tbl_theme_category ORDER by intAscending ASC"];
    
    while ([rs next]) {
        
        NSString *categoryId = [rs stringForColumn:@"_id"];
        NSString *categoryName = [rs stringForColumn:@"vchCategoryName"];
        NSString *CategoryImage = [rs stringForColumn:@"vchCategoryImage"];
        
        categoryId = categoryId != nil ? categoryId : @"";
        categoryName = categoryName != nil ? categoryName : @"";
        CategoryImage = CategoryImage != nil ? CategoryImage : @"";
        
        NSDictionary *dic = @{@"CategoryId": categoryId, @"CategoryName":categoryName, @"CategoryImage":CategoryImage};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}


+(NSArray*)getIndexViewData:(NSString*)date{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT _id,vchCategoryName,vchCategoryImage from tbl_theme_category WHERE dtStartDate<='%@' And (dtEndDate>='%@' or dtEndDate is null)  ORDER by intAscending ASC",date,date]];
    
    while ([rs next]) {
        
        NSString *categoryId = [rs stringForColumn:@"_id"];
        NSString *categoryName = [rs stringForColumn:@"vchCategoryName"];
        NSString *CategoryImage = [rs stringForColumn:@"vchCategoryImage"];
        
        categoryId = categoryId != nil ? categoryId : @"";
        categoryName = categoryName != nil ? categoryName : @"";
        CategoryImage = CategoryImage != nil ? CategoryImage : @"";
        
        NSDictionary *dic = @{@"CategoryId": categoryId, @"CategoryName":categoryName, @"CategoryImage":CategoryImage};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}

/**
 取得居家服務設計(裝修諮詢服務)html 資料
 @param nil
 @returns NSDictionary key值:Title, Content
 @exception nil
 */
+(NSDictionary*)getServiceAndDesignHtmlString {
    NSDictionary *result;
    
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQuery:@"SELECT vchTitle,vchContent From tbl_content WHERE _id=1"];
    
    while ([rs next]) {
        NSString *title = [rs stringForColumn:@"vchTitle"];
        NSString *content = [rs stringForColumn:@"vchContent"];
        
        title = title != nil ? title : @"";
        content = content != nil ? content : @"";
        
        result = @{@"Title": title, @"Content": content};
    }
    
    [db close];
    [rs close];
    
    
    return result;
}

// 取得主題風格 for 正式版
+(NSArray*)getThemeData:(NSInteger)categoryID{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT _id,vchThemeName,vchSummary,vchImage1 from tbl_theme WHERE intCategoryID='%ld'",categoryID]];
    
    while ([rs next]) {
        
        NSString *themeId = [rs stringForColumn:@"_id"];
        NSString *vchThemeName = [rs stringForColumn:@"vchThemeName"];
        NSString *vchSummary = [rs stringForColumn:@"vchSummary"];
        NSString *vchImage1 = [rs stringForColumn:@"vchImage1"];
        
        
        themeId = themeId != nil ? themeId  : @"";
        vchThemeName = vchThemeName != nil ? vchThemeName : @"";
        vchSummary = vchSummary != nil ? vchSummary : @"";
        vchImage1 = vchImage1 != nil ? vchImage1 : @"";
        
        
        NSDictionary *dic = @{@"themeId": themeId, @"vchThemeName":vchThemeName, @"vchSummary":vchSummary,@"vchImage1":vchImage1};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}

// 取得主題風格 dtStart ,End date for 測試版
+(NSArray*)getThemeData:(NSInteger)categoryID date:(NSString*)date{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT _id,vchThemeName,vchSummary,vchImage1 from tbl_theme WHERE intCategoryID=%ld And dtStartDate<='%@' And (dtEndDate>='%@' or dtEndDate is null) ORDER by intAscending ASC",categoryID,date,date]];
    
    while ([rs next]) {
        
        NSString *themeId = [rs stringForColumn:@"_id"];
        NSString *vchThemeName = [rs stringForColumn:@"vchThemeName"];
        NSString *vchSummary = [rs stringForColumn:@"vchSummary"];
        NSString *vchImage1 = [rs stringForColumn:@"vchImage1"];
        
        
        themeId = themeId != nil ? themeId  : @"";
        vchThemeName = vchThemeName != nil ? vchThemeName : @"";
        vchSummary = vchSummary != nil ? vchSummary : @"";
        vchImage1 = vchImage1 != nil ? vchImage1 : @"";
        
        
        NSDictionary *dic = @{@"themeId": themeId, @"vchThemeName":vchThemeName, @"vchSummary":vchSummary,@"vchImage1":vchImage1};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}


// 取得主題風格詳細  for 正式版
+(NSArray*)getThemeDataDetail:(NSInteger)themeID{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQueryWithFormat:@"SELECT vchThemeName,vchSummary,vchImage2,vchKeyword,vchDescription from tbl_theme WHERE _id=%ld",themeID];
    
    
    while ([rs next]) {
        
        NSString *vchThemeName = [rs stringForColumn:@"vchThemeName"];
        NSString *vchSummary = [rs stringForColumn:@"vchSummary"];
        NSString *vchImage2 = [rs stringForColumn:@"vchImage2"];
        NSString *vchKeyword = [rs stringForColumn:@"vchKeyword"];
        NSString *vchDescription = [rs stringForColumn:@"vchDescription"];
        
        
        
        vchThemeName = vchThemeName != nil ? vchThemeName  : @"";
        vchSummary = vchSummary != nil ? vchSummary : @"";
        vchImage2 = vchImage2 != nil ? vchImage2 : @"";
        vchKeyword = vchKeyword != nil ? vchKeyword : @"";
        vchDescription = vchDescription !=nil ? vchDescription : @"";
        
        
        NSDictionary *dic = @{@"vchThemeName": vchThemeName, @"vchSummary":vchSummary, @"vchImage2":vchImage2,@"vchKeyword":vchKeyword,@"vchDescription":vchDescription};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
    
}

// 取得主題風格詳細  for 測試版
+(NSArray*)getThemeDataDetail:(NSInteger)themeID date:(NSString*)date{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT vchThemeName,vchSummary,vchImage2,vchKeyword,vchDescription from tbl_theme WHERE _id=%ld And dtStartDate<='%@' And (dtEndDate>='%@' or dtEndDate is null) ",themeID,date,date]];
    
    
//    SELECT vchThemeName,vchDescription,vchImage2,vchKeyword,intContentType,vchURL from tbl_theme WHERE _id=[主題風格ID] And dtStartDate<='2015-06-05' And (dtEndDate>='2015-06-05' or dtEndDate is null)
    
    while ([rs next]) {
        
        NSString *vchThemeName = [rs stringForColumn:@"vchThemeName"];
        NSString *vchSummary = [rs stringForColumn:@"vchSummary"];
        NSString *vchImage2 = [rs stringForColumn:@"vchImage2"];
        NSString *vchKeyword = [rs stringForColumn:@"vchKeyword"];
        NSString *vchDescription = [rs stringForColumn:@"vchDescription"];
        
        
        
        vchThemeName = vchThemeName != nil ? vchThemeName  : @"";
        vchSummary = vchSummary != nil ? vchSummary : @"";
        vchImage2 = vchImage2 != nil ? vchImage2 : @"";
        vchKeyword = vchKeyword != nil ? vchKeyword : @"";
        vchDescription = vchDescription !=nil ? vchDescription : @"";
        
        
        NSDictionary *dic = @{@"vchThemeName": vchThemeName, @"vchSummary":vchSummary, @"vchImage2":vchImage2,@"vchKeyword":vchKeyword,@"vchDescription":vchDescription};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
    
}


// 主題風格產品

+(NSArray*)getThemeProduct:(NSInteger)themeID{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQueryWithFormat:@"SELECT vchSKU From tbl_theme_product WHERE intThemeID=%ld and vchSKU is not null and vchSKU<>'' ORDER by intAscending ASC",themeID];
    
    while ([rs next]) {
        
        NSString *vchSKU = [rs stringForColumn:@"vchSKU"];
        [tempArray addObject:vchSKU];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
    
}

// 取得店面分區

+(NSArray*)getRegionData {
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQueryWithFormat:@"SELECT _id,vchRegionName from tbl_store_region"];
    
    while ([rs next]) {
        
        NSString *regionId = [rs stringForColumn:@"_id"];
        NSString *vchRegionName = [rs stringForColumn:@"vchRegionName"];
        
        regionId = regionId != nil ? regionId  : @"";
        vchRegionName = vchRegionName != nil ? vchRegionName : @"";
        
        NSDictionary *dic = @{@"regionId": regionId, @"vchRegionName":vchRegionName};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}


// 取得分區下的店面 , 傳入regionId
+(NSArray*)getStoreData:(NSString*)whichOne{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQueryWithFormat:@"SELECT _id,vchStoreId,vchStoreName,vchStoreAddress,dblLatitude,dblLongtitude,vchPhone,vchOpenTime,vchLine From tbl_store WHERE intRegionID=%@",whichOne];
    
    while ([rs next]) {
        
        NSString *regionId = [rs stringForColumn:@"_id"];
        NSString *vchStoreId = [rs stringForColumn:@"vchStoreId"];
        NSString *vchStoreName = [rs stringForColumn:@"vchStoreName"];
        NSString *vchStoreAddress = [rs stringForColumn:@"vchStoreAddress"];
        NSString *dblLatitude = [rs stringForColumn:@"dblLatitude"];
        NSString *dblLongtitude = [rs stringForColumn:@"dblLongtitude"];
        NSString *vchPhone = [rs stringForColumn:@"vchPhone"];
        NSString *vchOpenTime = [rs stringForColumn:@"vchOpenTime"];
        NSString *vchLine = [rs stringForColumn:@"vchLine"];
        
        regionId = regionId != nil ? regionId  : @"";
        vchStoreId = vchStoreId != nil ? vchStoreId : @"";
        vchStoreName = vchStoreName != nil ? vchStoreName : @"";
        vchStoreAddress = vchStoreAddress != nil ? vchStoreAddress : @"";
        dblLatitude = dblLatitude !=nil ? dblLatitude : @"";
        dblLongtitude = dblLongtitude !=nil ? dblLongtitude : @"";
        vchPhone = vchPhone !=nil ? vchPhone: @"";
        vchOpenTime = vchOpenTime!=nil ? vchOpenTime : @"";
        vchLine = vchLine !=nil ? vchLine : @"";
        
        NSDictionary *dic = @{@"regionId": regionId, @"vchStoreId":vchStoreId, @"vchStoreName":vchStoreName,@"vchStoreAddress":vchStoreAddress,@"dblLatitude":dblLatitude,@"dblLongtitude":dblLongtitude,@"vchPhone":vchPhone,@"vchOpenTime":vchOpenTime,@"vchLine":vchLine};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}


// 取得分區下所有的店面(北中南東) , 傳入regionId
+(NSArray*)getAllStoreData:(NSArray*)regionId{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<regionId.count; i++)
    {
        FMDatabase *db = [self dbConnection:webSQLite];
        [db open];
        FMResultSet *rs = [db executeQueryWithFormat:@"SELECT _id,vchStoreId,vchStoreName,vchStoreAddress,dblLatitude,dblLongtitude,vchPhone,vchOpenTime,vchLine From tbl_store WHERE intRegionID=%@",[regionId[i]objectForKey:@"regionId"]];
        
        while ([rs next]) {
            
            NSString *regionId = [rs stringForColumn:@"_id"];
            NSString *vchStoreId = [rs stringForColumn:@"vchStoreId"];
            NSString *vchStoreName = [rs stringForColumn:@"vchStoreName"];
            NSString *vchStoreAddress = [rs stringForColumn:@"vchStoreAddress"];
            NSString *dblLatitude = [rs stringForColumn:@"dblLatitude"];
            NSString *dblLongtitude = [rs stringForColumn:@"dblLongtitude"];
            NSString *vchPhone = [rs stringForColumn:@"vchPhone"];
            NSString *vchOpenTime = [rs stringForColumn:@"vchOpenTime"];
            NSString *vchLine = [rs stringForColumn:@"vchLine"];
            
            regionId = regionId != nil ? regionId  : @"";
            vchStoreId = vchStoreId != nil ? vchStoreId : @"";
            vchStoreName = vchStoreName != nil ? vchStoreName : @"";
            vchStoreAddress = vchStoreAddress != nil ? vchStoreAddress : @"";
            dblLatitude = dblLatitude !=nil ? dblLatitude : @"";
            dblLongtitude = dblLongtitude !=nil ? dblLongtitude : @"";
            vchPhone = vchPhone !=nil ? vchPhone: @"";
            vchOpenTime = vchOpenTime!=nil ? vchOpenTime : @"";
            vchLine = vchLine !=nil ? vchLine : @"";
            
            NSDictionary *dic = @{@"regionId": regionId, @"vchStoreId":vchStoreId, @"vchStoreName":vchStoreName,@"vchStoreAddress":vchStoreAddress,@"dblLatitude":dblLatitude,@"dblLongtitude":dblLongtitude,@"vchPhone":vchPhone,@"vchOpenTime":vchOpenTime,@"vchLine":vchLine};
            
            [tempArray addObject:dic];
        }
        
        [db close];
        [rs close];
        
        result = [NSArray arrayWithArray:tempArray];
        
    }
    
    
    return result;
}

// 取得單一店面 , 傳入 _Id
+(NSArray*)getSingleStoreData:(NSString*)whichOne{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQueryWithFormat:@"SELECT _id,vchStoreId,vchStoreName,vchStoreAddress,dblLatitude,dblLongtitude,vchPhone,vchOpenTime,vchLine From tbl_store WHERE _id=%@",whichOne];
    
    while ([rs next]) {
        
        NSString *regionId = [rs stringForColumn:@"_id"];
        NSString *vchStoreId = [rs stringForColumn:@"vchStoreId"];
        NSString *vchStoreName = [rs stringForColumn:@"vchStoreName"];
        NSString *vchStoreAddress = [rs stringForColumn:@"vchStoreAddress"];
        NSString *dblLatitude = [rs stringForColumn:@"dblLatitude"];
        NSString *dblLongtitude = [rs stringForColumn:@"dblLongtitude"];
        NSString *vchPhone = [rs stringForColumn:@"vchPhone"];
        NSString *vchOpenTime = [rs stringForColumn:@"vchOpenTime"];
        NSString *vchLine = [rs stringForColumn:@"vchLine"];
        
        
        regionId = regionId != nil ? regionId  : @"";
        vchStoreId = vchStoreId != nil ? vchStoreId : @"";
        vchStoreName = vchStoreName != nil ? vchStoreName : @"";
        vchStoreAddress = vchStoreAddress != nil ? vchStoreAddress : @"";
        dblLatitude = dblLatitude !=nil ? dblLatitude : @"";
        dblLongtitude = dblLongtitude !=nil ? dblLongtitude : @"";
        vchPhone = vchPhone !=nil ? vchPhone: @"";
        vchOpenTime = vchOpenTime!=nil ? vchOpenTime : @"";
        vchLine = vchLine !=nil ? vchLine : @"";
        
        
        NSDictionary *dic = @{@"regionId": regionId, @"vchStoreId":vchStoreId, @"vchStoreName":vchStoreName,@"vchStoreAddress":vchStoreAddress,@"dblLatitude":dblLatitude,@"dblLongtitude":dblLongtitude,@"vchPhone":vchPhone,@"vchOpenTime":vchOpenTime,@"vchLine":vchLine};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}

// 取得全部離目前位置最近的店面 , 傳入全部由近到遠的_Id
+(NSArray*)getShortestDistanceStoreData:(NSArray*)allStore{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<allStore.count; i++) {
        
        FMDatabase *db = [self dbConnection:webSQLite];
        [db open];
        
        FMResultSet *rs = [db executeQueryWithFormat:@"SELECT _id,vchStoreId,vchStoreName,vchStoreAddress,dblLatitude,dblLongtitude,vchPhone,vchOpenTime,vchLine From tbl_store WHERE _id=%ld",(long)[allStore[i]integerValue]];
        NSLog(@"allStore %ld",(long)[allStore[i]integerValue]);
        
        while ([rs next]) {
            
            NSString *regionId = [rs stringForColumn:@"_id"];
            NSString *vchStoreId = [rs stringForColumn:@"vchStoreId"];
            NSString *vchStoreName = [rs stringForColumn:@"vchStoreName"];
            NSString *vchStoreAddress = [rs stringForColumn:@"vchStoreAddress"];
            NSString *dblLatitude = [rs stringForColumn:@"dblLatitude"];
            NSString *dblLongtitude = [rs stringForColumn:@"dblLongtitude"];
            NSString *vchPhone = [rs stringForColumn:@"vchPhone"];
            NSString *vchOpenTime = [rs stringForColumn:@"vchOpenTime"];
            NSString *vchLine = [rs stringForColumn:@"vchLine"];
            
            
            regionId = regionId != nil ? regionId  : @"";
            vchStoreId = vchStoreId != nil ? vchStoreId : @"";
            vchStoreName = vchStoreName != nil ? vchStoreName : @"";
            vchStoreAddress = vchStoreAddress != nil ? vchStoreAddress : @"";
            dblLatitude = dblLatitude !=nil ? dblLatitude : @"";
            dblLongtitude = dblLongtitude !=nil ? dblLongtitude : @"";
            vchPhone = vchPhone !=nil ? vchPhone: @"";
            vchOpenTime = vchOpenTime!=nil ? vchOpenTime : @"";
            vchLine = vchLine !=nil ? vchLine : @"";
            
            
            NSDictionary *dic = @{@"regionId": regionId, @"vchStoreId":vchStoreId, @"vchStoreName":vchStoreName,@"vchStoreAddress":vchStoreAddress,@"dblLatitude":dblLatitude,@"dblLongtitude":dblLongtitude,@"vchPhone":vchPhone,@"vchOpenTime":vchOpenTime,@"vchLine":vchLine};
            
            [tempArray addObject:dic];
        }
        
        [db close];
        [rs close];
        
        result = [NSArray arrayWithArray:tempArray];
        
    }
    
    
    return result;
}




// 取得全部店面經緯度
+(NSArray*)getPositionData{
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQueryWithFormat:@"SELECT _id,vchStoreId,vchStoreName,vchStoreAddress,dblLatitude,dblLongtitude,vchPhone,vchOpenTime,vchLine From tbl_store"];
    
    while ([rs next]) {
        
        NSString *regionId = [rs stringForColumn:@"_id"];
        NSString *vchStoreId = [rs stringForColumn:@"vchStoreId"];
        NSString *vchStoreName = [rs stringForColumn:@"vchStoreName"];
        NSString *vchStoreAddress = [rs stringForColumn:@"vchStoreAddress"];
        NSString *dblLatitude = [rs stringForColumn:@"dblLatitude"];
        NSString *dblLongtitude = [rs stringForColumn:@"dblLongtitude"];
        NSString *vchPhone = [rs stringForColumn:@"vchPhone"];
        NSString *vchOpenTime = [rs stringForColumn:@"vchOpenTime"];
        NSString *vchLine = [rs stringForColumn:@"vchLine"];
        
        
        regionId = regionId != nil ? regionId  : @"";
        vchStoreId = vchStoreId != nil ? vchStoreId : @"";
        vchStoreName = vchStoreName != nil ? vchStoreName : @"";
        vchStoreAddress = vchStoreAddress != nil ? vchStoreAddress : @"";
        dblLatitude = dblLatitude !=nil ? dblLatitude : @"";
        dblLongtitude = dblLongtitude !=nil ? dblLongtitude : @"";
        vchPhone = vchPhone !=nil ? vchPhone: @"";
        vchOpenTime = vchOpenTime!=nil ? vchOpenTime : @"";
        vchLine = vchLine !=nil ? vchLine : @"";
        
        
        NSDictionary *dic = @{@"regionId": regionId, @"vchStoreId":vchStoreId, @"vchStoreName":vchStoreName,@"vchStoreAddress":vchStoreAddress,@"dblLatitude":dblLatitude,@"dblLongtitude":dblLongtitude,@"vchPhone":vchPhone,@"vchOpenTime":vchOpenTime,@"vchLine":vchLine};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}


#pragma mark - 取得最新消息資料
/**
 取得分類名稱
 @param nil
 @returns NSArray 裡面包含NSDictionary key值:CategoryId, CategoryName
 @exception nil
 */
+(NSArray*)getNewsCategoryName {
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQuery:@"SELECT _id,vchCategoryName From tbl_news_category Order by intAscending ASC"];
    
    while ([rs next]) {
        
        NSString *categoryId = [rs stringForColumn:@"_id"];
        NSString *categoryName = [rs stringForColumn:@"vchCategoryName"];
        NSLog(@"categoryId -- %@", categoryId);
        categoryId = categoryId != nil ? categoryId : @"";
        categoryName = categoryName != nil ? categoryName : @"";
        
        NSDictionary *dic = @{@"CategoryId": categoryId, @"CategoryName":categoryName};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
    
}

/**
 取得新聞列表
 @param 分類Id
 @returns NSArray 裡面包含NSDictionary key值:Subject, Image, Summary, StartDate, EndDate
 @exception nil
 */
+(NSArray*)getNewsListDataByCategoryId:(NSString*)categoryId{
    
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQuery:@"SELECT _id, vchSubject,vchImage,vchSummary,dtStartDate,dtEndDate from tbl_news WHERE intCategoryID = ?", categoryId];
    
    while ([rs next]) {
        
        NSString *subject = [rs stringForColumn:@"vchSubject"];
        NSString *image = [rs stringForColumn:@"vchImage"];
        NSString *summary = [rs stringForColumn:@"vchSummary"];
        NSString *startDate = [rs stringForColumn:@"dtStartDate"];
        NSString *endDate = [rs stringForColumn:@"dtEndDate"];
        NSString *newsId = [rs stringForColumn:@"_id"];
        
        subject = subject != nil ? subject : @"";
        image = image != nil ? image : @"";
        summary = summary != nil ? summary : @"";
        startDate = startDate != nil ? startDate : @"";
        endDate = endDate != nil ? endDate : @"";
        newsId = newsId != nil ? newsId : @"";
        
        NSDictionary *dic = @{@"Subject": subject, @"Image":image, @"Summary":summary, @"StartDate":startDate, @"EndDate":endDate, @"NewsId":newsId};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}

// for test version
+(NSArray*)getNewsListDataByCategoryId:(NSString*)categoryId date:(NSString*)date{
    
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT _id, vchSubject,vchImage,vchSummary,dtStartDate,dtEndDate from tbl_news WHERE intCategoryID = %@ And dtStartDate<='%@' And (dtEndDate>='%@' or dtEndDate is null)  order by dtStartDate DESC", categoryId,date,date]];
    
    while ([rs next]) {
        
        NSString *subject = [rs stringForColumn:@"vchSubject"];
        NSString *image = [rs stringForColumn:@"vchImage"];
        NSString *summary = [rs stringForColumn:@"vchSummary"];
        NSString *startDate = [rs stringForColumn:@"dtStartDate"];
        NSString *endDate = [rs stringForColumn:@"dtEndDate"];
        NSString *newsId = [rs stringForColumn:@"_id"];
        
        subject = subject != nil ? subject : @"";
        image = image != nil ? image : @"";
        summary = summary != nil ? summary : @"";
        startDate = startDate != nil ? startDate : @"";
        endDate = endDate != nil ? endDate : @"";
        newsId = newsId != nil ? newsId : @"";
        
        NSDictionary *dic = @{@"Subject": subject, @"Image":image, @"Summary":summary, @"StartDate":startDate, @"EndDate":endDate, @"NewsId":newsId};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
}

/**
 取得新聞詳細資料
 @param 新聞Id
 @returns NSArray 裡面包含NSDictionary key值: Subject, Image, Content, StartDate, EndDate
 @exception nil
 */
+(NSArray*)getNewsDetailDataByNewsId:(NSString*)newsId {
    NSArray *result;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [self dbConnection:webSQLite];
    [db open];
    
    FMResultSet *rs = [db executeQuery:@"SELECT vchSubject,vchImage,vchContent,dtStartDate,dtEndDate from tbl_news WHERE _id = ?", newsId];
    
    while ([rs next]) {
        
        NSString *subject = [rs stringForColumn:@"vchSubject"];
        NSString *image = [rs stringForColumn:@"vchImage"];
        NSString *content = [rs stringForColumn:@"vchContent"];
        NSString *startDate = [rs stringForColumn:@"dtStartDate"];
        NSString *endDate = [rs stringForColumn:@"dtEndDate"];
        
        subject = subject != nil ? subject : @"";
        image = image != nil ? image : @"";
        content = content != nil ? content : @"";
        startDate = startDate != nil ? startDate : @"";
        endDate = endDate != nil ? endDate : @"";
        
        NSDictionary *dic = @{@"Subject": subject, @"Image":image, @"Content":content, @"StartDate":startDate, @"EndDate":endDate};
        
        [tempArray addObject:dic];
    }
    
    [db close];
    [rs close];
    
    result = [NSArray arrayWithArray:tempArray];
    
    return result;
    
}
@end
