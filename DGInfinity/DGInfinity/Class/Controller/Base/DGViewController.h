//
//  DGViewController.h
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGViewController : UIViewController

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *closeBtn;

- (void)setUpBackItem;
- (void)setUpCloseItem;
- (void)backBtnClick:(id)sender;
- (void)closeBtnClick:(id)sender;
- (void)gotoNewsTabWithType:(NSInteger)type;
- (void)gotoNewsTabWithDst:(NSString *)dst;

@end
