//
//  CheckUtil.m
//  DGInfinity
//
//  Created by myeah on 16/11/4.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "CheckUtil.h"

@implementation CheckUtil

+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber
{
    if (!phoneNumber.length) {
        return NO;
    }
    NSString *format = @"^1\\d{10}$";
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",format];
    return [pre evaluateWithObject:phoneNumber];
}

@end
