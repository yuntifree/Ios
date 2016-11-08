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
    model.time = [NSDate stringWithDateStr:info[@"ctime"] formatStr:@"HH:mm"];
    model.date = [NSDate stringWithDateStr:info[@"ctime"] formatStr:@"yyyy/MM/dd"];
    model.dst = info[@"dst"];
    model.stype = [info[@"stype"] integerValue];
    model.seq = [info[@"seq"] integerValue];
    return model;
}

@end
