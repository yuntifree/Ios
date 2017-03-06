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
    return model;
}

@end
