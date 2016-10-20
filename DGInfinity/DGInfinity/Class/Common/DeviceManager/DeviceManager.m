//
//  DeviceManager.m
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DeviceManager.h"
#import <sys/utsname.h>
#import <stdio.h>
#import <stdlib.h>
#import "SSKeychain.h"
#import "Reachability.h"

@implementation DeviceManager

+ (NSString *)getiPhoneModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone7,1"])
        return @"iPhone 6 Plus";
    else if ([deviceString isEqualToString:@"iPhone7,2"])
        return @"iPhone 6";
    else if ([deviceString isEqualToString:@"iPhone8,1"])
        return @"iPhone 6s";
    else if ([deviceString isEqualToString:@"iPhone8,2"])
        return @"iPhone 6s Plus";
    else if ([deviceString isEqualToString:@"iPhone9,1"])
        return @"iPhone 7";
    else if ([deviceString isEqualToString:@"iPhone9,2"])
        return @"iPhone 7 Plus";
    else if ([deviceString isEqualToString:@"iPhone6,1"])
        return @"iPhone 5s";
    else if ([deviceString isEqualToString:@"iPhone6,2"])
        return @"iPhone 5s";
    else if ([deviceString isEqualToString:@"iPhone8,4"])
        return @"iPhone SE";
    else if ([deviceString isEqualToString:@"iPhone5,1"])
        return @"iPhone 5";
    else if ([deviceString isEqualToString:@"iPhone5,2"])
        return @"iPhone 5";
    else if ([deviceString isEqualToString:@"iPhone5,3"])
        return @"iPhone 5c";
    else if ([deviceString isEqualToString:@"iPhone5,4"])
        return @"iPhone 5c";
    else if ([deviceString isEqualToString:@"iPhone3,1"])
        return @"iPhone 4";
    else if ([deviceString isEqualToString:@"iPhone3,2"])
        return @"iPhone 4";
    else if ([deviceString isEqualToString:@"iPhone3,3"])
        return @"iPhone 4";
    else if ([deviceString isEqualToString:@"iPhone4,1"])
        return @"iPhone 4S";
    else if ([deviceString isEqualToString:@"iPhone1,1"])
        return @"iPhone 1G";
    else if ([deviceString isEqualToString:@"iPhone1,2"])
        return @"iPhone 3G";
    else if ([deviceString isEqualToString:@"iPhone2,1"])
        return @"iPhone 3GS";
    else if ([deviceString isEqualToString:@"iPod1,1"])
        return @"iPod Touch 1G";
    else if ([deviceString isEqualToString:@"iPod2,1"])
        return @"iPod Touch 2G";
    else if ([deviceString isEqualToString:@"iPod3,1"])
        return @"iPod Touch 3G";
    else if ([deviceString isEqualToString:@"iPod4,1"])
        return @"iPod Touch 4G";
    else if ([deviceString isEqualToString:@"iPod5,1"])
        return @"iPod Touch 5G";
    else if ([deviceString isEqualToString:@"iPad1,1"])
        return @"iPad";
    else if ([deviceString isEqualToString:@"iPad2,1"])
        return @"iPad 2 Wi-Fi";
    else if ([deviceString isEqualToString:@"iPad2,2"])
        return @"iPad 2 Wi-Fi+3G+GSM";
    else if ([deviceString isEqualToString:@"iPad2,3"])
        return @"iPad 2 Wi-Fi+3G+GSM+CDMA";
    else if ([deviceString isEqualToString:@"iPad2,4"])
        return @"iPad 2 Wi-Fi";
    else if ([deviceString isEqualToString:@"iPad2,5"])
        return @"iPad mini Wi-Fi";
    else if ([deviceString isEqualToString:@"iPad2,6"])
        return @"iPad mini Wi-Fi+3G+4G+GSM";
    else if ([deviceString isEqualToString:@"iPad2,7"])
        return @"iPad mini Wi-Fi+3G+4G+GSM+CDMA";
    else if ([deviceString isEqualToString:@"iPad3,1"])
        return @"iPad 3 Wi-Fi";
    else if ([deviceString isEqualToString:@"iPad3,2"])
        return @"iPad 3 Wi-Fi+3G+GSM+CDMA";
    else if ([deviceString isEqualToString:@"iPad3,3"])
        return @"iPad 3 Wi-Fi+3G+GSM";
    else if ([deviceString isEqualToString:@"iPad3,4"])
        return @"iPad 4 Wi-Fi";
    else if ([deviceString isEqualToString:@"iPad3,5"])
        return @"iPad 4 Wi-Fi+3G+4G+GSM";
    else if ([deviceString isEqualToString:@"iPad3,6"])
        return @"iPad 4 Wi-Fi+3G+4G+GSM+CDMA ";
    else
        return @"未知";
    return deviceString;
}

+ (NSString *)getDeviceId
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *currentDeviceUUIDStr = [SSKeychain passwordForService:bundleIdentifier account:@"uuid"];
    if (currentDeviceUUIDStr == nil || !currentDeviceUUIDStr.length)
    {
        NSUUID *currentDeviceUUID  = [UIDevice currentDevice].identifierForVendor;
        currentDeviceUUIDStr = currentDeviceUUID.UUIDString;
        currentDeviceUUIDStr = [currentDeviceUUIDStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        currentDeviceUUIDStr = [currentDeviceUUIDStr lowercaseString];
        [SSKeychain setPassword:currentDeviceUUIDStr forService:bundleIdentifier account:@"uuid"];
    }
    return currentDeviceUUIDStr;
}

+ (NSInteger)getNettype
{
    NSInteger nettype = 0;
    // 判断网络情况
    Reachability *r = [Reachability reachabilityForInternetConnection];
    switch ([r currentReachabilityStatus]) {
        case ReachableViaWiFi:
            // 使用WiFi网络
            nettype = 0;
            break;
        case ReachableVia4G:
            // 使用4G网络
            nettype = 1;
            break;
        case ReachableVia3G:
            // 使用3G网络
            nettype = 2;
            break;
        case ReachableVia2G:
            // 使用2G网络
            nettype = 3;
            break;
        default:
            break;
    }
    return nettype;
}

@end
