//
//  PulsingHaloLayer.m
//  https://github.com/shu223/PulsingHalo
//
//  Created by shuichi on 12/5/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//
//  Inspired by https://github.com/samvermette/SVPulsingAnnotationView


#import "PulsingHaloLayer.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@interface PulsingHaloLayer () <CAAnimationDelegate>
#else
@interface PulsingHaloLayer ()
#endif
@property (nonatomic, strong) CALayer *effect;
@property (nonatomic, strong) CAAnimationGroup *animationGroup;
@end


@implementation PulsingHaloLayer
@dynamic repeatCount;

- (void)dealloc
{
    [self.effect removeFromSuperlayer];
    [self removeFromSuperlayer];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.effect = [CALayer new];
        self.effect.contentsScale = [UIScreen mainScreen].scale;
        self.effect.opacity = 0;
        [self addSublayer:self.effect];
        
        [self _setupDefaults];
        [self _setupAnimationGroup];
    }
    return self;
}


// =============================================================================
#pragma mark - Accessor

- (void)start {
    if (![self.effect.animationKeys count]) {
        [self.effect addAnimation:self.animationGroup forKey:@"pulse"];
    }
}

- (void)stop {
    if ([self.effect.animationKeys count]) {
        [self.effect removeAllAnimations];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.effect.frame = frame;
}

- (void)setBackgroundColor:(CGColorRef)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.effect.backgroundColor = backgroundColor;
}

- (void)setRadius:(CGFloat)radius {
    
    _radius = radius;
    
    CGFloat diameter = self.radius * 2;
    
    self.effect.bounds = CGRectMake(0, 0, diameter, diameter);
    self.effect.cornerRadius = self.radius;
}

- (void)setPulseInterval:(NSTimeInterval)pulseInterval {
    
    _pulseInterval = pulseInterval;
    
    if (_pulseInterval == INFINITY) {
        [self.effect removeAnimationForKey:@"pulse"];
    }
}

- (void)setHaloLayerNumber:(NSInteger)haloLayerNumber {
    
    _haloLayerNumber = haloLayerNumber;
    self.instanceCount = haloLayerNumber;
    self.instanceDelay = (self.animationDuration + self.pulseInterval) / haloLayerNumber;
}

- (void)setStartInterval:(NSTimeInterval)startInterval {
    
    _startInterval = startInterval;
    self.instanceDelay = startInterval;
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration {

    _animationDuration = animationDuration;
    
    self.instanceDelay = (self.animationDuration + self.pulseInterval) / self.haloLayerNumber;
}

- (void)setRepeatCount:(float)repeatCount {
    [super setRepeatCount:repeatCount];
    self.animationGroup.repeatCount = repeatCount;
}


// =============================================================================
#pragma mark - Private

- (void)_setupDefaults {
    _fromValueForRadius = 1;
    _keyTimeForHalfOpacity = 0.2;
    _animationDuration = 3;
    _pulseInterval = 0;
    _useTimingFunction = YES;

    self.repeatCount = HUGE_VALF;
    self.radius = 56.5;
    self.haloLayerNumber = 3;
    self.startInterval = 1;
    self.backgroundColor = [RGB(0xffffff, 0.4) CGColor];
}

- (void)_setupAnimationGroup {
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = self.animationDuration + self.pulseInterval;
    animationGroup.repeatCount = self.repeatCount;
    if (self.useTimingFunction) {
        CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        animationGroup.timingFunction = defaultCurve;
    }
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    scaleAnimation.fromValue = @(self.fromValueForRadius);
    scaleAnimation.toValue = @(116 / self.radius);
    scaleAnimation.duration = self.animationDuration;
    
//    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
//    opacityAnimation.duration = self.animationDuration;
//    CGFloat fromValueForAlpha = CGColorGetAlpha(self.backgroundColor);
//    opacityAnimation.values = @[@0, @(fromValueForAlpha * 2), @0];
//    opacityAnimation.keyTimes = @[@0, @(self.keyTimeForHalfOpacity), @1];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1;
    opacityAnimation.toValue = @0;
    opacityAnimation.duration = self.animationDuration;
    
    NSArray *animations = @[scaleAnimation, opacityAnimation];
    animationGroup.animations = animations;
    animationGroup.removedOnCompletion = NO;
    
    self.animationGroup = animationGroup;
    self.animationGroup.delegate = self;
}


// =============================================================================
#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
//    if ([self.effect.animationKeys count]) {
//        [self.effect removeAllAnimations];
//    }
//    [self.effect removeFromSuperlayer];
//    [self removeFromSuperlayer];
}

@end
