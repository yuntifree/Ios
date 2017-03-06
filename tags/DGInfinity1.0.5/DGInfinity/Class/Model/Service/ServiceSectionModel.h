//
//  ServiceSectionModel.h
//  DGInfinity
//
//  Created by myeah on 16/11/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceSectionModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray *items;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
