//
//  WiFiCGI.h
//  DGInfinity
//
//  Created by myeah on 16/11/10.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiFiCGI : NSObject

/**
 *  get_weather_news
 */
+ (void)getWeatherNews:(void (^)(DGCgiResult *res))complete;

/**
 *  get_front_info
 */
+ (void)getFrontInfo:(void (^)(DGCgiResult *res))complete;

/**
 *  report_wifi
 *  @param ssid wifi的ssid
 *  @param password 密码
 *  @param longitude 经度 采用百度地图
 *  @param latitude 纬度
 */
+ (void)reportWifi:(NSString *)ssid
          password:(NSString *)password
         longitudu:(double)longitude
          latitude:(double)latitude
          complete:(void (^)(DGCgiResult *res))complete;

/**
 *  report_apmac
 *  @param apmac ap的mac地址
 */
+ (void)reportApMac:(NSString *)apmac
           complete:(void (^)(DGCgiResult *res))complete;


@end
