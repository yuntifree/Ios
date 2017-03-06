//
//  UIImage+Format.h
//  DGInfinity
//
//  Created by myeah on 16/12/6.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Format)

- (NSData *)getData;
- (NSString *)getFormatWithData:(NSData *)data;

@end
