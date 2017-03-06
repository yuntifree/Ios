//
//  ActivityCGI.h
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/19.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityCGI : NSObject

/**
 *  get_activity
 */
+ (void)getActivity:(void(^)(DGCgiResult *res))complete;

@end
