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

+ (instancetype)createWithBrand:(NSString *)brand ip:(NSString *)ip
{
    WiFiExamDeviceModel *model = [WiFiExamDeviceModel new];
    model.brand = brand;
    model.ip = ip;
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
