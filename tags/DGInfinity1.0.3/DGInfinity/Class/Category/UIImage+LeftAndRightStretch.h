//
//  UIImage+LeftAndRightStretch.h
//  Live
//
//  Created by jacky.lee on 16/8/1.
//  Copyright © 2016年 aini25. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LeftAndRightStretch)

/**
 *  图片左右拉伸
 *  fLeftCapWidth:  第一次拉伸的left点
 *  fTopCapHeight:  第一次拉伸的top点
 *  tempWidth:      图片最后要展示的宽度
 *  sLeftCapWidth:  第二次拉伸的left点
 *  sTopCapHeight:  第二次拉伸的top点
 */
- (UIImage *)stretchImageWithFLeftCapWidth:(CGFloat)fLeftCapWidth
                        fTopCapHeight:(CGFloat)fTopCapHeight
                            tempWidth:(CGFloat)tempWidth
                        sLeftCapWidth:(CGFloat)sLeftCapWidth
                        sTopCapHeight:(CGFloat)sTopCapHeight;

@end
