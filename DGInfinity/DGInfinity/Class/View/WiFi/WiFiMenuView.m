//
//  WiFiMenuView.m
//  DGInfinity
//
//  Created by myeah on 16/11/9.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiMenuView.h"
#import "PulsingHaloLayer.h"
#import "AnimationManager.h"
#import "NetworkManager.h"

#define ROTATIONSSECONDS 5

@interface WiFiMenuView () <CAAnimationDelegate>
{
    __weak IBOutlet UIButton *_connectBtn;
    __weak IBOutlet UILabel *_statusLbl;
    __weak IBOutlet UILabel *_temperatureLbl;
    __weak IBOutlet UILabel *_weatherLbl;
    __weak IBOutlet UILabel *_hotLbl;
    __weak IBOutlet UILabel *_badgeLbl;
    __weak IBOutlet UIImageView *_backView;
    __weak IBOutlet UIImageView *_leftWeatherView;
    __weak IBOutlet UIImageView *_rightWeatherView;
    PulsingHaloLayer *_halo;
    UIImageView *_outsideSmallCircle;
    UIImageView *_outsideBigCircle;
    UIImageView *_aroundCircle;
    
    // layout constraint
    __weak IBOutlet NSLayoutConstraint *_badgeLblWidth;
    __weak IBOutlet NSLayoutConstraint *_examIconLeft;
    __weak IBOutlet NSLayoutConstraint *_testIconLeft;
    __weak IBOutlet NSLayoutConstraint *_mapIconLeft;
    __weak IBOutlet NSLayoutConstraint *_welfareIconLeft;
    __weak IBOutlet NSLayoutConstraint *_connectBtnTop;
    __weak IBOutlet NSLayoutConstraint *_statusLblBottom;
    
    TimeType _currentType;
    ENV_STATUS _currentStatus;
    ConnectStatus _connectStatus;
    CAAnimation *_leftAnimation;
    CAAnimation *_rightAnimation;
    CABasicAnimation *_aroundAnimation;
}
@end

@implementation WiFiMenuView

- (void)dealloc
{
    _leftAnimation = nil;
    _rightAnimation = nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _connectBtnTop.constant *= [Tools layoutFactor];
    _statusLblBottom.constant *= [Tools layoutFactor];
    _examIconLeft.constant *= [Tools layoutFactor];
    _testIconLeft.constant *= [Tools layoutFactor];
    _mapIconLeft.constant *= [Tools layoutFactor];
    _welfareIconLeft.constant *= [Tools layoutFactor];
    
    _halo = [PulsingHaloLayer layer];
    _halo.position = CGPointMake(kScreenWidth / 2, _connectBtnTop.constant + 56.5);
    [self.layer addSublayer:_halo];
    
    _currentType = TimeTypeDay;
    _currentStatus = ENV_DEFAULT;
    _connectStatus = ConnectStatusDefault;
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img_bg_day.png"];
    _backView.image = [UIImage imageWithContentsOfFile:imagePath];
    
    // connect views
    _outsideSmallCircle = [[UIImageView alloc] initWithImage:ImageNamed(@"circle_outside_small")];
    _outsideSmallCircle.center = _halo.position;
    [self addSubview:_outsideSmallCircle];
    
    _outsideBigCircle = [[UIImageView alloc] initWithImage:ImageNamed(@"circle_outside_big")];
    _outsideBigCircle.center = _halo.position;
    [self addSubview:_outsideBigCircle];
    
    _aroundCircle = [[UIImageView alloc] initWithImage:ImageNamed(@"circle_around")];
    _aroundCircle.center = _halo.position;
    [self addSubview:_aroundCircle];
    
    [self setConnectBtnStatus:ConnectStatusNotConnect];
    [self checkConnectBtnStatus];
}

- (void)setConnectBtnStatus:(ConnectStatus)status
{
    if (_connectStatus == status) return;
    _connectStatus = status;
    _outsideBigCircle.hidden = _outsideSmallCircle.hidden = _connectStatus == ConnectStatusNotConnect;
    _aroundCircle.hidden = _connectStatus != ConnectStatusConnecting;
    [_connectBtn setImage:(status == ConnectStatusConnected ? ImageNamed(@"Connect") : nil) forState:UIControlStateNormal];
    [_aroundCircle.layer removeAnimationForKey:@"rotationAnimation"];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (status == ConnectStatusNotConnect) {
        _connectBtn.userInteractionEnabled = YES;
        _connectBtn.selected = NO;
        [_connectBtn setTitle:@"一键连接" forState:UIControlStateNormal];
        [_connectBtn setAttributedTitle:nil forState:UIControlStateNormal];
        _statusLbl.text = @"发现东莞城市免费WiFi";
        [_halo start];
        [_aroundCircle.layer removeAnimationForKey:@"rotationAnimation"];
    } else if (status == ConnectStatusConnected) {
        _connectBtn.userInteractionEnabled = YES;
        _currentStatus = ENV_LOGIN;
        _connectBtn.selected = YES;
        [_connectBtn setTitle:@"" forState:UIControlStateNormal];
        [_connectBtn setAttributedTitle:nil forState:UIControlStateNormal];
        _statusLbl.text = @"已连接东莞城市免费WiFi";
        [_halo stop];
        [_aroundCircle.layer removeAnimationForKey:@"rotationAnimation"];
    } else {
        _connectBtn.userInteractionEnabled = NO;
        _connectBtn.selected = NO;
        [_connectBtn setTitle:@"" forState:UIControlStateNormal];
        _statusLbl.text = @"正在连接东莞城市免费WiFi";
        [_halo stop];
        if (!_aroundAnimation) {
            _aroundAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            _aroundAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
            _aroundAnimation.duration = ROTATIONSSECONDS;
            _aroundAnimation.cumulative = YES;
            _aroundAnimation.delegate = self;
            _aroundAnimation.removedOnCompletion = NO;
        }
        [_aroundCircle.layer addAnimation:_aroundAnimation forKey:@"rotationAnimation"];
        [self countDownLoadingSeconds:@(ROTATIONSSECONDS)];
    }
}

