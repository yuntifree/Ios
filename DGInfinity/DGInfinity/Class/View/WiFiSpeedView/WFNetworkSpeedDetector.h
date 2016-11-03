//
//  WFNetworkSpeedDetector.h
//  360FreeWiFi
//
//  Created by lisheng on 15/4/28.
//  Copyright (c) 2015年 qihoo360. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol WFNetworkSpeedDetectorDelegate <NSObject>

- (void)didFinishDetectWithAverageSpeed:(CGFloat)speed;//最终的平均结果。
- (void)didDetectRealtimeSpeed:(CGFloat)speed;//实时速度。

@end




@interface WFNetworkSpeedDetector : NSObject
@property (assign, nonatomic) id<WFNetworkSpeedDetectorDelegate> delegate;

+ (instancetype)sharedSpeedDetector;
- (void)startSpeedDetector;
- (void)stopSpeedDetector;
@property (assign, nonatomic, getter=isSpeedDetecting) BOOL speedDetecting;
@end
