//
//  NewsMenuModel.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/30.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsMenuModel.h"

@implementation NewsMenuModel

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    NewsMenuModel *model = [NewsMenuModel new];
    model.title = info[@"title"];
    model.type = [info[@"type"] integerValue];
    model.dst = info[@"dst"];
    model.ctype = [info[@"ctype"] integerValue];
    return model;
}

@end
