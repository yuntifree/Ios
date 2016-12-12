//
//  WiFiCGI.m
//  DGInfinity
//
//  Created by myeah on 16/11/10.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiCGI.h"

@implementation WiFiCGI

+ (void)getWeatherNews:(void (^)(DGCgiResult *))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_weather_news" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)getFrontInfo:(void (^)(DGCgiResult *))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_front_info" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)reportWifi:(NSString *)ssid
          password:(NSString *)password
         longitudu:(double)longitude
          latitude:(double)latitude
          complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"ssid": ssid,
                        @"password": password,
                        @"longitude": @(longitude),
                        @"latitude": @(latitude)};
    [[RequestManager shareManager] loadAsync:params cgi:@"report_wifi" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)reportApMac:(NSString *)apmac
           complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"apmac": apmac};
    [[RequestManager shareManager] loadAsync:params cgi:@"report_apmac" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)getFlashAd:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_flash_ad" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
