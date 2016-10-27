//
//  AppDelegate.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "AppDelegate.h"
#import "DGTabBarController.h"
#import <IQKeyboardManager.h>
#import "NetworkManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate () <NetWorkMgrDelegate>
{
    UIBackgroundTaskIdentifier _backgroundTaskID;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setUpAttribute];
    
    // wifiSDK
#if !(TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] initEnv:WIFISDK_SSID withWurl:WIFISDK_URL withVNO:WIFISDK_VNOCODE];
    [[UserAuthManager manager] logEnable:YES];
#endif
    
    // keyboardManager
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    // Notifications
    [Tools registerNotification];
    
    // Network
    [[NetworkManager shareManager] startNotifier];
    
    DGTabBarController *root = [[DGTabBarController alloc] init];
    self.window.rootViewController = root;
    
    // autoLogin
    [MSApp autoLogin];
    
    return YES;
}

- (void)setUpAttribute
{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UIView appearance] setExclusiveTouch:YES];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, SystemFont(18), NSFontAttributeName,nil]];
    [[UINavigationBar appearance] setBarTintColor:RGB(0x428be5, 1)];
    
//    [self registerNetwork:WIFISDK_SSID];
}

//- (void)registerNetwork:(NSString *)ssid
//
//{
//    NSString *values[] = {ssid};
//    
//    CFArrayRef arrayRef = CFArrayCreate(kCFAllocatorDefault,(void *)values,
//                                        
//                                        (CFIndex)1, &kCFTypeArrayCallBacks);
//    
//    if( CNSetSupportedSSIDs(arrayRef)) {
//        
//        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//        
//        CNMarkPortalOnline((__bridge CFStringRef)(ifs[0]));
//        
//        DDDLog(@"%@", ifs);
//        
//    }
//}

////注册一个SSID，注意此方法多次调用时，最后一次有效
//- (void)registerNetworkOnlyOneSSIDValidate:(NSString *)ssid
//{
//    [self registerNetwork:@[ssid]];
//}
////注册多个SSID，多次调用，最后一次有效
//- (void)registerNetwork:(NSArray *)ssidStringArray
//{
//    CFArrayRef ssidCFArray = (__bridge CFArrayRef)ssidStringArray;
//    if(!CNSetSupportedSSIDs(ssidCFArray)) {
//        return;
//    }
//    CFArrayRef interfaces = CNCopySupportedInterfaces();
//    for (int i = 0; i < CFArrayGetCount(interfaces); i++) {
//        CFStringRef interface = CFArrayGetValueAtIndex(interfaces, i);
//        CNMarkPortalOnline(interface);
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskID];
        _backgroundTaskID = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NetworkManager shareManager] addNetworkObserver:self];
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[NetworkManager shareManager] removeNetworkObserver:self];
    if (_backgroundTaskID) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskID];
        _backgroundTaskID = UIBackgroundTaskInvalid;
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - NetWorkMgrDelegate
- (void)didNetworkStateChanged:(NetworkStatus)ns
{
    static BOOL userNotifiedOfReachability = NO;
    if (ns == ReachableViaWiFi) {
        if (!userNotifiedOfReachability && [[Tools getCurrentSSID] isEqualToString:WIFISDK_SSID]) {
            [Tools showNotificationMessages:@"点击这里，一键认证东莞无线城市WiFi"];
            userNotifiedOfReachability = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                userNotifiedOfReachability = NO;
            });
        }
    }
}

@end
