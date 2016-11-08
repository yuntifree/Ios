//
//  NewsVideoModel.h
//  DGInfinity
//
//  Created by myeah on 16/10/27.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsVideoModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *dst;
@property (nonatomic, assign) int stype;
@property (nonatomic, assign) NSInteger seq;
@property (nonatomic, assign) NSInteger play;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
