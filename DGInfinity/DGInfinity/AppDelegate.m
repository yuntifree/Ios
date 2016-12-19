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
#import "LoginViewController.h"
#import "AnimationManager.h"
#import "LaunchGuideViewController.h"
#import "DGNavigationViewController.h"
#import "MiPushSDK.h"

@interface AppDelegate () <NetWorkMgrDelegate, BMKGeneralDelegate, MiPushSDKDelegate, UNUserNotificationCenterDelegate>
{
    UIBackgroundTaskIdentifier _backgroundTaskID;
}
@end

@implementation AppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRootViewController) name:KNC_LOGIN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRootViewController) name:KNC_LOGOUT object:nil];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self setUpAttribute];
    
    // wifiSDK
#if !(TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] initEnv:WIFISDK_SSID withWurl:WIFISDK_URL withVNO:WIFISDK_VNOCODE];
    [[UserAuthManager manager] logEnable:NO];
#endif
    
    // keyboardManager
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    // Network
    [[NetworkManager shareManager] startNotifier];
    [[NetworkManager shareManager] registerNetworkExtension];
    
    // UMeng
    [MobClick setAppVersion:XcodeAppVersion];
    UMConfigInstance.appKey = UMengAppKey;
    [MobClick startWithConfigure:UMConfigInstance];
    
    // BaiduMap
    [[BaiduMapSDK shareBaiduMapSDK] startUserLocationService];
    BOOL ret = [[[BMKMapManager alloc] init] start:BaiduMapAppKey generalDelegate:self];
    if (!ret) {
        DDDLog(@"manager start failed!");
    }
    
    // MiPush
    [MiPushSDK registerMiPush:self type:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound connect:YES];
    
    // RootViewController
    [self setRootViewController];
    
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
    [[UINavigationBar appearance] setBarTintColor:COLOR(0, 156, 251, 1)];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)setRootViewController
{
    CAAnimation *animation = [self.window.layer animationForKey:@"changeRoot"];
    if (!animation) {
        animation = [AnimationManager changeRootAnimation];
        [self.window.layer addAnimation:animation forKey:@"changeRoot"];
    }
    UIViewController *root;
    if (!SApp.appVersion || ![SApp.appVersion isEqualToString:XcodeAppVersion]) {
        __weak typeof(self) wself = self;
        root = [[LaunchGuideViewController alloc] init];
        ((LaunchGuideViewController *)root).block = ^ {
            SApp.appVersion = XcodeAppVersion;
            [wself setRootViewController];
        };
    } else {
        if (SApp.uid) {
            root = [[DGTabBarController alloc] init];
        } else {
            root = [[DGNavigationViewController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
        }
    }
    self.window.rootViewController = root;
}

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

// iOS8及以下
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    return [Pingpp handleOpenURL:url withCompletion:nil];
}

// iOS9及以上
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    return [Pingpp handleOpenURL:url withCompletion:nil];
}

#pragma mark - 注册push服务.
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 注册APNS成功, 注册deviceToken
    DDDLog(@"推送服务注册成功");
    [MiPushSDK bindDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    // 注册APNS失败.
    DDDLog(@"注册推送服务失败：%@",err.description);
}

#pragma mark - Local And Push Notification
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 当同时启动APNs与内部长连接时, 把两处收到的消息合并. 通过miPushReceiveNotification返回
    [MiPushSDK handleReceiveRemoteNotification:userInfo];
}

// iOS10新加入的回调方法
// 应用在前台收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    //    completionHandler(UNNotificationPresentationOptionAlert);
}

// 点击通知进入应用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    completionHandler();
}

#pragma mark - MiPushSDKDelegate
- (void)miPushRequestSuccWithSelector:(NSString *)selector data:(NSDictionary *)data
{
    if ([selector isEqualToString:@"bindDeviceToken:"]) {
        [SApp setMiPush];
    }
}

- (void)miPushRequestErrWithSelector:(NSString *)selector error:(int)error data:(NSDictionary *)data
{
    DDDLog(@"小米推送请求失败：%@, errcode = %d", selector, error);
}

/**
 *  当App启动并运行在前台时，SDK内部会运行一个Socket长连接到Server端，以接收消息推送。
 *  长连接接收到的消息。消息格式跟APNs格式一样。
 */
- (void)miPushReceiveNotification:(NSDictionary *)data
{
    DDDLog(@"收到的推送消息为：%@",data);
}

#pragma mark - NetWorkMgrDelegate
- (void)didNetworkStateChanged:(NetworkStatus)ns
{
    static BOOL userNotifiedOfReachability = NO;
    if (ns == ReachableViaWiFi) {
        if (!userNotifiedOfReachability && [[Tools getCurrentSSID] isEqualToString:WIFISDK_SSID]) {
            [Tools showNotificationMessages:@"点击这里，一键认证东莞无限城市WiFi"];
            userNotifiedOfReachability = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                userNotifiedOfReachability = NO;
            });
        }
    }
}

#pragma mark - BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        DDDLog(@"联网成功");
    } else {
        DDDLog(@"onGetNetworkState %d", iError);
    }
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        DDDLog(@"授权成功");
    } else {
        DDDLog(@"onGetPermissionState %d", iError);
    }
}

@end
