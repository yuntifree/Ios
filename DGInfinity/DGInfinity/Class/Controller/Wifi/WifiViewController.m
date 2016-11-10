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
#import "WiFiTipView.h"
#import "WiFiCGI.h"

#define Height (kScreenHeight - 20 - 44 - 49)

@interface WifiViewController () <WIFISpeedViewDelegate, WiFiMenuViewDelegate, UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    WiFiMenuView *_menuView;
    WiFiTipView *_tipView;
}

@property (nonatomic, strong) WiFiSpeedView *speedView;

@end

@implementation WifiViewController

- (WiFiSpeedView *)speedView
{
    if (_speedView == nil) {
        _speedView = [[WiFiSpeedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth * 317 / 375)];
        _speedView.delegate = self;
    }
    return _speedView;
}

- (NSString *)title
{
    return @"无线";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_tipView showInView:_menuView];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpScrollView];
    [self setUpSubViews];
    [self getWeatherAndNews];
}

- (void)setUpScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, Height)];
    _scrollView.contentSize = CGSizeMake(kScreenWidth, Height * 2);
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delaysContentTouches = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
}

- (void)setUpSubViews
{
    _menuView = [[NSBundle mainBundle] loadNibNamed:@"WiFiMenuView" owner:nil options:nil][0];
    _menuView.frame = CGRectMake(0, 0, kScreenWidth, Height);
    _menuView.delegate = self;
    [_scrollView addSubview:_menuView];
    
    _tipView = [[WiFiTipView alloc] initWithFrame:CGRectMake(kScreenWidth - 96, Height - 36, 88, 24)];
}

- (void)getWeatherAndNews
{
    [WiFiCGI getWeatherNews:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *weather = data[@"weather"];
                if ([weather isKindOfClass:[NSDictionary class]]) {
                    [_menuView setWeather:weather];
                }
            }
        } else {
            [self makeToast:res.desc];
        }
    }];
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

#pragma mark - WiFiMenuViewDelegate
- (void)WiFiMenuViewClick:(WiFiMenuType)type
{
    if (type == WiFiMenuTypeSpeedTest) {
        if (![_menuView.subviews containsObject:self.speedView]) {
            self.speedView.alpha = 0;
            [_menuView addSubview:self.speedView];
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
    } else if (type == WiFiMenuTypeMap) {
        BaiduMapVC *vc = [[BaiduMapVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView) {
        if (_tipView) {
            [_tipView dismiss];
            _tipView = nil;
        }
    }
}

@end
