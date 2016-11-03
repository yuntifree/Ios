//
//  WiFiSpeedView.m
//  360FreeWiFi
//
//  Created by lijinwei on 15/11/5.
//  Copyright © 2015年 qihoo360. All rights reserved.
//

#import "WiFiSpeedView.h"
#import "WiFiRecord.h"
#import "WFNetworkSpeedDetector.h"
#import "AnimationManager.h"
#import "WIFDefine.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "NetworkManager.h"

typedef NS_ENUM(NSUInteger, WFWiFiInfoPageBackgroundHintColorType) {
    WFWiFiInfoPageBackgroundHintColorTypeOrange,
    WFWiFiInfoPageBackgroundHintColorTypeBlue,
};

//按这些状态进行更新上面容器和下面容器的子视图。
typedef NS_ENUM(NSUInteger, WFWiFiInfoConnectedState)
{
    WFWiFiInfoConnectedStateNone,//KVO视图监听的初始状态。
    WFWiFiInfoConnectedStateConnectedWithoutSpeed,//能上网，没有速度，更换图片，背景为蓝色，并切换下面的hintLabel
    WFWiFiInfoConnectedStateConnectedWithUserSpeed,//能上网，拿的是服务器端的速度，连接后本客户端并没有测速，背景蓝色，并切换下面的HintLabel。
    WFWiFiInfoConnectedStateConnectedTestingSpeed,//正在测速，进行动画。
    WFWiFiInfoConnectedStateConnectedTestedSpeed,//已经测速。
};



const float EPSINON = 0.00001;
#define FLOAT_IS_ZERO(x) ((x >= - EPSINON) && (x <= EPSINON))

static CGFloat kWiFiInfoCenterImageViewWidthRatio = 0.27886;
static CGFloat kWiFiInfoCenterImageBgRingWidthRatio = 0.28;

static CGFloat kWiFiInfoSpeedScaleContainerViewWidthRatio = 0.27886;
static CGFloat kWiFiInfoSpeedScaleContainerViewHeightRatio = 0.27886;

static CGFloat kWiFiInfoBottomSharedContainerHeight = 0.1889;//126;// +60

static NSUInteger kEvalueSpeedTitleLableOriginY = 0;
static NSUInteger kSharedBottomContainerOriginY = 0;

#define iS3X (IS_IPHONE_SIX || IS_IPHONE_SIX_PLUS)

#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))
#define kHelveticeFontWithSize(sizeInt) [UIFont fontWithName:@"Helvetica" size:sizeInt]

//bottomContainer
#define kInfoPageBottomContainerEvalueSpeedLabelTag 31010

#define kBottomHintLabelFontSize 12
#define kTopContainerTextColor 0x1462bb
#define kBigStartSpeedDetectLabelSize 25
#define kUserSpeedHintLabelSize 14
#define kSpeedNumberLabelSize 35
#define kSpeedNumberUnitLabelSize 18
#define kSmallTestSpeedHintLabelSize 19

//topContainer
#define kInfoPageTopContainerAutoLinkPercentLabelTag 30010
#define kInfoPageTopContainerTestSpeedHintLabelTag 30011
#define kInfoPageTopContainerServerSpeedHintLabelTag 30012
#define kInfoPageTopContainerSpeedLabelTag 30013

#define kTopContainerTextColor 0x1462bb

#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式

#define UICOLOR_ARGB(color) [UIColor colorWithRed: ((((unsigned int)color) >> 16) & 0xFF) / 255.0 green: ((((unsigned int)color) >> 8) & 0xFF) / 255.0 blue: (((unsigned int)color) & 0xFF) / 255.0 alpha: ((((unsigned int)color) >> 24) & 0xFF) / 255.0]

#define COLOR_THEME UICOLOR_ARGB(0xff288dff)
#define COLOR_THEME_HIGHLIGHTED UICOLOR_ARGB(0xff1174e4)

const CGFloat menuOpenTitleY = 0.2503;
const CGFloat kWiFiInfoTopContainerFrameRatio = 0.46875;
const CGFloat statusViewHeight = 0.19640;//131;
const CGFloat menuOpenImageCenterY = 0.1304;
const CGFloat menuOpenButtonY = 0.058965;

@interface WiFiSpeedView () <WFNetworkSpeedDetectorDelegate>
{
    WiFiRecord *_connectedRecord;
    BOOL _testingSpeed;
    NSDictionary *_BtnInfo;
    NSDictionary *_wifiInfoPageCenterImageViewResourceDic;
    NSDictionary *_wifiInfoPageBackgroundHintColorDic;
}

@property (assign, nonatomic) WFWiFiInfoConnectedState state;
@property (assign, nonatomic) WFWiFiInfoConnectedState lastState;

@property (strong, nonatomic) UIView *wifiStateIndicatorBackgroundView;
@property (strong, nonatomic) UIImageView *wifiInfoPageCenterImageView;
@property (strong, nonatomic) UIButton *wifiInfoPageCenterButton;
@property (strong, nonatomic) UIImageView *wifiInfoPageCenterImageBgRingImageView;
@property (strong, nonatomic) UIView *speedScaleContainerView;//包含当前速度和灰色背景的容器视图。
@property (strong, nonatomic) UIImageView *currentSpeedScaleImageView;//当前速度的刻度标识
@property (strong, nonatomic) UIImageView *speedScaleBackgroundImageView;//灰色的刻度
@property (strong, nonatomic) CAShapeLayer *maskLayer;

#pragma mark -
#pragma mark =============== Public WiFi Info Container SubViews ================

@property (strong, nonatomic) UIView *wifiInfoPageTopContainer;;//用来管理子视图。
@property (strong, nonatomic) UIView *wifiInfoPageBottomContainer;