- (void)countDownLoadingSeconds:(NSNumber *)seconds
{
    int second = seconds.intValue;
    if (!second) return;
    NSString *secondsStr = [NSString stringWithFormat:@"%i秒",second];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:secondsStr];
    [attrString addAttribute:NSFontAttributeName value:SystemFont(22) range:NSMakeRange(0, 1)];
    [attrString addAttribute:NSFontAttributeName value:SystemFont(14) range:NSMakeRange(1, secondsStr.length - 1)];
    [_connectBtn setAttributedTitle:attrString forState:UIControlStateNormal];
    [self performSelector:@selector(countDownLoadingSeconds:) withObject:@(second - 1) afterDelay:1.0f];
}

- (void)setWeather:(NSDictionary *)weather
{
    _temperatureLbl.text = [NSString stringWithFormat:@"%ld°C",[weather[@"temp"] integerValue]];
    _weatherLbl.text = weather[@"info"];
    NSString *imageName = nil;
    switch ([weather[@"type"] integerValue]) {
        case WeatherTypeSun:
            imageName = @"Sunny";
            break;
        case WeatherTypeCloud:
            imageName = @"Cloudy";
            break;
        case WeatherTypeRain:
            imageName = @"Rain";
            break;
        case WeatherTypeSnow:
            imageName = @"Snow";
            break;
        default:
            break;
    }
    _leftWeatherView.image = _rightWeatherView.image = ImageNamed(imageName);
}

- (void)setHotNews:(NSString *)title
{
    _hotLbl.text = [NSString stringWithFormat:@"东莞头条：%@",title];
    _hotLbl.userInteractionEnabled = YES;
}

- (void)setDeviceBadge:(NSInteger)badge
{
    _badgeLbl.text = [NSString stringWithFormat:@"%ld",badge];
    _badgeLblWidth.constant = [_badgeLbl.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium]}].width + 10;
    _badgeLbl.hidden = !(badge > 0);
}

- (void)setBackViewImage
{
    TimeType type = [Tools getTimeType];
    if (_currentType != type) {
        _currentType = type;
        NSString *imagePath = nil;
        if (_currentType == TimeTypeDay) {
            imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img_bg_day.png"];
        } else {
            imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img_bg_night.png"];
        }
        _backView.image = [UIImage imageWithContentsOfFile:imagePath];
    }
}

- (void)startAnimation
{
    if (_connectStatus == ConnectStatusNotConnect) {
        [_halo start];
    }
    if (!_leftAnimation) {
        _leftAnimation = [AnimationManager positionAnimationFromPosition:_leftWeatherView.center toPosition:CGPointMake(_leftWeatherView.center.x - 50, _leftWeatherView.center.y) duration:6];
        _leftAnimation.repeatCount = INFINITY;
        _leftAnimation.autoreverses = YES;
    }
    [_leftWeatherView.layer addAnimation:_leftAnimation forKey:@"weather"];
    if (!_rightAnimation) {
        _rightAnimation = [AnimationManager positionAnimationFromPosition:_rightWeatherView.center toPosition:CGPointMake(_rightWeatherView.center.x + 20, _rightWeatherView.center.y) duration:3];
        _rightAnimation.repeatCount = INFINITY;
        _rightAnimation.autoreverses = YES;
    }
    [_rightWeatherView.layer addAnimation:_rightAnimation forKey:@"weather"];
}

- (void)stopAnimation
{
    if (_connectStatus == ConnectStatusNotConnect) {
        [_halo stop];
    }
    [_leftWeatherView.layer removeAnimationForKey:@"weather"];
    [_rightWeatherView.layer removeAnimationForKey:@"weather"];
}

- (void)checkConnectBtnStatus
{
#if !(TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] checkEnvironmentBlock:^(ENV_STATUS status) {
        if (_currentStatus != status) {
            _currentStatus = status;
            if (status == ENV_LOGIN) {
                [self setConnectBtnStatus:ConnectStatusConnected];
            } else if (status == ENV_NOT_WIFI) {
                if ([[Tools getCurrentSSID] isEqualToString:WIFISDK_SSID]) {
                    // 已经portal认证
                    [self setConnectBtnStatus:ConnectStatusConnected];
                } else {
                    // 别的网络（WiFi或者4G）
//                    if ([[NetworkManager shareManager] isWiFi]) {
//                        [self setConnectBtnStatus:ConnectStatusConnected];
//                    } else {
//                        [self setConnectBtnStatus:ConnectStatusNotConnect];
//                    }
                    [self setConnectBtnStatus:ConnectStatusNotConnect];
                }
            } else {
                [self setConnectBtnStatus:ConnectStatusNotConnect];
            }
        }
    }];
#else
    [self setConnectBtnStatus:ConnectStatusNotConnect];
#endif
}

- (IBAction)menuViewTap:(UITapGestureRecognizer *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(WiFiMenuViewClick:)]) {
        [_delegate WiFiMenuViewClick:sender.view.tag];
    }
}

- (IBAction)connectBtnClick:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(WiFiMenuViewClick:)]) {
        if (_connectStatus == ConnectStatusConnected) {
            [_delegate WiFiMenuViewClick:WiFiMenuTypeConnected];
        } else {
            [_delegate WiFiMenuViewClick:WiFiMenuTypeConnect];
        }
    }
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [_aroundCircle.layer animationForKey:@"rotationAnimation"]) {
        [self setConnectBtnStatus:ConnectStatusConnected];
    }
}

@end
