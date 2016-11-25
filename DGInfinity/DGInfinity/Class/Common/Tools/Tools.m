//
//  Tools.m
//  DGInfinity
//
//  Created by myeah on 16/10/26.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "Tools.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "NetworkManager.h"
#import <AVFoundation/AVFoundation.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#import <arpa/inet.h>
#include <net/if.h>
#include "getgateway.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#define IP_MASK_IPv4    @"mask_ipv4"
#define IP_MASK_IPv6    @"mask_ipv6"

@implementation Tools

+ (void)openWifiList
{
    NSURL *openURL = [NSURL URLWithString:@"prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
        [[UIApplication sharedApplication] openURL:openURL];
    } else {
        [[UIApplication sharedApplication].keyWindow.rootViewController showAlertWithTitle:@"提示" message:@"请手动打开系统WiFi列表" cancelTitle:@"知道了" cancelHandler:nil defaultTitle:nil defaultHandler:nil];
    }
}

+ (void)registerNotification
{
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

+ (void)showNotificationMessages:(NSString *)body
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *freeWifiNotification  = [UILocalNotification new];
    freeWifiNotification.alertAction = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    freeWifiNotification.alertBody = body;
    freeWifiNotification.soundName = UILocalNotificationDefaultSoundName;
    freeWifiNotification.fireDate = [NSDate date];
    [[UIApplication sharedApplication] scheduleLocalNotification:freeWifiNotification];
}

+ (NSString *)getCurrentSSID
{
    if (![[NetworkManager shareManager] isWiFi]) {
        return nil;
    }
    NSArray *supportedInterfacesArray = (__bridge_transfer id)CNCopySupportedInterfaces();
    id currentNetworkInfoDictionary = nil;
    for (NSString *interfaceName in supportedInterfacesArray) {
        currentNetworkInfoDictionary = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
        if ([currentNetworkInfoDictionary count] > 0) {
            break;
        }
        currentNetworkInfoDictionary = nil;
    }
    
    NSString *ssid = nil;
    if ([currentNetworkInfoDictionary isKindOfClass: [NSDictionary class]]) {
        ssid = [currentNetworkInfoDictionary objectForKey: @"SSID"];
    }
    return ssid;
}

+ (NSString *)getBSSID
{
    /*! Get the interfaces */
    NSArray *interfaces = (__bridge NSArray *) CNCopySupportedInterfaces();
    NSString *BSSID;
    
    /*! Cycle interfaces */
    for (NSString *interface in interfaces)
    {
        CFDictionaryRef networkDetails = CNCopyCurrentNetworkInfo((__bridge CFStringRef) interface);
        if (networkDetails)
        {
            BSSID = (NSString *)CFDictionaryGetValue(networkDetails, kCNNetworkInfoKeyBSSID);
            CFRelease(networkDetails);
        }
    }
    
    NSMutableString* formatSSID = [[NSMutableString alloc] initWithCapacity:100];
    NSArray* separateSSID = [BSSID componentsSeparatedByString:@":"];
    if( [separateSSID count] == 6 )
    {
        for (NSString * ssid in separateSSID) {
            if( [formatSSID length] > 0 )
            {
                [formatSSID appendString:@":"];
            }
            if( [ssid length] == 1 )
            {
                [formatSSID appendFormat:@"0%@", ssid];
            }
            else
            {
                [formatSSID appendFormat:@"%@", ssid];
            }
            
        }
    }
    
    return formatSSID.length ? [formatSSID uppercaseString] : @"";
}

+ (void)openSetting
{
    if (UIApplicationOpenSettingsURLString != NULL) {
        NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:appSettings]) {
            [[UIApplication sharedApplication] openURL:appSettings];
        }
    } else {
        NSURL *url = [NSURL URLWithString:@"prefs:root=com.yunxingzh.wireless"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

+ (CGFloat)layoutFactor
{
    CGFloat factor = 1.0f;
    NSInteger height = kScreenHeight;
    switch (height) {
        case 480:
            factor = 480 / 667.0;
            break;
        case 568:
            factor = 568 / 667.0;
            break;
        case 667:
            break;
        case 736:
            factor = 736 / 667.0;
            break;
        default:
            break;
    }
    return factor;
}

+ (void)permissionOfCamera:(void (^)())successBlock noPermission:(void (^)(NSString *tip))noPermisson
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) { // 检测摄像头权限
        if (granted) { // 已经打开了摄像头权限
            dispatch_async(dispatch_get_main_queue(), ^{
                if (successBlock) {
                    successBlock();
                }
            });
        } else { // 没有打开摄像头权限
            dispatch_async(dispatch_get_main_queue(), ^{
                if (noPermisson) {
                    noPermisson(@"此应用程序没有权限访问您的相机，请到「设置->东莞无线」中打开相机权限。");
                }
            });
        }
    }];
}

