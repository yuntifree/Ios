//
//  JokeCGI.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/23.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JokeCGI : NSObject

/**
 *  get_jokes
 *  @param seq 分页
 */
+ (void)getJokes:(NSInteger)seq
        complete:(void(^)(DGCgiResult *res))complete;

@end