#pragma mark - top container subViews
@property (strong, nonatomic) UILabel *wifiInfoPageTopContainerSpeedLabel;//速度的展示。
@property (strong, nonatomic) UIView *wifiInfoPageTopContainerSeperatorLineView;
@property (strong, nonatomic) UILabel *wifiInfoPageTopContainerTestSpeedHintLabel;//小的立即测速，测速中的提示,重新。
@property (strong, nonatomic) UILabel *wifiInfoPageTopContainerServerSpeedHintLabel;//网友测速的提示。
@property (strong, nonatomic) UILabel *wifiInfoPageTopContainerBigTestSpeedHintLabel;//大的立即测速。

#pragma mark ======================== bottom Container SubView ========================
@property (strong, nonatomic) UILabel *evalueSpeedLabel;//对网速评价
@property (strong, nonatomic) UILabel *evalueSpeedTitleLabel;

@property (strong, nonatomic) UIView *sharedWiFiInfoHintContainer;//此容器要添加到wifiInfoOutsideContainerView的视图。
@property (strong, nonatomic) UILabel *sharedWiFiInfoHintContainerLabel;
@property (strong, nonatomic) UIButton *sharedWiFiInfoHintContainerButton;

@end

@implementation WiFiSpeedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = COLOR_THEME;
        [self setupWiFiPageSubViews];
    }
    return self;
}


- (void)setupWiFiPageSubViews
{
    [self initializeDataStructure];

#pragma mark -
    //这是一个和界面大小一致的可变颜色的背景图
    _wifiStateIndicatorBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_wifiStateIndicatorBackgroundView];
    [_wifiStateIndicatorBackgroundView setBackgroundColor:[UIColor clearColor]];
    
    _wifiInfoPageCenterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWiFiInfoCenterImageViewWidthRatio * kScreenHeight, kWiFiInfoCenterImageViewWidthRatio * kScreenHeight)];
    _wifiInfoPageCenterImageView.image = [UIImage imageNamed:@"center_image_white_ball"];
    _wifiInfoPageCenterImageView.center = CGPointMake(kScreenWidth/2, 0.1349*kScreenHeight);
    [_wifiStateIndicatorBackgroundView addSubview:_wifiInfoPageCenterImageView];

    _wifiInfoPageCenterImageBgRingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWiFiInfoCenterImageBgRingWidthRatio * kScreenHeight, kWiFiInfoCenterImageBgRingWidthRatio * kScreenHeight)];
    _wifiInfoPageCenterImageBgRingImageView.image = [UIImage imageNamed:@"center_image_white_ball_bg_ring"];
    _wifiInfoPageCenterImageBgRingImageView.center = _wifiInfoPageCenterImageView.center;
    
    //begin
    _speedScaleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWiFiInfoSpeedScaleContainerViewWidthRatio * kScreenHeight, kWiFiInfoSpeedScaleContainerViewHeightRatio * kScreenHeight)];
    [_speedScaleContainerView setBackgroundColor:[UIColor clearColor]];
    [_wifiStateIndicatorBackgroundView insertSubview:_speedScaleContainerView belowSubview:_wifiInfoPageCenterImageView];
    
    _speedScaleContainerView.transform = CGAffineTransformMakeScale(1/2, 1/2);
    
    _speedScaleContainerView.center = CGPointMake(_wifiInfoPageCenterImageView.center.x, _wifiInfoPageCenterImageView.center.y);
    
    _speedScaleBackgroundImageView = [[UIImageView alloc] initWithFrame:_speedScaleContainerView.bounds];
    _speedScaleBackgroundImageView.image = [UIImage imageNamed:@"speed_scale_image_bg"];
    [_speedScaleContainerView addSubview:_speedScaleBackgroundImageView];
    
    
    _currentSpeedScaleImageView = [[UIImageView alloc] initWithFrame:_speedScaleContainerView.bounds];
    _currentSpeedScaleImageView.image = [UIImage imageNamed:@"speed_scale_image_current_speed"];
    [_speedScaleContainerView addSubview:_currentSpeedScaleImageView];
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(_speedScaleContainerView.bounds), CGRectGetMidY(_speedScaleContainerView.bounds)) radius:0.11944*kScreenHeight startAngle:degreesToRadians(-210) endAngle:degreesToRadians(30) clockwise:YES];
    
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.fillColor = [UIColor clearColor].CGColor;
    _maskLayer.strokeColor = [UIColor blackColor].CGColor;
    _maskLayer.lineCap = kCALineCapButt;
    _maskLayer.lineWidth = 60;
    _maskLayer.path = [path CGPath];
    _maskLayer.strokeEnd = 0.f;
    [_currentSpeedScaleImageView.layer setMask:_maskLayer];
    
    [self setupWiFiInfoPageTopAndBottomContainers];
}

#pragma mark - WIFMenuContentViewDeleagte

- (NSString *)getNavigationTitle
{
    return @"WiFi测速";
}

- (void)contentViewDidAppear
{
    if ([self.delegate respondsToSelector: @selector(updateSpeedNavTitle:)]) {
        [self.delegate updateSpeedNavTitle: [self getNavigationTitle]];
    }
}

- (void)wifiDisconnected
{
    _connectedRecord.m_ssid = nil;
    _connectedRecord.m_avgspeed = nil;
    _BtnInfo = nil;
}

- (void)wifiConnected
{
    if (_connectedRecord.m_ssid == nil) {
        if ([Tools getCurrentSSID]) {
            [self adjustWiFiInfoPageForState:WFWiFiInfoConnectedStateConnectedWithoutSpeed];//默认状态
        }
        
    }else{
        if (_state != WFWiFiInfoConnectedStateConnectedTestingSpeed) {
            if ([Tools getCurrentSSID]) {
                [self adjustWiFiInfoPageForState:_state];
            }
        }else{
        }
    }
    
    _connectedRecord.m_ssid = [Tools getCurrentSSID];
}

- (void)wifiInfoUpdate:(WiFiRecord*) record {
    [self updateWiFiInfo:record];
}

