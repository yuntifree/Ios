//
//  WiFiRecord.m
//  360FreeWiFi
//
//  Created by lijinwei on 14-10-24.
//  Copyright (c) 2014年 qihoo360. All rights reserved.
//

#import "WiFiRecord.h"
#import "NSSafeAddition.h"
#import <objc/runtime.h>

@interface WiFiShop()<NSCoding>

@end

@implementation WiFiShop

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        if ([dictionary isKindOfClass: [NSDictionary class]]) {
            _identifier = [dictionary[@"id"] safeStringValue];
            _name = [dictionary[@"name"] safeStringValue];
            _brandName = [dictionary[@"brand_name"] safeStringValue];
            _url = [dictionary[@"url"] safeStringValue];
            _icon = [dictionary[@"icon"] safeStringValue];
            _tab = [dictionary[@"tab"] safeStringValue];
            _partnerId = [dictionary[@"partner_id"] safeStringValue];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject: self.identifier forKey: @"shop.id"];
    [coder encodeObject: self.name forKey: @"shop.name"];
    [coder encodeObject: self.brandName forKey: @"shop.brand_name"];
    [coder encodeObject: self.url forKey: @"shop.url"];
    [coder encodeObject: self.icon forKey: @"shop.icon"];
    [coder encodeObject: self.tab forKey: @"shop.tab"];
    [coder encodeObject: self.partnerId forKey: @"shop.partner_id"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _identifier = [coder decodeObjectForKey: @"shop.id"];
        _name = [coder decodeObjectForKey: @"shop.name"];
        _brandName = [coder decodeObjectForKey: @"shop.brand_name"];
        _url = [coder decodeObjectForKey: @"shop.url"];
        _icon = [coder decodeObjectForKey: @"shop.icon"];
        _tab = [coder decodeObjectForKey: @"shop.tab"];
        _partnerId = [coder decodeObjectForKey: @"shop.partner_id"];
    }
    return self;
}

@end

@interface WiFiSecurity()<NSCoding>

@end

@implementation WiFiSecurity

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        if ([dictionary isKindOfClass: [NSDictionary class]]) {
            _level = [dictionary[@"level"] safeIntegerValue];
            _datetime = [dictionary[@"datetime"] safeStringValue];
            _detailDictionary = [dictionary[@"detail"] safeDictionaryValue];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInteger: self.level forKey: @"security.level"];
    [coder encodeObject: self.datetime forKey: @"security.datetime"];
    [coder encodeObject: self.detailDictionary forKey: @"security.detail"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _level = [coder decodeIntegerForKey: @"security.level"];
        _datetime = [coder decodeObjectForKey: @"security.datetime"];
        _detailDictionary = [coder decodeObjectForKey: @"security.detail"];
    }
    return self;
}

@end


@interface WiFiRecord ()<NSCoding>

@end



@implementation WiFiRecord

@synthesize m_id;
@synthesize m_mac;
@synthesize m_ssid;
@synthesize m_pwd;
@synthesize m_salt;
@synthesize m_lat;
@synthesize m_lng;
@synthesize m_alt;
@synthesize m_geohash;
@synthesize m_address;
@synthesize m_displayname;
@synthesize m_displaydesc;
@synthesize m_displayicon;
@synthesize m_belongto;
@synthesize m_contactinfo;
@synthesize m_lastheartbeat;
@synthesize m_avgspeed;
@synthesize m_lastspeed;
@synthesize m_ispublic;
@synthesize m_isphishing;
@synthesize m_isfake;
@synthesize m_isdnswell;
@synthesize m_connectedrate;
@synthesize m_shareable;
@synthesize m_sharetimes;
@synthesize m_connecttimes;
@synthesize m_wifiIcon;
@synthesize m_distance;
@synthesize m_isLocalOCR;
@synthesize m_wifirating;
@synthesize m_signalstrength;
@synthesize m_shop;
@synthesize m_security;
@synthesize m_securityLevel;
@synthesize m_status;
@synthesize m_dnsHijack;

- (id)init
{
    if(self = [super init])
    {
        
    }
    return self;
}

