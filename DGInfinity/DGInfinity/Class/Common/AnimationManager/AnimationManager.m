//
//  AnimationManager.m
//  DGInfinity
//
//  Created by myeah on 16/11/3.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "AnimationManager.h"

@implementation AnimationManager

+ (CABasicAnimation *)scaleAnimationFrom:(CGFloat)fromScale toScale:(CGFloat)toScale duration:(CGFloat)duration
{
    NSString *keyPath = @"transform.scale";
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = [NSNumber numberWithFloat:fromScale];
    animation.toValue = [NSNumber numberWithFloat:toScale];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}
+ (CABasicAnimation *)opacityAnimationFrom:(CGFloat)fromOpacity toOpacity:(CGFloat)toOpacity duration:(CGFloat)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:fromOpacity];
    animation.toValue = [NSNumber numberWithFloat:toOpacity];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    return animation;
}

+ (CABasicAnimation *)rotationAnimationFrom:(CGFloat)fromDegree toDegree:(CGFloat)toDegree duration:(CGFloat)duration repeadCount:(NSUInteger)count timingFunction:(NSString *)functionName
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:fromDegree];
    rotationAnimation.toValue = [NSNumber numberWithFloat: toDegree];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = NO;
    rotationAnimation.repeatCount = count;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:functionName];
    return rotationAnimation;
}

+ (CAAnimation *)fakeDropInAnimationWithFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration
{
    NSArray *values = @[@(0.01), @(1.2), @(0.9), @(1)];
    NSArray *keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
    CAKeyframeAnimation *keyFrameScaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    keyFrameScaleAnimation.keyTimes = keyTimes;
    keyFrameScaleAnimation.values = values;
    keyFrameScaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    keyFrameScaleAnimation.duration = duration;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:fromPosition];
    animation.toValue = [NSValue valueWithCGPoint:toPosition];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.duration = duration;
    
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = duration * 2/3;
    fadeIn.fromValue = [NSNumber numberWithFloat:0.f];
    fadeIn.toValue = [NSNumber numberWithFloat:1.f];
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeIn.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup new];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animGroup.animations = @[keyFrameScaleAnimation, animation, fadeIn];
    animGroup.duration = duration;
    
    return animGroup;
}

+ (CABasicAnimation *)positionAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition duration:(CFTimeInterval)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:fromPosition];
    animation.toValue = [NSValue valueWithCGPoint:toPosition];
    animation.duration = duration;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

+ (CAAnimation *)popOutAnimation
{
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = 0.4;
    scale.removedOnCompletion = NO;
    scale.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:1.f],
                    [NSNumber numberWithFloat:1.2f],
                    [NSNumber numberWithFloat:.75f],
                    nil];
    
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.duration = 0.4 * .4f;
    fadeOut.fromValue = [NSNumber numberWithFloat:1.f];
    fadeOut.toValue = [NSNumber numberWithFloat:0.f];
    fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    fadeOut.beginTime = 0.4 * .6f;
    fadeOut.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *popOutAnimationGroup = [CAAnimationGroup new];
    popOutAnimationGroup.animations = [NSArray arrayWithObjects:scale, fadeOut, nil];
    popOutAnimationGroup.duration = 0.4f;
    popOutAnimationGroup.removedOnCompletion = NO;
    popOutAnimationGroup.fillMode = kCAFillModeForwards;
    popOutAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return popOutAnimationGroup;
}

+ (CAAnimation *)boundsAnimationFrom:(CGRect)fromRect to:(CGRect)toRect duration:(NSTimeInterval)duration delegate:(id)delegate
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:fromRect];
    animation.toValue = [NSValue valueWithCGRect:toRect];
    animation.delegate = delegate;
    return animation;
}

+ (CAAnimation *)fadeAnimationFrom:(CGFloat)fromFloat to:(CGFloat)toFloat duration:(NSTimeInterval)duration delegate:(id)delegate
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:fromFloat];
    animation.toValue = [NSNumber numberWithFloat:toFloat];
    animation.duration = duration;
    animation.delegate = delegate;
    return animation;
}

+ (CAKeyframeAnimation *)positionKeyFrameAnimationWithKeyPath:(NSString *)keyPath keyTime:(NSArray *)keyTimes values:(NSArray *)values duration:(NSTimeInterval)duration delegate:(id)delegate
{
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    keyFrameAnimation.keyTimes = keyTimes;
    keyFrameAnimation.values = values;
    keyFrameAnimation.duration = duration;
    keyFrameAnimation.delegate = delegate;
    return keyFrameAnimation;
}

+ (CAAnimation *)imageContentAnimationFrom:(UIImage *)fromImg to:(UIImage *)toImg duration:(NSTimeInterval)duration delegate:(id)delegate
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contents"];
    animation.fromValue = (__bridge id)(fromImg.CGImage);
    animation.toValue = (__bridge id)(toImg.CGImage);
    animation.duration = duration;
    animation.delegate = delegate;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    return animation;
}

+ (CAAnimation *)popInAnimation
{
    
    CAKeyframeAnimation *animation  = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.4, 0.4, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.85, 0.85, 0.7)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.duration = 1;
    animation.values = values;
    
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.duration = 1;
    fadeIn.fromValue = [NSNumber numberWithFloat:0.f];
    fadeIn.toValue = [NSNumber numberWithFloat:1.f];
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeIn.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[fadeIn];
    animationGroup.duration = 1;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    return animationGroup;
}

+ (CAAnimation *)changeRootAnimation
{
    CATransition *animation = [CATransition animation];
    animation.duration = 1.0f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionFade;
    return animation;
}

@end
