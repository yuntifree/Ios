//
//  WiFiScanQrcodeViewController.h
//  DGInfinity
//
//  Created by myeah on 16/11/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGViewController.h"

typedef void(^successBlock)(void);

@interface WiFiScanQrcodeViewController : DGViewController

@property (nonatomic, copy) successBlock success;

@end
