//
//  MeHeader.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/20.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^HeadViewTap)(void);
typedef void (^WriteViewTap)(void);

@interface MeHeader : UIView

@property (nonatomic, copy) HeadViewTap headTap;
@property (nonatomic, copy) WriteViewTap writeTap;

- (void)setHeaderValue:(NSDictionary *)info;
- (void)setNickname:(NSString *)nickname;
- (void)setHead:(NSString *)headurl;

@end
