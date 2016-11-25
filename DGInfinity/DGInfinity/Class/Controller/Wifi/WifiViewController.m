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
#import "WiFiWelfareViewController.h"
#import "NetworkManager.h"

#define Height (kScreenHeight - 20 - 44 - 49)

@interface WifiViewController ()
<
WiFiMenuViewDelegate,
UIScrollViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
NetWorkMgrDelegate
>
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

- (void)dealloc
{
    [[NetworkManager shareManager] removeNetworkObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _newsArray = [NSMutableArray arrayWithCapacity:3];
        [[NetworkManager shareManager] addNetworkObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)willEnterForeground
{
#if (!TARGET_IPHONE_SIMULATOR)
    [[UserAuthManager manager] checkEnvironmentBlock:^(ENV_STATUS status) {
        if (status == ENV_NOT_WIFI) {
            if ([[Tools getCurrentSSID] isEqualToString:WIFISDK_SSID]) {
                // 已经portal认证
            } else {
                // 别的网络
            }
        } else if (status == ENV_LOGIN) {
            // 已经通过SDK认证
        } else if (status == ENV_NOT_LOGIN) {
            if (SApp.wifiAccount && SApp.wifipass) {
                // 调用SDK认证
                [self doLogon];
            } else {
                // 调用SDK注册，然后再调用认证
                [self doRegister];
            }
        }
    }];
#endif
}

- (void)doRegister
{
#if (!TARGET_IPHONE_SIMULATOR)
    [SVProgressHUD show];
    [[UserAuthManager manager] doRegisterWithUserName:SApp.username andPassWord:SApp.wifipass andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSString *retflag = response[@"retflag"];
            if ([retflag isEqualToString:@"0"]) {
                SApp.wifiAccount = SApp.username;
                [self doLogon];
            } else {
                [self makeToast:response[@"reason"]];
            }
        } else {
            [self makeToast:[NSString stringWithFormat:@"请求失败 %@", error.description]];
        }
    }];
#endif
}

- (void)doLogon
{
#if (!TARGET_IPHONE_SIMULATOR)
    [SVProgressHUD show];
    [[UserAuthManager manager] doLogon:SApp.wifiAccount andPassWord:SApp.wifipass andTimeOut:WIFISDK_TIMEOUT block:^(NSDictionary *response, NSError *error) {
        [SVProgressHUD dismiss];
        if (!error) {
            NSString *retflag = response[@"retflag"];
            if ([retflag isEqualToString:@"0"]) {
                [self makeToast:@"认证成功"];
                [_menuView setConnectBtnStatus:ConnectStatusConnected];
                [WiFiCGI reportApMac:[Tools getBSSID] complete:nil];
            } else {
                [self makeToast:response[@"reason"]];
            }
        } else {
            [self makeToast:[NSString stringWithFormat:@"请求失败 %@", error.description]];
        }
    }];
#endif
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
        if (!_newsArray.count) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self getWeatherAndNews];
            });
        }
    }
}

- (void)handleFooterViewAction:(WiFiFooterType)type
{
    UITabBarController *root = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    switch (type) {
        case WiFiFooterTypeLookForNews:
        case WiFiFooterTypeNews:
        case WiFiFooterTypeVideo:
        {
            UINavigationController *nav = root.viewControllers[1];
            NewsViewController *vc = (NewsViewController *)nav.topViewController;
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
        case WiFiFooterTypeService:
        case WiFiFooterTypeGoverment:
        {
            root.selectedIndex = 2;
        }
            break;
        case WiFiFooterTypeLive:
        {
            
        }
            break;
        case WiFiFooterTypeShopping:
        {
            
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
#if (!TARGET_IPHONE_SIMULATOR)
            [SVProgressHUD show];
            [[UserAuthManager manager] checkEnvironmentBlock:^(ENV_STATUS status) {
                [SVProgressHUD dismiss];
                if (status == ENV_NOT_LOGIN) {
                    if (SApp.wifiAccount && SApp.wifipass) {
                        [self doLogon];
                    } else {
                        [self doRegister];
                    }
                } else if (status == ENV_LOGIN) {
                    [self makeToast:@"已连接上东莞免费WiFi"];
                    [_menuView setConnectBtnStatus:ConnectStatusConnected];
                } else {
                    UIWindow *window = [UIApplication sharedApplication].keyWindow;
                    if (!_connectTipView) {
                        _connectTipView = [[WiFiConnectTipView alloc] initWithFrame:window.bounds];
                    }
                    [_connectTipView showInView:window];
                }
            }];
#else
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!_connectTipView) {
                _connectTipView = [[WiFiConnectTipView alloc] initWithFrame:window.bounds];
            }
            [_connectTipView showInView:window];
#endif
        }
            break;
        case WiFiMenuTypeWelfare:
        {
            WiFiWelfareViewController *vc = [[WiFiWelfareViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case WiFiMenuTypeTemperature:
        case WiFiMenuTypeWeather:
        {
            WebViewController *vc = [[WebViewController alloc] init];
            vc.url = WeatherURL;
            [self.navigationController pushViewController:vc animated:YES];
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
            if (!_newsArray.count) {
                [self getWeatherAndNews];
            }
            if (scrollView.contentOffset.y == Height) {
                scrollView.scrollEnabled = NO;
            }
        }
    }
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

#pragma mark - NetWorkMgrDelegate
- (void)didNetworkStateChanged:(NetworkStatus)ns
{
    [_menuView checkConnectBtnStatus];
}

@end
