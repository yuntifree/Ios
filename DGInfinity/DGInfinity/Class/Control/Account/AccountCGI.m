//
//  AccountCGI.m
//  DGInfinity
//
//  Created by myeah on 16/10/19.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "AccountCGI.h"
#import "DeviceManager.h"
#import "CMCCUserInfo.h"

@implementation AccountCGI

+ (void)getPhoneCode:(NSString *)phone
                type:(NSInteger)type
            complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"phone": phone,
                        @"type": @(type)};
    [[RequestManager shareManager] loadAsync:params cgi:@"get_phone_code" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)doRegister:(NSString *)username
          password:(NSString *)password
          complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    if ([username isEqualToString:TestAccount]) {
        params[@"data"] = @{@"username": username,
                            @"password": [[password dataUsingEncoding:NSUTF8StringEncoding] md5Hash],
                            @"channel": @"App Store",
                            @"model": [DeviceManager getiPhoneModel],
                            @"udid": [DeviceManager getDeviceId]};
    } else {
        params[@"data"] = @{@"username": username,
                            @"password": [[password dataUsingEncoding:NSUTF8StringEncoding] md5Hash],
                            @"channel": @"App Store",
                            @"model": [DeviceManager getiPhoneModel],
                            @"udid": [DeviceManager getDeviceId],
                            @"code": password};
    }
    
    [[RequestManager shareManager] loadAsync:params cgi:@"register" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)login:(NSString *)username
     password:(NSString *)password
     complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"username": username,
                        @"password": [[password dataUsingEncoding:NSUTF8StringEncoding] md5Hash],
                        @"model": [DeviceManager getiPhoneModel],
                        @"udid": [DeviceManager getDeviceId]};
    [[RequestManager shareManager] loadAsync:params cgi:@"login" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)autoLogin:(NSString *)privdata
         complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"privdata": privdata};
    [[RequestManager shareManager] loadAsync:params cgi:@"auto_login" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)logout:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"logout" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)getCheckCode:(NSString *)phone
            complete:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"phone": phone};
    [[RequestManager shareManager] loadAsync:params cgi:@"get_check_code" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)ConnectWifi:(void (^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    CMCCUserInfo *info = [CMCCUserInfo shareInfo];
    if (info.wlanacname) {
        data[@"wlanacname"] = info.wlanacname;
    }
    if (info.wlanuserip) {
        data[@"wlanuserip"] = info.wlanuserip;
    }
    if (info.wlanacip) {
        data[@"wlanacip"] = info.wlanacip;
    }
    if (info.wlanusermac) {
        data[@"wlanusermac"] = info.wlanusermac;
    }
    data[@"apmac"] = [Tools getBSSID];
    params[@"data"] = data;
    [[RequestManager shareManager] loadAsync:params cgi:@"connect_wifi" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
