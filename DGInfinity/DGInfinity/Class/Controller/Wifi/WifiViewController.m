//
//  WifiViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WifiViewController.h"
#import "BaiduMapVC.h"
#import "WiFiMenuView.h"
#import "WiFiTipView.h"
#import "WiFiCGI.h"
#import "NewsReportModel.h"
#import "WebViewController.h"
#import "NewsReportCell.h"
#import "WiFiFooterView.h"
#import "WiFiSpeedTestViewController.h"
#import "NewsViewController.h"
#import "WiFiScanQrcodeViewController.h"
#import "WiFiExaminationViewController.h"
#import "WiFiConnectTipView.h"

#define Height (kScreenHeight - 20 - 44 - 49)

@interface WifiViewController () <WiFiMenuViewDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UIScrollView *_scrollView;
    WiFiMenuView *_menuView;
    WiFiTipView *_tipView;
    UITableView *_tableView;
    WiFiFooterView *_footerView;
    WiFiConnectTipView *_connectTipView;
    
    NSMutableArray *_newsArray;
    NSDictionary *_frontInfo;
}

@end

@implementation WifiViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _newsArray = [NSMutableArray arrayWithCapacity:3];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_menuView setBackViewImage];
    [_menuView startAnimation];
    if ([Tools getTimeType] == TimeTypeNight) {
        [self.navigationController.navigationBar setBarTintColor:RGB(0x236EC5, 1)];
    } else {
        [self.navigationController.navigationBar setBarTintColor:COLOR(0, 156, 251, 1)];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_menuView stopAnimation];
    [self.navigationController.navigationBar setBarTintColor:COLOR(0, 156, 251, 1)];
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
    
    [self setUpNavItem];
    [self setUpScrollView];
    [self setUpSubViews];
    [self getWeatherAndNews];
}

- (void)setUpNavItem
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 74, 20)];
    label.text = @"东莞无线";
    label.textColor = [UIColor whiteColor];
    label.font = SystemFont(18);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage originalImage:@"wireless_ico_QRcode"] style:UIBarButtonItemStylePlain target:self action:@selector(scanQRcode)];
}

- (void)scanQRcode
{
    [Tools permissionOfCamera:^{
        WiFiScanQrcodeViewController *vc = [WiFiScanQrcodeViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    } noPermission:^(NSString *tip) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:tip preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Tools openSetting];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Height, kScreenWidth, Height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 100;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = COLOR(245, 245, 245, 1);
    [_scrollView addSubview:_tableView];
    
    __weak typeof(self) wself = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [wself returnToFirstPage];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    [header setTitle:@"下拉，回到首页" forState:MJRefreshStateIdle];
    [header setTitle:@"释放，回到首页" forState:MJRefreshStatePulling];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    _tableView.mj_header = header;
    
    _footerView = [[NSBundle mainBundle] loadNibNamed:@"WiFiFooterView" owner:nil options:nil][0];
    _tableView.tableFooterView = _footerView;
    _footerView.block = ^(WiFiFooterType type) {
        [wself handleFooterViewAction:type];
    };
}

- (void)returnToFirstPage
{
    if (_scrollView.contentOffset.y) {
        _scrollView.scrollEnabled = YES;
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [_tableView.mj_header endRefreshing];
    }
}

- (void)handleFooterViewAction:(WiFiFooterType)type
{
    UITabBarController *root = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav = root.viewControllers[1];
    NewsViewController *vc = (NewsViewController *)nav.topViewController;
    switch (type) {
        case WiFiFooterTypeLookForNews:
        case WiFiFooterTypeNews:
        case WiFiFooterTypeVideo:
        {
            root.selectedIndex = 1;
            if (type == WiFiFooterTypeLookForNews || type == WiFiFooterTypeNews) {
                [vc setCurrentPage:0];
            } else {
                [vc setCurrentPage:1];
            }
        }
            break;
        case WiFiFooterTypeBanner:
        {
            WebViewController *vc = [[WebViewController alloc] init];
            vc.url = _frontInfo[@"banner"][@"dst"];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
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
                NSArray *news = data[@"news"];
                if ([news isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *info in news) {
                        NewsReportModel *model = [NewsReportModel createWithInfo:info];
                        [_newsArray addObject:model];
                        if (![_newsArray indexOfObject:model]) {
                            [_menuView setHotNews:model.title];
                        }
                    }
                }
                [_tableView reloadData];
            }
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (void)getFrontInfo
{
    [WiFiCGI getFrontInfo:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                _frontInfo = data;
                [_footerView setFrontInfo:_frontInfo];
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

- (void)openWebWithModel:(NewsReportModel *)model
{
    WebViewController *vc = [[WebViewController alloc] init];
    vc.url = model.dst;
    vc.newsType = NT_REPORT;
    vc.title = model.title;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WiFiMenuViewDelegate
- (void)WiFiMenuViewClick:(WiFiMenuType)type
{
    switch (type) {
        case WiFiMenuTypeSpeedTest:
        {
            WiFiSpeedTestViewController *vc = [[WiFiSpeedTestViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case WiFiMenuTypeMap:
        {
            BaiduMapVC *vc = [[BaiduMapVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case WiFiMenuTypeHot:
        {
            if (_newsArray.count) {
                [self openWebWithModel:_newsArray[0]];
            }
        }
            break;
        case WiFiMenuTypeExamination:
        {
            __weak typeof(_menuView) wmenu = _menuView;
            WiFiExaminationViewController *vc = [[WiFiExaminationViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            vc.badgeblock = ^ (NSInteger deviceCount) {
                [wmenu setDeviceBadge:deviceCount];
            };
        }
            break;
        case WiFiMenuTypeConnect:
        {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!_connectTipView) {
                _connectTipView = [[WiFiConnectTipView alloc] initWithFrame:window.bounds];
            }
            [_connectTipView showInView:window];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView) {
        if (scrollView.contentOffset.y) {
            if (_tipView) {
                [_tipView dismiss];
                _tipView = nil;
            }
            if (_frontInfo == nil) {
                [self getFrontInfo];
            }
            if (scrollView.contentOffset.y == Height) {
                scrollView.scrollEnabled = NO;
            }
        } else {
            if (!_newsArray.count) {
                [self getWeatherAndNews];
            }
        }
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView displayWitMsg:NoDataTip ForDataCount:_newsArray.count];
    return _newsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row < _newsArray.count) {
        cell = [NewsReportCell getNewsReportCell:tableView model:_newsArray[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _newsArray.count) {
        NewsReportModel *model = _newsArray[indexPath.row];
        model.read = YES;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [SApp reportClick:[ReportClickModel createWithReportModel:model]];
        NSURL *url = [NSURL URLWithString:model.dst];
        if ([url.scheme isEqualToString:@"itms"] || [url.scheme isEqualToString:@"itms-apps"]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [self openWebWithModel:model];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _newsArray.count) {
        NewsReportModel *model = _newsArray[indexPath.row];
        if (model.stype == RT_AD) {
            ReportClickModel *rcm = [ReportClickModel createWithReportModel:model];
            rcm.type = RCT_ADSHOW;
            [SApp reportClick:rcm];
        }
    }
}

@end
