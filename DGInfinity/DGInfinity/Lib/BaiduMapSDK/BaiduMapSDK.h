//
//  BaiduMapSDK.h
//  BaiduSB
//
//  Created by jacky.lee on 16/8/10.
//  Copyright © 2016年 aini25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "LocationInfo.h"

/**
 *  获取两点之间的距离
 */
UIKIT_EXTERN int MetersTwoCoordinate2D(CLLocationCoordinate2D a, CLLocationCoordinate2D b);

@protocol BaiduMapSDKDelegate <NSObject>

@optional
- (void)didUpdateUserLocation:(CLLocationCoordinate2D)coordinate2D;

@end

@interface BaiduMapSDK : NSObject

@property (nonatomic, weak) id <BaiduMapSDKDelegate> delegate;

+ (BaiduMapSDK *)shareBaiduMapSDK;

/**
 *  是否开启了定位
 */
- (BOOL)locationServicesEnabled;

/**
 *  删除代理
 */
- (void)removeDelegate:(id) delegate;

/**
 *  开始定位
 */
- (void)startUserLocationService;

/**
 *  停止定位
 */
- (void)stopUserLocationService;

/**
 *  获取用户当前位置
 */
- (BMKUserLocation *)getUserLocation;

/**
 *  打开地图客户端，默认打开百度地图，如果没有百度地图，则打开系统地图
 */
- (void)openMapApp:(LocationInfo *)startLocationInfo
   endLocationInfo:(LocationInfo *)endLocationInfo;

@end
