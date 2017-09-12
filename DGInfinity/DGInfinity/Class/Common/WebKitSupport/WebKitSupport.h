//
//  WebKitSupport.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/9/12.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WebKitSupport : NSObject

@property (nonatomic, strong, readonly) WKProcessPool *processPool;

+ (instancetype)sharedSupport;

@end
