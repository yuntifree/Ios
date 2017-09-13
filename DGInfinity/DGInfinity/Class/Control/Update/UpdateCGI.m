//
//  UpdateCGI.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/9/13.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "UpdateCGI.h"

@implementation UpdateCGI

+ (void)checkUpdate:(NSString *)channel
           complete:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"channel": channel};
    [[RequestManager shareManager] loadAsync:params cgi:@"check_update" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
