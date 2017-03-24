//
//  NewsVideoModel.m
//  DGInfinity
//
//  Created by myeah on 16/10/27.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsVideoModel.h"

@implementation NewsVideoModel

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
    NewsVideoModel *model = [NewsVideoModel new];
    model.id_ = [info[@"id"] integerValue];
    model.title = info[@"title"];
    model.images = info[@"images"];
    model.source = info[@"source"];
    model.date = [NSDate stringWithDateStr:info[@"ctime"] formatStr:@"yyyy/MM/dd"];
    model.dst = info[@"dst"];
    model.stype = [info[@"stype"] intValue];
    model.seq = [info[@"seq"] integerValue];
    model.play = [info[@"play"] integerValue];
    return model;
}

@end

@implementation NewsVideoTopModel

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    NewsVideoTopModel *model = [NewsVideoTopModel new];
    model.title = info[@"title"];
    model.dst = info[@"dst"];
    model.img = info[@"img"];
    return model;
}

@end
