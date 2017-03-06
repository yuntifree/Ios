//
//  UITabBarItem+Setup.m
//  DGInfinity
//
//  Created by myeah on 16/10/19.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "UITabBarItem+Setup.h"

#define FONT_TITLE [UIFont boldSystemFontOfSize:10.0]
#define COLOR_STATUS_SELECTED RGB(0x288DFF, 1)

@implementation UITabBarItem (Setup)

- (void)setImage:(NSString *)image selectedImage:(NSString *)selectedImage
{
    NSDictionary *textTitleOptionsNormal = [NSDictionary dictionaryWithObjectsAndKeys:FONT_TITLE, NSFontAttributeName, nil];
    NSDictionary *textTitleOptionsSelected = [NSDictionary dictionaryWithObjectsAndKeys:COLOR_STATUS_SELECTED,  NSForegroundColorAttributeName, FONT_TITLE, NSFontAttributeName, nil];
    [self setTitleTextAttributes:textTitleOptionsNormal forState:UIControlStateNormal];
    [self setTitleTextAttributes:textTitleOptionsSelected forState:UIControlStateSelected];
    self.image = [UIImage originalImage:image];
    self.selectedImage = [UIImage originalImage:selectedImage];
    [self setTitlePositionAdjustment:UIOffsetMake(0.0, -3.0)];
    self.imageInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
}

@end
