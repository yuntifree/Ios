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
 */
+ (void)feedBack:(NSString *)content
        complete:(void(^)(DGCgiResult *res))complete;

@end
