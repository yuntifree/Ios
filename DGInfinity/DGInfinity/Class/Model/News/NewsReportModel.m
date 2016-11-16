//
//  NewsReportModel.m
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsReportModel.h"

@implementation NewsReportModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _read = NO;
    }
    return self;
}

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    NewsReportModel *model = [NewsReportModel new];
    model.id_ = [info[@"id"] integerValue];
    model.title = info[@"title"];
    model.images = info[@"images"];
    NSString *source = info[@"source"];
    if (kScreenWidth == 320 && source.length > 5) {
        source = [NSString stringWithFormat:@"%@...",[source substringToIndex:5]];
    } else if (source.length > 8) {
        source = [NSString stringWithFormat:@"%@...",[source substringToIndex:8]];
    }
    model.source = source;
    model.time = [NSDate stringWithDateStr:info[@"ctime"] formatStr:@"HH:mm"];
    model.date = [NSDate stringWithDateStr:info[@"ctime"] formatStr:@"yyyy/MM/dd"];
    model.dst = info[@"dst"];
    model.stype = [info[@"stype"] integerValue];
    model.seq = [info[@"seq"] integerValue];
    return model;
}

@end
