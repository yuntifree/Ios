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

+ (instancetype)sharedMSApp;
+ (void)destory;

@end
