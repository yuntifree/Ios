//
//  BaiduMapSDK.m
//  BaiduSB
//
//  Created by jacky.lee on 16/8/10.
//  Copyright © 2016年 aini25. All rights reserved.
//

#import "BaiduMapSDK.h"
#import <MapKit/MapKit.h>

const int MaxUpdateTime = 5;
const CLLocationDistance DRIVEDISTANCE = 300;

UIKIT_EXTERN int MetersTwoCoordinate2D(CLLocationCoordinate2D a, CLLocationCoordinate2D b)
{
    BMKMapPoint point1 = BMKMapPointForCoordinate(a);
    BMKMapPoint point2 = BMKMapPointForCoordinate(b);
    int distance = round(BMKMetersBetweenMapPoints(point1, point2));
    return distance;
}

UIKIT_STATIC_INLINE CLLocationDistance FMetersTwoCoordinate2D(CLLocationCoordinate2D a, CLLocationCoordinate2D b)
{
    BMKMapPoint point1 = BMKMapPointForCoordinate(a);
    BMKMapPoint point2 = BMKMapPointForCoordinate(b);
    return BMKMetersBetweenMapPoints(point1, point2);
}

@interface BaiduMapSDK () <BMKLocationServiceDelegate>
{
    BMKLocationService *_locationService;
    NSMutableArray *_delegates;
    NSTimeInterval _oldTime;
}

@end

@implementation BaiduMapSDK

+ (BaiduMapSDK *)shareBaiduMapSDK
{
    static BaiduMapSDK *baiduMapSDK = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baiduMapSDK = [[BaiduMapSDK alloc] init];
    });
    return baiduMapSDK;
}

- (id)init
{
    self = [super init];
    if (self) {
        _locationService = [[BMKLocationService alloc] init];
        _delegates = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)setDelegate:(id<BaiduMapSDKDelegate>)delegate
{
    if ([delegate isKindOfClass:[NSObject class]]) {
        @synchronized (_delegates) {
            [_delegates addObject:delegate];
        }
    }
}

- (void)removeDelegate:(id<BaiduMapSDKDelegate>)delegate
{
    if ([delegate isKindOfClass:[NSObject class]]) {
        @synchronized (_delegates) {
            [_delegates removeObject:delegate];
        }
    }
}

- (BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied;
}

- (void)startUserLocationService
{
    _locationService.distanceFilter = 3.0f;
    _locationService.delegate = self;
    [_locationService startUserLocationService];
}

- (void)stopUserLocationService
{
    _locationService.distanceFilter = kCLDistanceFilterNone;
    _locationService.delegate = nil;
    [_locationService stopUserLocationService];
}

- (BMKUserLocation *)getUserLocation
{
    return _locationService.userLocation;
}

// 是否有安装百度地图
- (BOOL)whetherInstallBaiduApp
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
}

- (void)openMapApp:(LocationInfo *)startLocationInfo endLocationInfo:(LocationInfo *)endLocationInfo
{
    [self whetherInstallBaiduApp] ? [self openBaiduMapApp:startLocationInfo endLocationInfo:endLocationInfo] : [self openSystemMapApp:startLocationInfo endLocationInfo:endLocationInfo];
}

- (void)openBaiduMapApp:(LocationInfo *)startLocationInfo endLocationInfo:(LocationInfo *)endLocationInfo
{
    CLLocationCoordinate2D startCoordinate2D = startLocationInfo.coordinate2D;
    CLLocationCoordinate2D endCoordinate2D = endLocationInfo.coordinate2D;
    CLLocationDistance distance = FMetersTwoCoordinate2D(startCoordinate2D, endCoordinate2D);
    BOOL drive = distance > DRIVEDISTANCE;
    BMKOpenRouteOption *opt = drive ? [[BMKOpenDrivingRouteOption alloc] init] : [[BMKOpenWalkingRouteOption alloc] init];
    opt.appScheme = @"dgwireless://";
    
    // 起点节点
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    start.pt = startCoordinate2D;
    start.name = startLocationInfo.busiName;
    opt.startPoint = start;
    
    // 终点节点
    BMKPlanNode *end = [[BMKPlanNode alloc] init];
    end.pt = endCoordinate2D;
    end.name = endLocationInfo.busiName;
    opt.endPoint = end;
    
    // 打开百度地图
    BMKOpenErrorCode code = drive ? [BMKOpenRoute openBaiduMapDrivingRoute:(BMKOpenDrivingRouteOption *)opt] : [BMKOpenRoute openBaiduMapWalkingRoute:(BMKOpenWalkingRouteOption *)opt];
    if (code != BMK_OPEN_NO_ERROR) { // 打开百度地图出错
        DDDLog(@"打开百度地图出错");
    }
}

- (void)openSystemMapApp:(LocationInfo *)startLocationInfo endLocationInfo:(LocationInfo *)endLocationInfo
{
    CLLocationCoordinate2D startCoordinate2D = startLocationInfo.coordinate2D;
    CLLocationCoordinate2D endCoordinate2D = endLocationInfo.coordinate2D;
    CLLocationDistance distance = FMetersTwoCoordinate2D(startCoordinate2D, endCoordinate2D);
    BOOL drive = distance > DRIVEDISTANCE;
    
    // 起点
    MKMapItem *start = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:startCoordinate2D addressDictionary:nil]];
    start.name = startLocationInfo.busiName;
    
    // 终点
    MKMapItem *end = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:endCoordinate2D addressDictionary:nil]];
    end.name = endLocationInfo.busiName;
    
    NSArray *items = @[start, end];
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithCapacity:3];
    options[MKLaunchOptionsMapTypeKey] = @(MKMapTypeStandard);
    options[MKLaunchOptionsShowsTrafficKey] = @(YES);
    options[MKLaunchOptionsDirectionsModeKey] = drive ? MKLaunchOptionsDirectionsModeDriving : MKLaunchOptionsDirectionsModeWalking;
    
    // 打开苹果自身地图应用
    BOOL b = [MKMapItem openMapsWithItems:items launchOptions:options];
    if (!b) {
        DDDLog(@"打开系统地图出错");
    }
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSTimeInterval nowTime = [NSDate date].timeIntervalSince1970;
    NSInteger interval = (NSInteger)(nowTime - _oldTime);
    if (interval > MaxUpdateTime) { // 五秒更新一次
        _oldTime = nowTime;
        @synchronized (_delegates) {
            for (id <BaiduMapSDKDelegate> delegate in _delegates) {
                if ([delegate respondsToSelector:@selector(didUpdateUserLocation:)]) {
                    [delegate didUpdateUserLocation:userLocation.location.coordinate];
                }
            }
        }
    }
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    DDDLog(@"定位失败 >> %@", error);
}

@end