- (void)updateWiFiInfo:(WiFiRecord*) record {
    if( record ) {
        NSString* speedStr = record.m_avgspeed;
        if (speedStr && !FLOAT_IS_ZERO([speedStr floatValue])) {
            if (_state == WFWiFiInfoConnectedStateConnectedWithoutSpeed) {
                __weak typeof(self) weakSelf = self;
                if (weakSelf) {
                    [weakSelf adjustWiFiInfoPageForState:WFWiFiInfoConnectedStateConnectedWithUserSpeed];
                    [weakSelf showCurrentSpeed:[speedStr floatValue]];
                    _connectedRecord.m_avgspeed = speedStr;
                    
                    NSString *formatedSpeed = [self formatSpeed:[speedStr floatValue]];
                    if ([self.delegate respondsToSelector: @selector(updateSpeedBarIcon:)]) {
                        [self.delegate updateSpeedBarIcon:formatedSpeed];
                    }
                }
            }
            
        }
    }
}

- (void)setupWiFiInfoPageTopAndBottomContainers
{
    _wifiInfoPageTopContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWiFiInfoTopContainerFrameRatio * kScreenWidth, kWiFiInfoTopContainerFrameRatio * kScreenWidth)];
    [_wifiStateIndicatorBackgroundView addSubview:_wifiInfoPageTopContainer];
    _wifiInfoPageTopContainer.center = _wifiInfoPageCenterImageView.center;
    _wifiInfoPageTopContainer.layer.cornerRadius = _wifiInfoPageTopContainer.frame.size.height * 0.5;
    
    [_wifiInfoPageTopContainer setBackgroundColor:[UIColor clearColor]];
    
    
    _wifiInfoPageBottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, menuOpenTitleY*kScreenHeight, kScreenWidth, kWiFiInfoBottomSharedContainerHeight*kScreenHeight)];
    [_wifiStateIndicatorBackgroundView addSubview:_wifiInfoPageBottomContainer];
    [_wifiInfoPageBottomContainer setBackgroundColor:[UIColor clearColor]];
    
    _wifiInfoPageCenterButton = [[UIButton alloc] initWithFrame:_wifiInfoPageTopContainer.bounds];
    [_wifiInfoPageTopContainer addSubview:_wifiInfoPageCenterButton];
    [_wifiInfoPageCenterButton setBackgroundColor:[UIColor clearColor]];
    [_wifiInfoPageCenterButton addTarget:self action:@selector(startDetectSpeed:) forControlEvents:UIControlEventTouchUpInside];
    [_wifiInfoPageCenterButton addTarget:self action:@selector(prepareDetectSpeed:) forControlEvents:UIControlEventTouchDown];
    [_wifiInfoPageCenterButton addTarget:self action:@selector(resetDetectSpeedBtn:) forControlEvents:UIControlEventTouchUpOutside];
    
    [self setupCachedTopContainerSubviews];
    [self setupCachedBottomContainerSubviews];
}


- (void)setupCachedTopContainerSubviews
{
    //速度
    _wifiInfoPageTopContainerSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 37)];//测速时候用。
    _wifiInfoPageTopContainerSpeedLabel.textAlignment = NSTextAlignmentCenter;
    _wifiInfoPageTopContainerSpeedLabel.textColor = RGB(kTopContainerTextColor, 1);
    _wifiInfoPageTopContainerSpeedLabel.tag = kInfoPageTopContainerSpeedLabelTag;
    
    NSString *initialSpeedText  = @"0.00k/s";
    NSUInteger length = [initialSpeedText length];
    NSMutableAttributedString *attributeSpeed = [[NSMutableAttributedString alloc] initWithString:initialSpeedText];
    NSUInteger fontSize = IS_IPHONE_FOUR?4:(IS_IPHONE_FIVE?4:0);
    [attributeSpeed setAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont systemFontOfSize:26-fontSize],NSFontAttributeName, nil] range:NSMakeRange(0, length - 3)];
    [attributeSpeed setAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont systemFontOfSize:24-fontSize],NSFontAttributeName, nil] range:NSMakeRange(length - 3, 1)];
    [attributeSpeed setAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont systemFontOfSize:14-fontSize], NSFontAttributeName , nil] range:NSMakeRange(length - 2, 2)];
    _wifiInfoPageTopContainerSpeedLabel.attributedText = attributeSpeed;
    
    [_wifiInfoPageTopContainer addSubview:_wifiInfoPageTopContainerSpeedLabel];
    _wifiInfoPageTopContainerSpeedLabel.center = CGPointMake(CGRectGetMidX(_wifiInfoPageTopContainer.bounds), CGRectGetMidY(_wifiInfoPageTopContainer.bounds));

    //大的立即测速
    _wifiInfoPageTopContainerBigTestSpeedHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _wifiInfoPageTopContainer.frame.size.width, 36)];
    _wifiInfoPageTopContainerBigTestSpeedHintLabel.font = [UIFont systemFontOfSize:20-fontSize];
    _wifiInfoPageTopContainerBigTestSpeedHintLabel.textColor = RGB(0x1462bb, 1);
    _wifiInfoPageTopContainerBigTestSpeedHintLabel.text = @"立即测速";
    _wifiInfoPageTopContainerBigTestSpeedHintLabel.alpha = 0.f;
    _wifiInfoPageTopContainerBigTestSpeedHintLabel.textAlignment = NSTextAlignmentCenter;
    [_wifiInfoPageTopContainer addSubview:_wifiInfoPageTopContainerBigTestSpeedHintLabel];
    _wifiInfoPageTopContainerBigTestSpeedHintLabel.center = CGPointMake(CGRectGetMidX(_wifiInfoPageTopContainer.bounds), CGRectGetMidY(_wifiInfoPageTopContainer.bounds));
    
}

