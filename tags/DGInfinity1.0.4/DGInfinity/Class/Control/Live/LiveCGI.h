//
//  LiveCGI.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/15.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveCGI : NSObject

/**
 *  get_live_info
 *  @param seq 序列号，分页拉取用
 */
+ (void)getLiveInfo:(NSInteger)seq
           complete:(void(^)(DGCgiResult *res))complete;

@end
