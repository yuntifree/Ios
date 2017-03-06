//
//  NewsCGI.m
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsCGI.h"

@implementation NewsCGI

+ (void)getHot:(NSInteger)type
           seq:(NSInteger)seq
      complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"type": @(type),
                        @"seq": @(seq)};
    [[RequestManager shareManager] loadAsync:params cgi:@"hot" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)reportClick:(NSInteger)id_
               type:(NSInteger)type
               name:(NSString *)name
           complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    if ([name isKindOfClass:[NSString class]] && name.length) {
        params[@"data"] = @{@"id": @(id_),
                            @"type": @(type),
                            @"name": name};
    } else {
        params[@"data"] = @{@"id": @(id_),
                            @"type": @(type)};
    }
    [[RequestManager shareManager] loadAsync:params cgi:@"report_click" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)getMenu:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_menu" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
