//
//  AccountCGI.h
//  DGInfinity
//
//  Created by myeah on 16/10/19.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountCGI : NSObject

/**
 *  get_phone_code
 *  @param phone 手机号
 *  @param type 验证类型 0-无uid(注册) 1-无uid(忘记密码)
 */
+ (void)getPhoneCode:(NSString *)phone
                type:(NSInteger)type
            complete:(void (^)(DGCgiResult *res))complete;

/**
 *  register
 *  @param username 用户名
 *  @param password 密码
 */
+ (void)doRegister:(NSString *)username
          password:(NSString *)password
          complete:(void (^)(DGCgiResult *res))complete;

/**
 *  login
 *  @param username 用户名
 *  @param password 密码
 */
+ (void)login:(NSString *)username
     password:(NSString *)password
     complete:(void (^)(DGCgiResult *res))complete;

/**
 *  auto_login
 *  @param privdata 上一次返回的privdata
 */
+ (void)autoLogin:(NSString *)privdata
         complete:(void (^)(DGCgiResult *res))complete;

/**
 *  logout
 */
+ (void)logout:(void (^)(DGCgiResult *res))complete;

/**
 *  get_check_code
 *  @param phone 手机号
 */
+ (void)getCheckCode:(NSString *)phone
            complete:(void (^)(DGCgiResult *res))complete;

/**
 *  connect_wifi
 *  @param wlanacname
 *  @param wlanuserip
 *  @param wlanacip
 *  @param wlanusermac
 *  @param apmac
 */
+ (void)ConnectWifi:(NSString *)wlanacname
         wlanuserip:(NSString *)wlanuserip
           wlanacip:(NSString *)wlanacip
        wlanusermac:(NSString *)wlanusermac
              apmac:(NSString *)apmac
           complete:(void (^)(DGCgiResult *res))complete;

@end
