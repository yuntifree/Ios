//
//  SettingFooterView.h
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OnTapAgreement)(void);

@interface SettingFooterView : UIView

@property (nonatomic, copy) OnTapAgreement tap;

@end
