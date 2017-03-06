//
//  MapCGI.m
//  DGInfinity
//
//  Created by myeah on 16/11/2.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "MapCGI.h"

@implementation MapCGI

+ (void)getNearbyAps:(double)longitude
            latitude:(double)latitude
            complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"longitude": @(longitude),
                        @"latitude": @(latitude)};
    [[RequestManager shareManager] loadAsync:params cgi:@"get_nearby_aps" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)getAllAps:(void (^)(DGCgiResult *))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_all_aps" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
