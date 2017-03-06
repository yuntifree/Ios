//
//  PartialTransparentView.h
//  DGInfinity
//
//  Created by myeah on 16/11/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PartialTransparentView : UIView

- (instancetype)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color andTransparentRects:(NSArray *)rects;

@end
