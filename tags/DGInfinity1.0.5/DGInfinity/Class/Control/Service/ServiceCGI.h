//
//  ServiceCGI.h
//  DGInfinity
//
//  Created by myeah on 16/10/31.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceCGI : NSObject

/**
 *  services
 */
+ (void)getServices:(void (^)(DGCgiResult *res))complete;

@end
