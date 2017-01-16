//
//  UserAuthManager.m
//  userauthSdk
//
//  Created by 吕东阳 on 16/6/17.
//  Copyright © 2016年 LDY. All rights reserved.
//

#import "UserAuthManager.h"
#import "CMCCUserInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>


#define SSID                      @"cmccssid"
#define WURL                      @"cmccurl"
#define VNO_CODE                  @"CMCC_VCODE"

#define YUEAP_HOST                @"http://112.33.2.51:7071/wsmp/interface?"
#define YUE_HOST_NAME             @"http://www.apple.com/cn/"


#define YUE_WLAN_ACNAME           @"wlanacname"
#define YUE_WLAN_USERIP           @"wlanuserip"
#define YUE_SSID                  @"ssid"
#define YUE_WLAN_ACIP             @"wlanacip"
#define YUE_WLAN_USERMAC          @"wlanusermac"




#define YUE_SESSIONID             @"sessionid"

#define TOKEN                     @"tokenID"


#ifdef DEBUG
#define LRString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define DYLog(...) printf("%s 第%d行: %s\n\n", [LRString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);

#else
#define DYLog(...)
#endif

@interface UserAuthManager ()<NSURLSessionDelegate, NSURLSessionTaskDelegate>
{
    
    void((^registerResponse)(NSDictionary *response, NSError *error));
    void((^logonResponse)(NSDictionary *response, NSError *error));
    void((^logoutResponse)(NSDictionary *response, NSError *error));
    void((^environmentCheck)(ENV_STATUS staus));
    
    BOOL logSwitch;
    
    
    
}

@end

@implementation UserAuthManager


+ (instancetype)manager
{
    static UserAuthManager *_sharedRequest = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedRequest = [[UserAuthManager alloc] init];
    });
    return  _sharedRequest;
}

#pragma mark- Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        logSwitch = NO;
    }
    return self;
}

#pragma mark -

#pragma mark - NSURLCONNECTIONDELEGATE

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler
{
    completionHandler = nil;
    
    /*
     http://120.234.130.196:880/wsmp/customize/dgwifi/login_p.html?wsmp-theme=1000&wsmp-page=0&wsmp-time=-1&wsmp-portal=101&wlanacname=2043.0769.200.00&wlanuserip=10.96.72.28&ssid=%E6%97%A0%E7%BA%BF%E4%B8%9C%E8%8E%9EDG-FREE&wlanacip=120.197.159.10
     */
    
    if (logSwitch)
    {
        DYLog(@"重定向后,返回Request____%@",request);
        
    }
    
    NSURL *url = [request URL];
    NSString *string = [url absoluteString];
    if (logSwitch)
    {
        DYLog(@"重定向后,返回URL____%@",string);
        
    }
    if ([string rangeOfString:@"wsmp"].location != NSNotFound && [string rangeOfString:@"ssid"].location != NSNotFound && [string rangeOfString:@"wlanacname"].location != NSNotFound)
    {
        NSArray *array = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?&"]];
        NSMutableDictionary *infoDic = [@{} mutableCopy];
        if (logSwitch)
        {
            DYLog(@"array____%@",array);
        }
        
        for (NSString *string in array)
        {
            NSArray *tempArray = [string componentsSeparatedByString:@"="];
            if (tempArray && [tempArray count] == 2)
            {
                NSString *key = tempArray[0];
                NSString *value = tempArray[1];
                [infoDic setObject:value forKey:key];
            }
        }
        NSString *encodeSSIDname = infoDic[YUE_SSID];
        if (logSwitch)
        {
            DYLog(@"重定向返回url编码后的SSID____%@",encodeSSIDname);
        }
        [CMCCUserInfo shareInfo].wlanacname = infoDic[YUE_WLAN_ACNAME];
        [CMCCUserInfo shareInfo].wlanuserip = infoDic[YUE_WLAN_USERIP];
        [CMCCUserInfo shareInfo].ssid = encodeSSIDname.stringByRemovingPercentEncoding;
        [CMCCUserInfo shareInfo].wlanacip = infoDic[YUE_WLAN_ACIP];
        [CMCCUserInfo shareInfo].wlanusermac = infoDic[YUE_WLAN_USERMAC];

        
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:VNO_CODE])
        {
            [CMCCUserInfo shareInfo].vnoCode = [[NSUserDefaults standardUserDefaults]objectForKey:VNO_CODE];
        }
        
        environmentCheck(ENV_NOT_LOGIN);
        if (logSwitch)
        {
            DYLog(@"当前网络为:需要认证的WiFi!");
            
        }
        
        /*
         ENV_NOT_WIFI = -1,      //当前连接的WiFi不是东莞环境的WiFi
         ENV_NOT_LOGIN = 0,      //需要认证
         ENV_ERROR = 1,          //无网络
         ENV_LOGIN = 2,          //已经认证成功

         */
    }
    else
    {
        environmentCheck(ENV_NOT_WIFI);
        if (logSwitch)
        {
            DYLog(@"当前网络为:无需认证的WiFi!,不能上网!");
            
        }
        
        
    }
    
}


