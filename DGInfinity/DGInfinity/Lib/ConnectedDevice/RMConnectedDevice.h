//
//  RMConnectedDevice.h
//  360FreeWiFi
//
//  Created by 黄继华 on 16/4/29.
//  Copyright © 2016年 qihoo360. All rights reserved.
//

@interface RMConnectedDevice : NSObject

@property(nonatomic, copy) NSString *ip;
@property(nonatomic, copy) NSString *mac;
@property(copy, nonatomic) NSString *display_name;
@property(copy, nonatomic) NSString *dev_name;
@property(copy, nonatomic) NSString *icon;
@property(nonatomic, copy) NSString *backgroundColor;
@property(nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *brand;
@property(nonatomic, assign) BOOL isCurrentDevice;

@end
