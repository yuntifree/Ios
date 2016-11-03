//
//  LoginViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/3.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "LoginViewController.h"
#import "AccountCGI.h"

@interface LoginViewController ()
{
    __weak IBOutlet UITextField *_nameField;
    __weak IBOutlet UITextField *_passwordField;
    __weak IBOutlet UITextField *_codeField;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)getCode:(id)sender {
    if (!_nameField.text.length) return;
    [SVProgressHUD show];
    [AccountCGI getPhoneCode:_nameField.text type:0 complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            [self showHint:@"获取成功"];
        } else {
            [self showHint:res.desc];
        }
    }];
}

- (IBAction)doRegister:(id)sender {
    if (!_nameField.text.length || !_passwordField.text.length || !_codeField.text.length) return;
    [SVProgressHUD show];
    [AccountCGI doRegister:_nameField.text password:_passwordField.text code:_codeField.text.integerValue complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                SApp.username = _nameField.text;
                [MSApp setUserInfo:data];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNC_LOGIN object:nil];
            }
        } else {
            [self showHint:res.desc];
        }
    }];
}

- (IBAction)doLogon:(id)sender {
    if (!_nameField.text.length || !_passwordField.text.length) return;
    [SVProgressHUD show];
    [AccountCGI login:_nameField.text password:_passwordField.text complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                SApp.username = _nameField.text;
                [MSApp setUserInfo:data];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNC_LOGIN object:nil];
            }
        } else {
            [self showHint:res.desc];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