- (void)setupCachedBottomContainerSubviews
{
    _evalueSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kEvalueSpeedTitleLableOriginY, kScreenWidth, 12)];
    _evalueSpeedLabel.textAlignment = NSTextAlignmentCenter;
    _evalueSpeedLabel.textColor = [UIColor whiteColor];
    _evalueSpeedLabel.font = [UIFont systemFontOfSize:12];
    _evalueSpeedLabel.tag = kInfoPageBottomContainerEvalueSpeedLabelTag;
    _evalueSpeedLabel.alpha = CommonTipsAlpha;
    [self addSubview:_evalueSpeedLabel];

    _evalueSpeedTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kEvalueSpeedTitleLableOriginY + 12 + 10, kScreenWidth, 20)];
    _evalueSpeedTitleLabel.textAlignment = NSTextAlignmentCenter;
    _evalueSpeedTitleLabel.textColor = [UIColor whiteColor];
    _evalueSpeedTitleLabel.font = [UIFont systemFontOfSize:20];
    [self addSubview:_evalueSpeedTitleLabel];
    [self updateEvalueSpeedLabelAndEvalueSpeedTitleLabelTop];

    _sharedWiFiInfoHintContainer = [self buildSharedWiFiInfoHintContainer];
    [_wifiInfoPageBottomContainer addSubview:_sharedWiFiInfoHintContainer];
    [self switchWiFiInfoPageBottomContainer:WFWiFiInfoConnectedStateConnectedWithoutSpeed];
}

- (void)updateEvalueSpeedLabelAndEvalueSpeedTitleLabelTop
{
    const CGSize  sizeImageLogo = CGSizeMake(0.167916*kScreenHeight, 0.167916*kScreenHeight);
    const CGFloat detailTop = menuOpenImageCenterY * kScreenHeight + sizeImageLogo.height / 2 + 3;
    const CGFloat detailHeight = (statusViewHeight * 0.8 + 0.0149925) * kScreenHeight;
    if (((self.evalueSpeedTitleLabel.text.length > 0 || self.evalueSpeedTitleLabel.attributedText.length > 0)) && self.evalueSpeedTitleLabel.alpha == 1 && self.evalueSpeedLabel.text.length > 0 && self.evalueSpeedLabel.alpha > 0) {
        CGFloat contentHeight = _evalueSpeedLabel.height / 2 + _evalueSpeedTitleLabel.height / 2 + 26;
        _evalueSpeedTitleLabel.y = detailTop + (detailHeight - contentHeight) / 2;
        _evalueSpeedLabel.y = _evalueSpeedTitleLabel.y + 26;
    } else {
        //如果不是 evalueSpeedTitleLabel 和 evalueSpeedLabel 都存在文字这种情况，则说明其中之一有文字或都没有文字，此时把它们都居中
        _evalueSpeedLabel.y = detailTop + detailHeight / 2;
        _evalueSpeedTitleLabel.y = detailTop + detailHeight / 2;
    }
}

//在显示相关的状态时候进行延迟加载。
- (UIView *)buildSharedWiFiInfoHintContainer//自动连接失败，已连接无法上网，已连接需要登录三种情况下公用的情况。
{
    const CGFloat commonButtonTop = (menuOpenButtonY + menuOpenTitleY + 0.0149925) * kScreenHeight + 44;
    if (!_sharedWiFiInfoHintContainer) {
        _sharedWiFiInfoHintContainer = [[UIView alloc] initWithFrame:CGRectMake(0, kSharedBottomContainerOriginY, kScreenWidth, kWiFiInfoBottomSharedContainerHeight*kScreenHeight)];
        _sharedWiFiInfoHintContainerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 21)];
        _sharedWiFiInfoHintContainerLabel.textColor = [UIColor whiteColor];
        _sharedWiFiInfoHintContainerLabel.font = kHelveticeFontWithSize(kBottomHintLabelFontSize * kScreenWidth/320);
        _sharedWiFiInfoHintContainerLabel.textAlignment = NSTextAlignmentCenter;
        [_sharedWiFiInfoHintContainerLabel setBackgroundColor:[UIColor clearColor]];
        [_sharedWiFiInfoHintContainer addSubview:_sharedWiFiInfoHintContainerLabel];

        CGFloat kPublicWiFiInfoHintContainerButtonWidth = 140 * kScreenWidth / 320;
        _sharedWiFiInfoHintContainerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _sharedWiFiInfoHintContainerButton = [[UIButton alloc] initWithFrame:CGRectMake( 0.5 * (kScreenWidth - kPublicWiFiInfoHintContainerButtonWidth), commonButtonTop, kPublicWiFiInfoHintContainerButtonWidth, 36)];
        _sharedWiFiInfoHintContainerButton.frame = CGRectMake( 0.5 * (kScreenWidth - kPublicWiFiInfoHintContainerButtonWidth), commonButtonTop, kPublicWiFiInfoHintContainerButtonWidth, 36);
        [_sharedWiFiInfoHintContainerButton setBackgroundColor:[UIColor clearColor]];
        [self setupNormalSharedWiFiInfoHintContainerButton];
        _sharedWiFiInfoHintContainerButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:_sharedWiFiInfoHintContainerButton];
        [_sharedWiFiInfoHintContainerButton addTarget:self action:@selector(handleSharedContainerButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sharedWiFiInfoHintContainer;
}


- (void)handleSharedContainerButtonClick:(UIButton *)sender
{
    if( sender.tag == WFWiFiInfoConnectedStateConnectedTestingSpeed ) {
        [self stopDetectSpeed];
        [self evalueSpeed:[_connectedRecord.m_avgspeed floatValue]];
        [self calculateSpeed:[_connectedRecord.m_avgspeed floatValue] * 1024];
    }
    else if( sender.tag == WFWiFiInfoConnectedStateConnectedWithoutSpeed ||
            sender.tag == WFWiFiInfoConnectedStateConnectedWithUserSpeed ) {
        [self prepareDetectSpeed:nil];
        [self startDetectSpeed:nil];
    }
    else if( sender.tag == WFWiFiInfoConnectedStateConnectedTestedSpeed ) {
        if ([self.delegate respondsToSelector: @selector(touchCloseBtn)]) {
            [self.delegate touchCloseBtn];
        }
    }
}

#pragma mark -
#pragma mark ======================= WFNetworkSpeedDetectorDelegate 方法 =======================
/**
 *  计算的平均速度，单位为b
 *
 *  @param speed 平均速度
 */
- (void)didFinishDetectWithAverageSpeed:(CGFloat)speed
{
    if (!FLOAT_IS_ZERO(speed)) {
        _connectedRecord.m_avgspeed = [NSString stringWithFormat:@"%f",speed/1024];
        [self adjustWiFiInfoPageForState:WFWiFiInfoConnectedStateConnectedTestedSpeed];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self evalueSpeed:speed/1024.f];
            [self calculateSpeed:speed];
            [self stopSpeedDetectionAnimation];
//            [WFWiFiInfoFetcher sharedFetcher].currentRecord.m_avgspeed = [NSString stringWithFormat: @"%f", speed / 1024.0];
            NSLog(@"didFinishDetectWithAverageSpeed");
            [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_CURRENT_SPEED_UPDATED object: nil];
            
            __weak typeof(self) weakSelf = self;
            [weakSelf performSelector:@selector(gotoFoundTabVC) withObject:nil afterDelay:2];
        });
