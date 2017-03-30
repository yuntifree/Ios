//
//  ServiceCellModel.m
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ServiceCellModel.h"

@implementation ServiceCellModel

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    ServiceCellModel *model = [ServiceCellModel new];
    model.title = info[@"title"];
    model.dst = info[@"dst"];
    model.sid = [info[@"sid"] integerValue];
    model.icon = info[@"icon"];
    return model;
}

@end

@implementation ServiceBannerModel

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    ServiceBannerModel *model = [ServiceBannerModel new];
    model.id_ = [info[@"id"] integerValue];
    model.img = info[@"img"];
    model.dst = info[@"dst"];
    model.type = [info[@"type"] integerValue];
    return model;
}

@end

@implementation ServiceCityModel

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    ServiceCityModel *model = [ServiceCityModel new];
    model.id_ = [info[@"id"] integerValue];
    model.img = info[@"img"];
    model.title = info[@"title"];
    model.dst = info[@"dst"];
    return model;
}

@end
