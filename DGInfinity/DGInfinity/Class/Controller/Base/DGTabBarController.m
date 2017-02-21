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
#import "MeViewController.h"

@interface DGTabBarController () <UITabBarControllerDelegate>

@end

@implementation DGTabBarController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        
        DGNavigationViewController *wifiNav = [[DGNavigationViewController alloc] initWithRootViewController:[WifiViewController new]];
        [wifiNav.tabBarItem setImage:@"tab_icon_wifi_gray" selectedImage:@"tab_icon_wifi_blue"];
        wifiNav.tabBarItem.title = @"无线";
        
        DGNavigationViewController *newsNav = [[DGNavigationViewController alloc] initWithRootViewController:[NewsViewController new]];
        [newsNav.tabBarItem setImage:@"tab_ico_headlines_gray" selectedImage:@"tab_ico_headlines_blue"];
        newsNav.tabBarItem.title = @"头条";
        
        DGNavigationViewController *serviceNav = [[DGNavigationViewController alloc] initWithRootViewController:[ServiceViewController new]];
        [serviceNav.tabBarItem setImage:@"tab_ico_find_gray" selectedImage:@"tab_ico_find_blue"];
        serviceNav.tabBarItem.title = @"发现";
        
        DGNavigationViewController *meNav = [[DGNavigationViewController alloc] initWithRootViewController:[MeViewController new]];
        [meNav.tabBarItem setImage:@"tab_ico_service_gray" selectedImage:@"tab_ico_my_blue"];
        meNav.tabBarItem.title = @"我";
        
#ifdef DEBUG
        DGNavigationViewController *shoppingNav = [[DGNavigationViewController alloc] initWithRootViewController:[ShoppingViewController new]];
        [shoppingNav.tabBarItem setImage:@"tab_ico_buy_gray" selectedImage:@"tab_ico_buy_blue"];
        self.viewControllers = @[wifiNav, newsNav, serviceNav, meNav, shoppingNav];
#else
        self.viewControllers = @[wifiNav, newsNav, serviceNav, meNav];
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
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == tabBarController.selectedIndex) {
        return NO;
    } else {
        return YES;
    }
}

@end
