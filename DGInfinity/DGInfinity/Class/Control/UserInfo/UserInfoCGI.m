//
//  UserInfoCGI.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/20.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "UserInfoCGI.h"

@implementation UserInfoCGI

+ (void)getUserInfo:(NSInteger)tuid
           complete:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"tuid": @(tuid)};
    [[RequestManager shareManager] loadAsync:params cgi:@"get_user_info" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)getRandNick:(void (^)(DGCgiResult *))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_rand_nick" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)modUserInfo:(NSString *)key
              value:(id)value
           complete:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{key: value};
    [[RequestManager shareManager] loadAsync:params cgi:@"mod_user_info" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)getDefHead:(void (^)(DGCgiResult *))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_def_head" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
