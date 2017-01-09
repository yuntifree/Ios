//
//  ServiceCellModel.h
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceCellModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *dst;
@property (nonatomic, assign) NSInteger sid;
@property (nonatomic, copy) NSString *icon;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
