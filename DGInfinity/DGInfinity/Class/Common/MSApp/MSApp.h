//
//  MSApp.h
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSApp : NSObject

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *privdata;
@property (nonatomic, assign) NSTimeInterval expire;
@property (nonatomic, copy) NSString *wifipass;

+ (instancetype)sharedMSApp;
+ (void)destory;

+ (void)setUserInfo:(NSDictionary *)data;
+ (void)autoLogin;

@end
