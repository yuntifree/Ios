//
//  NewsMenuModel.h
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/30.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsMenuModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *dst;
@property (nonatomic, assign) NSInteger ctype;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
