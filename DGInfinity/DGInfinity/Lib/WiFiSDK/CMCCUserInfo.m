//
//  UserInfo.m
//  userauthSdk
//
//  Created by 吕东阳 on 16/6/17.
//  Copyright © 2016年 LDY. All rights reserved.
//

#import "CMCCUserInfo.h"

static CMCCUserInfo *_userInfo = nil;

@implementation CMCCUserInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (CMCCUserInfo *)shareInfo
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userInfo = [[CMCCUserInfo alloc] init];
    });
    return _userInfo;
}

@end

