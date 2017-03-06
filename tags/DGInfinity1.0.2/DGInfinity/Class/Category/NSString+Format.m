//
//  NSString+Format.m
//  DGInfinity
//
//  Created by myeah on 16/12/1.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NSString+Format.h"

@implementation NSString (Format)

- (NSString *)deleteHeadEndSpace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
