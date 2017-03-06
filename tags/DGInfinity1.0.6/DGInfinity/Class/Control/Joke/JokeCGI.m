//
//  JokeCGI.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/23.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "JokeCGI.h"

@implementation JokeCGI

+ (void)getJokes:(NSInteger)seq
        complete:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"seq": @(seq)};
    [[RequestManager shareManager] loadAsync:params cgi:@"get_jokes" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
