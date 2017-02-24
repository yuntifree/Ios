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
#import "WebViewController.h"
#import "WiFiSpeedTestViewController.h"
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
#import "NewsViewController.h"
#import "WiFiFunctionCell.h"
#import "WiFiFunctionModel.h"

#define Height (kScreenHeight - 20 - 44 - 49)

static NSString *icons[] = {
    @"btn_wifitest",
    @"btn_wifimap",
    @"btn_wifilist",
    @"btn_wifiwelfare"
};

static NSString *titles[] = {
    @"WiFi测速",
    @"WiFi地图",
    @"WiFi体检",
    @"WiFi公益"
};

static NSString *descs[] = {
    @"速度如何一测便知",
    @"全城覆盖随意行走",
    @"发现更多小伙伴",
    @"一键扫描惠及全民"
};

@interface WifiViewController ()
<
WiFiMenuViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
NetWorkMgrDelegate
>
{
    UIScrollView *_scrollView;
    WiFiMenuView *_menuView;
    UITableView *_tableView;
    WiFiConnectTipView *_connectTipView;
    LeftUserinfoView *_leftUserinfoView;
    
    NSString *_weatherUrl;
    NSString *_noticeContent;
    NSString *_noticeUrl;
    NSMutableArray *_functions;
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
        _weatherUrl = WeatherURL;
        _functions = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < 4; i++) {
            WiFiFunctionModel *model = [WiFiFunctionModel new];
            model.imageName = icons[i];
            model.title = titles[i];
            model.desc = descs[i];
            [_functions addObject:model];
        }
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
//                if ([[NetworkManager shareManager] isWiFi]) {
//                    [_menuView setConnectBtnStatus:ConnectStatusConnected];
//                } else {
//                    [_menuView setConnectBtnStatus:ConnectStatusNotConnect];
//                }
                [_menuView setConnectBtnStatus:ConnectStatusNotConnect];
            }
        } else if (status == ENV_LOGIN) {
            // 已经通过SDK认证
            [_menuView setConnectBtnStatus:ConnectStatusConnected];
        } else if (status == ENV_NOT_LOGIN) {
            [self doLogon];
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
    [self setUpScrollView];
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

- (void)setUpScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, Height)];
    _scrollView.contentSize = CGSizeMake(kScreenWidth, Height);
    _scrollView.bounces = NO;
    _scrollView.delaysContentTouches = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
}

- (void)setUpSubViews
{
    _menuView = [[NSBundle mainBundle] loadNibNamed:@"WiFiMenuView" owner:nil options:nil][0];
    _menuView.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth / 375 * 291);
    _menuView.delegate = self;
    [_scrollView addSubview:_menuView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _menuView.height, kScreenWidth, Height - _menuView.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = IPHONE4 ? 52 : _tableView.height / _functions.count;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.separatorColor = COLOR(231, 231, 231, 1);
    [_scrollView addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"WiFiFunctionCell" bundle:nil] forCellReuseIdentifier:@"WiFiFunctionCell"];
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
            }
        } else if (E_CGI_FAILED != res._errno) {
            [self makeToast:res.desc];
        }
    }];
}

#pragma mark

- (void)gotoNewsTabWithType:(NSInteger)type
{
    UITabBarController *root = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UINavigationController *nav = root.viewControllers[1];
    NewsViewController *vc = (NewsViewController *)nav.topViewController;
    vc.defaultType = type;
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
                } else if (status == ENV_NOT_WIFI) {
                    if ([[Tools getCurrentSSID] isEqualToString:WIFISDK_SSID]) {
                        [_menuView setConnectBtnStatus:ConnectStatusConnecting];
                    } else {
                        [self showConnectTipView];
                    }
                } else {
                    [self showConnectTipView];
                }
            }];
#else
//            [self showConnectTipView];
            [_menuView setConnectBtnStatus:ConnectStatusConnecting];
#endif
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
        case WiFiMenuTypeConnected:
        {
            [self gotoNewsTabWithType:NT_REPORT];
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

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _functions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WiFiFunctionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WiFiFunctionCell"];
    if (indexPath.row < _functions.count) {
        [cell setFunctionValue:_functions[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _functions.count) {
        switch (indexPath.row) {
            case 0:
            {
                WiFiSpeedTestViewController *vc = [[WiFiSpeedTestViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
            {
                BaiduMapVC *vc = [[BaiduMapVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                WiFiExaminationViewController *vc = [[WiFiExaminationViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                vc.badgeblock = ^ (NSInteger deviceCount) {
                    
                };
            }
                break;
            case 3:
            {
                WiFiWelfareViewController *vc = [[WiFiWelfareViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - NetWorkMgrDelegate
- (void)didNetworkStateChanged:(NetworkStatus)ns
{
    [_menuView checkConnectBtnStatus];
}

@end
