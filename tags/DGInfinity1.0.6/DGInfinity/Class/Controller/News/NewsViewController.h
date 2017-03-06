//
//  NewsViewController.h
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGViewController.h"

@interface NewsViewController : DGViewController

@property (nonatomic, assign) NSInteger defaultType;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, assign) BOOL jumped; // 是否由别的页面跳转而来

@end
