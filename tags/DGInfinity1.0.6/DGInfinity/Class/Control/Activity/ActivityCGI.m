//
//  ActivityCGI.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/19.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ActivityCGI.h"

@implementation ActivityCGI

+ (void)getActivity:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_activity" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
