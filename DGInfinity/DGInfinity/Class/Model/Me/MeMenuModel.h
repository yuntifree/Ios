//
//  MeMenuModel.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/8/24.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeMenuModel : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) BOOL showPoint;

+ (instancetype)createWithIcon:(NSString *)icon
                         title:(NSString *)title
                          desc:(NSString *)desc
                     showPoint:(BOOL)showPoint;

@end
