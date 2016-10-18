//
//  RequestManager.m
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "RequestManager.h"
#import "DeviceManager.h"

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

@implementation RequestManager

static RequestManager *manager = nil;

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = (RequestManager *)[AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        // set timeoutInterval
        manager.requestSerializer.timeoutInterval = MAX_REQUEST_TIMEOUT;
    });
    return manager;
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
    params[@"channel"] = @"App Store";
    params[@"model"] = [DeviceManager getiPhoneModel];
    params[@"udid"] = [DeviceManager getDeviceId];
    
    return params;
}

- (NSString *)urlPath:(NSString *)cgi
{
    return [NSString stringWithFormat:@"%@%@",ServerURL, cgi];
}

- (void)loadAsync:(NSDictionary *)params cgi:(NSString *)cgi complete:(void(^)(DGCgiResult *res))complete
{
    NetworkShow;
    [self POST:[self urlPath:cgi] parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
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
            } else {
                DGCgiResult *r = [[DGCgiResult alloc] init];
                r._errno = E_INVALID_DATA;
                r.desc = @"请检查您的网络~";
                complete(r);
            }
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
