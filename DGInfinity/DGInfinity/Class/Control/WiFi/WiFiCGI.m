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

@end
