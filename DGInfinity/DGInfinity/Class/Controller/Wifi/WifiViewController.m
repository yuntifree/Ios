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
#import "WiFiCGI.h"
#import "NewsReportModel.h"
#import "WebViewController.h"
#import "NewsReportCell.h"
#import "WiFiSpeedTestViewController.h"
#import "NewsViewController.h"
#import "WiFiScanQrcodeViewController.h"
#import "WiFiExaminationViewController.h"
#import "WiFiConnectTipView.h"
#import "WiFiWelfareViewController.h"
#import "NetworkManager.h"
#import "DGSplashView.h"
#import <AFNetworking.h>
#import "CheckUpdateView.h"
#import "AccountCGI.h"
#import "LeftUserinfoView.h"

@interface WifiViewController ()
<
WiFiMenuViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
NetWorkMgrDelegate
>
{
    
    __weak IBOutlet UIView *_topView;
    __weak IBOutlet UITableView *_tableView;
    WiFiMenuView *_menuView;
    WiFiConnectTipView *_connectTipView;
    LeftUserinfoView *_leftUserinfoView;
    
    NSMutableArray *_newsArray;
    NSString *_weatherUrl;
    NSString *_noticeContent;
    NSString *_noticeUrl;
}

@property (nonatomic, assign) BOOL isHiddenStatusBar;

@end

@implementation WifiViewController

- (void)dealloc
{
    [[NetworkManager shareManager] removeNetworkObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isHiddenStatusBar = NO;
        _newsArray = [NSMutableArray arrayWithCapacity:3];
        _weatherUrl = WeatherURL;
        [[NetworkManager shareManager] addNetworkObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo) name:kNCModHead object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserInfo) name:kNCModNickname object:nil];
    }
    return self;
}

- (void)refreshUserInfo
{
    [_leftUserinfoView refreshUserinfo];
}

- (void)willEnterForeground
{
#if (!TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] checkEnvironmentBlock:^(ENV_STATUS status) {
        if (status == ENV_NOT_WIFI) {
            if ([[Tools getCurrentSSID] isEqualToString:WIFISDK_SSID]) {
                // 已经portal认证
                [_menuView setConnectBtnStatus:ConnectStatusConnected];
            } else {
                // 别的网络（WiFi或者4G）
                if ([[NetworkManager shareManager] isWiFi]) {
                    [_menuView setConnectBtnStatus:ConnectStatusConnected];
                } else {
                    [_menuView searchNearbyAps];
                }
            }
        } else if (status == ENV_LOGIN) {
            // 已经通过SDK认证
            [_menuView setConnectBtnStatus:ConnectStatusConnected];
        } else if (status == ENV_NOT_LOGIN) {
            [self doLogon];
        } else {
            [_menuView setConnectBtnStatus:ConnectStatusSearch];
        }
    }];
#endif
    if (SApp.beWakened) {
        SApp.beWakened = NO;
        [self showSplashView];
    }
}

- (void)doLogon
{
    [_menuView setConnectBtnStatus:ConnectStatusConnecting];
    [AccountCGI ConnectWifi:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            
        } else {
            [_menuView setConnectBtnStatus:ConnectStatusNotConnect];
            [self makeToast:res.desc];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_menuView setBackViewImage];
    [_menuView startAnimation];
    [_leftUserinfoView refreshUserinfo];
    if ([Tools getTimeType] == TimeTypeNight) {
        [self.navigationController.navigationBar setBarTintColor:RGB(0x236EC5, 1)];
    } else {
        [self.navigationController.navigationBar setBarTintColor:COLOR(0, 156, 251, 1)];
    }
}

- (void)showSplashView
{
    NSString *dateStr = [NSDate formatStringWithDate:[NSDate date]];
    if (SApp.splashExpire && [SApp.splashExpire compare:dateStr] != NSOrderedAscending && [Tools containsImageForKey:SApp.splashImage]) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        DGSplashView *splash = [[DGSplashView alloc] initWithImage:[Tools getImageForKey:SApp.splashImage] dst:SApp.splashDst title:SApp.splashTitle];
        [window addSubview:splash];
        _isHiddenStatusBar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        __weak typeof(self) wself = self;
        splash.action = ^(enum SplashActionType type, NSString *dst, NSString *title) {
            if (type == SplashActionTypeDismiss) {
                wself.isHiddenStatusBar = NO;
                [wself setNeedsStatusBarAppearanceUpdate];
            } else if (type == SplashActionTypeGet) {
                WebViewController *vc = [[WebViewController alloc] init];
                vc.url = dst;
                vc.title = title;
                [wself.navigationController pushViewController:vc animated:YES];
            } else if (type == SplashActionSkipOrCountDown) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wself showCheckUpdataView];
                });
            }
        };
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
    [self showCheckUpdataView];
}

