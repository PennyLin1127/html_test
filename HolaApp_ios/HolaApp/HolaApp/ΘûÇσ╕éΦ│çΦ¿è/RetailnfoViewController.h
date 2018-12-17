//
//  RetailnfoViewController.h
//  HolaApp
//
//  Created by Joseph on 2015/4/11.
//  Copyright (c) 2015年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationViewController.h"
#import <CoreLocation/CoreLocation.h>

typedef enum : NSUInteger {
    areaFilter,
    storeFilter,
    firstTimeStore,
} WhichOfFilter;


typedef enum : NSUInteger {
    showShortDistanceByGPS,
    showStoreBySelected,
} showStoreByWhat;

@interface RetailnfoViewController : NavigationViewController <CLLocationManagerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (assign,nonatomic) double  latitudeValue;
@property (assign,nonatomic) double  longitudeValue;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIPickerView *pickView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// 區域
@property (strong,nonatomic) NSArray *areaPickerArray;  // 地區名Array
@property (strong,nonatomic) NSString *areaStr;
@property (strong,nonatomic) NSString *areaId; // save area id

// 分店
@property (strong,nonatomic) NSString *vchStoreName;
@property (strong,nonatomic) NSMutableArray *storeArray; // 分店資料，裡頭data是dic，第一個為空字串，for 選擇門市picker用
@property (strong,nonatomic) NSMutableArray *storeArray4TableView ; // 分店資料，裡頭data是dic，在search button按下去才init
@property (strong,nonatomic) NSString *storeId; //save store id for single store

@property (strong,nonatomic) NSMutableArray *firsTimeStoreArray;

// 經緯度
@property (strong,nonatomic) NSString *dblLatitude;
@property (strong,nonatomic) NSString *dblLongtitude;
@property (strong,nonatomic) NSArray *tempArray4HolaData;
@property (strong,nonatomic) NSMutableArray *laloDataArray; // 存SQL所有的經緯度資料


// set currentLocation of CLLocation
@property (strong,nonatomic) CLLocation *currentLocation;

// 儲存目前GPS位置與SQL裡各個店家的距離
@property (strong,nonatomic) NSMutableArray *distances; // 儲存目前位置與各店位置的距離
@property (strong,nonatomic) NSMutableArray *distancesIndex; // 存下最小距離的index

// LINE
@property (strong,nonatomic) NSMutableArray *LineUrlArray;
@end




/*
How to fix CLLocationManager location updates issue in iOS 8
需要在plist加入 NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription 
以及填入目的。
 
已知經緯度連到google
http://maps.google.com/?q=緯度,經度
 

*/