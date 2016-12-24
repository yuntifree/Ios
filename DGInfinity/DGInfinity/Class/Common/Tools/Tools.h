//
//  Tools.h
//  DGInfinity
//
//  Created by myeah on 16/10/26.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+ (void)openWifiList;
+ (void)registerNotification;
+ (void)showNotificationMessages:(NSString *)body;
+ (NSString *)getCurrentSSID;
+ (NSString *)getBSSID;
+ (void)openSetting;
+ (CGFloat)layoutFactor;
+ (void)permissionOfCamera:(void (^)())successBlock noPermission:(void (^)(NSString *tip))noPermisson;
+ (NSString *)getWlanSubnetMask;
+ (NSString *)getWlanIPAddress;
+ (NSString *)getServerWiFiIPAddress;
+ (TimeType)getTimeType;
+ (BOOL)isAllowedNotification;
+ (NSString *)dictionaryToJsonString:(NSDictionary *)dictionary;
+ (NSDictionary *)jsonStringToDictionary:(NSString *)jsonString;
+ (void)saveImage:(UIImage *)image forKey:(NSString *)key;
+ (BOOL)containsImageForKey:(NSString *)key;
+ (UIImage *)getImageForKey:(NSString *)key;

@end
