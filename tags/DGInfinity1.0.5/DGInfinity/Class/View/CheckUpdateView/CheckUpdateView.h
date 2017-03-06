//
//  CheckUpdateView.h
//  DGInfinity
//
//  Created by 刘启飞 on 2017/1/13.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckUpdateView : UIView

- (instancetype)initWithVersion:(NSString *)version trackViewUrl:(NSString *)trakViewUrl;
- (void)showInView:(UIView *)view;

@end
