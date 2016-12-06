//
//  UploadCGI.h
//  DGInfinity
//
//  Created by myeah on 16/12/6.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadCGI : NSObject

/**
 *  get_image_token
 */
+ (void)getImageToken:(void(^)(DGCgiResult *res))complete;

/**
 *  apply_image_upload
 *  @param size 图片大小
 *  @param format 图片格式
 */
+ (void)applyImageUpload:(NSInteger)size
                  format:(NSString *)format
                complete:(void(^)(DGCgiResult *res))complete;

@end
