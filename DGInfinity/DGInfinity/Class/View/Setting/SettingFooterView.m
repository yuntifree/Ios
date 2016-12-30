//
//  SettingFooterView.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "SettingFooterView.h"

@implementation SettingFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *agreementLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 54, frame.size.width, 17)];
        agreementLbl.text = @"《东莞无限用户协议》";
        agreementLbl.textAlignment = NSTextAlignmentCenter;
        agreementLbl.font = SystemFont(11);
        agreementLbl.textColor = COLOR(0, 160, 251, 1);
        [agreementLbl addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAgreement)]];
        agreementLbl.userInteractionEnabled = YES;
        [self addSubview:agreementLbl];
        
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(agreementLbl.frame) + 4, frame.size.width, 17)];
        descLbl.text = @"版权所有 © 2016-2017东莞无限";
        descLbl.textAlignment = NSTextAlignmentCenter;
        descLbl.font = SystemFont(12);
        descLbl.textColor = COLOR(180, 180, 180, 1);
        [self addSubview:descLbl];
    }
    return self;
}

- (void)onTapAgreement
{
    if (_tap) {
        _tap();
    }
}

@end
