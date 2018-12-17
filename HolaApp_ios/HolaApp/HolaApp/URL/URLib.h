//
//  URLib.h
//  HolaApp
//
//  Created by Joseph on 2015/2/25.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHouseURLManager.h"

// For ihouse
//#define HOLA_INDEX @"http://172.17.120.114/v1/index/index"
//#define HOLA_PRODUCTLIST @"http://172.17.120.114/v1/product/list"
//#define HOLA_JOINREGISTER @"http://172.17.120.114/v1/member/join"
//
//#define HOLA_httpClientURL @"http://172.17.120.114/"
//#define HOLA_PRODUCTMENU_PATH @"v1/product/menu"
//#define HOLA_PRODUCTCOMPARE_PATH @"v1/product/compare"
//
//#define HOLA_PRODUCTDETAIL_PATH @"v1/product/detail"
//
//#define HOLA_PRODUCTCOMPARE_PATH1 @"http://172.17.120.114/v1/product/compare"
//#define HOLA_PRODUCTSEARCH @"http://172.17.120.114/v1/goods/index"
//#define HOLA_PRODUCTMENUUPDATE_PATH @"http://172.17.120.114/v1/product/menu"
//
//#define HOLA_THEME_CATEGORY_PATH @"http://172.17.120.189/DB/ThemeCategory/Thumbnail/"
//
//#define HOLA_THEME_PATH @"http://172.17.120.189/DB/ThemeList/Thumbnail/"
//
//#define HOLA_PIC_URL_STR @"http://cdn.i-house.com.tw/pub/img/"
//#define HOLA_WEB_SHOPPING @"http://www.i-house.com.tw/product/detail/id/"
//
//#define HOLA_STORE_MAP @"http://maps.google.com/?q="

// For HOLA
#define HOLA_INDEX @"/v1/index/index"
#define HOLA_PRODUCTLIST @"/v1/product/list"
//#define HOLA_JOINREGISTER @"http://apidemo.hola.com.tw/v1/member/join"

//#define HOLA_httpClientURL @"http://apidemo.hola.com.tw/"
#define HOLA_PRODUCTMENU_PATH @"/v1/product/menu" //依照產品分類代碼查詢
#define HOLA_PRODUCTCOMPARE_PATH @"/v1/product/compare"
#define HOLA_PRODUCTSEARCH_PATH @"/v1/goods/index"//依照產品關鍵字搜尋

#define HOLA_PRODUCTDETAIL_PATH @"/v1/product/detail"

#define HOLA_PRODUCTCOMPARE_PATH1 @"/v1/product/compare"
//#define HOLA_PRODUCTSEARCH @"http://apidemo.hola.com.tw/v1/goods/index"
//#define HOLA_PRODUCTMENUUPDATE_PATH @"http://apidemo.hola.com.tw/v1/product/menu"

// SQL
//#define HOLA_THEME_CATEGORY_PATH @"/DB/ThemeCategory/Thumbnail/"
//#define HOLA_THEME_PATH @"/DB/ThemeList/Thumbnail/"

// Pic url
#define HOLA_PIC_URL_STR @"http://cdn.hola.com.tw/pub/img/"
#define HOLA_WEB_SHOPPING @"http://www.hola.com.tw/product/detail/id/"

// Google MAP
#define HOLA_STORE_MAP @"http://maps.google.com/?q="

#define HOLA_PRODUCT_SHARE @"https://s3-ap-southeast-1.amazonaws.com/i-house/index.html?sku="

/* 網路購物網址 (跳出去)
特力屋：http://www.i-house.com.tw/product/detail/id/產品的ID
HOLA：http://www.hola.com.tw/product/detail/id/產品的ID
*/

/* 到店折扣卷 (webView)
 在btnO2oCoupon API(compare,detail)裡面的 url
 ex:"url": "http://o2o.sharer.com.tw/Product/ihouse/22089004495005/016031994"
*/


/*

 HOLA,ihouse都在同一台主機上
 所以只能靠網址分開 (VirtualHost)
 使ip連線預設是連特力屋的
 
 apidemo.i-house.com.tw => 特力屋
 apidemo.hola.com.tw => HOLA
 
 IP都是同一組

*/


@interface URLib : NSObject



@end
