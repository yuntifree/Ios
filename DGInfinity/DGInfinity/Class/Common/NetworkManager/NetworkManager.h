//
//  NetworkManager.h
//  DGInfinity
//
//  Created by myeah on 16/10/26.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@protocol NetWorkMgrDelegate <NSObject>

- (void)didNetworkStateChanged:(NetworkStatus)ns;

@end

@interface NetworkManager : NSObject

+ (instancetype)shareManager;
- (void)startNotifier;
- (void)stopNotifier;
- (NetworkStatus)currentReachabilityStatus;
- (void)addNetworkObserver:(id<NetWorkMgrDelegate>)delegate;
- (void)removeNetworkObserver:(id<NetWorkMgrDelegate>)delegate;

@end
