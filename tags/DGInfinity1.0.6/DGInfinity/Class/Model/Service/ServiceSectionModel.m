//
//  ServiceSectionModel.m
//  DGInfinity
//
//  Created by myeah on 16/11/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ServiceSectionModel.h"
#import "ServiceCellModel.h"

@implementation ServiceSectionModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [NSMutableArray arrayWithCapacity:6];
    }
    return self;
}

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    ServiceSectionModel *model = [ServiceSectionModel new];
    model.title = info[@"title"];
    NSArray *items = info[@"items"];
    if ([items isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in items) {
            ServiceCellModel *md = [ServiceCellModel createWithInfo:dict];
            md.type = RCT_SERVICE;
            [model.items addObject:md];
        }
    }
    return model;
}

@end
