//
//  WebKitSupport.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/9/12.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "WebKitSupport.h"

@implementation WebKitSupport

+ (instancetype)sharedSupport
{
    static WebKitSupport *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _processPool = [WKProcessPool new];
    }
    return self;
}

@end
