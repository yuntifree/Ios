//
//  PartialTransparentView.m
//  DGInfinity
//
//  Created by myeah on 16/11/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "PartialTransparentView.h"

@interface PartialTransparentView ()
{
    NSArray *rectsArray;
    UIColor *backgroundColor;
}

@end

@implementation PartialTransparentView

- (instancetype)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color andTransparentRects:(NSArray *)rects
{
    backgroundColor = color;
    rectsArray = rects;
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [backgroundColor setFill];
    UIRectFill(rect);
    
    // clear the background in the given rectangles
    for (NSValue *holeRectValue in rectsArray) {
        CGRect holeRect = [holeRectValue CGRectValue];
        CGRect holeRectIntersection = CGRectIntersection( holeRect, rect );
        [[UIColor clearColor] setFill];
        UIRectFill(holeRectIntersection);
    }
}

@end
