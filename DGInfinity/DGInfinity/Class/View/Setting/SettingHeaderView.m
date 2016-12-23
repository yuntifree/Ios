//
//  SettingHeaderView.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "SettingHeaderView.h"

@implementation SettingHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - 62) / 2, 54 * [Tools layoutFactor], 62, 62)];
        logoView.image = ImageNamed(@"set_ico_logo");
        [self addSubview:logoView];
        
        UILabel *appLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoView.frame) + 9, frame.size.width, 22)];
        appLbl.text = @"东莞无限";
        appLbl.textAlignment = NSTextAlignmentCenter;
        appLbl.font = SystemFont(16);
        appLbl.textColor = COLOR(74, 74, 74, 1);
        [self addSubview:appLbl];
        
        UILabel *versionLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(appLbl.frame) + 2, frame.size.width, 20)];
        versionLbl.text = [NSString stringWithFormat:@"V%@",XcodeAppVersion];
        versionLbl.textAlignment = NSTextAlignmentCenter;
        versionLbl.font = SystemFont(14);
        versionLbl.textColor = COLOR(0, 156, 251, 1);
        [self addSubview:versionLbl];
    }
    return self;
}

@end
