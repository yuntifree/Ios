//
//  LiveListModel.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/8.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "LiveListModel.h"

@implementation LiveListModel

+ (instancetype)createWithInfo:(NSDictionary *)info
{
    LiveListModel *model = [LiveListModel new];
    model.avatar = info[@"avatar"];
    model.img = info[@"img"];
    model.nickname = info[@"nickname"];
    model.live_id = [info[@"live_id"] integerValue];
    model.location = info[@"location"];
    model.watches = [info[@"watches"] integerValue];
    model.live = [info[@"live"] intValue];
    return model;
}

@end
