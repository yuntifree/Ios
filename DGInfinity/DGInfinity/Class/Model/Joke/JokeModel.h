//
//  JokeModel.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/23.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JokeModel : NSObject

@property (nonatomic, assign) NSInteger id_;
@property (nonatomic, assign) NSInteger seq;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger heart;
@property (nonatomic, assign) NSInteger bad;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, assign) BOOL unliked;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
