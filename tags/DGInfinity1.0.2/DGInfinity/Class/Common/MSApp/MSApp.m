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
#import "WiFiCGI.h"

#define KUD_UID                     @"KUD_UID"
#define KUD_TOKEN                   @"KUD_TOKEN"
#define KUD_USERNAME                @"KUD_USERNAME"
#define KUD_PRIVDATA                @"KUD_PRIVDATA"
#define KUD_EXPIRE                  @"KUD_EXPIRE"
#define KUD_WIFIPASS                @"KUD_WIFIPASS"
#define KUD_APPVERSION              @"KUD_APPVERSION"
#define KUD_SPLASHIMAGE             @"KUD_SPLASHIMAGE"
#define KUD_SPLASHDST               @"KUD_SPLASHDST"
#define KUD_SPLASHTITLE             @"KUD_SPLASHTITLE"

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
    mSapp.uid = 0;
    mSapp.token = nil;
    mSapp.privdata = nil;
    mSapp.expire = 0;
    mSapp.wifipass = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reportArray = [NSMutableArray array];
    }
    return self;
}

+ (void)setUserInfo:(NSDictionary *)data
{
    NSInteger uid = [data[@"uid"] integerValue];
    NSString *token = data[@"token"];
    NSString *privdata = data[@"privdata"];
    NSTimeInterval expire = [data[@"expire"] doubleValue];
    if (uid) {
        SApp.uid = uid;
    }
    if (token.length) {
        SApp.token = token;
    }
    if (privdata.length) {
        SApp.privdata = privdata;
    }
    if (expire > 0) {
        SApp.expire = expire + [[NSDate date] timeIntervalSince1970];
    }
}

+ (void)autoLogin
{
    if (SApp.uid && SApp.privdata.length && SApp.expire <= [[NSDate date] timeIntervalSince1970]) {
        [AccountCGI autoLogin:SApp.privdata complete:^(DGCgiResult *res) {
            if (E_OK == res._errno) {
                NSDictionary *data = res.data[@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    [self setUserInfo:data];
                }
            }
        }];
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
            } else if ([data isKindOfClass:[NSDictionary class]]) {
                NSString *img = data[@"img"];
                if (img.length && ![[YYImageCache sharedCache] containsImageForKey:img withType:YYImageCacheTypeDisk]) {
                    [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:img] options:0 progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                        if (image) {
                            SApp.splashImage = url.absoluteString;
                            SApp.splashDst = data[@"dst"];
                            SApp.splashTitle = data[@"title"];
                            [[YYImageCache sharedCache] setImage:image forKey:SApp.splashImage];
                        }
                    }];
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

- (void)setExpire:(NSTimeInterval)expire
{
    [NSUSERDEFAULTS setObject:@(expire) forKey:KUD_EXPIRE];
    [NSUSERDEFAULTS synchronize];
}

- (NSTimeInterval)expire
{
    return [[NSUSERDEFAULTS objectForKey:KUD_EXPIRE] doubleValue];
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
