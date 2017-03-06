//
//  CheckUtil.h
//  DGInfinity
//
//  Created by myeah on 16/11/4.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckUtil : NSObject

/**
 *  判断是否是合法的手机号
 *  @param phoneNumber 手机号
 */
+ (BOOL)checkPhoneNumber:(NSString *)phoneNumber;

@end
