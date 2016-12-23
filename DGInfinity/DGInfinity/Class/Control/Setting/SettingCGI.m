//
//  SettingCGI.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "SettingCGI.h"

@implementation SettingCGI

+ (void)feedBack:(NSString *)content
        complete:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"content": content};
    [[RequestManager shareManager] loadAsync:params cgi:@"feedback" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
