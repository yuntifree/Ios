//
//  WiFiNoNetView.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/3/10.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "WiFiNoNetView.h"

@implementation WiFiNoNetView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *backView = [UIView new];
        [self addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.width.equalTo(@200);
            make.height.equalTo(@151);
        }];
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:ImageNamed(@"ico_crying")];
        imgView.origin = CGPointMake((200 - imgView.width) / 2, 0);
        [backView addSubview:imgView];
        
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imgView.frame) + 16, 200, 17)];
        descLbl.textColor = COLOR(155, 155, 155, 1);
        descLbl.font = SystemFont(12);
        descLbl.textAlignment = NSTextAlignmentCenter;
        descLbl.text = @"网络请求失败，请检查你的网络";
        [backView addSubview:descLbl];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((200 - 112) / 2, CGRectGetMaxY(descLbl.frame) + 16, 112, 48);
        button.titleLabel.font = SystemFont(18);
        [button setTitleEdgeInsets:UIEdgeInsetsMake(-5, 0, 0, 0)];
        [button setTitle:@"刷新" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundImage:ImageNamed(@"btn_refresh_nor") forState:UIControlStateNormal];
        [button setBackgroundImage:ImageNamed(@"btn_refresh_pre") forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:button];
    }
    return self;
}

- (void)btnClick:(UIButton *)button
{
    if (_buttonClick) {
        _buttonClick();
    }
}

@end
