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
#import "MapCGI.h"
#import "BaiduMapSDK.h"

#define ROTATIONSSECONDS 5

@interface WiFiMenuView () <CAAnimationDelegate>
{
    __weak IBOutlet UIButton *_connectBtn;
    __weak IBOutlet UILabel *_statusLbl;
    __weak IBOutlet UILabel *_temperatureLbl;
    __weak IBOutlet UILabel *_weatherLbl;
    __weak IBOutlet UIImageView *_backView;
    __weak IBOutlet UIImageView *_leftWeatherView;
    __weak IBOutlet UIImageView *_rightWeatherView;
    __weak IBOutlet UIView *_noticeView;
    __weak IBOutlet UILabel *_noticeLbl;
    __weak IBOutlet UIView *_buttonView;
    
    
    PulsingHaloLayer *_halo;
    UIImageView *_outsideSmallCircle;
    UIImageView *_outsideBigCircle;
    UIImageView *_aroundCircle;
    
    // layout constraint
    __weak IBOutlet NSLayoutConstraint *_leftWeatherViewBottom;
    __weak IBOutlet NSLayoutConstraint *_rightWeatherViewTop;
    __weak IBOutlet NSLayoutConstraint *_statusLblTop;
    
    TimeType _currentType;
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
    
    CGFloat factor = [Tools layoutFactor];
    _leftWeatherViewBottom.constant *= factor;
    _rightWeatherViewTop.constant *= factor;
    _statusLblTop.constant = _statusLblTop.constant * factor + (factor >= 1 ? : -10);
    
    _halo = [PulsingHaloLayer layer];
    _halo.position = CGPointMake(kScreenWidth / 2, kScreenWidth / 375 * 244 / 2);
    [self.layer addSublayer:_halo];
    
    _currentType = TimeTypeDay;
    _connectStatus = ConnectStatusDefault;
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"img_bg_day.png"];
    _backView.image = [UIImage imageWithContentsOfFile:imagePath];
    
    // connect views
    _outsideSmallCircle = [[UIImageView alloc] initWithImage:ImageNamed(@"circle_outside_small")];
    _outsideSmallCircle.center = _halo.position;
    _outsideSmallCircle.alpha = 0;
    [self addSubview:_outsideSmallCircle];
    
    _outsideBigCircle = [[UIImageView alloc] initWithImage:ImageNamed(@"circle_outside_big")];
    _outsideBigCircle.center = _halo.position;
    _outsideBigCircle.alpha = 0;
    [self addSubview:_outsideBigCircle];
    
    _aroundCircle = [[UIImageView alloc] initWithImage:ImageNamed(@"circle_around")];
    _aroundCircle.center = _halo.position;
    _aroundCircle.alpha = 0;
    [self addSubview:_aroundCircle];
    
    _connectBtn.alpha = _buttonView.alpha = 0;
    [self checkConnectBtnStatus];
}

