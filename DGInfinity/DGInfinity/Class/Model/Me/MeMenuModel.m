//
//  MeMenuModel.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/8/24.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "MeMenuModel.h"

@implementation MeMenuModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showPoint = NO;
    }
    return self;
}

+ (instancetype)createWithIcon:(NSString *)icon
                         title:(NSString *)title
                          desc:(NSString *)desc
                     showPoint:(BOOL)showPoint
{
    MeMenuModel *model = [MeMenuModel new];
    model.icon = icon;
    model.title = title;
    model.desc = desc;
    model.showPoint = showPoint;
    return model;
}

@end
