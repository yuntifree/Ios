//
//  Tools.m
//  DGInfinity
//
//  Created by myeah on 16/10/26.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "Tools.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation Tools

+ (void)openWifiList
{
    NSURL *openURL = [NSURL URLWithString:@"prefs:root=WIFI"];
    if ([[UIApplication sharedApplication] canOpenURL:openURL]) {
        [[UIApplication sharedApplication] openURL:openURL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请手动打开系统WiFi列表" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
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

@end
