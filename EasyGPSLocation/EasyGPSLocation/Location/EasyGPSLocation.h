//
//  EasyGPSLocation.h
//  EasyGPSLocation
//
//  Created by Liangk on 2017/11/8.
//  Copyright © 2017年 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

typedef void(^GPSLocationResultBlock)(BOOL success,NSString* msg);

/**
 GPS定位控制器
 */
@interface EasyGPSLocation : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) GPSLocationResultBlock locationResultBlock;  //GPS定位结果回调block
@property (nonatomic) BOOL isLocationSuccess;  //是否定位成功


/**
 获取单例
 
 @return GPS定位控制器单例
 */
+ (instancetype)sharedInstance;

/**
 *  注册GPS定位结果回调block
 *
 *  @param block GPS定位结果回调block
 */
- (void)registerGPSLocationResultBlock:(GPSLocationResultBlock)block;

/**
 获取定位服务是否可用
 
 @return 定位服务是否可用
 */
+ (BOOL)locationServicesEnabled;

/**
 启动定位，定位成功后会缓存最新的定位位置
 
 @return 启动定位成功返回YES，否则返回NO
 */
- (BOOL)startLocation;

/**
 获取定位位置，如果GPS定位操作还没有成功执行，则会尝试获取上一次启动GPS定位的位置
 
 @return 定位位置或者nil
 */
+ (CLLocation*)getLocation;

/**
 获取定位城市，如果GPS定位操作还没有成功执行，则会尝试获取上一次启动GPS定位的城市，如果没有获取到则默认返回“广州市”
 
 @return 定位城市
 */
+ (NSString*)getLocationCity;

@end
