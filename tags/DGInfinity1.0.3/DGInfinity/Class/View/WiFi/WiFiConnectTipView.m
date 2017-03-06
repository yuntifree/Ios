//
//  WiFiConnectTipView.m
//  DGInfinity
//
//  Created by myeah on 16/11/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiConnectTipView.h"
#import "UIButton+ResizableImage.h"
#import "AnimationManager.h"

@interface WiFiConnectTipView ()
{
    UIImageView *_backView;
    UIButton *_closeBtn;
    UIButton *_goWifiListBtn;
}
@end

@implementation WiFiConnectTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _backView = [[UIImageView alloc] initWithFrame:self.bounds];
        NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img_connect.png"];
        _backView.image = [UIImage imageWithContentsOfFile:imagePath];
        [self addSubview:_backView];
        
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(self.width - 50, 20, 30, 30);
        [_closeBtn setBackgroundImage:ImageNamed(@"ico_cancel") forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeBtn];
        
        _goWifiListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goWifiListBtn.frame = CGRectMake(42, self.height - 40 - 97 * [Tools layoutFactor], self.width - 84, 40);
        [_goWifiListBtn dg_setBackgroundImage:ImageNamed(@"btn_Start button") forState:UIControlStateNormal];
        [_goWifiListBtn addTarget:self action:@selector(goWiFiListBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _goWifiListBtn.titleLabel.font = SystemFont(18);
        [_goWifiListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_goWifiListBtn setTitle:@"去系统WiFi列表连接" forState:UIControlStateNormal];
        [self addSubview:_goWifiListBtn];
    }
    return self;
}

- (void)closeBtnClick:(UIButton *)button
{
    [self dismiss];
}

- (void)goWiFiListBtnClick:(UIButton *)button
{
    [self dismiss];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [Tools openWifiList];
    });
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    self.alpha = 1;
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
