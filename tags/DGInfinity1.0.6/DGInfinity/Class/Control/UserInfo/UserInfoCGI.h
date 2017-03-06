//
//  UserInfoCGI.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/20.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoCGI : NSObject

/**
 *  get_user_info
 *  @param tuid 目标用户id
 */
+ (void)getUserInfo:(NSInteger)tuid
           complete:(void(^)(DGCgiResult *res))complete;

/**
 *  get_rand_nick
 */
+ (void)getRandNick:(void(^)(DGCgiResult *res))complete;

/**
 *  mod_user_info
 *  @param key 需要修改的属性
 *  @param value 对应的值
 */
+ (void)modUserInfo:(NSString *)key
              value:(id)value
           complete:(void(^)(DGCgiResult *res))complete;

/**
 *  get_def_head
 */
+ (void)getDefHead:(void(^)(DGCgiResult *res))complete;

@end
