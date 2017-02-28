//
//  WFNetworkSpeedDetector.m
//  360FreeWiFi
//
//  Created by lisheng on 15/4/28.
//  Copyright (c) 2015年 qihoo360. All rights reserved.
//

#import "WFNetworkSpeedDetector.h"

#define kCalculateSpeedInterval 0.1

@interface WFNetworkSpeedDetector ()
{
    NSArray *_detectTargetURLs;
    NSURLConnection *_speedDetectConnection;
    NSTimer *_speedDetectTimer;
    NSDate *_beginDate;
    NSDate *_lastDate;
    NSUInteger _detectCount;//重试次数。
    
    NSMutableData *_acceptedTotalData;
    CGFloat _acceptTotalDataLength;//为了处理失败情况下的计算，用来不直接用[_acceptedTotalData length] 计算
    NSUInteger _evenOddCount;
    BOOL _ignoreFirstDataPack;
    CGFloat _fakeSpeed;
}

//@property (strong, nonatomic) dispatch_queue_t customSpeedDetectorQueue;
@end





@implementation WFNetworkSpeedDetector

static WFNetworkSpeedDetector * wfnetworkSpeedDetector;
+ (instancetype)sharedSpeedDetector
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wfnetworkSpeedDetector = [WFNetworkSpeedDetector new];
    });
    return wfnetworkSpeedDetector;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _detectTargetURLs = [[NSArray alloc] initWithObjects:@"http://download.weather.com.cn/3g/current/ChinaWeather_Android.apk", @"http://down.360safe.com/360mse/f/360fmse_js010001.apk", nil];
        _detectCount = 0;
//        _customSpeedDetectorQueue = dispatch_queue_create("com.yunxingzh.speeddetector", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}


- (void)startSpeedDetector
{
    _speedDetecting = YES;
//    dispatch_async(_customSpeedDetectorQueue, ^{
//        
//        [self cleanAllData];
//        
//        _request.URL = [NSURL URLWithString:[_detectTargetURLs objectAtIndex:_detectCount]];
//        [_request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
//        _request.timeoutInterval = 5;
//        _speedDetectConnection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:YES];
//        
//        _speedDetectTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(detectSpeedWithLimitTime) userInfo:nil repeats:NO];
//        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
//    });
    [self cleanAllData];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[_detectTargetURLs objectAtIndex:_detectCount]] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5];
    _speedDetectConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    _speedDetectTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(detectSpeedWithLimitTime) userInfo:nil repeats:NO];
    
}
- (void)stopSpeedDetector
{
    _speedDetecting = NO;
    [self cleanAllData];
    self.delegate = nil;
}

- (void)cleanAllData
{
    if (_speedDetectConnection) {
        [_speedDetectConnection cancel];
        _speedDetectConnection = nil;
    }
    if (_speedDetectTimer) { //未到10s而结束
        [_speedDetectTimer invalidate];
        _speedDetectTimer = nil;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


#pragma mark -
#pragma mark ===================== NSURLConnection Delegate ====================

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (connection == _speedDetectConnection) {
        if (_speedDetectTimer) {
            [_speedDetectTimer invalidate];
            _speedDetectTimer = nil;
        }
        if (_detectCount == (_detectTargetURLs.count - 1)) {
            _detectCount = 0;
            //测速结果失败。
            if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDetectWithAverageSpeed:)]) {
                [self.delegate didFinishDetectWithAverageSpeed:0.f];
            }
        }else{
            _detectCount++;
            [self performSelector:@selector(startSpeedDetector) withObject:self afterDelay:1];
        }
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == _speedDetectConnection) {
        _acceptedTotalData = [NSMutableData new];
        _acceptTotalDataLength = 0.f;
        _beginDate = [NSDate date];
        _lastDate = _beginDate;
        _ignoreFirstDataPack = YES;
        return;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == _speedDetectConnection) {
        [_acceptedTotalData appendData:data];
        _acceptTotalDataLength = [_acceptedTotalData length];
        
        NSDate *currentDate = [NSDate date];
        
        if (_ignoreFirstDataPack) {
            _ignoreFirstDataPack = NO;
//            NSTimeInterval intervalSinceBegin = [currentDate timeIntervalSinceDate:_beginDate];
//            CGFloat realtimeSpeed = _acceptTotalDataLength/(intervalSinceBegin  * 5);//第一次数字一般计算非常大
//            if (self.delegate && [self.delegate respondsToSelector:@selector(didDetectRealtimeSpeed:)]) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.delegate didDetectRealtimeSpeed:realtimeSpeed];
//                });
//            }
            _lastDate = currentDate;
        }else{
            
            NSTimeInterval interval = [currentDate timeIntervalSinceDate:_lastDate];
            NSTimeInterval thredHold = 0.3;
            
            if (interval > thredHold) {
                NSTimeInterval intervalSinceBegin = [currentDate timeIntervalSinceDate:_beginDate];
                CGFloat realtimeSpeed = _acceptTotalDataLength/intervalSinceBegin;
                if (self.delegate && [self.delegate respondsToSelector:@selector(didDetectRealtimeSpeed:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate didDetectRealtimeSpeed:realtimeSpeed];
                    });
                }
                _lastDate = currentDate;
                return;
            }
        }
        
        
        return;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == _speedDetectConnection) {
        if (_speedDetectConnection) {
            [_speedDetectConnection cancel];
            _speedDetectConnection = nil;
        }
        [self detectSpeedWithLimitTime];
    }
}

