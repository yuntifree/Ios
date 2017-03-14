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
#import "LoginViewController.h"
#import "AnimationManager.h"
#import "LaunchGuideViewController.h"
#import "DGNavigationViewController.h"
#import "MiPushSDK.h"
#import "WebViewController.h"
#import "LaunchGifViewController.h"

@interface AppDelegate () <NetWorkMgrDelegate, BMKGeneralDelegate, MiPushSDKDelegate, UNUserNotificationCenterDelegate>
{
    UIBackgroundTaskIdentifier _backgroundTaskID;
    BOOL _isBackgroundMode; // 是否是点击推送栏
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
        _isBackgroundMode = NO;
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
    
    // autoLogin
    [MSApp autoLogin];
    
    // RootViewController
    [self setRootViewController];
    
    // App 被 NetworkExtension 被动启动时，applicationState == UIApplicationStateBackground
    if (application.applicationState == UIApplicationStateBackground) {
        SApp.beWakened = YES;
    }
    
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
    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
}

- (void)setRootViewController
{
    static BOOL launchGif = NO;
    CAAnimation *animation = [self.window.layer animationForKey:@"changeRoot"];
    if (!animation) {
        animation = [AnimationManager changeRootAnimation];
        [self.window.layer addAnimation:animation forKey:@"changeRoot"];
    }
    UIViewController *root;
    if (!launchGif) {
        launchGif = YES;
        root = [[LaunchGifViewController alloc] init];
    } else {
        if (!SApp.appVersion || ![SApp.appVersion isEqualToString:XcodeAppVersion]) {
            __weak typeof(self) wself = self;
            root = [[LaunchGuideViewController alloc] init];
            ((LaunchGuideViewController *)root).block = ^ {
                SApp.appVersion = XcodeAppVersion;
                [wself setRootViewController];
            };
        } else {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                // BaiduMap
                [[BaiduMapSDK shareBaiduMapSDK] startUserLocationService];
                BOOL ret = [[[BMKMapManager alloc] init] start:BaiduMapAppKey generalDelegate:self];
                if (!ret) {
                    DDDLog(@"manager start failed!");
                }
                
                // MiPush
                [MiPushSDK registerMiPush:self type:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound connect:YES];
            });
            
            if (SApp.uid) {
                root = [[DGTabBarController alloc] init];
                [SApp setMiPush];
            } else {
                root = [[DGNavigationViewController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
            }
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
    [[NetworkManager shareManager] addNetworkObserver:self];
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

// iOS10之前点击通知栏进入应用
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 当同时启动APNs与内部长连接时, 把两处收到的消息合并. 通过miPushReceiveNotification返回
    _isBackgroundMode = YES;
    [MiPushSDK handleReceiveRemoteNotification:userInfo];
}

// iOS10新加入的回调方法
// 应用在前台收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        _isBackgroundMode = NO;
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
//    completionHandler(UNNotificationPresentationOptionAlert);
}

// 点击通知进入应用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        _isBackgroundMode = YES;
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    completionHandler();
}

#pragma mark - MiPushSDKDelegate
- (void)miPushRequestSuccWithSelector:(NSString *)selector data:(NSDictionary *)data
{
    DDDLog(@"小米推送请求成功：%@, data = %@", selector, data);
    // 成功绑定DeviceToken
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
    if (!_isBackgroundMode) return;
    _isBackgroundMode = NO;
    NSString *payload = data[@"payload"];
    NSDictionary *json = [Tools jsonStringToDictionary:payload];
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSInteger type = [json[@"type"] integerValue];
        switch (type) {
            case 1: // 新增模块推广 跳转到首页
            {
                
            }
                break;
            case 2: // 活动推广 跳转到活动页
            {
                NSString *dst = json[@"dst"];
                if ([dst isKindOfClass:[NSString class]] && dst.length) {
                    DGNavigationViewController *navigationVC = nil;
                    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
                    if ([rootVC isKindOfClass:[DGNavigationViewController class]]) {
                        navigationVC = (DGNavigationViewController *)rootVC;
                    } else if ([rootVC isKindOfClass:[DGTabBarController class]]) {
                        DGTabBarController *tabVC = (DGTabBarController *)rootVC;
                        navigationVC = tabVC.selectedViewController;
                    }
                    if (navigationVC) {
                        WebViewController *vc = [WebViewController new];
                        vc.url = dst;
                        [navigationVC pushViewController:vc animated:YES];
                    }
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
