//
//  MSApp.h
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportClickModel.h"

@interface MSApp : NSObject

// user info
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *privdata;
@property (nonatomic, assign) NSTimeInterval expire;
@property (nonatomic, copy) NSString *wifipass;

// app info
@property (nonatomic, copy) NSString *appVersion;

// temp data
@property (nonatomic, strong) NSMutableArray *reportArray;

+ (instancetype)sharedMSApp;
+ (void)destory;

+ (void)setUserInfo:(NSDictionary *)data;
+ (void)autoLogin;
- (void)reportClick:(ReportClickModel *)model;
- (void)setMiPush;
- (void)unSetMiPush;

@end
