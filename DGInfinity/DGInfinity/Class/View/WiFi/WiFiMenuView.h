//
//  WiFiMenuView.h
//  DGInfinity
//
//  Created by myeah on 16/11/9.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WiFiMenuType) {
    WiFiMenuTypeConnect = 1000,
    WiFiMenuTypeExamination = 1001,
    WiFiMenuTypeSpeedTest = 1002,
    WiFiMenuTypeMap = 1003,
    WiFiMenuTypeWelfare = 1004,
    WiFiMenuTypeHot = 1005,
    WiFiMenuTypeTemperature = 1006,
    WiFiMenuTypeWeather = 1007,
    WiFiMenuTypeConnected = 1008
};

typedef NS_ENUM(NSInteger, ConnectStatus) {
    ConnectStatusNotConnect = 0,
    ConnectStatusConnected = 1
};

@protocol WiFiMenuViewDelegate <NSObject>

- (void)WiFiMenuViewClick:(WiFiMenuType)type;

@end

@interface WiFiMenuView : UIView

@property (nonatomic, weak) id <WiFiMenuViewDelegate> delegate;

- (void)setWeather:(NSDictionary *)weather;
- (void)setHotNews:(NSString *)title;
- (void)setDeviceBadge:(NSInteger)badge;
- (void)setBackViewImage;
- (void)startAnimation;
- (void)stopAnimation;
- (void)checkConnectBtnStatus;
- (void)setConnectBtnStatus:(ConnectStatus)status;

@end