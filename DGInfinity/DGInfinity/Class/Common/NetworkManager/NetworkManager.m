//
//  NetworkManager.m
//  DGInfinity
//
//  Created by myeah on 16/10/26.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NetworkManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NEHotspotHelper.h>

@interface NetworkManager ()
{
    Reachability *_reachability;
    NSHashTable *_observers;
    NetworkStatus _currentStatus;
    NSString *_lastSSID;
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
        _currentStatus = [_reachability currentReachabilityStatus];
        _observers = [NSHashTable weakObjectsHashTable];
        _lastSSID = nil;
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
    NSString *currentSSID = [Tools getCurrentSSID];
    if (_currentStatus == ns) {
        if (!(ns == ReachableViaWiFi && ![_lastSSID isEqualToString:currentSSID])) {
            //修复wifi切换时，切换过快时，从A到B派发两次change事件的问题
            return;
        }
    }
    _currentStatus = ns;
    _lastSSID = currentSSID;
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

- (BOOL)isWiFi
{
    return _currentStatus == ReachableViaWiFi;
}

- (void)addNetworkObserver:(id<NetWorkMgrDelegate>)delegate
{
    if ([_observers containsObject:delegate]) {
        return;
    }
    @synchronized (_observers) {
        [_observers addObject:delegate];
    }
}

- (void)removeNetworkObserver:(id<NetWorkMgrDelegate>)delegate
{
    if (![_observers containsObject:delegate]) {
        return;
    }
    @synchronized (_observers) {
        [_observers removeObject:delegate];
    }
}

- (void)registerNetworkExtension
{
    if (!IOS9) {
        [self registerNetworkOnlyOneSSIDValidate:WIFISDK_SSID];
    } else {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"✅东莞无线城市WiFi，请点击连接", kNEHotspotHelperOptionDisplayName, nil];
        dispatch_queue_t queue = dispatch_queue_create("com.yunxingzh.ex", 0);
        BOOL success = [NEHotspotHelper registerWithOptions:options queue:queue handler:^(NEHotspotHelperCommand * cmd) {
            if(cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList)
            {
                for (NEHotspotNetwork *network in cmd.networkList)
                {
                    DDDLog(@"----%@",network.SSID);
                    if ([network.SSID isEqualToString:WIFISDK_SSID])
                    {
                        [network setConfidence:kNEHotspotHelperConfidenceHigh];
                        NEHotspotHelperResponse *response = [cmd createResponse:kNEHotspotHelperResultSuccess];
                        [response setNetwork:network];
                        [response deliver];
                    }
                }
            }
        }];
        DDDLog(@"success = %i",success);
    }
}

- (void)registerNetworkOnlyOneSSIDValidate:(NSString *)ssid
{
    [self registerNetwork:@[ssid]];
}

- (void)registerNetwork:(NSArray *)ssidStringArray
{
    CFArrayRef ssidCFArray = (__bridge CFArrayRef)ssidStringArray;
    if(!CNSetSupportedSSIDs(ssidCFArray)) {
        return;
    }
    CFArrayRef interfaces = CNCopySupportedInterfaces();
    for (int i = 0; i < CFArrayGetCount(interfaces); i++) {
        CFStringRef interface = CFArrayGetValueAtIndex(interfaces, i);
        CNMarkPortalOnline(interface);
    }
}

@end
