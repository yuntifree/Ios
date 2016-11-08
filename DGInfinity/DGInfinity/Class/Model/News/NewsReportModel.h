//
//  NewsReportModel.h
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsReportModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *dst;
@property (nonatomic, assign) NSInteger stype;
@property (nonatomic, assign) NSInteger seq;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
