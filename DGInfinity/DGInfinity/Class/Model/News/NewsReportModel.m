//
//  NewsReportModel.m
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsReportModel.h"

@implementation NewsReportModel

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    NewsReportModel *model = [NewsReportModel new];
    model.title = info[@"title"];
    model.images = info[@"images"];
    model.source = info[@"source"];
    model.ctime = info[@"ctime"];
    model.dst = info[@"dst"];
    model.stype = [info[@"stype"] intValue];
    model.seq = [info[@"seq"] integerValue];
    return model;
}

@end
