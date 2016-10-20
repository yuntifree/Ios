//
//  ServiceHeaderView.m
//  DGInfinity
//
//  Created by myeah on 16/10/19.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ServiceHeaderView.h"

#define Padding (kScreenWidth - 45 * 5) / 6.0

@implementation ServiceHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(0xfafafa, 1);
        
        NSArray *titleArray = @[@"招聘", @"二手", @"租房", @"家政", @"更多"];
        NSArray *imageArray = @[@"icon_zp", @"icon_es", @"icon_zf", @"icon_jz", @"icon_gd"];
        for (int i = 0; i < titleArray.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            [button setBackgroundImage:ImageNamed(imageArray[i]) forState:UIControlStateNormal];
            button.frame = CGRectMake(Padding * (i + 1) + 45 * i, 10, 45, 45);
            button.tag = 10000 + i;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(button.x, button.y + button.height + 12, 45, 17)];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = RGB(0x000000, 0.6);
            label.font = SystemFont(14);
            label.text = titleArray[i];
            [self addSubview:label];
        }
    }
    return self;
}

- (void)buttonClick:(UIButton *)button
{
    if (_headClick) {
        _headClick(button.tag - 10000);
    }
}

@end