#pragma mark ----

- (void)logEnable:(BOOL)value
{
    logSwitch = value;
}

- (void)checkEnvironmentBlock:(void (^)(ENV_STATUS status))_block;
{
    environmentCheck = _block;
    
    
    NSURL *url = [NSURL URLWithString:YUE_HOST_NAME];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData  timeoutInterval:2.0];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if (logSwitch)
          {
              DYLog(@"无重定向返回response_____%@",response);
          }
          
          
          if(response && !error)
          {
//              NSString *ssidName = [[NSUserDefaults standardUserDefaults]objectForKey:SSID];
              if ([[CMCCUserInfo shareInfo].ssid isEqualToString:WIFISDK_SSID])
              {
                  environmentCheck(ENV_LOGIN);//已登录认证的WiFi
                  
                  if (logSwitch)
                  {
                      DYLog(@"当前网络为:认证成功的WiFi!可以上网!");
                      
                  }
                  
              }
              else
              {
                  environmentCheck(ENV_NOT_WIFI);//不是需要认证的WiFi
                  if (logSwitch)
                  {
                      DYLog(@"当前网络为:不是需要认证的网络！");
                      
                  }
                  
              }
              
              
              
          }
          else if (error)
          {
              //网络检测异常(无网络)
              environmentCheck(ENV_ERROR);//无网络
              if (logSwitch)
              {
                  DYLog(@"当前无网络!不能上网!");
                  
              }
              
              
          }
          
      }];
    
    [dataTask resume];
    
}

-(void)doRegisterWithUserName:(NSString*)userName andPassWord:(NSString*)passWord andTimeOut:(NSTimeInterval)timeOut block:(void (^)(NSDictionary *response, NSError *error))_block
{
    double newTime = timeOut / 1000.0;
    registerResponse = _block;
    [self registerWithUserName:userName andPSW:passWord andTimeOut:newTime];
    
}

- (void)doLogon:(NSString *)token andPassWord:(NSString*)passWord andTimeOut:(NSTimeInterval)timeOut block:(void (^)(NSDictionary *response, NSError *error))_block
{
    [[NSUserDefaults standardUserDefaults]setObject:token forKey:TOKEN];
    [[NSUserDefaults standardUserDefaults]synchronize];
    double newTime = timeOut / 1000.0;
    logonResponse = _block;
    [self loginWithUserName:token andPSW:passWord andTimeOut:newTime];
    
}

- (void)doLogout:(NSString *)token andTimeOut:(NSTimeInterval)timeOut block:(void (^)(NSDictionary *response, NSError *error))_block
{
    double newTime = timeOut / 1000.0;
    logoutResponse = _block;
    [self logoutWithUserName:token andTimeOut:newTime];
}

- (void)initEnv:(NSString *)ssid withWurl:(NSString *)wurl withVNO:(NSString *)vnoCode
{    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:ssid forKey:SSID];
    [userDefault setObject:wurl forKey:WURL];
    [userDefault setObject:vnoCode forKey:VNO_CODE];
    [userDefault synchronize];
}

#pragma mark- register and logon