- (bool) readFromJosnDictionary:(NSDictionary*)data{
    
    self.m_ssid = [[data safeObjectForKey:@"ssid"] safeStringValue];
    self.m_pwd = [[data safeObjectForKey:@"pwd"] safeStringValue];
    self.m_mac = [[data safeObjectForKey:@"mac"] safeStringValue];
    self.m_displayname = [[data safeObjectForKey:@"display_name"] safeStringValue];
    self.m_displaydesc = [[data safeObjectForKey:@"display_desc"] safeStringValue];
    self.m_displayicon = [[data safeObjectForKey:@"display_icon"] safeStringValue];
    self.m_wifiIcon = [[data safeObjectForKey:@"display_icon"] safeStringValue];
    self.m_connecttimes =[NSString stringWithFormat:@"%d", [[data safeObjectForKey:@"conn_user"] safeStringValue].intValue];
    self.m_avgspeed = [[data safeObjectForKey:@"avgspeed"] safeStringValue];
    self.m_wifirating = [[data safeObjectForKey:@"score"] safeStringValue];
    self.m_signalstrength = [self evalueWiFiStrength:self.m_wifirating];
    self.m_salt = [[data safeObjectForKey:@"salt"] safeStringValue];
    self.m_lat = [[data safeObjectForKey:@"lat"] safeStringValue];
    self.m_lng = [[data safeObjectForKey:@"lng"] safeStringValue];
    self.m_securityLevel = [[data safeObjectForKey:@"security_level"] safeIntegerValue];
    self.m_shop = [[WiFiShop alloc] initWithDictionary: [data safeObjectForKey: @"shop"]];
    self.m_security = [[WiFiSecurity alloc] initWithDictionary: [data safeObjectForKey: @"security"]];
    self.m_status =[[data safeObjectForKey:@"status"] safeIntegerValue];
    self.m_ispublic = [[data safeObjectForKey:@"ispublic"] safeStringValue];
    self.m_isphishing = [[data safeObjectForKey:@"isphishing"] safeStringValue];
    self.m_isfake = [[data safeObjectForKey:@"isfake"] safeStringValue];
    self.m_isdnswell = [[data safeObjectForKey:@"isdnswell"] safeStringValue];
    self.m_dnsHijack = 0;

    return true;
}

+ (WiFiRecord*) initFromJosnDictionary:(NSDictionary*)data{
    WiFiRecord * record = [[WiFiRecord alloc] init];
    if ([record readFromJosnDictionary:data])
        return  record;
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.m_id forKey:@"m_id"];
    [aCoder encodeObject:self.m_mac forKey:@"m_mac"];
    [aCoder encodeObject:self.m_ssid forKey:@"m_ssid"];
    [aCoder encodeObject:self.m_pwd forKey:@"m_pwd"];
    [aCoder encodeObject:self.m_salt forKey:@"m_salt"];
    [aCoder encodeObject:self.m_lat forKey:@"m_lat"];
    [aCoder encodeObject:self.m_lng forKey:@"m_lng"];
    [aCoder encodeObject:self.m_alt forKey:@"m_alt"];
    [aCoder encodeObject:self.m_geohash forKey:@"m_geohash"];
    [aCoder encodeObject:self.m_address forKey:@"m_address"];
    [aCoder encodeObject:self.m_displayname forKey:@"display_name"];
    [aCoder encodeObject:self.m_displaydesc forKey:@"display_desc"];
    [aCoder encodeObject:self.m_displayicon forKey:@"display_icon"];
    [aCoder encodeObject:self.m_belongto forKey:@"m_belongto"];
    [aCoder encodeObject:self.m_contactinfo forKey:@"m_contactinfo"];
    [aCoder encodeObject:self.m_lastheartbeat forKey:@"m_lastheartbeat"];
    [aCoder encodeObject:self.m_avgspeed forKey:@"m_avgspeed"];
    [aCoder encodeObject:self.m_lastspeed forKey:@"m_lastspeed"];
    [aCoder encodeObject:self.m_ispublic forKey:@"m_ispublic"];
    [aCoder encodeObject:self.m_isphishing forKey:@"m_isphishing"];
    [aCoder encodeObject:self.m_isfake forKey:@"m_isfake"];
    [aCoder encodeObject:self.m_isdnswell forKey:@"m_isdnswell"];
    [aCoder encodeObject:self.m_connectedrate forKey:@"m_connectedrate"];
    [aCoder encodeObject:self.m_shareable forKey:@"m_shareable"];
    [aCoder encodeObject:self.m_sharetimes forKey:@"m_sharetimes"];
    [aCoder encodeObject:self.m_connecttimes forKey:@"conn_user"];
    [aCoder encodeObject:self.m_wifiIcon forKey:@"display_icon"];
    [aCoder encodeObject:[NSNumber numberWithLongLong:self.m_distance] forKey:@"m_distance"];
    [aCoder encodeObject:self.m_wifiIcon forKey:@"m_wifiicon"];
    [aCoder encodeObject:self.m_wifirating forKey:@"m_wifirating"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.m_signalstrength] forKey:@"m_signalstrength"];
    [aCoder encodeObject:@(self.m_securityLevel) forKey:@"m_securityLevel"];
    [aCoder encodeObject:self.m_shop forKey:@"m_shop"];
    [aCoder encodeObject:self.m_security forKey:@"m_security"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.m_id = [aDecoder decodeObjectForKey:@"m_id"];
        self.m_mac = [aDecoder decodeObjectForKey:@"m_mac"];
        self.m_ssid = [aDecoder decodeObjectForKey:@"m_ssid"];
        self.m_pwd = [aDecoder decodeObjectForKey:@"m_pwd"];
        self.m_salt = [aDecoder decodeObjectForKey:@"m_salt"];
        self.m_lat = [aDecoder decodeObjectForKey:@"m_lat"];
        self.m_lng = [aDecoder decodeObjectForKey:@"m_lng"];
        self.m_alt = [aDecoder decodeObjectForKey:@"m_alt"];
        self.m_geohash = [aDecoder decodeObjectForKey:@"m_geohash"];
        self.m_address = [aDecoder decodeObjectForKey:@"m_address"];
        self.m_displayname = [aDecoder decodeObjectForKey:@"display_name"];
        self.m_displaydesc = [aDecoder decodeObjectForKey:@"display_desc"];
        self.m_displayicon = [aDecoder decodeObjectForKey:@"display_icon"];
        self.m_belongto = [aDecoder decodeObjectForKey:@"m_belongto"];
        self.m_contactinfo = [aDecoder decodeObjectForKey:@"m_contactinfo"];
        self.m_lastheartbeat = [aDecoder decodeObjectForKey:@"m_lastheartbeat"];
        self.m_avgspeed = [aDecoder decodeObjectForKey:@"m_avgspeed"];
        self.m_lastspeed = [aDecoder decodeObjectForKey:@"m_lastspeed"];
        self.m_ispublic = [aDecoder decodeObjectForKey:@"m_ispublic"];
        self.m_isphishing = [aDecoder decodeObjectForKey:@"m_isphishing"];
        self.m_isfake = [aDecoder decodeObjectForKey:@"m_isfake"];
        self.m_isdnswell = [aDecoder decodeObjectForKey:@"m_isdnswell"];
        self.m_connectedrate = [aDecoder decodeObjectForKey:@"m_connectedrate"];
        self.m_shareable = [aDecoder decodeObjectForKey:@"m_shareable"];
        self.m_sharetimes = [aDecoder decodeObjectForKey:@"m_sharetimes"];
        self.m_connecttimes = [aDecoder decodeObjectForKey:@"conn_user"];
        self.m_wifiIcon = [aDecoder decodeObjectForKey:@"display_icon"];
        self.m_distance = [[aDecoder decodeObjectForKey:@"m_distance"] longLongValue];
        self.m_wifiIcon = [aDecoder decodeObjectForKey:@"m_wifiicon"];
        self.m_wifirating = [aDecoder decodeObjectForKey:@"m_wifirating"];
        self.m_signalstrength = [[aDecoder decodeObjectForKey:@"m_signalstrength"] integerValue];
        self.m_securityLevel = [[aDecoder decodeObjectForKey: @"m_securityLevel"] integerValue];
        self.m_shop = [aDecoder decodeObjectForKey: @"m_shop"];
        self.m_security = [aDecoder decodeObjectForKey: @"m_security"];
    }
    return self;
    
}

