//
//  AppDelegate.h
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NetWorkMgrDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

