//
//  CheckUpdateView.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/1/13.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "CheckUpdateView.h"
#import "AnimationManager.h"

@interface CheckUpdateView ()
{
    UIView *_backgroundView;
    UIView *_alertView;
    
    NSString *_trackViewUrl;
}
@end

@implementation CheckUpdateView

- (void)dealloc
{
    DDDLog(@"CheckUpdateView Dealloc");
}

- (instancetype)initWithVersion:(NSString *)version trackViewUrl:(NSString *)trakViewUrl
{
    self = [super initWithFrame:kScreenFrame];
    if (self) {
        _trackViewUrl = trakViewUrl;
        
        // backgroundView
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundView];
        
        // alertView
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 286, 220)];
        _alertView.center = CGPointMake(kScreenWidth / 2 - 9, kScreenHeight / 2 - 20);
        [self addSubview:_alertView];
        
        // alertBackgroundView
        UIImageView *alertBackgroundView = [[UIImageView alloc] initWithImage:ImageNamed(@"img_bg_update")];
        [_alertView addSubview:alertBackgroundView];
        
        // versionLbl
        UILabel *versionLbl = [[UILabel alloc] initWithFrame:CGRectMake(18, 100, _alertView.width - 18, 20)];
        versionLbl.text = [NSString stringWithFormat:@"V%@",version];
        versionLbl.textColor = COLOR(0, 156, 251, 1);
        versionLbl.font = SystemFont(14);
        versionLbl.textAlignment = NSTextAlignmentCenter;
        [_alertView addSubview:versionLbl];
        
        // descLbl
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(versionLbl.x, CGRectGetMaxY(versionLbl.frame) + 4, versionLbl.width, 20)];
        descLbl.text = @"新版本来袭，立即尝新";
        descLbl.textColor = COLOR(90, 90, 90, 1);
        descLbl.font = SystemFont(14);
        descLbl.textAlignment = NSTextAlignmentCenter;
        [_alertView addSubview:descLbl];
        
        // cancelBtn
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelBtn.frame = CGRectMake(descLbl.x, CGRectGetMaxY(descLbl.frame) + 19.5, 134, 41);
        [cancelBtn setTitle:@"以后再说" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:COLOR(155, 155, 155, 1) forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = SystemFont(16);
        [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:cancelBtn];
        
        // goBtn
        UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        goBtn.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame), cancelBtn.y, 134, 41);
        [goBtn setTitle:@"前往更新" forState:UIControlStateNormal];
        [goBtn setTitleColor:COLOR(0, 156, 251, 1) forState:UIControlStateNormal];
        goBtn.titleLabel.font = SystemFont(16);
        [goBtn addTarget:self action:@selector(goBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_alertView addSubview:goBtn];
        
        // padingView
        UIView *padingView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cancelBtn.frame), CGRectGetMaxY(descLbl.frame) + 33, 0.5, 17)];
        padingView.backgroundColor = COLOR(155, 155, 155, 1);
        [_alertView addSubview:padingView];
        
    }
    return self;
}

- (void)cancelBtnClick
{
    [self dismiss];
}

- (void)goBtnClick
{
    [self dismiss];
    if (!_trackViewUrl) return;
    NSURL *url = [NSURL URLWithString:_trackViewUrl];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:url];
        });
    }
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    _alertView.alpha = 0.0f;
    _alertView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:0.25 animations:^{
        _backgroundView.backgroundColor = RGB(0x000000, 0.6);
        _alertView.alpha = 1.0f;
        _alertView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        
    }];
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
