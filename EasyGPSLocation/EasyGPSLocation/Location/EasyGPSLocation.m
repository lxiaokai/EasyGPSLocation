//
//  EasyGPSLocation.m
//  EasyGPSLocation
//
//  Created by Liangk on 2017/11/8.
//  Copyright © 2017年 liang. All rights reserved.
//

#import "EasyGPSLocation.h"

#define GPSLocationControllerLocationKey @"GPSLocationControllerLocation"
#define GPSLocationControllerLocationCityKey @"GPSLocationControllerLocationCity"

@interface EasyGPSLocation ()

@property (nonatomic, strong) CLLocation* location;  //定位位置
@property (nonatomic, strong) NSString* locationCity;  //定位城市
@property (nonatomic, strong) CLLocationManager* locMgr;  //地理定位管理器
@property (nonatomic, strong) CLGeocoder* geoCoder;  //地理位置编码器

@end

@implementation EasyGPSLocation

/**
 获取单例
 
 @return GPS定位控制器单例
 */
+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

/**
 *  注册GPS定位结果回调block
 *
 *  @param block GPS定位结果回调block
 */
- (void)registerGPSLocationResultBlock:(GPSLocationResultBlock)block {
    _locationResultBlock = block;
}

/**
 获取定位服务是否可用
 
 @return 定位服务是否可用
 */
+ (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

/**
 启动定位，定位成功后会缓存最新的定位位置
 
 @return 启动定位成功返回YES，否则返回NO
 */
- (BOOL)startLocation {
    BOOL result = YES;
    if (!_locMgr) {
        // 创建定位管理器
        self.locMgr = [[CLLocationManager alloc] init];
        double version = [[UIDevice currentDevice].systemVersion doubleValue];//判定系统版本。
        if(version >= 8.0f){
            [self.locMgr requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8定位需要）
        }
        // 设置代理
        self.locMgr.delegate = self;
    }
    
    //开始定位
    [self.locMgr startUpdatingLocation];
    
    return result;
}

/**
 获取定位位置，如果GPS定位操作还没有成功执行，则会尝试获取上一次启动GPS定位的位置
 
 @return 定位位置或者nil
 */
+ (CLLocation*)getLocation {
    CLLocation* retLocation = [EasyGPSLocation sharedInstance].location;
    if (!retLocation) {
        //尝试从配置缓存读取
        NSDictionary *userLocation = [[NSUserDefaults standardUserDefaults] objectForKey:GPSLocationControllerLocationKey];
        NSNumber *lat = userLocation[@"lat"];
        NSNumber *lon = userLocation[@"long"];
        
        retLocation = [[CLLocation alloc] initWithLatitude:lat.doubleValue longitude:lon.doubleValue];
    }
    return retLocation;
}

/**
 获取定位城市，如果GPS定位操作还没有成功执行，则会尝试获取上一次启动GPS定位的城市，如果没有获取到则默认返回“广州市”
 
 @return 定位城市
 */
+ (NSString*)getLocationCity {
    NSString* city = [EasyGPSLocation sharedInstance].locationCity;
    if (!city) {
        //尝试从配置缓存读取
        city = [[NSUserDefaults standardUserDefaults] stringForKey:GPSLocationControllerLocationCityKey];
    }
    if (!city) {
        city = @"广州市";
    }
    return city;
}

#pragma mark - CLLocationManagerDelegate
/**
 *  只要定位到用户的位置，就会调用（调用频率特别高）
 *  @param locations : 装着CLLocation对象
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // CLLocation中存放的是一些经纬度, 速度等信息. 要获取地理位置需要转换做地理位置编码.
    // 得到位置对象
    CLLocation *loc = [locations firstObject];
    _location = loc;
    
    //缓存位置
    NSNumber *lat = [NSNumber numberWithDouble:loc.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:loc.coordinate.longitude];
    NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
    [[NSUserDefaults standardUserDefaults] setObject:userLocation forKey:GPSLocationControllerLocationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 停止定位(省电措施：只要不想用定位服务，就马上停止定位服务)
    [manager stopUpdatingLocation];
    
    //反地理位置编码
    _geoCoder = [[CLGeocoder alloc] init];
    __weak EasyGPSLocation* weakSelf = self;
    [_geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        __strong EasyGPSLocation* strongSelf = weakSelf;
        
        if (error||placemarks.count==0) {
            if (strongSelf.locationResultBlock) {
                strongSelf.locationResultBlock(NO,@"定位地址无法识别");
            }
        }
        else//编码成功
        {
            //显示最前面的地标信息
            CLPlacemark *firstPlacemark=[placemarks firstObject];
            NSString* locality = firstPlacemark.locality ;
            NSString* subStr = nil;
            if (((NSInteger)[locality length] - 1) >= 0) {
                subStr = [locality substringFromIndex:[locality length] -1];
            }
            if (subStr != nil ) {
                strongSelf.locationCity=locality;
                
                //缓存位置
                [[NSUserDefaults standardUserDefaults] setObject:locality forKey:GPSLocationControllerLocationCityKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            [strongSelf.locMgr stopUpdatingLocation];
            strongSelf.isLocationSuccess = YES;
            
            if (strongSelf.locationResultBlock) {
                strongSelf.locationResultBlock(YES,@"定位成功");
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.locationResultBlock) {
        self.locationResultBlock(NO,@"定位失败，请确认是否开启了定位权限");
    }
}


@end
