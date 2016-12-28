//
//  WiFiExamModel.h
//  DGInfinity
//
//  Created by myeah on 16/11/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiFiExamModel : NSObject

@end

@interface WiFiExamDeviceModel : WiFiExamModel

@property (nonatomic, copy) NSString *hostname;
@property (nonatomic, copy) NSString *ip;

+ (instancetype)createWithBrand:(NSString *)brand ip:(NSString *)ip hostname:(NSString *)hostname;

@end

@interface WiFiExamDescModel : WiFiExamModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;

+ (instancetype)createWithTitle:(NSString *)title desc:(NSString *)desc;

@end