- (void)showCheckUpdataView
{
    static BOOL isChecked = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!isChecked && ![self containSplashView]) {
            isChecked = YES;
            [self checkUpdate];
        }
    });
}

- (BOOL)containSplashView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    __block BOOL isContained = NO;
    [window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[DGSplashView class]]) {
            isContained = YES;
            *stop = YES;
        }
    }];
    return isContained;
}

- (void)checkUpdate
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:CheckUpdateURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSData class]]) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([dict isKindOfClass:[NSDictionary class]]) {
                NSArray *results = dict[@"results"];
                if ([results isKindOfClass:[NSArray class]] && results.count) {
                    NSDictionary *info = results[0];
                    if ([info isKindOfClass:[NSDictionary class]]) {
                        NSString *version = info[@"version"];
                        if ([version compare:XcodeAppVersion] == NSOrderedDescending) {
                            CheckUpdateView *view = [[CheckUpdateView alloc] initWithVersion:version trackViewUrl:info[@"trackViewUrl"]];
                            [view showInView:[UIApplication sharedApplication].keyWindow];
                        }
                    }
                }
            }
        }
    } failure:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpNavItem];
    [self setUpSubViews];
    [self getWeatherAndNews];
    
    if (!SApp.beWakened) {
        [self showSplashView];
    }
    // getFlashAD
    [SApp getFlashAD];
}

- (void)setUpNavItem
{
    UIBarButtonItem *leftFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftFixedSpace.width = -15;
    _leftUserinfoView = [[LeftUserinfoView alloc] initWithFrame:CGRectMake(0, 0, 100, 26)];
    _leftUserinfoView.tapBlock = ^ {
        UITabBarController *root = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        root.selectedIndex = 3;
    };
    self.navigationItem.leftBarButtonItems = @[leftFixedSpace, [[UIBarButtonItem alloc] initWithCustomView:_leftUserinfoView]];
    UIBarButtonItem *rightFixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightFixedSpace.width = -15;
    self.navigationItem.rightBarButtonItems = @[rightFixedSpace, [[UIBarButtonItem alloc] initWithImage:[UIImage originalImage:@"wireless_ico_QRcode"] style:UIBarButtonItemStylePlain target:self action:@selector(scanQRcode)]];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:ImageNamed(@"text")];
}

- (void)scanQRcode
{
    [Tools permissionOfCamera:^{
        WiFiScanQrcodeViewController *vc = [WiFiScanQrcodeViewController new];
        [self.navigationController pushViewController:vc animated:YES];
        __weak typeof(self) wself = self;
        vc.success = ^ {
            [wself WiFiMenuViewClick:WiFiMenuTypeConnect];
        };
    } noPermission:^(NSString *tip) {
        [self showAlertWithTitle:@"提示" message:tip cancelTitle:@"忽略" cancelHandler:nil defaultTitle:@"开启" defaultHandler:^(UIAlertAction *action) {
            [Tools openSetting];
        }];
    }];
}

- (void)setUpSubViews
{
    _menuView = [[NSBundle mainBundle] loadNibNamed:@"WiFiMenuView" owner:nil options:nil][0];
    [_topView addSubview:_menuView];
    [_menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_topView);
    }];
    _menuView.delegate = self;
    
    _tableView.estimatedRowHeight = 100;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.tableFooterView = [UIView new];
}

#pragma mark - GET DATA

