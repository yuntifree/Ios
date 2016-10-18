//
//  WifiViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WifiViewController.h"

#define WIFISDK_TIMEOUT  5 * 1000

@interface WifiViewController ()
{
    __weak IBOutlet UITextField *_nameField;
    __weak IBOutlet UITextField *_passwordField;
    
}
@end

@implementation WifiViewController

- (NSString *)title
{
    return @"无线";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)doRegister:(id)sender {
    if (!_nameField.text.length || !_passwordField.text.length) return;
    [SVProgressHUD show];
#if !(TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] doRegisterWithUserName:_nameField.text andPassWord:_passwordField.text andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSString *retflag = response[@"retflag"];
            if ([retflag isEqualToString:@"0"]) {
                [self showHint:@"注册成功"];
            } else {
                [self showHint:response[@"reason"]];
            }
        } else {
            [self showHint:[NSString stringWithFormat:@"请求失败 %@", error.description]];
        }
    }];
#endif
}

- (IBAction)doLogon:(id)sender {
    if (!_nameField.text.length || !_passwordField.text.length) return;
    [SVProgressHUD show];
#if !(TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] doLogon:_nameField.text andPassWord:_passwordField.text andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSString *retflag = response[@"retflag"];
            if ([retflag isEqualToString:@"0"]) {
                [self showHint:@"认证成功"];
            } else {
                [self showHint:response[@"reason"]];
            }
        } else {
            [self showHint:[NSString stringWithFormat:@"请求失败 %@", error.description]];
        }
    }];
#endif
}

- (IBAction)doLogout:(id)sender {
    if (!_nameField.text.length || !_passwordField.text.length) return;
    [SVProgressHUD show];
#if !(TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] doLogout:_nameField.text andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSString *retflag = response[@"retflag"];
            if ([retflag isEqualToString:@"0"]) {
                [self showHint:@"登出成功"];
            } else {
                [self showHint:response[@"reason"]];
            }
        } else {
            [self showHint:[NSString stringWithFormat:@"请求失败 %@", error.description]];
        }
    }];
#endif
}

- (void)showHint:(NSString *)hint
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:hint message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
