//
//  WiFiSpeedTestViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/14.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiSpeedTestViewController.h"
#import "WiFiSpeedView.h"
#import "NetworkManager.h"

@implementation WiFiSpeedTestViewController

- (NSString *)title
{
    return @"WiFi测速";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[NetworkManager shareManager] isWiFi]) {
        [self showAlertWithTitle:@"提示" message:@"您正在使用移动网络，WiFi测速会产生一定的流量消耗" cancelTitle:@"知道了" cancelHandler:nil defaultTitle:nil defaultHandler:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = COLOR(0, 156, 251, 1);
    
    WiFiSpeedView *spView = [[WiFiSpeedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 350)];
    spView.center = CGPointMake(self.view.center.x, self.view.center.y - 64);
    [self.view addSubview:spView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
