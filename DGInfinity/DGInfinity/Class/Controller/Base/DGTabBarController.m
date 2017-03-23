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
        [newsNav.tabBarItem setImage:@"tab_ico_entertainment_gray" selectedImage:@"tab_ico_entertainment_blue"];
        newsNav.tabBarItem.title = @"娱乐";
        
        DGNavigationViewController *serviceNav = [[DGNavigationViewController alloc] initWithRootViewController:[ServiceViewController new]];
        [serviceNav.tabBarItem setImage:@"tab_ico_life_gray" selectedImage:@"tab_ico_life_blue"];
        serviceNav.tabBarItem.title = @"生活";
        
        DGNavigationViewController *meNav = [[DGNavigationViewController alloc] initWithRootViewController:[MeViewController new]];
        [meNav.tabBarItem setImage:@"tab_ico_my_gray" selectedImage:@"tab_ico_my_blue"];
        meNav.tabBarItem.title = @"我";
        
        self.viewControllers = @[wifiNav, newsNav, serviceNav, meNav];
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
        switch (index) {
            case 0:
                MobClick(@"tab_Index");
                break;
            case 1:
                MobClick(@"tab_entertainment");
            case 2:
                MobClick(@"tab_life");
            case 3:
                MobClick(@"tab_me");
                break;
            default:
                break;
        }
        return YES;
    }
}

@end
