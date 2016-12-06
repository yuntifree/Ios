//
//  PayCGI.h
//  DGInfinity
//
//  Created by myeah on 16/12/6.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayCGI : NSObject

/**
 *  pingpp_pay
 *  @param amount 金额（单位：分）
 *  @param channel 支付渠道
 */
+ (void)PingppPay:(NSInteger)amount
          channel:(NSString *)channel
         complete:(void(^)(DGCgiResult *res))complete;

@end
