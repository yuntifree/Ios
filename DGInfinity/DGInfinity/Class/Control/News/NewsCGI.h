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

/**
 *  report_click
 *  @param id_ 媒体id （视频/新闻/广告）
 *  @param type 类型 0- 视频播放 1-新闻点击 2-广告展示 3-广告点击
 *  @param name type=7,8 传name来区分子类型
 */
+ (void)reportClick:(NSInteger)id_
               type:(NSInteger)type
               name:(NSString *)name
           complete:(void (^)(DGCgiResult *res))complete;

/**
 *  get_menu
 */
+ (void)getMenu:(void (^)(DGCgiResult *res))complete;

@end