//注册请求
- (void)registerWithUserName:(NSString *)userName andPSW:(NSString*)psw andTimeOut:(NSTimeInterval)timeOut
{
    NSMutableDictionary *headDic = [@{} mutableCopy];
    [headDic setObject:@"reg" forKey:@"action"];
    if([[NSUserDefaults standardUserDefaults]objectForKey:VNO_CODE])
    {
        [headDic setObject:[[NSUserDefaults standardUserDefaults]objectForKey:VNO_CODE] forKey:@"vnoCode"];
    }
    
    
    // bodyDic
    NSMutableDictionary *bodyDic = [@{} mutableCopy];
    if (userName)
    {
        [bodyDic setObject:userName forKey:@"custCode"];
        [bodyDic setObject:userName forKey:@"mobilePhone"];
    }
    if(psw)
    {
        [bodyDic setObject:psw forKey:@"pass"];

    }
    if (logSwitch) {
        DYLog(@"register action body = %@", bodyDic);
    }
    
    NSURLRequest *request = [self requestWithHead:headDic body:bodyDic andTimeOut:10];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                      
  {
      if (data)
      {
          id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
          if (logSwitch)
          {
              DYLog(@"registerResult____%@",result);
          }
          
          if (registerResponse)
          {
              registerResponse(result, nil);
          }
          
      }
      else if (error)
      {
          if (registerResponse)
          {
              registerResponse(nil, error);
          }
      }
      
  }];
    [dataTask resume];
    
    
}

// 登录请求

- (void)loginWithUserName:(NSString *)userName andPSW:(NSString*)psw andTimeOut:(NSTimeInterval)timeOut
{
    
    
    // headDic
    NSMutableDictionary *headDic = [@{} mutableCopy];
    [headDic setObject:@"login" forKey:@"action"];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *vnoCode = [userDefault objectForKey:VNO_CODE];
    [headDic setObject:vnoCode forKey:@"vnoCode"];
    
    // bodyDic
    NSMutableDictionary *bodyDic = [@{} mutableCopy];
    [bodyDic setObject:userName forKey:@"custCode"];
    NSString *ssid = [CMCCUserInfo shareInfo].ssid;
    if (ssid) {
        [bodyDic setObject:ssid forKey:@"ssid"];
    }
    NSString *wlanacname = [CMCCUserInfo shareInfo].wlanacname;
    if (wlanacname) {
        [bodyDic setObject:wlanacname forKey:@"wlanacname"];
    }
    NSString *wlanacip = [CMCCUserInfo shareInfo].wlanacip;
    if (wlanacip)
    {
        [bodyDic setObject:wlanacip forKey:@"wlanacip"];
    }
    NSString *wlanusermac = [CMCCUserInfo shareInfo].wlanusermac;
    if (wlanusermac)
    {
        [bodyDic setObject:wlanusermac forKey:@"wlanusermac"];
    }
    NSString *userIP = [CMCCUserInfo shareInfo].wlanuserip;
    if (userIP)
    {
        [bodyDic setObject:userIP forKey:@"ip"];
    }
    if (psw)
    {
        [bodyDic setObject:psw forKey:@"pass"];

    }

    if (logSwitch) {
        DYLog(@"login action body = %@", bodyDic);
    }
    
    NSURLRequest *request = [self requestWithHead:headDic body:bodyDic andTimeOut:timeOut];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
  
  {
      if (data)
      {
          id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
          if (logSwitch)
          {
              DYLog(@"网络认证result____%@",result);
              
          }
          if ([result isKindOfClass:[NSDictionary class]])
          {
              NSString *str = [[result objectForKey:@"head"] objectForKey:@"retflag"];
              
              if (str && [str isEqualToString:@"0"])
              {
                  
                  
                  NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                  [userDefault setObject:[CMCCUserInfo shareInfo].wlanacname forKey:YUE_WLAN_ACNAME];
                  [userDefault setObject:[CMCCUserInfo shareInfo].wlanacip forKey:YUE_WLAN_ACIP];
                  [userDefault setObject:[CMCCUserInfo shareInfo].wlanuserip forKey:YUE_WLAN_USERIP];
                  [userDefault setObject:[CMCCUserInfo shareInfo].wlanusermac forKey:YUE_WLAN_USERMAC];
                  [userDefault setObject:[CMCCUserInfo shareInfo].ssid forKey:YUE_SSID];
                  
                  
                  NSString *sessionID = [[result objectForKey:@"body"] objectForKey:YUE_SESSIONID];
                  if (sessionID)
                  {
                      [userDefault setObject:sessionID forKey:YUE_SESSIONID];
                  }
                  [userDefault synchronize];
                  
                  
                  
              }
          }
          if (logonResponse)
          {
              logonResponse(result, nil);
          }
          
      }
      else if(error)
      {
          if (logonResponse)
          {
              logonResponse(nil, error);
          }
      }
      
      
  }];
    [dataTask resume];
}

