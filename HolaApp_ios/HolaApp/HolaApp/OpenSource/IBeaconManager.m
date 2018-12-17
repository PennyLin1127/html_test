//
//  IBeaconManager.m
//  BNQapp
//
//  Created by Jimmy Liu on 2014/10/17.
//  Copyright (c) 2014年 JimmyLiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBeaconManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "IHouseURLManager.h"
#import "PerfectAPIManager.h"

#define BEACON_UUID @"A35680C2-C420-4574-964F-C2B39AB43BFE"
#define HOLA_BEACON_IDENTIFIER @"HolaBeaconIfentifier"

@interface IBeaconManager(){
    
}
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@property (nonatomic, strong) NSMutableArray *beaconsArray;
@property (nonatomic, strong) NSMutableArray *beaconDatasArray;
@end


@implementation IBeaconManager


+(IBeaconManager *)shareIBeaconManager
{
    static IBeaconManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        
    });
    
    return manager;
}

//覆寫init
-(id)init
{
    self = [super init];
    if (self) {
        NSLog(@"初始化IBeaconManager相關變數");
        //初始化 CLLocationManager
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.activityType = CLActivityTypeFitness;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.lassAlert = [NSDate date];
        
       
        // Active "always authorization" in location service of settings after user allow permision
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        [self.locationManager startUpdatingLocation];

    
        
        //固定UUID
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:BEACON_UUID];
        NSLog(@"BeaconUUID -- %@",BEACON_UUID);
        
        //初始化beacon
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:HOLA_BEACON_IDENTIFIER];
        self.beaconRegion.notifyEntryStateOnDisplay = YES;
        
        //初始化 beaconsArray 並加入 beacon
        self.beaconsArray = [[NSMutableArray alloc] init];
        [self.beaconsArray addObject:self.beaconRegion];
        
        //iOS8 專用Code
//        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//            [self.locationManager requestWhenInUseAuthorization];
//        }
        

        
    }
    
    return  self;
}

#pragma mark 控制 CLLocationManager 相關方法
-(void)startAllMonitoringBeacons
{
    [self.locationManager startUpdatingLocation];
    for (CLBeaconRegion *beaconRegion in self.beaconsArray) {
        [self.locationManager startMonitoringForRegion:beaconRegion];
        //0527
        [self.locationManager performSelector:@selector(requestStateForRegion:) withObject:beaconRegion afterDelay:1];
    }

}

-(void) startAllRangingBeacons {
    [self.locationManager startUpdatingLocation];
    for (CLBeaconRegion *beaconRegion in self.beaconsArray) {
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    }
}

-(void)stopAllMonitoringBeacons {
    //0530
    [self.locationManager stopUpdatingLocation];
    for (CLBeaconRegion *beaconRegion in self.beaconsArray) {
        [self.locationManager stopMonitoringForRegion:beaconRegion];

    }
}

-(void) stopAllRagingBeacons {
        //0530
        [self.locationManager stopUpdatingLocation];
    
    for (CLBeaconRegion *beaconRegion in self.beaconsArray) {
        [self.locationManager stopRangingBeaconsInRegion:beaconRegion];
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"status -- %d", status);
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error -- %@", error);
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self stopAllMonitoringBeacons];
    NSLog(@"error -- %@" , error);
}

//-(void)startMonitoringItem:(id)item
//{
//    [self.locationManager startMonitoringForRegion:item];
//    [self.locationManager startRangingBeaconsInRegion:item];
//    [self.locationManager startUpdatingLocation];
//    [self.beaconsArray addObject:item];
//}

//-(void)stopMonitoringItem:(id)item
//{
//    
//    [self.locationManager stopRangingBeaconsInRegion:item];
//    [self.locationManager stopMonitoringForRegion:item];
//    [self.beaconsArray removeObject:item];
//}


-(void)startUpdataLocation {
    [self.locationManager startUpdatingLocation];
}
-(void)stopUpdataLocation {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark 接收beacon方法
//在monitor下進入 Region
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    //0530
    NSLog(@"Enter Region");
    [self startAllRangingBeacons];
}

//在monitor下離開 Region
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
    //0530
    NSLog(@"didExitRegion --%@", region.identifier);
    [self stopAllRagingBeacons];
}


-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //    NSLog(@"didStartMonitoringForRegion");
    NSLog(@"didStartMonitoringForRegion region -- %@", region);
    
    //[self.locationManager requestStateForRegion:region];
    
    
}

