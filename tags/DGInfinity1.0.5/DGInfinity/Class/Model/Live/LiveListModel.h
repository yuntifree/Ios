//
//  LiveListModel.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/8.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveListModel : NSObject

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *img;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, assign) NSInteger live_id;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign) NSInteger watches;
@property (nonatomic, assign) int live;
@property (nonatomic, assign) NSInteger seq;
@property (nonatomic, copy) NSString *p_time;

+ (instancetype)createWithInfo:(NSDictionary *)info;

@end
