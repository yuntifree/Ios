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

@implementation Tools

+ (void)openWifiList
{
    NSURL *openURL = [NSURL URLWithString:@"prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
        [[UIApplication sharedApplication] openURL:openURL];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请手动打开系统WiFi列表" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
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
    
    return formatSSID;
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

@end
