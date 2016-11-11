//
//  WiFiCGI.h
//  DGInfinity
//
//  Created by myeah on 16/11/10.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiFiCGI : NSObject

/**
 *  get_weather_news
 */
+ (void)getWeatherNews:(void (^)(DGCgiResult *res))complete;

/**
 *  get_front_info
 */
+ (void)getFrontInfo:(void (^)(DGCgiResult *res))complete;

@end
