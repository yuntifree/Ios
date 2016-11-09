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
#import <AFNetworking.h>

@interface DGTabBarController ()

@end

@implementation DGTabBarController

- (instancetype)init
{
    self = [super init];
    if (self) {
        DGNavigationViewController *wifiNav = [[DGNavigationViewController alloc] initWithRootViewController:[WifiViewController new]];
        [wifiNav.tabBarItem setImage:@"tab_icon_wifi_gray" selectedImage:@"tab_icon_wifi_blue"];
        DGNavigationViewController *newsNav = [[DGNavigationViewController alloc] initWithRootViewController:[NewsViewController new]];
        [newsNav.tabBarItem setImage:@"tab_ico_headlines_gray" selectedImage:@"tab_ico_headlines_blue"];
        DGNavigationViewController *serviceNav = [[DGNavigationViewController alloc] initWithRootViewController:[ServiceViewController new]];
        [serviceNav.tabBarItem setImage:@"tab_ico_service_gray" selectedImage:@"tab_ico_service_green"];
        DGNavigationViewController *shoppingNav = [[DGNavigationViewController alloc] initWithRootViewController:[ShoppingViewController new]];
        [shoppingNav.tabBarItem setImage:@"tab_ico_buy_gray" selectedImage:@"tab_icon_buy_blue"];
        self.viewControllers = @[wifiNav, newsNav, serviceNav, shoppingNav];
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
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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

@end