- (void)detectSpeedWithLimitTime
{
    if (_speedDetectConnection) {
        [_speedDetectConnection cancel];
        _speedDetectConnection = nil;
    }
    if (_speedDetectTimer) { //未到10s而结束
        [_speedDetectTimer invalidate];
        _speedDetectTimer = nil;
    }
    _detectCount = 0;//对下次检测重新计数
    NSTimeInterval allTime = [[NSDate date] timeIntervalSinceDate:_beginDate];
    if (allTime > 5) {
        CGFloat speed = _acceptTotalDataLength/allTime;//防止提前结束，所以用此进行计算
        [self notifyAverageSpeed:[NSNumber numberWithFloat:speed]];
    }else{//延迟4秒进行假动画。
        if (allTime != 0) {
            CGFloat speed = _acceptTotalDataLength/allTime;
            _evenOddCount = 0;
            [self randomFakeSpeedCalculate:[NSNumber numberWithFloat:speed]];
            [self performSelector:@selector(notifyAverageSpeed:) withObject:[NSNumber numberWithFloat:speed] afterDelay:5.0f];
        }
    }
}

- (void)notifyAverageSpeed:(NSNumber *)speedNum
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(randomFakeSpeedCalculate:) object:speedNum];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDetectWithAverageSpeed:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _speedDetecting = NO;
            [self.delegate didFinishDetectWithAverageSpeed:[speedNum floatValue]];
        });
    }
}

- (void)randomFakeSpeedCalculate:(NSNumber *)speedNum
{
    CGFloat factor = [self factorForSpeed:speedNum];
    CGFloat delay = 0.3;
    
    NSUInteger rand = arc4random()%6 + 5;
//    NSLog(@"FACTOR ==== %f === %lu", factor, (unsigned long)rand);
    CGFloat fakeSpeed;
    if (_evenOddCount%2 == 0) {
        fakeSpeed = [speedNum floatValue] + rand * factor;
        delay -= 0.1;
    }else{
        fakeSpeed = [speedNum floatValue] - rand * factor;
        delay += 0.1;
    }
    _evenOddCount++;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDetectRealtimeSpeed:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didDetectRealtimeSpeed:fakeSpeed];
            [self performSelector:@selector(randomFakeSpeedCalculate:) withObject:speedNum afterDelay:0.3];
        });
    }
}

//用下载3M来进行分类系数。
- (CGFloat)factorForSpeed:(NSNumber *)speedNum
{
    CGFloat speed = [speedNum floatValue];
    if (speed > 5 * 1024 * 1024) {
        return 0.1 * 1024 * 1024;
    }
    if (speed > 0.6 * 1024 * 1024) {
        return 5 * 1024;
    }
    if (speed > 200 * 1024) {
        return 2 * 1024;
    }
    return 1 * 1024;
}


@end
