
//
//  LiveCGI.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/15.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "LiveCGI.h"

@implementation LiveCGI

+ (void)getLiveInfo:(NSInteger)seq
           complete:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"seq": @(seq)};
    [[RequestManager shareManager] loadAsync:params cgi:@"get_live_info" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
