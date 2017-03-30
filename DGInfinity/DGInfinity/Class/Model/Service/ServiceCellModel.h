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
@property (nonatomic, assign) ReportClickType rcType;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end

@interface ServiceBannerModel : NSObject

@property (nonatomic, assign) NSInteger id_;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *dst;
@property (nonatomic, assign) ReportClickType rcType;
@property (nonatomic, assign) NSInteger type;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end

@interface ServiceCityModel : NSObject

@property (nonatomic, assign) NSInteger id_;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *dst;
@property (nonatomic, assign) ReportClickType rcType;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
