//
//  PayCGI.m
//  DGInfinity
//
//  Created by myeah on 16/12/6.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "PayCGI.h"

@implementation PayCGI

+ (void)PingppPay:(NSInteger)amount
          channel:(NSString *)channel
         complete:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"amount": @(amount),
                        @"channel": channel};
    [[RequestManager shareManager] loadAsync:params cgi:@"pingpp_pay" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
