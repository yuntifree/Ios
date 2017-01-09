//
//  MSApp.m
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "MSApp.h"
#import "AccountCGI.h"
#import "NewsCGI.h"
#import "MiPushSDK.h"
#import "WiFiCGI.h"

#define KUD_UID                     @"KUD_UID"
#define KUD_TOKEN                   @"KUD_TOKEN"
#define KUD_USERNAME                @"KUD_USERNAME"
#define KUD_PRIVDATA                @"KUD_PRIVDATA"
#define KUD_EXPIRETIME              @"KUD_EXPIRETIME"
#define KUD_WIFIPASS                @"KUD_WIFIPASS"
#define KUD_APPVERSION              @"KUD_APPVERSION"
#define KUD_SPLASHIMAGE             @"KUD_SPLASHIMAGE"
#define KUD_SPLASHDST               @"KUD_SPLASHDST"
#define KUD_SPLASHTITLE             @"KUD_SPLASHTITLE"
#define KUD_SPLASHEXPIRE            @"KUD_SPLASHEXPIRE"

@implementation MSApp

static MSApp *mSapp = nil;

+ (instancetype)sharedMSApp
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mSapp = [[[self class] alloc] init];
    });
    return mSapp;
}

+ (void)destory
{
    [SApp unSetMiPush];
    mSapp.uid = 0;
    mSapp.token = nil;
    mSapp.privdata = nil;
    mSapp.expiretime = nil;
    mSapp.wifipass = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reportArray = [NSMutableArray array];
        _beWakened = NO;
    }
    return self;
}

+ (void)setUserInfo:(NSDictionary *)data
{
    NSInteger uid = [data[@"uid"] integerValue];
    NSString *token = data[@"token"];
    NSString *privdata = data[@"privdata"];
    NSString *expiretime = data[@"expiretime"];
    if (uid) {
        SApp.uid = uid;
    }
    if (token.length) {
        SApp.token = token;
    }
    if (privdata.length) {
        SApp.privdata = privdata;
    }
    if (expiretime.length) {
        SApp.expiretime = expiretime;
    }
    [SApp setMiPush];
}

+ (void)autoLogin
{
    NSString *dateStr = [NSDate formatStringWithDate:[NSDate date]];
    if (SApp.uid && SApp.privdata.length && (!SApp.expiretime || [SApp.expiretime compare:dateStr] != NSOrderedDescending)) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); // 创建信号量
        
        NSURL *url = [NSURL URLWithString:[[RequestManager shareManager] urlPath:@"auto_login"]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1.5];
        [request setHTTPMethod:@"POST"];
        NSMutableDictionary *params = [RequestManager httpParams];
        params[@"data"] = @{@"privdata": SApp.privdata};
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:data];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error && data) {
                NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([res isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *data = res[@"data"];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        [self setUserInfo:data];
                    }
                }
            }
            dispatch_semaphore_signal(semaphore); // 发送信号
        }];
        [task resume];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); // 等待信号
    }
}

- (void)setMiPush
{
    if (SApp.uid) {
        [MiPushSDK setAlias:[NSString stringWithFormat:@"%ld",SApp.uid]];
    }
}

- (void)unSetMiPush
{
    if (SApp.uid) {
        [MiPushSDK unsetAlias:[NSString stringWithFormat:@"%ld",SApp.uid]];
    }
}

- (void)getFlashAD
{
    if (!SApp.uid) return;
    [WiFiCGI getFlashAd:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if (!data) {
                SApp.splashImage = nil;
                SApp.splashDst = nil;
                SApp.splashTitle = nil;
                SApp.splashExpire = nil;
            } else if ([data isKindOfClass:[NSDictionary class]]) {
                NSString *img = data[@"img"];
                if (img.length) {
                    if ([Tools containsImageForKey:img]) {
                        SApp.splashImage = img;
                        SApp.splashDst = data[@"dst"];
                        SApp.splashTitle = data[@"title"];
                        SApp.splashExpire = data[@"expire"];
                    } else {
                        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:img] options:0 progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                            if (image) {
                                SApp.splashImage = img;
                                SApp.splashDst = data[@"dst"];
                                SApp.splashTitle = data[@"title"];
                                SApp.splashExpire = data[@"expire"];
                                [Tools saveImage:image forKey:img];
                            }
                        }];
                    }
                }
            }
        }
    }];
}

