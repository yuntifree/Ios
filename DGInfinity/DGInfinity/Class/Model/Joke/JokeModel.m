//
//  JokeModel.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/23.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "JokeModel.h"

@implementation JokeModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _liked = NO;
        _unliked = NO;
    }
    return self;
}

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    JokeModel *model = [JokeModel new];
    model.id_ = [info[@"id"] integerValue];
    model.seq = [info[@"seq"] integerValue];
    model.content = info[@"content"];
    model.heart = [info[@"heart"] integerValue];
    model.bad = [info[@"bad"] integerValue];
    return model;
}

@end
