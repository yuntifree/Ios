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

+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(reSize.width, reSize.height), NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

@end
