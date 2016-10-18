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

@interface DGTabBarController ()

@end

@implementation DGTabBarController

- (instancetype)init
{
    self = [super init];
    if (self) {
        DGNavigationViewController *wifiNav = [[DGNavigationViewController alloc] initWithRootViewController:[WifiViewController new]];
        DGNavigationViewController *newsNav = [[DGNavigationViewController alloc] initWithRootViewController:[NewsViewController new]];
        DGNavigationViewController *serviceNav = [[DGNavigationViewController alloc] initWithRootViewController:[ServiceViewController new]];
        DGNavigationViewController *shoppingNav = [[DGNavigationViewController alloc] initWithRootViewController:[ShoppingViewController new]];
        self.viewControllers = @[wifiNav, newsNav, serviceNav, shoppingNav];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
