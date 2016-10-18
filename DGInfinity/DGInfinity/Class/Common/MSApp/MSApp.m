//
//  MSApp.m
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "MSApp.h"

#define KUD_UID                     @"KUD_UID"
#define KUD_TOKEN                   @"KUD_TOKEN"

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
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
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

@end
