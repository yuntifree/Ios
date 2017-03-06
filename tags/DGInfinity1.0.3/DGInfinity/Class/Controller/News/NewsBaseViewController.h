//
//  NewsBaseViewController.h
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/30.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGViewController.h"

@interface NewsBaseViewController : DGViewController

@property (nonatomic, assign) BOOL scrollsToTop;

// 请求参数
@property (nonatomic, assign) NSInteger type;

- (void)loadData;

@end
