//
//  DeviceManager.h
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceManager : NSObject

+ (NSString *)getiPhoneModel;
+ (NSString *)getDeviceId;
+ (NSInteger)getNettype;

@end
