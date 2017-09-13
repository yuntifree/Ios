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
}
@end

@implementation CheckUpdateView

- (void)dealloc
{
    DDDLog(@"CheckUpdateView Dealloc");
}

- (instancetype)initWithTitle:(NSString *)title desc:(NSString *)desc
{
    self = [super initWithFrame:kScreenFrame];
    if (self) {
        
        // backgroundView
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundView];
        
        // alertView
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 286, 250)];
        _alertView.center = CGPointMake(kScreenWidth / 2 - 9, kScreenHeight / 2 - 20);
        [self addSubview:_alertView];
        
        // alertBackgroundView
        UIImageView *alertBackgroundView = [[UIImageView alloc] initWithImage:ImageNamed(@"img_bg_update")];
        [_alertView addSubview:alertBackgroundView];
        
        // versionLbl
        UILabel *versionLbl = [[UILabel alloc] initWithFrame:CGRectMake(18, 102, _alertView.width - 18, 18)];
        versionLbl.text = @"【新内容】";
        versionLbl.textColor = COLOR(90, 90, 90, 1);
        versionLbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        versionLbl.textAlignment = NSTextAlignmentCenter;
        [_alertView addSubview:versionLbl];
        
        // titleLbl
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(versionLbl.frame) + 14, _alertView.width - 40 - 22, 18)];
        titleLbl.text = title;
        titleLbl.textColor = COLOR(90, 90, 90, 1);
        titleLbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        [_alertView addSubview:titleLbl];
        
        // descLbl
        UILabel *descLbl = [[UILabel alloc] initWithFrame:CGRectMake(titleLbl.x, CGRectGetMaxY(titleLbl.frame) + 6, titleLbl.width, 36)];
        descLbl.text = desc;
        descLbl.textColor = COLOR(90, 90, 90, 1);
        descLbl.font = SystemFont(15);
        descLbl.numberOfLines = 2;
        [_alertView addSubview:descLbl];
        
        // cancelBtn
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        cancelBtn.frame = CGRectMake(18, CGRectGetMaxY(descLbl.frame) + 15, 134, 41);
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
    NSURL *url = [NSURL URLWithString:CheckUpdateURL];
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
    [UIView animateWithDuration:0.5 animations:^{
        _backgroundView.backgroundColor = RGB(0x000000, 0.6);
        _alertView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
    _alertView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [UIView animateKeyframesWithDuration:1.0 delay:0 options:0 animations: ^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 / 2.0 animations: ^{
            _alertView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
        [UIView addKeyframeWithRelativeStartTime:1 / 2.0 relativeDuration:1 / 2.0 animations: ^{
            _alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
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
