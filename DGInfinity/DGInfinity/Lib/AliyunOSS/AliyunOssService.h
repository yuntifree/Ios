//
//  AliyunOssService.h
//  Live
//
//  Created by jacky.lee on 16/3/31.
//  Copyright © 2016年 aini25. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliyunOssService : NSObject

+ (AliyunOssService *)sharedAliyunOssService;

- (void)applyImage:(UIImage *)image complete:(void(^)(UploadPictureState state, NSString *picture))complete;

@end