- (void)getWeatherAndNews
{
    [WiFiCGI getWeatherNews:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *weather = data[@"weather"];
                if ([weather isKindOfClass:[NSDictionary class]]) {
                    [_menuView setWeather:weather];
                    _weatherUrl = weather[@"dst"];
                }
                NSDictionary *notice = data[@"notice"];
                if ([notice isKindOfClass:[NSDictionary class]]) {
                    [_menuView setNotice:notice[@"title"]];
                    _noticeContent = notice[@"content"];
                    _noticeUrl = notice[@"dst"];
                }
                NSArray *news = data[@"news"];
                if ([news isKindOfClass:[NSArray class]]) {
                    if (news.count) {
                        [_newsArray removeAllObjects];
                    }
                    for (NSDictionary *info in news) {
                        NewsReportModel *model = [NewsReportModel createWithInfo:info];
                        [_newsArray addObject:model];
                    }
                }
                [_tableView reloadData];
            }
        } else {
            if (E_CGI_FAILED == res._errno && !_newsArray.count) {
                __weak typeof(self) wself = self;
                [_tableView configureNoNetStyleWithdidTapButtonBlock:^{
                    [wself getWeatherAndNews];
                } didTapViewBlock:^{
                    
                }];
            } else {
                [self makeToast:res.desc];
            }
        }
    }];
}

#pragma mark

- (void)openWebWithModel:(NewsReportModel *)model
{
    WebViewController *vc = [[WebViewController alloc] init];
    vc.url = model.dst;
    vc.newsType = NT_REPORT;
    vc.title = model.title;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoNewsTabWithType:(NSInteger)type
{
    UITabBarController *root = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav = root.viewControllers[1];
    NewsViewController *vc = (NewsViewController *)nav.topViewController;
    vc.defaultType = type;
    vc.jumped = YES;
    root.selectedIndex = 1;
}

- (BOOL)prefersStatusBarHidden
{
    return _isHiddenStatusBar;
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
        case WiFiMenuTypeConnect:
        {
#if (!TARGET_IPHONE_SIMULATOR)
            [SVProgressHUD show];
            [[UserAuthManager manager] checkEnvironmentBlock:^(ENV_STATUS status) {
                [SVProgressHUD dismiss];
                if (status == ENV_NOT_LOGIN) {
                    [self doLogon];
                } else if (status == ENV_LOGIN) {
                    [self makeToast:@"已连接上东莞免费WiFi"];
                    [_menuView setConnectBtnStatus:ConnectStatusConnected];
                } else {
                    [self showConnectTipView];
                }
            }];
#else
            [_menuView setConnectBtnStatus:ConnectStatusConnecting];
#endif
        }
            break;
        case WiFiMenuTypeWelfare:
        {
            if ([[Tools getCurrentSSID] isEqualToString:WIFISDK_SSID]) {
                [self makeToast:@"您连接的是东莞无限免费WiFi，无需分享噢"];
            } else {
                WiFiWelfareViewController *vc = [[WiFiWelfareViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case WiFiMenuTypeTemperature:
        case WiFiMenuTypeWeather:
        {
            WebViewController *vc = [[WebViewController alloc] init];
            vc.url = _weatherUrl;
            vc.title = @"东莞天气";
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case WiFiMenuTypeNotice:
        {
            if (_noticeContent.length) {
                [self showAlertWithTitle:@"通知" message:_noticeContent cancelTitle:@"知道了" cancelHandler:nil defaultTitle:nil defaultHandler:nil];
            } else if (_noticeUrl.length) {
                WebViewController *vc = [[WebViewController alloc] init];
                vc.url = _noticeUrl;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

- (void)showConnectTipView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!_connectTipView) {
        _connectTipView = [[WiFiConnectTipView alloc] initWithFrame:window.bounds];
    }
    [_connectTipView showInView:window];
}

- (void)headerTap:(UITapGestureRecognizer *)tap
{
    [self gotoNewsTabWithType:NT_LOCAL];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
        if (!model.read) {
            model.read = YES;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = nil;
    if (_newsArray.count) {
        view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 100, 22)];
        label.text = @"本地热点";
        label.textColor = COLOR(0, 156, 251, 1);
        label.font = SystemFont(16);
        [view addSubview:label];
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:ImageNamed(@"icon_more")];
        icon.frame = CGRectMake(kScreenWidth - 32, 7, 32, 32);
        [view addSubview:icon];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 1)];
        line.backgroundColor = COLOR(230, 230, 230, 1);
        [view addSubview:line];
        
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTap:)]];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_newsArray.count) {
        return 46;
    }
    return 0;
}

#pragma mark - NetWorkMgrDelegate
- (void)didNetworkStateChanged:(NetworkStatus)ns
{
    [_menuView checkConnectBtnStatus];
}

@end
