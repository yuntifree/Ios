//
//  WiFiExamModel.m
//  DGInfinity
//
//  Created by myeah on 16/11/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiExamModel.h"

@implementation WiFiExamModel

@end

@implementation WiFiExamDeviceModel

+ (instancetype)createWithBrand:(NSString *)brand ip:(NSString *)ip hostname:(NSString *)hostname
{
    WiFiExamDeviceModel *model = [WiFiExamDeviceModel new];
    model.ip = ip;
    model.hostname = hostname.length ? [[hostname stringByReplacingOccurrencesOfString:@".lan" withString:@""] capitalizedString] : brand.length ? brand : @"未知设备";
    return model;
}

@end

@implementation WiFiExamDescModel

+ (instancetype)createWithTitle:(NSString *)title desc:(NSString *)desc
{
    WiFiExamDescModel *model = [WiFiExamDescModel new];
    model.title = title;
    model.desc = desc;
    return model;
}

@end
