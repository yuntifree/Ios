//
//  DGSplashView.h
//  DGInfinity
//
//  Created by myeah on 16/12/12.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

enum SplashActionType {
    SplashActionTypeGet = 0,
    SplashActionTypeDismiss
};

typedef void(^SplashAction)(enum SplashActionType type, NSString *target);

@interface DGSplashView : UIView

@property (nonatomic, copy) SplashAction action;

- (instancetype)initWithImage:(UIImage *)image target:(NSString *)target;

@end
