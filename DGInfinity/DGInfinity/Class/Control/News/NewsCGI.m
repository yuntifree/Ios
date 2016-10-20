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

@end
