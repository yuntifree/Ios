//
//  WebViewController.h
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGViewController.h"

typedef NS_ENUM(NSInteger, WebItemType) {
    ITEMTYPE_BACK = 0,
    ITEMTYPE_CLOSE = 1
};

@interface WebViewController : DGViewController

@property (nonatomic, copy) NSString *url;

@end
