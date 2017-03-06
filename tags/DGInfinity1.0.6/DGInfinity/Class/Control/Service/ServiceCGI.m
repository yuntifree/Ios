//
//  ServiceCGI.m
//  DGInfinity
//
//  Created by myeah on 16/10/31.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ServiceCGI.h"

@implementation ServiceCGI

+ (void)getServices:(void (^)(DGCgiResult *))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"services" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)getDiscovery:(void (^)(DGCgiResult *))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_discovery" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