+ (NSString *)getWlanSubnetMask
{
    NSDictionary *dictionary = [self getIPAddresses];
    NSString *mask = dictionary[@"en0/mask_ipv4"];
    if ([mask length] == 0) {
        mask = dictionary[@"en0/mask_ipv6"];
    }
    return mask;
}

/*! 获取 WLAN IP 地址 */
+ (NSString *)getWlanIPAddress
{
    BOOL isWlanIp = NO;
    
    NSString *address = [self getCurrentIPAddress: &isWlanIp];
    
    if (isWlanIp == NO) {
        address = nil;
    }
    
    return address;
}

/*!
 *    获取设备当前的 IP 地址。
 *    优先获取 WLAN 地址，其不存在时再获取 WWAN 地址；优先获取 IPv4 地址，其不存在时再获取 IPv6 地址
 */
+ (NSString *)getCurrentIPAddress:(BOOL *)isWlanIp
{
    NSDictionary *dictionary = [self getIPAddresses];
    
    NSString *address = dictionary[@"en0/ipv4"];
    if (isWlanIp) {
        *isWlanIp = YES;
    }
    
    //169.254.0.0-169.254.255.255，是保留地址段，开启了dhcp服务的设备但又无法获取到dhcp的会随机使用这个网段的 ip
    if (address.length == 0 || [address hasPrefix: @"169.254"]) {
        address = dictionary[@"en0/ipv6"];
        if (isWlanIp) {
            *isWlanIp = YES;
        }
    }
    
    if (address.length == 0) {
        address = dictionary[@"pdp_ip0/ipv4"];
        if (isWlanIp) {
            *isWlanIp = NO;
        }
    }
    
    if (address.length == 0) {
        address = dictionary[@"pdp_ip0/ipv6"];
        if (isWlanIp) {
            *isWlanIp = NO;
        }
    }
    
    return address;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
            
            const struct sockaddr_in *netmask = (const struct sockaddr_in *)interface->ifa_netmask;
            if(netmask && (netmask->sin_family == AF_INET || netmask->sin_family == AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type = nil;
                if (netmask->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &netmask->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_MASK_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *netmask = (const struct sockaddr_in6 *)interface->ifa_netmask;
                    if(inet_ntop(AF_INET6, &netmask->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_MASK_IPv6;
                    }
                }
                if (type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String: addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString *)getServerWiFiIPAddress
{
    if (![[NetworkManager shareManager] isWiFi]) {
        return nil;
    }
    
    in_addr_t addr = 0;
    getdefaultgateway(&addr);
    addr = ntohl(addr);
    
    NSString *ip = nil;
    if (addr > 0) {
        int i1 = addr / (256 * 256 * 256);
        int i2 = (addr - i1 * 256 * 256 * 256) / (256 * 256);
        int i3 = (addr - i1 * 256 * 256 * 256 - i2 * 256 * 256) / 256;
        int i4 = addr - i1 * 256 * 256 * 256 - i2 * 256 * 256 - i3 * 256;
        ip = [NSString stringWithFormat: @"%d.%d.%d.%d", i1, i2, i3, i4];
    }
    
    return ip;
}

+ (TimeType)getTimeType
{
    NSString *hourStr = [NSDate stringWithDate:[NSDate date] formatStr:@"HH"];
    NSInteger hour = [hourStr integerValue];
    TimeType type;
    if (hour >= 6 && hour < 19) { // 早上6点-晚上7点算白天
        type = TimeTypeDay;
    } else {
        type = TimeTypeNight;
    }
    return type;
}

@end
