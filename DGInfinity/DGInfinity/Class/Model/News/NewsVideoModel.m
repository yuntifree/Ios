//
//  NewsVideoModel.m
//  DGInfinity
//
//  Created by myeah on 16/10/27.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsVideoModel.h"

@implementation NewsVideoModel

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    NewsVideoModel *model = [NewsVideoModel new];
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
