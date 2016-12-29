//
//  UINavigationBar+ExclusiveTouch.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/29.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "UINavigationBar+ExclusiveTouch.h"

@implementation UINavigationBar (ExclusiveTouch)

+ (void)load
{
    [super load];
    Method fromMethod = class_getInstanceMethod([self class], @selector(layoutSubviews));
    Method toMethod = class_getInstanceMethod([self class], @selector(swizzlingLayoutSubviews));
    if (!class_addMethod([self class], @selector(swizzlingLayoutSubviews), method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        method_exchangeImplementations(fromMethod, toMethod);
    }
}

- (void)swizzlingLayoutSubviews
{
    [self swizzlingLayoutSubviews];
    for (UIView *view in self.subviews) {
        [view setExclusiveTouch:YES];
    }
}

@end
