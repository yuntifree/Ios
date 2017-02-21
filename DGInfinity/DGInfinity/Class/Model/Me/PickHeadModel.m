//
//  PickHeadModel.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/21.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "PickHeadModel.h"

@implementation PickHeadModel

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    PickHeadModel *model = [PickHeadModel new];
    model.headurl = info[@"headurl"];
    model.desc = info[@"desc"];
    model.age = info[@"age"];
    return model;
}

@end
