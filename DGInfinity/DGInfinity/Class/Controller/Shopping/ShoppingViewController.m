//
//  ShoppingViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ShoppingViewController.h"
#import "AccountCGI.h"
#import <AFHTTPSessionManager.h>

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
//    [SVProgressHUD show];
//    [AccountCGI logout:^(DGCgiResult *res) {
//        [SVProgressHUD dismiss];
//        if (E_OK == res._errno) {
//            [MSApp destory];
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNC_LOGOUT object:nil];
//        } else {
//            [self makeToast:res.desc];
//        }
//    }];
#if (!TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] doLogout:SApp.username andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
        if (!error) {
            NSDictionary *head = response[@"head"];
            if ([head isKindOfClass:[NSDictionary class]]) {
                NSString *retflag = head[@"retflag"];
                if ([retflag isEqualToString:@"0"]) {
                    [self makeToast:@"下线成功"];
                } else {
                    [self makeToast:head[@"reason"]];
                }
            }
        } else {
            [self makeToast:error.description];
        }
    }];
#endif
}

- (IBAction)payTest:(UIButton *)sender {
    NSString *channel = nil;
    if (sender.tag == 1000) {
        channel = @"wx";
    } else if (sender.tag == 1001) {
        channel = @"alipay";
    } else {
        return;
    }
    
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 测试1分钱
    NSDictionary *params = @{@"channel": channel,
                             @"amount": @"1"};
    
    [manager POST:PingppUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        if (responseObject && [responseObject isKindOfClass:[NSData class]]) {
            NSString *charge = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            [Pingpp createPayment:charge appURLScheme:PingppUrlScheme withCompletion:^(NSString *result, PingppError *error) {
                if ([result isEqualToString:@"success"]) {
                    [self makeToast:@"支付成功"];
                } else {
                    [self makeToast:[error getMsg]];
                }
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self makeToast:error.description];
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
