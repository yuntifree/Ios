//
//  LocationInfo.h
//  BaiduSB
//
//  Created by jacky.lee on 16/8/12.
//  Copyright © 2016年 aini25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>

@interface LocationInfo : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate2D;      // 位置经纬度
@property (nonatomic, copy) NSString *busiName;                         // 店名
@property (nonatomic, copy) NSString *locationDesc;                     // 位置描述
@property (nonatomic, assign) BOOL isMyLocation;                        // 是否是我的位置

- (id)initWithCoordinate2D:(CLLocationCoordinate2D)coordinate2D
                  busiName:(NSString *)busiName
              locationDesc:(NSString *)locationDesc
              isMyLocation:(BOOL)isMyLocation;

@end
