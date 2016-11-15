//
//  ServiceHeaderView.m
//  DGInfinity
//
//  Created by myeah on 16/10/19.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ServiceHeaderView.h"
#import "UIButton+Vertical.h"

#define Width 44
#define Padding (kScreenWidth - Width * 5) / 6.0

@implementation ServiceHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        NSArray *titleArray = @[@"招聘", @"二手", @"租房", @"家政", @"更多"];
        NSArray *imageArray = @[@"cooperation", @"secong_hand", @"housing", @"Housekeeping", @"more"];
        for (int i = 0; i < titleArray.count; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:ImageNamed(imageArray[i]) forState:UIControlStateNormal];
            [button setTitle:titleArray[i] forState:UIControlStateNormal];
            [button setTitleColor:COLOR(60, 60, 60, 1) forState:UIControlStateNormal];
            button.frame = CGRectMake(Padding * (i + 1) + Width * i, 0, Width, frame.size.height);
            button.tag = 10000 + i;
            button.titleLabel.font = SystemFont(14);
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [button verticalImageAndTitle:9];
            [self addSubview:button];
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
