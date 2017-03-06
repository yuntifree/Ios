//
//  LaunchGuideViewController.h
//  DGInfinity
//
//  Created by myeah on 16/11/22.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGViewController.h"

typedef void(^goBlock)(void);

@interface LaunchGuideViewController : DGViewController

@property (nonatomic, copy) goBlock block;

@end