- (void)setConnectBtnStatus:(ConnectStatus)status
{
    if (_connectStatus == status) return;
    _connectStatus = status;
    _statusLbl.alpha = 0;
    [UIView animateWithDuration:0.5 animations:^{
        _statusLbl.alpha = 1;
        _connectBtn.alpha = _connectStatus != ConnectStatusConnected;
        _outsideBigCircle.alpha = _outsideSmallCircle.alpha = _aroundCircle.alpha = _connectStatus == ConnectStatusConnecting;
        _buttonView.alpha = _connectStatus == ConnectStatusConnected;
    }];
    [_aroundCircle.layer removeAnimationForKey:@"rotationAnimation"];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (status == ConnectStatusNotConnect) {
        _connectBtn.userInteractionEnabled = YES;
        [_connectBtn setTitle:@"一键连接" forState:UIControlStateNormal];
        [_connectBtn setAttributedTitle:nil forState:UIControlStateNormal];
        _statusLbl.text = @"检测到免费WiFi热点";
        [_halo start];
    } else if (status == ConnectStatusConnected) {
        _connectBtn.userInteractionEnabled = YES;
        [_connectBtn setTitle:@"" forState:UIControlStateNormal];
        [_connectBtn setAttributedTitle:nil forState:UIControlStateNormal];
        _statusLbl.text = [NSString stringWithFormat:@"已连接%@",[Tools getCurrentSSID]];
        [_halo stop];
    } else if (status == ConnectStatusConnecting) {
        _connectBtn.userInteractionEnabled = NO;
        [_connectBtn setTitle:@"" forState:UIControlStateNormal];
        _statusLbl.text = @"正在连接免费WiFi";
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
    } else {
        _connectBtn.userInteractionEnabled = YES;
        [_connectBtn setTitle:@"找WiFi" forState:UIControlStateNormal];
        [_connectBtn setAttributedTitle:nil forState:UIControlStateNormal];
        _statusLbl.text = @"寻找附近免费WiFi";
        [_halo start];
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

- (void)setNotice:(NSString *)notice
{
    if (notice.length) {
        _noticeView.hidden = NO;
        _noticeLbl.text = notice;
    } else {
        _noticeView.hidden = YES;
    }
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
    if (_connectStatus == ConnectStatusNotConnect || _connectStatus == ConnectStatusSearch) {
        [_halo start];
    }
    if (!_leftAnimation) {
        CGPoint center = CGPointMake(-10 + 83.0 / 2, kScreenWidth / 375 * 244 - 83.0 / 2 - _leftWeatherViewBottom.constant);
        _leftAnimation = [AnimationManager positionAnimationFromPosition:center toPosition:CGPointMake(center.x - 50, center.y) duration:6];
        _leftAnimation.repeatCount = INFINITY;
        _leftAnimation.autoreverses = YES;
    }
    [_leftWeatherView.layer addAnimation:_leftAnimation forKey:@"weather"];
    if (!_rightAnimation) {
        CGPoint center = CGPointMake(kScreenWidth - (83.0 / 2 - 30), _rightWeatherViewTop.constant + 83.0 / 2);
        _rightAnimation = [AnimationManager positionAnimationFromPosition:center toPosition:CGPointMake(center.x + 20, center.y) duration:3];
        _rightAnimation.repeatCount = INFINITY;
        _rightAnimation.autoreverses = YES;
    }
    [_rightWeatherView.layer addAnimation:_rightAnimation forKey:@"weather"];
}

- (void)stopAnimation
{
    if (_connectStatus == ConnectStatusNotConnect || _connectStatus == ConnectStatusSearch) {
        [_halo stop];
    }
    [_leftWeatherView.layer removeAnimationForKey:@"weather"];
    [_rightWeatherView.layer removeAnimationForKey:@"weather"];
}

- (void)checkConnectBtnStatus
{
#if !(TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] checkEnvironmentBlock:^(ENV_STATUS status) {
        if (status == ENV_LOGIN) {
            [self setConnectBtnStatus:ConnectStatusConnected];
        } else if (status == ENV_NOT_WIFI) {
            if ([[Tools getCurrentSSID] isEqualToString:WIFISDK_SSID]) {
                // 已经portal认证
                [self setConnectBtnStatus:ConnectStatusConnected];
            } else {
                // 别的网络（WiFi或者4G）
                if ([[NetworkManager shareManager] isWiFi]) {
                    [self setConnectBtnStatus:ConnectStatusConnected];
                } else {
                    [self searchNearbyAps];
                }
            }
        } else if (status == ENV_NOT_LOGIN) {
            [self setConnectBtnStatus:ConnectStatusNotConnect];
        } else {
            [self setConnectBtnStatus:ConnectStatusSearch];
        }
    }];
#else
    [self setConnectBtnStatus:ConnectStatusNotConnect];
#endif
}

- (void)searchNearbyAps
{
    if (![[BaiduMapSDK shareBaiduMapSDK] locationServicesEnabled]) {
        [self setConnectBtnStatus:ConnectStatusSearch];
    } else {
        CLLocationCoordinate2D coordinate = [[BaiduMapSDK shareBaiduMapSDK] getUserLocation].location.coordinate;
        [MapCGI getNearbyAps:coordinate.longitude latitude:coordinate.latitude complete:^(DGCgiResult *res) {
            if (E_OK == res._errno) {
                NSDictionary *data = res.data[@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    NSArray *infos = data[@"infos"];
                    if ([infos isKindOfClass:[NSArray class]] && infos.count) {
                        BOOL exist = NO;
                        for (NSDictionary *info in infos) {
                            if (MetersTwoCoordinate2D(coordinate, CLLocationCoordinate2DMake([info[@"latitude"] doubleValue], [info[@"longitude"] doubleValue])) <= 20) {
                                exist = YES;
                                break;
                            }
                        }
                        exist ? [self setConnectBtnStatus:ConnectStatusNotConnect] : [self setConnectBtnStatus:ConnectStatusSearch];
                    } else {
                        [self setConnectBtnStatus:ConnectStatusSearch];
                    }
                } else {
                    [self setConnectBtnStatus:ConnectStatusSearch];
                }
            } else {
                [self setConnectBtnStatus:ConnectStatusSearch];
            }
        }];
    }
}

- (IBAction)testBtnClick:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(WiFiMenuViewClick:)]) {
        [_delegate WiFiMenuViewClick:sender.tag];
    }
}

- (IBAction)shareBtnClick:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(WiFiMenuViewClick:)]) {
        [_delegate WiFiMenuViewClick:sender.tag];
    }
}

- (IBAction)menuViewTap:(UITapGestureRecognizer *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(WiFiMenuViewClick:)]) {
        [_delegate WiFiMenuViewClick:sender.view.tag];
    }
}

- (IBAction)connectBtnClick:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(WiFiMenuViewClick:)]) {
        if (_connectStatus == ConnectStatusNotConnect) {
            [_delegate WiFiMenuViewClick:WiFiMenuTypeConnect];
        } else {
            [_delegate WiFiMenuViewClick:WiFiMenuTypeMap];
        }
    }
}

- (IBAction)noticeBtnClick:(UIButton *)sender {
    [UIView animateWithDuration:0.25 animations:^{
        _noticeView.alpha = 0;
    } completion:^(BOOL finished) {
        _noticeView.hidden = YES;
    }];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [_aroundCircle.layer animationForKey:@"rotationAnimation"]) {
        [self setConnectBtnStatus:ConnectStatusConnected];
    }
}

@end
