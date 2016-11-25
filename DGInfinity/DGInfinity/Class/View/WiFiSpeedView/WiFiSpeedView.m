//
//  WiFiSpeedView.m
//  360FreeWiFi
//
//  Created by lijinwei on 15/11/5.
//  Copyright © 2015年 qihoo360. All rights reserved.
//

#import "WiFiSpeedView.h"
#import "WFNetworkSpeedDetector.h"
#import "UIButton+ResizableImage.h"

typedef NS_ENUM(NSInteger, TestBtnStatus) {
    TestBtnStatusNone = 1000,       // 还没测速
    TestBtnStatusTesting = 1001,    // 测速中
    TestBtnStatusTested = 1002      // 测速结束
};

const float EPSINON = 0.00001;
#define FLOAT_IS_ZERO(x) ((x >= - EPSINON) && (x <= EPSINON))

#define degreesToRadians(x) (M_PI*(x)/180.0) //把角度转换成PI的方式

@implementation WiFiSpeedRecord

- (instancetype)init
{
    self = [super init];
    if (self) {
        _speed = @"";
        _desc = @"";
    }
    return self;
}

@end

@interface WiFiSpeedView () <WFNetworkSpeedDetectorDelegate>
{
    CAShapeLayer *_maskLayer;
    UIImageView *_backProgressView;
    UIImageView *_foreProgressView;
    UIImageView *_indicatorView;
    UILabel *_speedLbl;
    UILabel *_descLbl;
    UIButton *_testBtn;
    
    WiFiSpeedRecord *_record;
}

@end

@implementation WiFiSpeedView

- (void)dealloc
{
    if ([WFNetworkSpeedDetector sharedSpeedDetector].isSpeedDetecting) {
        [[WFNetworkSpeedDetector sharedSpeedDetector] stopSpeedDetector];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = COLOR(0, 156, 251, 1);
        _record = [WiFiSpeedRecord new];
        [self setupWiFiPageSubViews];
    }
    return self;
}


- (void)setupWiFiPageSubViews
{
    UIImage *image = ImageNamed(@"full_Compass");
    _backProgressView = [[UIImageView alloc] initWithImage:image];
    _backProgressView.frame = CGRectMake((self.width - image.size.width) / 2, 0, image.size.width, image.size.height);
    [self addSubview:_backProgressView];
    
    image = ImageNamed(@"empty_Compass");
    _foreProgressView = [[UIImageView alloc] initWithImage:image];
    _foreProgressView.frame = _backProgressView.frame;
    [self addSubview:_foreProgressView];
    
    image = ImageNamed(@"Oval");
    UIImageView *ovalView = [[UIImageView alloc] initWithImage:image];
    ovalView.frame = CGRectMake((self.width - image.size.width) / 2, CGRectGetMaxY(_foreProgressView.frame) - image.size.height / 2 - 1, image.size.width, image.size.height);
    [self addSubview:ovalView];
    
    image = ImageNamed(@"Pointer");
    _indicatorView = [[UIImageView alloc] initWithImage:image];
    _indicatorView.layer.anchorPoint = CGPointMake(1, 0.5);
    _indicatorView.layer.position = ovalView.center;
    [self addSubview:_indicatorView];
    
    _speedLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_foreProgressView.frame) + 64, self.width, 18)];
    _speedLbl.font = SystemFont(18);
    _speedLbl.textColor = [UIColor whiteColor];
    _speedLbl.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_speedLbl];
    
    _descLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_speedLbl.frame) + 10, self.width, 14)];
    _descLbl.font = SystemFont(12);
    _descLbl.textColor = [UIColor whiteColor];
    _descLbl.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_descLbl];
    
    _testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _testBtn.frame = CGRectMake((self.width - 140) / 2, CGRectGetMaxY(_descLbl.frame) + 74, 140, 40);
    _testBtn.titleLabel.font = SystemFont(18);
    _testBtn.tag = TestBtnStatusNone;
    [_testBtn dg_setBackgroundImage:ImageNamed(@"btn_test") forState:UIControlStateNormal];
    [_testBtn setTitle:@"开始测速" forState:UIControlStateNormal];
    [_testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_testBtn addTarget:self action:@selector(testBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_testBtn];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(_backProgressView.bounds), CGRectGetMaxY(_backProgressView.bounds)) radius:100 startAngle:degreesToRadians(-180) endAngle:degreesToRadians(0) clockwise:YES];
    
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.fillColor = [UIColor clearColor].CGColor;
    _maskLayer.strokeColor = [UIColor blackColor].CGColor;
    _maskLayer.lineCap = kCALineCapButt;
    _maskLayer.lineWidth = 60;
    _maskLayer.path = [path CGPath];
    _maskLayer.strokeEnd = 0.f;
    [_backProgressView.layer setMask:_maskLayer];
}