//        dispatch_async(dispatch_get_global_queue(NULL, DISPATCH_QUEUE_PRIORITY_HIGH), ^{
//            [[WFSpeedUploader sharedUploader] uploadSpeed:speed/1024];
//        });
    }else{
        [self adjustWiFiInfoPageForState:self.lastState];
        [self stopSpeedDetectionAnimation];
    }
}

- (void)gotoFoundTabVC {
    if ([self.delegate respondsToSelector: @selector(touchCloseBtn)]) {
        [self.delegate touchCloseBtn];
    }
}

- (void)adjustWiFiInfoPageForState:(WFWiFiInfoConnectedState)state
{
    if ([WFNetworkSpeedDetector sharedSpeedDetector].isSpeedDetecting) {
        [[WFNetworkSpeedDetector sharedSpeedDetector] stopSpeedDetector];
        [self stopSpeedDetectionAnimation];
    }

    self.lastState = self.state;
    self.state = state;
    [self switchWiFiInfoPageTopContainer:state];
    [self switchWiFiInfoPageBottomContainer:state];
}

/**
 *  计算的平均速度，单位为b
 *
 *  @param speed 平均速度
 */

- (void)didDetectRealtimeSpeed:(CGFloat)speed
{
    [self calculateSpeed:speed];
}

#pragma mark -
#pragma mark ======================= 测速相关的计算 =============================

- (void)prepareDetectSpeed:(UIButton *)sender
{
    if ([WFNetworkSpeedDetector sharedSpeedDetector].isSpeedDetecting) {
        return;
    }
    if (_state != WFWiFiInfoConnectedStateConnectedWithUserSpeed && _state != WFWiFiInfoConnectedStateConnectedWithoutSpeed && _state != WFWiFiInfoConnectedStateConnectedTestedSpeed) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _wifiInfoPageCenterImageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
        _wifiInfoPageTopContainer.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)resetDetectSpeedBtn:(UIButton *)sender
{
    if ([WFNetworkSpeedDetector sharedSpeedDetector].isSpeedDetecting ) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _wifiInfoPageCenterImageView.transform = CGAffineTransformMakeScale(1, 1);
        _wifiInfoPageTopContainer.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)startDetectSpeed:(UIButton *)sender
{
    if ([WFNetworkSpeedDetector sharedSpeedDetector].isSpeedDetecting ) {
        return;
    }
    NSLog(@"STATUE ==== %lu",(unsigned long)self.state);
    if (self.state == WFWiFiInfoConnectedStateConnectedTestingSpeed ) {
        return;
    }

    if ([[NetworkManager shareManager] currentReachabilityStatus] != ReachableViaWiFi) {
        return;
    }
    
    [self adjustWiFiInfoPageForState:WFWiFiInfoConnectedStateConnectedTestingSpeed];
    _sharedWiFiInfoHintContainerButton.userInteractionEnabled = NO;
    [self startSpeedDetectionAnimation];

//    [[WIFWiFiTraceManager sharedInstance] traceWithOperation: @"speed" andParam: nil];
}

- (void)stopDetectSpeed
{
    [[WFNetworkSpeedDetector sharedSpeedDetector] stopSpeedDetector];
    [self stopSpeedDetectionAnimation];
//    [self adjustWiFiInfoPageForState:self.lastState];
    if (_connectedRecord.m_avgspeed > 0) {
        [self adjustWiFiInfoPageForState:WFWiFiInfoConnectedStateConnectedTestedSpeed];
    } else {
        [self adjustWiFiInfoPageForState:WFWiFiInfoConnectedStateConnectedWithoutSpeed];
    }

//    [[WIFWiFiTraceManager sharedInstance] traceWithOperation: @"stopSpeed" andParam: nil];
}


- (void)startSpeedDetectionAnimation
{
    _speedScaleContainerView.alpha = 0.f;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.6 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        _wifiInfoPageCenterImageView.transform = CGAffineTransformMakeScale(1, 1);
        _wifiInfoPageTopContainer.transform = CGAffineTransformMakeScale(1, 1);
        _speedScaleContainerView.transform = CGAffineTransformIdentity;
        _wifiInfoPageCenterImageBgRingImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        _speedScaleContainerView.alpha = 1.f;
    } completion:^(BOOL finished) {
        //开始测速.
        _testingSpeed = YES;
        _sharedWiFiInfoHintContainerButton.userInteractionEnabled = YES;
        [WFNetworkSpeedDetector sharedSpeedDetector].delegate = self;
        [[WFNetworkSpeedDetector sharedSpeedDetector] startSpeedDetector];
    }];
}

