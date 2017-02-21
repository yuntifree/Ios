//
//  PickHeadModel.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/21.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PickHeadModel : NSObject

@property (nonatomic, copy) NSString *headurl;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *age;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
