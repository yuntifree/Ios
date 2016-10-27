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

@end
