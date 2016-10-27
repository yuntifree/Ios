//
//  NetworkManager.m
//  DGInfinity
//
//  Created by myeah on 16/10/26.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NetworkManager.h"

@interface NetworkManager ()
{
    Reachability *_reachability;
    NSMutableArray *_observers;
}
@end

@implementation NetworkManager

static NetworkManager *manager = nil;

- (void)dealloc
{
    
}

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reachability = [Reachability reachabilityWithHostName:@"www.yunxingzh.com"];
        _observers = [NSMutableArray array];
    }
    return self;
}

- (void)startNotifier
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReachabilityChanged) name:kReachabilityChangedNotification object:nil];
    [_reachability startNotifier];
}

- (void)stopNotifier
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_reachability stopNotifier];
}

- (void)networkReachabilityChanged
{
    NetworkStatus ns = [self currentReachabilityStatus];
    @synchronized (_observers) {
        for (id<NetWorkMgrDelegate> delegate in _observers) {
            if ([delegate respondsToSelector:@selector(didNetworkStateChanged:)]) {
                [delegate didNetworkStateChanged:ns];
            }
        }
    }
}

- (NetworkStatus)currentReachabilityStatus
{
    return [_reachability currentReachabilityStatus];
}

- (void)addNetworkObserver:(id<NetWorkMgrDelegate>)delegate
{
    NSUInteger index = [_observers indexOfObjectIdenticalTo:delegate];
    if (index != NSNotFound) {
        return;
    }
    @synchronized (_observers) {
        [_observers addObject:delegate];
    }
}

- (void)removeNetworkObserver:(id<NetWorkMgrDelegate>)delegate
{
    NSUInteger index = [_observers indexOfObjectIdenticalTo:delegate];
    if (index == NSNotFound) {
        return;
    }
    @synchronized (_observers) {
        [_observers removeObjectAtIndex:index];
    }
}

@end