// 按距离升序
- (NSComparisonResult)compareWithDisAs:(WiFiRecord *)info
{
    int64_t srcDis = self.m_distance;
    int64_t destDis = info.m_distance;
    int nCountMe = self.m_sharetimes.intValue;
    int nCountDest = info.m_sharetimes.intValue;
    
    if (srcDis < destDis) {
        return NSOrderedAscending;
    }
    
    if (srcDis >= destDis) {
        return NSOrderedDescending;
    }
    
    if (nCountMe < nCountDest) {
        return NSOrderedAscending;
    }
    
    if (nCountMe >= nCountDest) {
        return NSOrderedDescending;
    }

    return NSOrderedSame;
}

- (WIFI_INFO_SIGNAL_STRENGTH)evalueWiFiStrength:(NSString *)strengthScore
{
    NSInteger strengthInt = [strengthScore integerValue];
    if (strengthInt >= 80) {
        return WIFI_INFO_SIGNAL_STRENGTH_FOUR;
    } else if (strengthInt >= 60) {
        return WIFI_INFO_SIGNAL_STRENGTH_THREE;
    } else if (strengthInt >= 30) {
        return WIFI_INFO_SIGNAL_STRENGTH_TWO;
    } else if (strengthInt > 0) {
        return WIFI_INFO_SIGNAL_STRENGTH_ONE;
    } else {
        return WIFI_INFO_SIGNAL_STRENGTH_FOUR;
    }
}

- (BOOL)isEqual:(WiFiRecord *)object
{
    if ([object isKindOfClass: [WiFiRecord class]] && [self.m_mac isEqualToString: object.m_mac] && [self.m_ssid isEqualToString: object.m_ssid]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@:%p> ssid:%@ mac:%@", [self class], self, self.m_ssid, self.m_mac];
}

@end
