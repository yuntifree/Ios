//
//  WebViewController.h
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGViewController.h"

typedef void(^Pop)(void);

@interface WebViewController : DGViewController

@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NewsType newsType;
@property (nonatomic, copy) Pop pop;
@property (nonatomic, assign) BOOL changeTitle;

@end
