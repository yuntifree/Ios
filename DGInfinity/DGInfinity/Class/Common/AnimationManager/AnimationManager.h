//
//  AnimationManager.h
//  DGInfinity
//
//  Created by myeah on 16/11/3.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnimationManager : NSObject

+ (CABasicAnimation *)scaleAnimationFrom:(CGFloat)fromScale toScale:(CGFloat)toScale duration:(CGFloat)duration;
+ (CABasicAnimation *)opacityAnimationFrom:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity duration:(CGFloat)duration;
+ (CABasicAnimation *)rotationAnimationFrom:(CGFloat)fromDegree toDegree:(CGFloat)toDegree duration:(CGFloat)duration repeadCount:(NSUInteger)count timingFunction:(NSString *)functionName;
+ (CAAnimation *)fakeDropInAnimationWithFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration;
+ (CABasicAnimation *)positionAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration;

+ (CAAnimation *)boundsAnimationFrom:(CGRect)fromRect to:(CGRect)toRect duration:(NSTimeInterval)duration delegate:(id)delegate;
+ (CAAnimation *)fadeAnimationFrom:(CGFloat)fromFloat to:(CGFloat)toFloat duration:(NSTimeInterval)duration delegate:(id)delegate;
+ (CAKeyframeAnimation *)positionKeyFrameAnimationWithKeyPath:(NSString *)keyPath keyTime:(NSArray *)keyTimes values:(NSArray *)values duration:(NSTimeInterval)duration delegate:(id)delegate;
+ (CAAnimation *)imageContentAnimationFrom:(UIImage *)fromImg to:(UIImage *)toImg duration:(NSTimeInterval)duration delegate:(id)delegate;
+ (CAAnimation *)popOutAnimation;
+ (CAAnimation *)popInAnimation;
+ (CAAnimation *)changeRootAnimation;

@end
