//
//  XHMenuButton.m
//  XHScrollMenu
//
//  Created by 曾 宪华 on 14-3-9.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "XHMenuButton.h"

@implementation XHMenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rectBig = CGRectInset(self.bounds, -(self.width / 2), 0);
    
    if (CGRectContainsPoint(rectBig, point)) {
        return self;
    } else {
        return nil;
    }
}

@end
