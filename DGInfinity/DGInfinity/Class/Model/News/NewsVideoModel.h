//
//  NewsVideoModel.h
//  DGInfinity
//
//  Created by myeah on 16/10/27.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsVideoModel : NSObject

@property (nonatomic, assign) NSInteger id_;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *dst;
@property (nonatomic, assign) int stype;
@property (nonatomic, assign) NSInteger seq;
@property (nonatomic, assign) NSInteger play;
@property (nonatomic, assign) BOOL read;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end

@interface NewsVideoTopModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *dst;
@property (nonatomic, copy) NSString *img;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