- (void)stopSpeedDetectionAnimation
{
    _wifiInfoPageCenterButton.userInteractionEnabled = NO;
    [[WFNetworkSpeedDetector sharedSpeedDetector] stopSpeedDetector];
    _speedScaleContainerView.alpha = 1.f;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState animations:^{
        _speedScaleContainerView.transform = CGAffineTransformMakeScale(1/2, 1/2);
        _wifiInfoPageCenterImageBgRingImageView.transform = CGAffineTransformIdentity;
        _speedScaleContainerView.alpha = 0.f;
    } completion:^(BOOL finished) {
        _maskLayer.strokeEnd = 0;
        _testingSpeed = NO;
        _wifiInfoPageCenterButton.userInteractionEnabled = YES;
    }];
}

//用中间的label进行显示当前速度
- (void)showCurrentSpeed:(CGFloat )speedKB
{
    NSString *formatedSpeed = [self formatSpeed:speedKB];
    NSUInteger length = formatedSpeed.length;
    NSMutableAttributedString *attributeSpeed = [[NSMutableAttributedString alloc] initWithString:formatedSpeed];
    NSUInteger fontSize = IS_IPHONE_FOUR?4:(IS_IPHONE_FIVE?4:0);
    [attributeSpeed setAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont systemFontOfSize:26-fontSize],NSFontAttributeName, nil] range:NSMakeRange(0, length - 3)];
    [attributeSpeed setAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont systemFontOfSize:24-fontSize],NSFontAttributeName, nil] range:NSMakeRange(length - 3, 1)];
    [attributeSpeed setAttributes:[[NSDictionary alloc] initWithObjectsAndKeys:[UIFont systemFontOfSize:14-fontSize], NSFontAttributeName , nil] range:NSMakeRange(length - 2, 2)];
    if(self.state == WFWiFiInfoConnectedStateConnectedWithUserSpeed )
    {
        _evalueSpeedTitleLabel.attributedText = attributeSpeed;
        _evalueSpeedLabel.text = @"来自网友的平均测速";
        
        [self updateEvalueSpeedLabelAndEvalueSpeedTitleLabelTop];
    }
    else {
        _wifiInfoPageTopContainerSpeedLabel.attributedText = attributeSpeed;
        
        if(self.state == WFWiFiInfoConnectedStateConnectedTestedSpeed ) {
            if ([self.delegate respondsToSelector: @selector(updateSpeedBarIcon:)]) {
                [self.delegate updateSpeedBarIcon:formatedSpeed];
            }
        }
    }
}

/**
 *  速度格式化和显示的入口方法
 *
 *  @param speed 以b为单位的速度。
 */
- (void)calculateSpeed:(CGFloat)speed
{
    CGFloat speedKB = speed/1024;
    [self strokeCurrentSpeed:speedKB];
    [self showCurrentSpeed:speedKB];
}

/**
 *  进行绘制相关的scale上面的刻度显示
 *
 *  @param speed 当前测出的速度，以kb为单位。
 */

- (void)strokeCurrentSpeed:(CGFloat)speed
{
    CGFloat radians = degreesToRadians([self degreeFromSpeed:speed]);
    _maskLayer.strokeEnd =  radians/(3 * M_PI/2);
}

//传入的speed的单位是KB
- (NSString *)formatSpeed:(CGFloat)speedkb
{
    NSString *formatedSpeed = [NSString new];
    
    if ( speedkb >= 0 && speedkb < 10) {
        formatedSpeed = [NSString stringWithFormat:@"%.2fK/s", speedkb];
    }else if (speedkb >= 10 && speedkb < 100){
        formatedSpeed = [NSString stringWithFormat:@"%.1fK/s", speedkb];
    }else if (speedkb >= 100 && speedkb < 1024){
        formatedSpeed = [NSString stringWithFormat:@"%.0fK/s", speedkb];
    }else if (speedkb >= 1024){
        formatedSpeed = [NSString stringWithFormat:@"%.2fM/s",speedkb/1024];
    }
    return formatedSpeed;
}


/**
 *  根据速度转化为现在的图形的函数
 *  @param speedkb 测试出的速度
 *  @return 需要转动的角度
 */

- (NSInteger)degreeFromSpeed:(CGFloat)speedkb
{
    if (speedkb > 5 * 1024) {
        return 270;
    }
    if (speedkb > 150) {
        return 220 + (speedkb - 150)/(5*1024 - 150)* 50;
    }
    if (speedkb > 80) {
        return 135 + (speedkb - 80)/(150 - 80) * 85;
    }
    if (speedkb > 20) {
        return 50 + (speedkb - 20)/(80 - 20) * 85;
    }else{
        return 0 + speedkb/ 20 * 50;
    }
    return 0;
}


/**
 *  网络速度评价分级
 *
 *  @param speedkb 检测到的数据，以KB为单位。
 */

- (void)evalueSpeed:(CGFloat)speedkb
{
    [self showCurrentSpeed:speedkb];

    NSString *text = @"";
    if (speedkb <= 0 && speedkb < 20) {
        text = @"聊天";
    } else if (speedkb < 80) {
        text = @"聊天、上网";
    } else if (speedkb < 150) {
        text = @"聊天、上网、玩游戏";
    } else {
        text = @"聊天、上网、玩游戏、看视频";
    }

    _evalueSpeedTitleLabel.text = @"当前网速适合";
    _evalueSpeedLabel.text = text;

    [self updateEvalueSpeedLabelAndEvalueSpeedTitleLabelTop];
}

#pragma mark ==================== some utils =====================

- (void)view:(UIView *)target centerXInView:(UIView *)containerView
{
    CGPoint center = target.center;
    center.x = containerView.frame.size.width *  0.5 ;
    target.center = center;
}

- (BOOL)isSPSSIDs
{
    NSString *ssid = [Tools getCurrentSSID];
    
    return [ssid isEqualToString:@"CMCC"] || [ssid isEqualToString:@"CMCC-WEB"] || [ssid isEqualToString:@"ChinaNet"] ||[ssid isEqualToString:@"ChinaUnicom"];
}

