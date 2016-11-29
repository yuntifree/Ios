//
//  ShoppingViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ShoppingViewController.h"
#import "AccountCGI.h"

@interface ShoppingViewController ()

@end

@implementation ShoppingViewController

- (NSString *)title
{
    return @"抢购";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)logout:(id)sender {
    if (!SApp.username.length) return;
    [SVProgressHUD show];
    [AccountCGI logout:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            [MSApp destory];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNC_LOGOUT object:nil];
        } else {
            [self makeToast:res.desc];
        }
    }];
//    [[UserAuthManager manager] doLogout:SApp.username andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
//        if (!error) {
//            NSDictionary *head = response[@"head"];
//            if ([head isKindOfClass:[NSDictionary class]]) {
//                NSString *retflag = head[@"retflag"];
//                if ([retflag isEqualToString:@"0"]) {
//                    [self makeToast:@"下线成功"];
//                } else {
//                    [self makeToast:head[@"reason"]];
//                }
//            }
//        } else {
//            [self makeToast:error.description];
//        }
//    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
