//
//  UIImage+LeftAndRightStretch.m
//  Live
//
//  Created by jacky.lee on 16/8/1.
//  Copyright © 2016年 aini25. All rights reserved.
//

#import "UIImage+LeftAndRightStretch.h"

@implementation UIImage (LeftAndRightStretch)

- (UIImage *)stretchImageWithFLeftCapWidth:(CGFloat)fLeftCapWidth
                        fTopCapHeight:(CGFloat)fTopCapHeight
                            tempWidth:(CGFloat)tempWidth
                        sLeftCapWidth:(CGFloat)sLeftCapWidth
                        sTopCapHeight:(CGFloat)sTopCapHeight
{
    UIImage *image1 = [self stretchableImageWithLeftCapWidth:fLeftCapWidth topCapHeight:fTopCapHeight];
    
    CGSize imageSize = self.size;
    CGFloat tw = tempWidth / 2.0 + imageSize.width / 2.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tw, imageSize.height), NO, [UIScreen mainScreen].scale);
    [image1 drawInRect:CGRectMake(0, 0, tw, imageSize.height)];
    UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [image2 stretchableImageWithLeftCapWidth:sLeftCapWidth topCapHeight:sTopCapHeight];
}

@end