- (void)switchWiFiInfoPageTopContainer:(WFWiFiInfoConnectedState)state
{
    if (self.lastState == state) {
        return;
    }
    [self switchWiFiInfoPageCenterImage:state];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        switch (state) {
            case WFWiFiInfoConnectedStateNone:
            {
                _wifiInfoPageTopContainerBigTestSpeedHintLabel.alpha = 1.f;
                _wifiInfoPageTopContainerSeperatorLineView.alpha = 0.f;
                _wifiInfoPageTopContainerServerSpeedHintLabel.alpha = 0.f;
                _wifiInfoPageTopContainerSpeedLabel.alpha = 0.f;
                _wifiInfoPageTopContainerTestSpeedHintLabel.alpha = 0.f;
            }
                break;

            case WFWiFiInfoConnectedStateConnectedWithoutSpeed:
            case WFWiFiInfoConnectedStateConnectedWithUserSpeed:
            {
                _wifiInfoPageTopContainerBigTestSpeedHintLabel.alpha = 1.f;
                _wifiInfoPageTopContainerSeperatorLineView.alpha = 0.f;
                _wifiInfoPageTopContainerServerSpeedHintLabel.alpha = 0.f;
                _wifiInfoPageTopContainerSpeedLabel.alpha = 0.f;
                _wifiInfoPageTopContainerTestSpeedHintLabel.alpha = 0.f;
            }
                break;
            case WFWiFiInfoConnectedStateConnectedTestingSpeed:
            {
                _wifiInfoPageTopContainerBigTestSpeedHintLabel.alpha = 0.f;
                _wifiInfoPageTopContainerSeperatorLineView.alpha =0.f;
                _wifiInfoPageTopContainerServerSpeedHintLabel.alpha = 0.f;
                _wifiInfoPageTopContainerSpeedLabel.alpha = 1.f;
                _wifiInfoPageTopContainerTestSpeedHintLabel.alpha = 0.f;
            }
                break;
            case WFWiFiInfoConnectedStateConnectedTestedSpeed:
            {
                _wifiInfoPageTopContainerBigTestSpeedHintLabel.alpha = 0.f;
                _wifiInfoPageTopContainerSeperatorLineView.alpha = 0.f;
                _wifiInfoPageTopContainerServerSpeedHintLabel.alpha = 0.f;
                _wifiInfoPageTopContainerSpeedLabel.alpha = 1.f;
                _wifiInfoPageTopContainerTestSpeedHintLabel.alpha = 0.f;
            }
                break;
        }
        
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)setupCommonButtonStatus:(UIButton*)button isRevert:(BOOL)isRevert {
    UIImage *resizeNormalImage = [[UIImage imageNamed:@"roundbutton_empty"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 40) resizingMode:UIImageResizingModeStretch];
    UIImage *resizeHightlightImage = [[UIImage imageNamed:@"roundbutton_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 40) resizingMode:UIImageResizingModeStretch];
    if( isRevert ) {
        [button setBackgroundImage:resizeNormalImage forState:UIControlStateHighlighted];
        [button setBackgroundImage:resizeHightlightImage forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [button setTitleColor:RGB(0x288DFF, 1) forState:UIControlStateNormal];
    }
    else {
        [button setBackgroundImage:resizeNormalImage forState:UIControlStateNormal];
        [button setBackgroundImage:resizeHightlightImage forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:RGB(0x288DFF, 1) forState:UIControlStateHighlighted];
    }
}

+ (void)calculateBtnWidthByTitle:(UIButton*)button {
//    CGFloat width = [button.titleLabel.text sizeWithFont: button.titleLabel.font constrainedToSize: CGSizeMake(kScreenWidth, button.frame.size.height)].width + 45*2;
    CGFloat width = [button.titleLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth, button.frame.size.height) options: NSStringDrawingTruncatesLastVisibleLine| NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : button.titleLabel.font} context:nil].size.width + 90;
    button.width = width;
    button.x = (kScreenWidth - width) / 2;
}

- (void)switchWiFiInfoPageBottomContainer:(WFWiFiInfoConnectedState)state
{
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        switch (state) {
            case WFWiFiInfoConnectedStateNone:
            {
                _evalueSpeedLabel.alpha = 0.f;
                _evalueSpeedTitleLabel.alpha = 0.f;
                _sharedWiFiInfoHintContainer.alpha = 0.f;
            }
                break;

            case WFWiFiInfoConnectedStateConnectedWithoutSpeed:
            {
                _evalueSpeedTitleLabel.alpha = 1.f;
                _sharedWiFiInfoHintContainer.alpha = 1.f;
                _sharedWiFiInfoHintContainerButton.hidden = NO;
                _sharedWiFiInfoHintContainerLabel.hidden = YES;
  
                [WiFiSpeedView setupCommonButtonStatus:_sharedWiFiInfoHintContainerButton isRevert:NO];
                [_sharedWiFiInfoHintContainerButton setTitle:@"测 速" forState:UIControlStateNormal];
                [_sharedWiFiInfoHintContainerButton setTitle:@"测 速" forState:UIControlStateHighlighted];
                
                [WiFiSpeedView calculateBtnWidthByTitle:_sharedWiFiInfoHintContainerButton];
                [WiFiSpeedView setupCommonButtonStatus:_sharedWiFiInfoHintContainerButton isRevert:NO];
                _sharedWiFiInfoHintContainerButton.tag = WFWiFiInfoConnectedStateConnectedWithoutSpeed;
                _evalueSpeedLabel.text = @"给这个WiFi网速跑跑分吧";
                _evalueSpeedLabel.alpha = CommonTipsAlpha;
                _evalueSpeedTitleLabel.text = @"暂无网速记录";

                if ([self.delegate respondsToSelector: @selector(updateSpeedBarIcon:)]) {
                    [self.delegate updateSpeedBarIcon: @"WiFi测速"];
                }
            }
                break;
            case WFWiFiInfoConnectedStateConnectedWithUserSpeed:
            {
                _evalueSpeedLabel.alpha = CommonTipsAlpha;
                [self evalueSpeed:[_connectedRecord.m_avgspeed floatValue]];
                _evalueSpeedTitleLabel.alpha = 1.f;
                _sharedWiFiInfoHintContainer.alpha = 1.f;
                _sharedWiFiInfoHintContainerButton.hidden = NO;
                _sharedWiFiInfoHintContainerLabel.hidden = YES;
                [self setupNormalSharedWiFiInfoHintContainerButton];
                [_sharedWiFiInfoHintContainerButton setTitle:@"测 速" forState:UIControlStateNormal];
                [_sharedWiFiInfoHintContainerButton setTitle:@"测 速" forState:UIControlStateHighlighted];
                _sharedWiFiInfoHintContainerButton.tag = WFWiFiInfoConnectedStateConnectedWithUserSpeed;
                [WiFiSpeedView setupCommonButtonStatus:_sharedWiFiInfoHintContainerButton isRevert:NO];
                [WiFiSpeedView calculateBtnWidthByTitle:_sharedWiFiInfoHintContainerButton];
            }
                break;
            case WFWiFiInfoConnectedStateConnectedTestingSpeed:
            {
                _evalueSpeedLabel.alpha = CommonTipsAlpha;
                _evalueSpeedTitleLabel.alpha = 1.f;
                _sharedWiFiInfoHintContainer.alpha = 1.f;
                _sharedWiFiInfoHintContainerButton.hidden = NO;
                _sharedWiFiInfoHintContainerLabel.hidden = YES;
                [_sharedWiFiInfoHintContainerButton setTitle:@"停止测速" forState:UIControlStateNormal];
                [_sharedWiFiInfoHintContainerButton setTitle:@"停止测速" forState:UIControlStateHighlighted];
                _sharedWiFiInfoHintContainerButton.tag = WFWiFiInfoConnectedStateConnectedTestingSpeed;
                _evalueSpeedTitleLabel.text = @"测速中";
                _evalueSpeedLabel.text = @"请稍等片刻...";
                [WiFiSpeedView calculateBtnWidthByTitle:_sharedWiFiInfoHintContainerButton];
                [WiFiSpeedView setupCommonButtonStatus:_sharedWiFiInfoHintContainerButton isRevert:NO];

            }
                break;
            case WFWiFiInfoConnectedStateConnectedTestedSpeed:
            {
                _evalueSpeedLabel.alpha = CommonTipsAlpha;
                _evalueSpeedTitleLabel.alpha = 1.f;
                _sharedWiFiInfoHintContainer.alpha = 1.f;
                _sharedWiFiInfoHintContainerButton.hidden = NO;
                _sharedWiFiInfoHintContainerLabel.hidden = YES;
                [self setupNormalSharedWiFiInfoHintContainerButton];
                [_sharedWiFiInfoHintContainerButton setTitle:@"去上网" forState:UIControlStateNormal];
                [_sharedWiFiInfoHintContainerButton setTitle:@"去上网" forState:UIControlStateHighlighted];
                _sharedWiFiInfoHintContainerButton.tag = WFWiFiInfoConnectedStateConnectedTestedSpeed;
                [self evalueSpeed: [_connectedRecord.m_avgspeed floatValue]];
                [WiFiSpeedView calculateBtnWidthByTitle:_sharedWiFiInfoHintContainerButton];
                [WiFiSpeedView setupCommonButtonStatus:_sharedWiFiInfoHintContainerButton isRevert:YES];
            }
                break;
        }

        [self updateEvalueSpeedLabelAndEvalueSpeedTitleLabelTop];
    } completion:^(BOOL finished) {

    }];
    
}

