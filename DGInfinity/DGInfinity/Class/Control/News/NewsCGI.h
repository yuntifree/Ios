//
//  NewsCGI.h
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsCGI : NSObject

/**
 *  hot
 *  @param type 0-新闻 1-视频 2-应用 3-游戏
 *  @param seq 序列号，分页拉取用
 */
+ (void)getHot:(NSInteger)type
           seq:(NSInteger)seq
      complete:(void (^)(DGCgiResult *res))complete;

@end
