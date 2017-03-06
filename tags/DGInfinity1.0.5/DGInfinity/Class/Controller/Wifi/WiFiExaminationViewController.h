//
//  WiFiExaminationViewController.h
//  DGInfinity
//
//  Created by myeah on 16/11/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGViewController.h"

typedef void(^badgeBlock)(NSInteger deviceCount);

@interface WiFiExaminationViewController : DGViewController

@property (nonatomic, copy) badgeBlock badgeblock;

@end
