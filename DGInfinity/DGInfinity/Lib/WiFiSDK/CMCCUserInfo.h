//
//  UserInfo.h
//  userauthSdk
//
//  Created by 吕东阳 on 16/6/17.
//  Copyright © 2016年 LDY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMCCUserInfo : NSObject

@property (nonatomic, copy) NSString *wlanacname;
@property (nonatomic, copy) NSString *wlanuserip;
@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *wlanacip;
@property (nonatomic, copy) NSString *wlanusermac;
@property (nonatomic, copy) NSString *vnoCode;

+ (CMCCUserInfo *)shareInfo;

@end
