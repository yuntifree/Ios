//
//  UIImage+Fit.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "UIImage+Fit.h"

@implementation UIImage (Fit)

+ (UIImage *)originalImage:(NSString *)name
{
    return [ImageNamed(name) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