- (void)setUid:(NSInteger)uid
{
    [NSUSERDEFAULTS setObject:[NSNumber numberWithInteger:uid] forKey:KUD_UID];
    [NSUSERDEFAULTS synchronize];
}

- (NSInteger)uid
{
    return [[NSUSERDEFAULTS objectForKey:KUD_UID] integerValue];
}

- (void)setToken:(NSString *)token
{
    [NSUSERDEFAULTS setObject:token forKey:KUD_TOKEN];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)token
{
    return [NSUSERDEFAULTS objectForKey:KUD_TOKEN];
}

- (void)setUsername:(NSString *)username
{
    [NSUSERDEFAULTS setObject:username forKey:KUD_USERNAME];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)username
{
    return [NSUSERDEFAULTS objectForKey:KUD_USERNAME];
}

- (void)setPrivdata:(NSString *)privdata
{
    [NSUSERDEFAULTS setObject:privdata forKey:KUD_PRIVDATA];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)privdata
{
    return [NSUSERDEFAULTS objectForKey:KUD_PRIVDATA];
}

- (void)setExpiretime:(NSString *)expiretime
{
    [NSUSERDEFAULTS setObject:expiretime forKey:KUD_EXPIRETIME];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)expiretime
{
    return [NSUSERDEFAULTS objectForKey:KUD_EXPIRETIME];
}

- (void)setWifipass:(NSString *)wifipass
{
    [NSUSERDEFAULTS setObject:wifipass forKey:KUD_WIFIPASS];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)wifipass
{
    return [NSUSERDEFAULTS objectForKey:KUD_WIFIPASS];
}

- (void)setAppVersion:(NSString *)appVersion
{
    [NSUSERDEFAULTS setObject:appVersion forKey:KUD_APPVERSION];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)appVersion
{
    return [NSUSERDEFAULTS objectForKey:KUD_APPVERSION];
}

- (void)setSplashImage:(NSString *)splashImage
{
    [NSUSERDEFAULTS setObject:splashImage forKey:KUD_SPLASHIMAGE];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)splashImage
{
    return [NSUSERDEFAULTS objectForKey:KUD_SPLASHIMAGE];
}

- (void)setSplashDst:(NSString *)splashDst
{
    [NSUSERDEFAULTS setObject:splashDst forKey:KUD_SPLASHDST];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)splashDst
{
    return [NSUSERDEFAULTS objectForKey:KUD_SPLASHDST];
}

- (void)setSplashTitle:(NSString *)splashTitle
{
    [NSUSERDEFAULTS setObject:splashTitle forKey:KUD_SPLASHTITLE];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)splashTitle
{
    return [NSUSERDEFAULTS objectForKey:KUD_SPLASHTITLE];
}

- (void)setSplashExpire:(NSString *)splashExpire
{
    [NSUSERDEFAULTS setObject:splashExpire forKey:KUD_SPLASHEXPIRE];
    [NSUSERDEFAULTS synchronize];
}

- (NSString *)splashExpire
{
    return [NSUSERDEFAULTS objectForKey:KUD_SPLASHEXPIRE];
}

#pragma mark - ReportClick
- (void)reportClick:(ReportClickModel *)model
{
    BOOL exist = NO;
    for (ReportClickModel *md in _reportArray) {
        if (model.id_ == md.id_ && model.type == md.type) {
            if (model.time > md.time + 60) {
                md.time = model.time;
                [NewsCGI reportClick:model.id_ type:model.type complete:nil];
            }
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [_reportArray addObject:model];
        [NewsCGI reportClick:model.id_ type:model.type complete:nil];
    }
}

@end
