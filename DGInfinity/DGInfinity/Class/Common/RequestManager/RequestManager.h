//
//  RequestManager.h
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGCgiResult : NSObject

@property (nonatomic, assign) int _errno;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSDictionary *data;

@end

@interface RequestManager : NSObject

+ (instancetype)shareManager;
+ (NSMutableDictionary *)httpParams;
- (NSString *)urlPath:(NSString *)cgi;
- (void)loadAsync:(NSDictionary *)params cgi:(NSString *)cgi complete:(void(^)(DGCgiResult *res))complete;

@end
