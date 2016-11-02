//
//  MapCGI.h
//  DGInfinity
//
//  Created by myeah on 16/11/2.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapCGI : NSObject

/**
 *  get_nearby_aps
 *  @param longitude 经度
 *  @param latitude 维度
 */
+ (void)getNearbyAps:(double)longitude
            latitude:(double)latitude
            complete:(void (^)(DGCgiResult *res))complete;

@end
