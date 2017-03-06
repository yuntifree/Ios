//
//  LocationInfo.m
//  BaiduSB
//
//  Created by jacky.lee on 16/8/12.
//  Copyright © 2016年 aini25. All rights reserved.
//

#import "LocationInfo.h"

@implementation LocationInfo

- (void)dealloc
{
    DDDLog(@"LocationInfo Dealloc");
}

- (id)initWithCoordinate2D:(CLLocationCoordinate2D)coordinate2D
                  busiName:(NSString *)busiName
              locationDesc:(NSString *)locationDesc
              isMyLocation:(BOOL)isMyLocation
{
    self = [super init];
    if (self) {
        _coordinate2D = coordinate2D;
        _busiName = busiName;
        _locationDesc = locationDesc;
        _isMyLocation = isMyLocation;
    }
    return self;
}

@end
