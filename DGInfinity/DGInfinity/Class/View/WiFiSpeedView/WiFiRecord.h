//
//  WiFiRecord.h
//  360FreeWiFi
//
//  Created by lijinwei on 14-10-24.
//  Copyright (c) 2014年 qihoo360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiFiShop : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *brandName;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *tab;
@property (nonatomic, copy) NSString *partnerId;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface WiFiSecurity : NSObject

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, copy) NSString *datetime;
@property (nonatomic, copy) NSDictionary *detailDictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

typedef NS_ENUM(NSUInteger, WIFI_INFO_SIGNAL_STRENGTH)
{
    WIFI_INFO_SIGNAL_STRENGTH_ONE = 1,
    WIFI_INFO_SIGNAL_STRENGTH_TWO,
    WIFI_INFO_SIGNAL_STRENGTH_THREE,
    WIFI_INFO_SIGNAL_STRENGTH_FOUR,
};


@interface WiFiRecord : NSObject

@property (nonatomic, strong) NSString * m_id;
@property (nonatomic, strong) NSString * m_mac;
@property (nonatomic, strong) NSString * m_ssid;
@property (nonatomic, strong) NSString * m_pwd;
@property (nonatomic, strong) NSString * m_salt;
@property (nonatomic, strong) NSString * m_alt;
@property (nonatomic, strong) NSString * m_lat;
@property (nonatomic, strong) NSString * m_lng;
@property (nonatomic, strong) NSString * m_geohash;
@property (nonatomic, strong) NSString * m_address;
@property (nonatomic, strong) NSString * m_displayname;
@property (nonatomic, strong) NSString * m_displaydesc;
@property (nonatomic, strong) NSString * m_displayicon;
@property (nonatomic, strong) NSString * m_belongto;
@property (nonatomic, strong) NSString * m_contactinfo;
@property (nonatomic, strong) NSString * m_lastheartbeat;
@property (nonatomic, strong) NSString * m_avgspeed;
@property (nonatomic, strong) NSString * m_lastspeed;
@property (nonatomic, strong) NSString * m_ispublic;
@property (nonatomic, strong) NSString * m_isphishing;
@property (nonatomic, strong) NSString * m_isfake;
@property (nonatomic, strong) NSString * m_isdnswell;
@property (nonatomic, strong) NSString * m_connectedrate;
@property (nonatomic, strong) NSString * m_shareable;
@property (nonatomic, strong) NSString * m_sharetimes;
@property (nonatomic, strong) NSString * m_connecttimes;
@property (nonatomic, strong) NSString* m_wifiIcon;
@property (nonatomic, assign) int64_t    m_distance;
@property (nonatomic, assign) BOOL m_isLocalOCR;
@property (nonatomic, strong) NSString *m_wifirating;
@property (nonatomic, assign) WIFI_INFO_SIGNAL_STRENGTH m_signalstrength;
@property (nonatomic, assign) NSInteger  m_status;
@property (nonatomic, assign) NSInteger m_securityLevel;
@property (nonatomic, strong) WiFiShop *m_shop;
@property (nonatomic, strong) WiFiSecurity *m_security;
@property (nonatomic, assign) NSInteger m_dnsHijack;

#pragma mark -
#pragma mark ============== added by sheng ==============
#pragma mark -
@property (nonatomic, assign) BOOL isConnectToWeb;//此标志位只是有网和无网的一个辅助标志位，用来区分有网和需要密码
@property (nonatomic, assign) BOOL isNotNeedPwd;

- (bool) readFromJosnDictionary:(NSDictionary*)data;
+ (WiFiRecord*) initFromJosnDictionary:(NSDictionary*)data;
- (NSComparisonResult)compareWithDisAs:(WiFiRecord *)info;

@end
