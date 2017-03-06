//
//  RMConnectedDevice.m
//  360FreeWiFi
//
//  Created by 黄继华 on 16/4/29.
//  Copyright © 2016年 qihoo360. All rights reserved.
//

#import "RMConnectedDevice.h"

@implementation RMConnectedDevice

- (BOOL)isEqual:(RMConnectedDevice *)object
{
    if (![object isKindOfClass: [RMConnectedDevice class]]) {
        return NO;
    }

    return [self.ip isEqualToString: object.ip];
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@: %p> ip: %@ mac:%@ color:%@", NSStringFromClass([self class]), self, self.ip, self.mac, self.backgroundColor];
}

@end