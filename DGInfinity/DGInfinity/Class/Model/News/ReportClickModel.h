//
//  ReportClickModel.h
//  DGInfinity
//
//  Created by myeah on 16/11/9.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsReportModel.h"
#import "NewsVideoModel.h"

@interface ReportClickModel : NSObject

@property (nonatomic, assign) NSInteger id_;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) ReportClickType type;

+ (instancetype)createWithReportModel:(NewsReportModel *)model;
+ (instancetype)createWithVideoModel:(NewsVideoModel *)model;

@end