// 登出请求

- (void)logoutWithUserName:(NSString *)userName andTimeOut:(NSTimeInterval)timeOut
{
    
    
    // headDic
    NSMutableDictionary *headDic = [@{} mutableCopy];
    [headDic setObject:@"logout" forKey:@"action"];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *vnoCode = [userDefault objectForKey:VNO_CODE];
    [headDic setObject:vnoCode forKey:@"vnoCode"];
    
    // bodyDic
    NSMutableDictionary *bodyDic = [@{} mutableCopy];
    [bodyDic setObject:userName forKey:@"custCode"];
    
    NSString *userIP = [[NSUserDefaults standardUserDefaults] objectForKey:YUE_WLAN_USERIP];
    if (userIP)
    {
        [bodyDic setObject:userIP forKey:@"ip"];
    }
    NSString *acIP = [[NSUserDefaults standardUserDefaults] objectForKey:YUE_WLAN_ACIP];
    if (acIP)
    {
        [bodyDic setObject:acIP forKey:@"acip"];
        [bodyDic setObject:acIP forKey:@"wlanacip"];

    }
    NSString *acName = [[NSUserDefaults standardUserDefaults] objectForKey:YUE_WLAN_ACNAME];
    if (acName)
    {
        [bodyDic setObject:acName forKey:@"wlanacname"];
    }
    NSString *wlanusermac = [[NSUserDefaults standardUserDefaults] objectForKey:YUE_WLAN_USERMAC];
    if (wlanusermac)
    {
        [bodyDic setObject:wlanusermac forKey:@"wlanusermac"];
    }
    if (logSwitch) {
        DYLog(@"logout action body = %@", bodyDic);
    }
    
    NSURLRequest *request = [self requestWithHead:headDic body:bodyDic andTimeOut:timeOut];
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                      
      {
          if (data)
          {
              id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
              if (logSwitch)
              {
                  DYLog(@"网络下线result____%@",result);
                  
              }
              if ([result isKindOfClass:[NSDictionary class]])
              {
                  NSString *str = [[result objectForKey:@"head"] objectForKey:@"retflag"];
                  
                  if (str && [str isEqualToString:@"0"])
                  {
                      NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                      [userDefault removeObjectForKey:YUE_WLAN_ACNAME];
                      [userDefault removeObjectForKey:YUE_WLAN_ACIP];
                      [userDefault removeObjectForKey:YUE_WLAN_USERIP];
                      [userDefault removeObjectForKey:YUE_WLAN_USERMAC];
                      [userDefault removeObjectForKey:YUE_SSID];
                      [userDefault synchronize];
                      
                      
                      
                  }
              }
              if (logoutResponse)
              {
                  logoutResponse(result, nil);
              }
              
          }
          else if(error)
          {
              if (logoutResponse)
              {
                  logoutResponse(nil, error);
              }
          }
          
          
      }];
    [dataTask resume];
}



#pragma mark- request

- (NSURLRequest *)requestWithHead:(NSDictionary *)headData body:(NSDictionary *)bodyData andTimeOut:(NSTimeInterval)timeOut
{
    // requestData
    NSMutableDictionary *parameters = [@{} mutableCopy];
    [parameters setObject:headData forKey:@"head"];
    [parameters setObject:bodyData forKey:@"body"];
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:parameters
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:nil];
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithData:requestData];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    if ([[userDefault objectForKey:WURL] isEqualToString:@""]
        || [userDefault objectForKey:WURL]==nil)
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:YUEAP_HOST]];
        
        [request setTimeoutInterval:timeOut];
        [request setHTTPMethod:@"POST"];
        NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBodyStream:inputStream];
        
        return request;
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[userDefault objectForKey:WURL]]];
        
        [request setTimeoutInterval:timeOut];
        [request setHTTPMethod:@"POST"];
        NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:msgLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBodyStream:inputStream];
        
        
        return request;
    }
}

@end
