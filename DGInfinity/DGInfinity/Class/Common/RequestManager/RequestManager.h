//
//  RequestManager.h
//  DGInfinity
//
//  Created by myeah on 16/10/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface DGCgiResult : NSObject

@property (nonatomic, assign) int _errno;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSDictionary *data;

@end

@interface RequestManager : AFHTTPSessionManager

+ (instancetype)shareManager;
+ (NSMutableDictionary *)httpParams;
- (void)loadAsync:(NSDictionary *)params cgi:(NSString *)cgi complete:(void(^)(DGCgiResult *res))complete;

@end
