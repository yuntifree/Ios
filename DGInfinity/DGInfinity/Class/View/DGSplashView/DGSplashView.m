//
//  DGSplashView.m
//  DGInfinity
//
//  Created by myeah on 16/12/12.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGSplashView.h"

@interface DGSplashView ()
{
    UIImageView *_backView;
    UILabel *_secondLbl;
    UIButton *_goBtn;
    dispatch_source_t _timer;
    
    NSString *_dst;
    NSString *_title;
    int _seconds;
}
@end

@implementation DGSplashView

- (void)dealloc
{
    DDDLog(@"DGSplashView dealloc");
}

- (instancetype)initWithImage:(UIImage *)image dst:(NSString *)dst title:(NSString *)title
{
    self = [self initWithFrame:kScreenFrame];
    if (self) {
        _backView.image = image;
        if ([dst isKindOfClass:[NSString class]] && dst.length) {
            _dst = dst;
            _backView.userInteractionEnabled = YES;
            _goBtn.hidden = NO;
        }
        _title = title;
        [self fireTimer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _seconds = SApp.beWakened ? 5 : 3;
        self.backgroundColor = [UIColor whiteColor];
        
        _backView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backView.userInteractionEnabled = NO;
        [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBtnClick)]];
        [self addSubview:_backView];
        
        UIImageView *leftIcon = [[UIImageView alloc] initWithImage:ImageNamed(@"text_ad")];
        leftIcon.origin = CGPointMake(10, 20);
        [self addSubview:leftIcon];
        
        UIButton *skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        skipBtn.frame = CGRectMake(frame.size.width - 64 - 19, 20, 64, 32);
        [skipBtn setBackgroundImage:ImageNamed(@"text_skip") forState:UIControlStateNormal];
        [skipBtn addTarget:self action:@selector(skipBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:skipBtn];
        
        _secondLbl = [[UILabel alloc] initWithFrame:CGRectMake(7, 7, 15, 18)];
        _secondLbl.textColor = COLOR(0, 160, 251, 1);
        _secondLbl.font = SystemFont(13);
        _secondLbl.textAlignment = NSTextAlignmentCenter;
        _secondLbl.text = [NSString stringWithFormat:@"%d",_seconds];
        [skipBtn addSubview:_secondLbl];
        
        CGFloat height = frame.size.width * 78 / 375;
        _goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBtn.hidden = YES;
        _goBtn.frame = CGRectMake(0, frame.size.height - height - 100 * [Tools layoutFactor], frame.size.width, height);
        [_goBtn setBackgroundImage:ImageNamed(@"text_getmore") forState:UIControlStateNormal];
        [_goBtn addTarget:self action:@selector(goBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_goBtn];
    }
    return self;
}

- (void)dismiss
{
    if (_action) {
        _action(SplashActionTypeDismiss, nil, nil);
    }
    [self cancelTimer];
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)skipBtnClick
{
    if (_action) {
        _action(SplashActionSkipOrCountDown, nil, nil);
    }
    [self dismiss];
}

- (void)goBtnClick
{
    if (_action) {
        _action(SplashActionTypeGet, _dst, _title);
    }
    [self dismiss];
}

- (void)fireTimer
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(_timer, ^{
        [wself timerRun];
    });
    dispatch_resume(_timer);
}

- (void)cancelTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)timerRun
{
    if (_seconds) {
        _secondLbl.text = [NSString stringWithFormat:@"%d",_seconds];
    } else {
        if (_action) {
            _action(SplashActionSkipOrCountDown, nil, nil);
        }
        [self dismiss];
    }
    _seconds--;
}

@end
