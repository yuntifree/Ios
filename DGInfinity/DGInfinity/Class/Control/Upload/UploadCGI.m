//
//  UploadCGI.m
//  DGInfinity
//
//  Created by myeah on 16/12/6.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "UploadCGI.h"

@implementation UploadCGI

+ (void)getImageToken:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    [[RequestManager shareManager] loadAsync:params cgi:@"get_image_token" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

+ (void)applyImageUpload:(NSInteger)size
                  format:(NSString *)format
                complete:(void(^)(DGCgiResult *res))complete
{
    NSMutableDictionary *params = [RequestManager httpParams];
    params[@"data"] = @{@"size": @(size),
                        @"format": format};
    [[RequestManager shareManager] loadAsync:params cgi:@"apply_image_upload" complete:^(DGCgiResult *res) {
        if (complete) {
            complete(res);
        }
    }];
}

@end
