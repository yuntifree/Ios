//
//  ReportClickModel.m
//  DGInfinity
//
//  Created by myeah on 16/11/9.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ReportClickModel.h"

@implementation ReportClickModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _time = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

+ (instancetype)createWithReportModel:(NewsReportModel *)model
{
    ReportClickModel *rcm = [ReportClickModel new];
    rcm.id_ = model.id_;
    if (model.stype == RT_NEWS) {
        rcm.type = RCT_NEWSCLICK;
    } else {
        rcm.type = RCT_ADCLICK;
    }
    return rcm;
}

+ (instancetype)createWithVideoModel:(NewsVideoModel *)model
{
    ReportClickModel *rcm = [ReportClickModel new];
    rcm.id_ = model.id_;
    rcm.type = RCT_VIDEOPLAY;
    return rcm;
}

@end
