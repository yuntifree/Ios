//
//  SettingModel.h
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;

+ (instancetype)createWithTitle:(NSString *)title desc:(NSString *)desc;

@end