//在持續偵測中
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    CLBeacon *firstBeacon = [beacons firstObject];
    
    if (firstBeacon.rssi < -85 || firstBeacon.rssi == 0) {
        //NSLog(@"不再範圍內 -- %d",firstBeacon.rssi);
        return;
    }
    
    NSLog(@"%@", firstBeacon);
    
    //檢查Beacon是否在範圍內
    if (firstBeacon.proximity == CLProximityUnknown) {
        //NSLog(@"不再範圍內 -- %d", firstBeacon.rssi);
        return;
    }
    
    NSLog(@"firstBeacon.accuracy -- %f", firstBeacon.accuracy);
    
    //先判斷時間
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastReceiveDate = [userDefaults objectForKey:[NSString stringWithFormat:@"BeaconMajor-%@ BeaconMinor-%@", firstBeacon.major, firstBeacon.minor]];
    NSDate *now = [NSDate date];
    
    //取出時間
    NSInteger timeInterval = 0.0;
    NSString *tempStr = [userDefaults objectForKey:[NSString stringWithFormat:@"BeaconNoRepeatSec major%@ minior%@", firstBeacon.major.stringValue, firstBeacon.minor.stringValue]];
    NSLog(@"tempStr -- %@", tempStr);
    if (tempStr == nil || [tempStr isEqualToString:@""]) {
        timeInterval = 0.0;
    }else {
        timeInterval = tempStr.integerValue;
    }
    
    if (lastReceiveDate) {
        NSTimeInterval distanceBetweenDates = [now timeIntervalSinceDate:lastReceiveDate];
        NSLog(@"distanceBetweenDates -- %f", distanceBetweenDates);
        
        if (distanceBetweenDates < timeInterval ) {
            NSLog(@"發送時間太短");
            return;
        }
    }
    
    //判斷距離
    
    NSString *nearBy;
    if (firstBeacon.proximity == CLProximityImmediate) {
        nearBy = @"0";
    }else if (firstBeacon.proximity == CLProximityNear) {
        nearBy = @"1";
    }else if (firstBeacon.proximity == CLProximityFar) {
        nearBy = @"2";
    }
    
    [self sendBeaconDataToServer:firstBeacon.major MinorId:firstBeacon.minor andNearBy:nearBy];
    
    //決定要發送什麼訊息
    //    UILocalNotification *theLocalPush=[[UILocalNotification alloc] init];
    //    theLocalPush.alertBody = @"";
    //    theLocalPush.soundName = @"yes";
    //    theLocalPush.userInfo = @{@"BeaconID": @""};
    //    //theLocalPush.applicationIconBadgeNumber = 1;
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:theLocalPush];
    
    //發送完記錄時間
    [userDefaults setObject:now forKey:[NSString stringWithFormat:@"BeaconMajor-%@ BeaconMinor-%@", firstBeacon.major, firstBeacon.minor]];
    [userDefaults synchronize];
    
    //    if (firstBeacon.proximity != CLProximityImmediate && firstBeacon.proximity != CLProximityNear) {
    //        return;
    //    }
    //    NSLog(@"%@:%i",region.identifier, firstBeacon.rssi);
    //    if (firstBeacon.rssi <-85) {
    //        return;
    //    }
    //
    //
    //    if (self.lassAlert  != nil && [[NSDate date] timeIntervalSinceDate:self.lassAlert]<10) {
    //        return;
    //    }
    //    if(self.lassAlert != nil) {
    //          NSLog(@"time:%f",[[NSDate date] timeIntervalSinceDate:self.lassAlert]);
    //    }
    
    
}