- (void)testBtnClick:(UIButton *)button
{
    switch (button.tag) {
        case TestBtnStatusNone:
        case TestBtnStatusTested:
        {
            [self startDetectSpeed];
        }
            break;
        case TestBtnStatusTesting:
        {
            [self stopSpeedDetectionAnimation];
        }
            break;
        default:
            break;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self evalueSpeed:speed/1024.f];
            [self calculateSpeed:speed];
            [self stopSpeedDetectionAnimation];
        });
    } else {
        [self stopSpeedDetectionAnimation];
    }
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

- (void)startDetectSpeed
{
    if ([WFNetworkSpeedDetector sharedSpeedDetector].isSpeedDetecting) {
        return;
    }
    
    [self startSpeedDetectionAnimation];
}

- (void)startSpeedDetectionAnimation
{
    [WFNetworkSpeedDetector sharedSpeedDetector].delegate = self;
    [[WFNetworkSpeedDetector sharedSpeedDetector] startSpeedDetector];
    _testBtn.tag = TestBtnStatusTesting;
    _speedLbl.text = @"正在测速";
    _descLbl.text = @"请稍等片刻...";
    [_testBtn setTitle:@"停止测速" forState:UIControlStateNormal];
}

- (void)stopSpeedDetectionAnimation
{
    _speedLbl.text = _record.speed;
    _descLbl.text = _record.desc;
    if (_testBtn.tag == TestBtnStatusTesting && [WFNetworkSpeedDetector sharedSpeedDetector].isSpeedDetecting) {
        _maskLayer.strokeEnd = 0.f;
        _indicatorView.transform = CGAffineTransformIdentity;
    }
    if (_record.speed.length) {
        [_testBtn setTitle:@"重新测速" forState:UIControlStateNormal];
        _testBtn.tag = TestBtnStatusTested;
    } else {
        [_testBtn setTitle:@"开始测速" forState:UIControlStateNormal];
        _testBtn.tag = TestBtnStatusNone;
    }
    [[WFNetworkSpeedDetector sharedSpeedDetector] stopSpeedDetector];
}

//用中间的label进行显示当前速度
- (void)showCurrentSpeed:(CGFloat )speedKB
{
    NSString *formatedSpeed = [self formatSpeed:speedKB];
    _record.speed = formatedSpeed;
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
}

/**
 *  进行绘制相关的scale上面的刻度显示
 *
 *  @param speed 当前测出的速度，以kb为单位。
 */

- (void)strokeCurrentSpeed:(CGFloat)speed
{
    CGFloat degree = [self degreeFromSpeed:speed];
    CGFloat radians = degreesToRadians(degree);
    [UIView animateWithDuration:0.1 animations:^{
        _indicatorView.layer.transform = CATransform3DMakeRotation(radians, 0, 0, 1);
        _maskLayer.strokeEnd = degree / 180.0;
    }];
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

- (CGFloat)degreeFromSpeed:(CGFloat)speedkb
{
    if (speedkb > 5 * 1024.0) {
        return 180;
    }
    if (speedkb > 150) {
        return 135 + (speedkb - 150)/(5 * 1024.0 - 150) * 45;
    }
    if (speedkb > 80) {
        return 90 + (speedkb - 80)/(150.0 - 80) * 45;
    }
    if (speedkb > 20) {
        return 45 + (speedkb - 20)/(80.0 - 20) * 45;
    }else{
        return 0 + speedkb/ 20.0 * 45;
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
    [self showCurrentSpeed:speedkb];
    NSString *desc = [NSString stringWithFormat:@"当前网速适合:%@",text];
    _record.desc = desc;
}

@end
