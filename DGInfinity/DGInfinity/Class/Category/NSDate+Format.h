//
//  NSDate+Format.h
//  DGInfinity
//
//  Created by myeah on 16/11/8.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Format)

+ (NSString *)stringWithDateStr:(NSString *)date formatStr:(NSString *)format;
+ (NSDate *)dateWithTimeStr:(NSString *)timeStr;
+ (NSString *)stringWithDate:(NSDate *)date formatStr:(NSString *)format;

@end
