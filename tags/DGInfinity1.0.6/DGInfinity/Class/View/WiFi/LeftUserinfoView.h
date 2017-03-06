//
//  LeftUserinfoView.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/24.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftUserinfoView : UIView

@property (nonatomic, copy) void(^tapBlock)(void);

- (void)refreshUserinfo;

@end
