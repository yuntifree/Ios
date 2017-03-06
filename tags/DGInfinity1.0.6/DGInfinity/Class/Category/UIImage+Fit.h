//
//  UIImage+Fit.h
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Fit)

+ (UIImage *)originalImage:(NSString *)name;
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;

@end
