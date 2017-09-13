//
//  UpdateCGI.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/9/13.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateCGI : NSObject

/**
 *  check_update
 *  @param channel 系统版本
 */
+ (void)checkUpdate:(NSString *)channel
           complete:(void(^)(DGCgiResult *res))complete;

@end
