//
//  ConnectedDeviceUtils.h
//  360FreeWiFi
//
//  Created by 黄继华 on 16/4/5.
//  Copyright © 2016年 qihoo360. All rights reserved.
//

#import "RMConnectedDevice.h"

#define NOTIFICATION_CONNECTED_DEVICE_LIST_CHANGED @"notification_connected_device_list_changed"

@interface ConnectedDeviceUtils : NSObject

+ (instancetype)sharedInstance;

- (void)sendUdpToRefreshConnectedDevice;
- (void)clearConnectedDeviceList;
- (NSArray<RMConnectedDevice *> *)getConnectedDeviceList;
- (NSArray<RMConnectedDevice *> *)getConnectedDeviceListWithoutCurrent;

@end