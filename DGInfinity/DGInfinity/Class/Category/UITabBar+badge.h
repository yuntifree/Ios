//
//  UITabBar+badge.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/8/24.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (badge)

- (void)showBadgeOnItemIndex:(int)index;
- (void)hideBadgeOnItemIndex:(int)index;

@end
