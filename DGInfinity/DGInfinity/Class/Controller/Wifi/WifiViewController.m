//
//  WifiViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WifiViewController.h"
#import "BaiduMapVC.h"
#import "WiFiSpeedView.h"
#import "WiFiMenuView.h"

@interface WifiViewController () <WIFISpeedViewDelegate>
{
    UIScrollView *_scrollView;
}

@property (nonatomic, strong) WiFiSpeedView *speedView;

@end

@implementation WifiViewController

- (WiFiSpeedView *)speedView
{
    if (_speedView == nil) {
        _speedView = [[WiFiSpeedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.888 * kScreenWidth)];
        _speedView.delegate = self;
    }
    return _speedView;
}

- (NSString *)title
{
    return @"无线";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpScrollView];
}

- (void)setUpScrollView
{
    CGFloat height = kScreenHeight - 20 - 44 - 49;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
    _scrollView.contentSize = CGSizeMake(kScreenWidth, height * 2);
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    WiFiMenuView *menuView = [[NSBundle mainBundle] loadNibNamed:@"WiFiMenuView" owner:nil options:nil][0];
    menuView.frame = CGRectMake(0, 0, kScreenWidth, height);
    [_scrollView addSubview:menuView];
}

/*
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
//    DDDLog(@"username = %@,wifipass = %@",SApp.username, SApp.wifipass);
//#if !(TARGET_IPHONE_SIMULATOR)
//    [[UserAuthManager manager] doRegisterWithUserName:SApp.username andPassWord:SApp.wifipass andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
//        if (!error) {
//            NSString *retflag = response[@"retflag"];
//            if ([retflag isEqualToString:@"0"]) {
//                [self showHint:@"注册成功"];
//            } else {
//                [self showHint:response[@"reason"]];
//            }
//        } else {
//            [self showHint:[NSString stringWithFormat:@"请求失败 %@", error.description]];
//        }
//    }];
//#endif
    if (!_nameField.text.length || !_passwordField.text.length || !_codeField.text.length) return;
    [SVProgressHUD show];
    [AccountCGI doRegister:_nameField.text password:_passwordField.text code:_codeField.text.integerValue complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                SApp.username = _nameField.text;
                [MSApp setUserInfo:data];
#if !(TARGET_IPHONE_SIMULATOR)
                [[UserAuthManager manager] doRegisterWithUserName:SApp.username andPassWord:SApp.wifipass andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
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
#else
                [self showHint:@"注册成功"];
#endif
            }
        } else {
            [self showHint:res.desc];
        }
    }];
}

- (void)gotoLogon
{
    DDDLog(@"username = %@, wifipass = %@",SApp.username, SApp.wifipass);
#if !(TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] doLogon:SApp.username andPassWord:SApp.wifipass andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
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
#if !(TARGET_IPHONE_SIMULATOR)
                [[UserAuthManager manager] checkEnvironmentBlock:^(ENV_STATUS status) {
                    DDDLog(@"-----%i",status);
                    [self gotoLogon];
                }];
#else
                [self showHint:@"登录成功"];
#endif
            }
        } else {
            [self showHint:res.desc];
        }
    }];
}

- (IBAction)doLogout:(id)sender {
    if (!SApp.username.length) return;
    [SVProgressHUD show];
    [AccountCGI logout:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
#if !(TARGET_IPHONE_SIMULATOR)
            [[UserAuthManager manager] doLogout:SApp.username andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
                if (!error) {
                    NSString *retflag = response[@"retflag"];
                    if ([retflag isEqualToString:@"0"]) {
                        [self showHint:@"登出成功"];
                        [MSApp destory];
                    } else {
                        [self showHint:response[@"reason"]];
                    }
                } else {
                    [self showHint:[NSString stringWithFormat:@"请求失败 %@", error.description]];
                }
            }];
#else
            [self showHint:@"登出成功"];
            [MSApp destory];
#endif
        } else {
            [self showHint:res.desc];
        }
    }];
}
*/

#pragma mark - WiFi Function
- (IBAction)searchNearbyWifi:(id)sender {
    BaiduMapVC *vc = [[BaiduMapVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)speedTest:(id)sender {
    if (![self.view.subviews containsObject:self.speedView]) {
        self.speedView.alpha = 0;
        [self.view addSubview:self.speedView];
        [UIView animateWithDuration:0.5 animations:^{
            self.speedView.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.speedView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.speedView removeFromSuperview];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WIFISpeedViewDelegate
- (void)touchCloseBtn
{
    self.navigationController.tabBarController.selectedIndex = 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.speedView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.speedView removeFromSuperview];
    }];
}

@end
