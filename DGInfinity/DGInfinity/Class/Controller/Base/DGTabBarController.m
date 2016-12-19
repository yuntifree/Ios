//
//  DGTabBarController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGTabBarController.h"
#import "DGNavigationViewController.h"
#import "WifiViewController.h"
#import "NewsViewController.h"
#import "ServiceViewController.h"
#import "ShoppingViewController.h"
#import "UITabBarItem+Setup.h"
#import "WebViewController.h"
#import "ActivityCGI.h"

@interface DGTabBarController () <UITabBarControllerDelegate>

@property (nonatomic, assign) NSInteger lastIndex;

@end

@implementation DGTabBarController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lastIndex = 0;
        self.delegate = self;
        
        DGNavigationViewController *wifiNav = [[DGNavigationViewController alloc] initWithRootViewController:[WifiViewController new]];
        [wifiNav.tabBarItem setImage:@"tab_icon_wifi_gray" selectedImage:@"tab_icon_wifi_blue"];
        wifiNav.tabBarItem.title = @"无线";
        DGNavigationViewController *newsNav = [[DGNavigationViewController alloc] initWithRootViewController:[NewsViewController new]];
        [newsNav.tabBarItem setImage:@"tab_ico_headlines_gray" selectedImage:@"tab_ico_headlines_blue"];
        DGNavigationViewController *serviceNav = [[DGNavigationViewController alloc] initWithRootViewController:[ServiceViewController new]];
        [serviceNav.tabBarItem setImage:@"tab_ico_service_gray" selectedImage:@"tab_ico_service_green"];
        serviceNav.tabBarItem.title = @"服务";
        
        DGNavigationViewController *activityNav = [[DGNavigationViewController alloc] initWithRootViewController:[DGViewController new]];
        [activityNav.tabBarItem setImage:@"tab_ico_buy_gray" selectedImage:@"tab_ico_buy_blue"];
        activityNav.tabBarItem.title = @"活动";
        
#ifdef DEBUG
        DGNavigationViewController *shoppingNav = [[DGNavigationViewController alloc] initWithRootViewController:[ShoppingViewController new]];
        [shoppingNav.tabBarItem setImage:@"tab_ico_buy_gray" selectedImage:@"tab_ico_buy_blue"];
        self.viewControllers = @[wifiNav, newsNav, serviceNav, activityNav, shoppingNav];
#else
        self.viewControllers = @[wifiNav, newsNav, serviceNav, activityNav];
#endif
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return [self.selectedViewController.childViewControllers.lastObject shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.selectedViewController.childViewControllers.lastObject supportedInterfaceOrientations];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    self.lastIndex = tabBarController.selectedIndex;
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([tabBarController.viewControllers indexOfObject:viewController] == 3) {
        [SVProgressHUD show];
        [ActivityCGI getActivity:^(DGCgiResult *res) {
            [SVProgressHUD dismiss];
            if (E_OK == res._errno) {
                NSDictionary *data = res.data[@"data"];
                if ([data isKindOfClass:[NSDictionary class]]) {
                    WebViewController *vc = [[WebViewController alloc] init];
                    vc.url = data[@"dst"];
                    vc.title = data[@"title"];
                    vc.changeTitle = NO;
                    DGNavigationViewController *nav = (DGNavigationViewController *)viewController;
                    [nav pushViewController:vc animated:NO];
                    __weak typeof(self) wself = self;
                    vc.pop = ^ {
                        wself.selectedIndex = wself.lastIndex;
                    };
                }
            } else {
                self.selectedIndex = self.lastIndex;
                [self makeToast:res.desc];
            }
        }];
    }
}
@end
