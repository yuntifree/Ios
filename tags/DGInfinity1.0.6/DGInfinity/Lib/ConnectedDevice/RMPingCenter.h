//
//  RMPingCenter.h
//  360FreeWiFi
//
//  Created by 黄继华 on 16/4/29.
//  Copyright © 2016年 qihoo360. All rights reserved.
//

#define NOTIFICATION_CONNECTED_DEVICE_LIST_CHANGED_USING_PING @"notification_connected_device_list_changed_using_ping"

@class RMConnectedDevice;

@interface RMPingCenter : NSObject

+ (instancetype)sharedInstance;

- (void)scan;
- (void)stop;
- (NSArray<RMConnectedDevice *> *)getConnectedDevice;
- (NSArray<RMConnectedDevice *> *)getConnectedDeviceWithoutCurrent;

@end
