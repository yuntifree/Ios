//
//  UserAuthManager.h
//  userauthSdk
//
//  Created by 吕东阳 on 16/6/17.
//  Copyright © 2016年 LDY. All rights reserved.
//
//  版本号V1.0.6
//
/* 
 
版本修改记录：
**********v1.0.1***********

1.更改重定向地址的判断（使用ip地址来对环境判断）。
 
**********v1.0.2***********

1.增加A6内核用于iPhone5中的架构。
 
**********v1.0.3***********
 
1.修改一个在iPhone5上编译时的一个bug。
 
**********v1.0.4***********
 
1.检测网络环境返回值有所更改，详见枚举。
 
**********v1.0.5***********
 
1.更改重定向地址的判断（使用特殊字符判断：wsmp && ssid && wlanacname）
2.重定向中SSID解码，解决认证成功后，再次调用checkEnv返回-1的问题。
 
**********v1.0.6***********

1.认证接口增加wlanusermac参数。
 */
#import <Foundation/Foundation.h>

typedef enum {
    ENV_NOT_WIFI = -1,      //当前连接的WiFi不是东莞环境的WiFi
    ENV_NOT_LOGIN = 0,      //需要认证
    ENV_ERROR = 1,          //无网络
    ENV_LOGIN = 2,          //已经认证成功
}ENV_STATUS;


@interface UserAuthManager : NSObject
{
    
}


+ (instancetype)manager;


/** 设置是否打印sdk的log信息,默认不开启
 @param value 设置为YES, 会输出log信息
 */
- (void)logEnable:(BOOL)value;



/**配置SSID和认证平台
 @param ssid SSID
 @param wurl -- 认证平台的地址
 @param vnoCode -- vnoCode
 */
- (void)initEnv:(NSString *)ssid withWurl:(NSString *)wurl withVNO:(NSString *)vnoCode;



/**网络环境检测
 @param _block -- 检测成功，失败后执行，包含一个状态值，详细见枚举
 */
- (void)checkEnvironmentBlock:(void (^)(ENV_STATUS status))_block;


/**用户注册
 @param userName -- 用户ID
 @param passWord -- 用户密码
 @param timeOut -- 超时时间，单位：毫秒 如：10*1000
 @param _block -- 注册成功，失败或异常时执行。block包含两个参数，response--服务器响应，error--网络错误
 */


-(void)doRegisterWithUserName:(NSString*)userName andPassWord:(NSString*)passWord andTimeOut:(NSTimeInterval)timeOut block:(void (^)(NSDictionary *response, NSError *error))_block;



/**用户登录
 @param token -- 用户ID
 @param passWord -- 用户密码
 @param timeOut -- 超时时间，单位：毫秒 如：10*1000
 @param _block -- 登录成功，失败或异常时执行。block包含两个参数，response--服务器响应，error--网络错误
 */
- (void)doLogon:(NSString *)token andPassWord:(NSString*)passWord andTimeOut:(NSTimeInterval)timeOut block:(void (^)(NSDictionary *response, NSError *error))_block;

/**用户登出
 @param token -- 用户ID
 @param timeOut -- 超时时间，单位：毫秒 如：10*1000
 @param _block -- 登出成功，失败或异常时执行。block包含两个参数，response--服务器响应，error--网络错误
 */
- (void)doLogout:(NSString *)token andTimeOut:(NSTimeInterval)timeOut block:(void (^)(NSDictionary *response, NSError *error))_block;



@end
