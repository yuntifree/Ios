//
//  WiFiTipView.m
//  DGInfinity
//
//  Created by myeah on 16/11/10.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiTipView.h"
#import "AnimationManager.h"

@implementation WiFiTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
        self.layer.contents = (__bridge id)(ImageNamed(@"Label_more").CGImage);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, frame.size.width, 17)];
        label.font = SystemFont(12);
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"上拉查看更多";
        [self addSubview:label];
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [self.layer addAnimation:[AnimationManager popInAnimation] forKey:@"pop"];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
