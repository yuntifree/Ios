//
//  DGInfinityConf.h
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#ifndef DGInfinityConf_h
#define DGInfinityConf_h

enum ErrorType {
    E_OK = 0, //正常
    E_MISS_PARAM = 1,  //缺少参数
    E_INVAL_PARAM = 2, //参数异常
    E_DATABASE = 3, //数据库错误
    E_INNER = 4, //服务器内部错误
    E_TOKEN = 101, // token验证失败
    E_CODE = 102, //短信验证码错误
    E_GET_CODE = 103, //获取短信验证码失败
    
    E_CGI_OFTEN = 0x90000,
    E_CGI_DUP   = 0x90010,
    E_CGI_FAILED = 0x90011,
    E_INVALID_DATA = 0x90020,
    E_INVALID_ENCRYPTED = 0x90021
};

enum TermType {
    T_ANDROID = 0,
    T_IOS = 1
};

#define ServerURL @"http://120.76.236.185/" // 测试环境
#define AppVersion 1 // 客户端内部版本

#endif /* DGInfinityConf_h */