-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    NSLog(@"beacon status is %ld",state);
    if (state == CLRegionStateInside) {
        NSLog(@"CLRegionStateInside -- %@", region);
         
        [self startAllRangingBeacons];
        [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
        }else {
        //NSLog(@"NOT INSIDE %d -- %@", state, region);
        [self stopAllRagingBeacons];
        [manager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
    }
}

-(void) getLocationManagerState
{
    NSLog(@"%d", [CLLocationManager authorizationStatus]);
    
}

#pragma mark 收到Beacon之後 執行發送資料
-(void) sendBeaconDataToServer:(NSNumber*)majorId MinorId:(NSNumber*)minorId andNearBy:(NSString*)nearBy{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //組成Dic
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *crmMemberCardID = [userDefaults objectForKey:USER_CRM_MEMBER_ID];
        crmMemberCardID = crmMemberCardID == nil ? @"" : crmMemberCardID;
        NSString *deviceTokenUUID = [userDefaults objectForKey:DEVICE_TOKEN_UUID];
        
        NSString *majorStr = majorId.stringValue;
        NSString *minorStr = minorId.stringValue;
        
        NSDictionary *dic = @{@"MemberCardID":crmMemberCardID , @"MajorID":majorStr, @"MinorID":minorStr, @"Token":deviceTokenUUID, @"Source":@"iOS", @"NearBy":nearBy};
        
        //測試用Code
        //NSDictionary *dic = @{@"MemberCardID":memberCardID , @"MajorID":@"200", @"MinorID":@"1", @"Token":deviceTokenUUID, @"Source":@"iOS"};
        
        //發送資料
        NSData *returnData;
        PerfectAPIManager *perfectAPIManager = [[PerfectAPIManager alloc] init];
        returnData = [perfectAPIManager getDataByPostMethodUseEncryptionSync:[IHouseURLManager getPerfectURLByAppName:BEACON_URL] AndDic:dic];
        
        if (returnData == nil) {
            NSLog(@"網路有問題 BeaconAPI資料回不來");
            
            NSInteger noRepeatSec = 60*10; //網路連線有問題 固定給10分鐘
            [self setBeaconNotSendDataSec:noRepeatSec majorId:majorStr miniorId:minorStr];
            
            return;
        }else {
            PerfectAPIManager *perfectAPIManager=[[PerfectAPIManager alloc]init];
            NSDictionary *returnDic = [perfectAPIManager convertEncryptionNSDataToDic:returnData];
            NSLog(@"returnDic -- %@", returnDic);
            
            if (returnDic == nil) {
                NSString *test = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                NSLog(@"test -- %@", test);
                
                NSInteger noRepeatSec = 60*10; //回nil 固定給10分鐘
               [self setBeaconNotSendDataSec:noRepeatSec majorId:majorStr miniorId:minorStr];

                return;
            }
            
            NSString *msgTest = [returnDic objectForKey:@"Msg"];
            NSLog(@"msgTest -- %@", msgTest);
            
            NSString *status = [returnDic objectForKey:@"Status"];
            status = status == nil ? @"" : status;
            if ([status isEqualToString:@"ERR"]) {
                NSInteger noRepeatSec = 60*10; //回ERROR 固定給10分鐘
                [self setBeaconNotSendDataSec:noRepeatSec majorId:majorStr miniorId:minorStr];
                return;
            }
            
            //準備發送local Notification
            //NSString *returnKey = [NSString stringWithFormat:BRACON_RETURN_DIC, majorStr, minorStr];
            
            //不重複的秒數
            NSInteger noRepeatSec = [[returnDic objectForKey:@"NoRepeatSec"] integerValue];
            if (noRepeatSec == 0) {
                noRepeatSec = 60*10; //0的話固定給10分鐘
            }
//            NSString *noRepeatSecStr = [NSString stringWithFormat:@"%zd", noRepeatSec];
//            [userDefaults setObject:noRepeatSecStr forKey:[NSString stringWithFormat:@"BeaconNoRepeatSec major%@ minior%@", majorStr, minorStr]];
//            [userDefaults synchronize];
            [self setBeaconNotSendDataSec:noRepeatSec majorId:majorStr miniorId:minorStr];
            
            NSString *msg = [returnDic objectForKey:@"Alert"];
            if (msg == nil ||[msg isEqualToString:@""]) {
                [self setBeaconNotSendDataSec:noRepeatSec majorId:majorStr miniorId:minorStr];
                return;
//                msg = @"有新訊息";
            }
            
            UILocalNotification *theLocalPush=[[UILocalNotification alloc] init];
            
            theLocalPush.alertBody = msg;
            theLocalPush.soundName = UILocalNotificationDefaultSoundName;
            theLocalPush.userInfo = @{@"BeaconReturnDic": returnDic};
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] presentLocalNotificationNow:theLocalPush];
            });
        }
    });
}

//設置Beacon不收訊息的秒數
-(void)setBeaconNotSendDataSec:(NSInteger)sec majorId:(NSString*)majorId miniorId:(NSString*)miniorId {
    NSLog(@"設定Beacon跳過的秒數 -- %zd", sec);
    //0612 Joseph 需要再確認秒數
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
#warning 目前設11秒後，才會在收到beacon
    NSString *noRepeatSecStr = [NSString stringWithFormat:@"%zd", 11];
    [userDefaults setObject:noRepeatSecStr forKey:[NSString stringWithFormat:@"BeaconNoRepeatSec major%@ minior%@", majorId, miniorId]];
    
    [userDefaults synchronize];

}

@end
