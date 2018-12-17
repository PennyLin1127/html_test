//
//  IBeaconManager.h
//  BNQapp
//
//  Created by Jimmy Liu on 2014/10/17.
//  Copyright (c) 2014年 JimmyLiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface IBeaconManager : NSObject <CLLocationManagerDelegate>

+(IBeaconManager *)shareIBeaconManager;

@property NSDate *lassAlert;
@property (nonatomic, strong) CLLocationManager *locationManager;

-(void) startAllMonitoringBeacons;
-(void) startAllRangingBeacons;
-(void) stopAllMonitoringBeacons;
-(void) stopAllRagingBeacons;

//-(void) startMonitoringItem:(id)item;
//-(void) stopMonitoringItem:(id)item;

-(void)startUpdataLocation;
-(void)stopUpdataLocation;
@end
