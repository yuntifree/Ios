//
//  RequestManager.m
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "RequestManager.h"
#import "DeviceManager.h"
#import <AFHTTPSessionManager.h>

#define MAX_REQUEST_TIMEOUT     7

@implementation DGCgiResult

- (instancetype)init
{
    self = [super init];
    if (self) {
        __errno = 0;
    }
    return self;
}

@end

@interface RequestManager ()
{
    AFHTTPSessionManager *_mgr;
}
@end

@implementation RequestManager

static RequestManager *manager = nil;

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mgr = [AFHTTPSessionManager manager];
        _mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
        _mgr.requestSerializer = [AFJSONRequestSerializer serializer];
        
        // set timeoutInterval
        _mgr.requestSerializer.timeoutInterval = MAX_REQUEST_TIMEOUT;
    }
    return self;
}

+ (NSMutableDictionary *)httpParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (SApp.uid) {
        params[@"uid"] = @(SApp.uid);
    }
    if (SApp.token.length) {
        params[@"token"] = SApp.token;
    }
    params[@"term"] = @(T_IOS);
    params[@"version"] = @(AppVersion);
    params[@"ts"] = CURRENT_TS;
    params[@"nettype"] = @([DeviceManager getNettype]);
    
    return params;
}

- (NSString *)urlPath:(NSString *)cgi
{
    return [NSString stringWithFormat:@"%@%@",ServerURL, cgi];
}

- (void)loadAsync:(NSDictionary *)params cgi:(NSString *)cgi complete:(void(^)(DGCgiResult *res))complete
{
    NetworkShow;
    [_mgr POST:[self urlPath:cgi] parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NetworkHide;
        if (responseObject && [responseObject isKindOfClass:[NSData class]]) {
            id json = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if (json && [json isKindOfClass:[NSDictionary class]]) {
                int errcode = [[json objectForKey:@"errno"] intValue];
                
                DGCgiResult *r = [[DGCgiResult alloc] init];
                r._errno = errcode;
                r.desc = [json objectForKey:@"desc"];
                r.data = json;
                complete(r);
                
                // 账号被踢 特殊逻辑
                if (E_TOKEN == r._errno) {
                    [MSApp destory];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNC_LOGOUT object:nil];
                }
            } else {
                DGCgiResult *r = [[DGCgiResult alloc] init];
                r._errno = E_INVALID_DATA;
                r.desc = @"请求数据错误~";
                complete(r);
            }
        } else {
            DGCgiResult *r = [[DGCgiResult alloc] init];
            r._errno = E_INVALID_DATA;
            r.desc = @"请求数据错误~";
            complete(r);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NetworkHide;
        DGCgiResult *r = [[DGCgiResult alloc] init];
        r._errno = E_CGI_FAILED;
        if ([[error localizedFailureReason] length]) {
            r.desc = [error localizedFailureReason];
        } else {
            r.desc = @"请检查您的网络~";
        }
        complete(r);
    }];
}

@end
