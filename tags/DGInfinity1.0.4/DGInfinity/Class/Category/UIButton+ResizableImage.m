//
//  UIButton+ResizableImage.m
//  DGInfinity
//
//  Created by myeah on 16/11/7.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "UIButton+ResizableImage.h"

@implementation UIButton (ResizableImage)

- (void)dg_setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    CGFloat imageW = image.size.width * 0.5;
    CGFloat imageH = image.size.height * 0.5;
    UIImage *img = [image resizableImageWithCapInsets:UIEdgeInsetsMake(imageH, imageW, imageH, imageW) resizingMode:UIImageResizingModeTile];
    [self setBackgroundImage:img forState:state];
}

@end
