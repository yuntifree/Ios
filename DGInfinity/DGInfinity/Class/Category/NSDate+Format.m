//
//  NSDate+Format.m
//  DGInfinity
//
//  Created by myeah on 16/11/8.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

+ (NSString *)stringWithDateStr:(NSString *)date formatStr:(NSString *)format
{
    NSDate *d = [NSDate dateWithTimeStr:date];
    return [NSDate stringWithDate:d formatStr:format];
}

+ (NSDate *)dateWithTimeStr:(NSString *)timeStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormat dateFromString:timeStr];
}

+ (NSString *)stringWithDate:(NSDate *)date formatStr:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatStringWithDate:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormat stringFromDate:date];
}

@end
