//
//  SettingModel.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "SettingModel.h"

@implementation SettingModel

+ (instancetype)createWithTitle:(NSString *)title desc:(NSString *)desc
{
    SettingModel *model = [SettingModel new];
    model.title = title;
    model.desc = desc;
    return model;
}

@end
