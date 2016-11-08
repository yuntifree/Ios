//
//  NewsTitleView.m
//  DGInfinity
//
//  Created by myeah on 16/11/8.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsTitleView.h"

@interface NewsTitleView ()
{
    UIView *_line;
    UIButton *_selectedBtn;
}
@end

@implementation NewsTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // button
        _selectedBtn = [self createButtonWithTitle:@"新闻" index:0];
        [self createButtonWithTitle:@"视频" index:1];
        _selectedBtn.selected = YES;
        _selectedBtn.titleLabel.font = SystemFont(18);
        
        // line
        _line = [[UIView alloc] initWithFrame:CGRectMake(16, 42, 42, 2)];
        _line.backgroundColor = COLOR(222, 242, 254, 1);
        [self addSubview:_line];
    }
    return self;
}

- (UIButton *)createButtonWithTitle:(NSString *)title index:(NSInteger)index
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = SystemFont(16);
    [button setTitleColor:COLOR(255, 255, 255, 0.6) forState:UIControlStateNormal];
    [button setTitleColor:COLOR(255, 255, 255, 1) forState:UIControlStateSelected];
    button.frame = CGRectMake(index * 74, 8, 74, 36);
    button.tag = 1000 + index;
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)changeBtn:(NSInteger)tag
{
    UIButton *button = (UIButton *)[self viewWithTag:tag];
    [UIView animateWithDuration:0.2 animations:^{
        _selectedBtn.selected = NO;
        _selectedBtn.titleLabel.font = SystemFont(16);
        button.selected = YES;
        button.titleLabel.font = SystemFont(18);
        _selectedBtn = button;
        _line.x = button.x + 16;
    }];
}

- (void)btnClick:(UIButton *)button
{
    if (button == _selectedBtn) return;
    if (_block) {
        [self changeBtn:button.tag];
        _block(button.tag - 1000);
    }
}

@end
