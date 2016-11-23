//
//  UIScrollView+EmptyData.h
//  DGInfinity
//
//  Created by myeah on 16/11/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (EmptyData)

- (void)configureEmptyDataSetStyleWithtitle:(NSString *)title
                                description:(NSString *)description
                                      image:(NSString *)image
                                buttonTitle:(NSString *)buttonTitle
                      buttonBackgroundImage:(NSString *)buttonBackgroundImage
                          didTapButtonBlock:(void(^)(void))didTapButtonBlock
                            didTapViewBlock:(void(^)(void))didTapViewBlock;

- (void)configureNoNetStyleWithdidTapButtonBlock:(void(^)(void))didTapButtonBlock
                                 didTapViewBlock:(void(^)(void))didTapViewBlock;

- (void)reloadEmptyDataSet;

@end
