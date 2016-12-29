//
//  SettingCGI.h
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingCGI : NSObject

/**
 *  feedback
 *  @param content 内容
 *  @param contact 联系方式
 */
+ (void)feedBack:(NSString *)content
         contact:(NSString *)contact
        complete:(void(^)(DGCgiResult *res))complete;

@end
