//
//  UserInfo.h
//  userauthSdk
//
//  Created by 吕东阳 on 16/6/17.
//  Copyright © 2016年 LDY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMCCUserInfo : NSObject

@property (nonatomic, strong) NSString *wlanacname;
@property (nonatomic, strong) NSString *wlanuserip;
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *wlanacip;
@property (nonatomic, strong) NSString *wlanusermac;
@property (nonatomic, strong) NSString *vnoCode;

+ (CMCCUserInfo *)shareInfo;

@end
