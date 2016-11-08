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
    E_USED_PHONE = 104, //手机号重复注册
    
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

typedef NS_ENUM(NSInteger, NewsType) {
    NT_REPORT = 0,
    NT_VIDEO = 1,
    NT_APP = 2,
    NT_GAME = 3
};

typedef NS_ENUM(NSInteger, ReportType) {
    RT_NEWS = 0,
    RT_AD = 1
};

// Server
#define ServerURL @"http://120.25.133.234/" // 测试环境
#define AppVersion 1 // 客户端内部版本

// WifiSDK
#define WIFISDK_TIMEOUT  5 * 1000
#define WIFISDK_URL @"http://192.168.100.4:880/wsmp/interface"
//#define WIFISDK_SSID @"无线东莞DG-FREE"
#define WIFISDK_SSID @"云行智慧"
#define WIFISDK_VNOCODE @"ROOT_VNO"

// 听云SDK
#define TingYunAppKey @"8a6175653d1b4fe3948ad8d9cd1b3fd7"

// 友盟SDK
#define UMengAppKey @"58183f77c62dca59990026e0"

// 百度地图SDK
#define BaiduMapAppKey @"kvGmE3GGGkaBotP6N6jWSBVCRLGkrwkM"

#endif /* DGInfinityConf_h */