//换图片。
- (void)switchWiFiInfoPageCenterImage:(WFWiFiInfoConnectedState)type
{
    CAAnimation *imageContentAnimation = [AnimationManager imageContentAnimationFrom:_wifiInfoPageCenterImageView.image to:[UIImage imageNamed:_wifiInfoPageCenterImageViewResourceDic[@(type)]] duration:0.1 delegate:self];
    [imageContentAnimation setValue:@"imageContentAnimation" forKey:@"Type"];
    [_wifiInfoPageCenterImageView.layer addAnimation:imageContentAnimation forKey:@"imageContentAnimation"];
    
    _speedScaleContainerView.hidden = NO;
    _wifiInfoPageCenterImageBgRingImageView.alpha = 1.f;
}


#pragma mark -
#pragma mark ========================== connecting 相关的方法 =============================

- (void)setupNormalSharedWiFiInfoHintContainerButton
{
    UIImage *resizeNormalImage = [[UIImage imageNamed:@"roundbutton_empty"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 40) resizingMode:UIImageResizingModeStretch];
    UIImage *resizeHightlightImage = [[UIImage imageNamed:@"roundbutton_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 40) resizingMode:UIImageResizingModeStretch];
    [_sharedWiFiInfoHintContainerButton setBackgroundImage:resizeNormalImage forState:UIControlStateHighlighted];
    [_sharedWiFiInfoHintContainerButton setBackgroundImage:resizeHightlightImage forState:UIControlStateNormal];
    [_sharedWiFiInfoHintContainerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_sharedWiFiInfoHintContainerButton setTitleColor:RGB(0x288DFF, 1) forState:UIControlStateNormal];
}

- (void)initializeDataStructure
{
    _wifiInfoPageCenterImageViewResourceDic = @{@(WFWiFiInfoConnectedStateNone):@"center_image_white_ball@3x",@(WFWiFiInfoConnectedStateConnectedWithoutSpeed):@"center_image_white_ball@3x",@(WFWiFiInfoConnectedStateConnectedWithUserSpeed):@"center_image_white_ball@3x", @(WFWiFiInfoConnectedStateConnectedTestingSpeed):@"center_image_white_ball@3x",@(WFWiFiInfoConnectedStateConnectedTestedSpeed):@"center_image_white_ball@3x",};
    
    _wifiInfoPageBackgroundHintColorDic = @{@(WFWiFiInfoPageBackgroundHintColorTypeBlue):@"#288DFF",@(WFWiFiInfoPageBackgroundHintColorTypeOrange):@"#EB9D38"};
    
    _connectedRecord = [WiFiRecord new];
}

@end
