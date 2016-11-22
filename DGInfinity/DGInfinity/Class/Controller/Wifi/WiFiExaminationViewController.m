//
//  WiFiExaminationViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiExaminationViewController.h"
#import "MainPresenter.h"
#import "WiFiExamCell.h"
#import "Device.h"
#import "WiFiExamSectionHeader.h"
#import "NetworkManager.h"

@interface WiFiExaminationViewController () <UITableViewDelegate, UITableViewDataSource, MainPresenterDelegate>
{
    __weak IBOutlet UITableView *_listView;
    
    NSMutableArray *_deviceArray;
    NSArray *_descArray;
    NSString *_localIP;
}

@property (nonatomic, strong) MainPresenter *presenter;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation WiFiExaminationViewController

#pragma mark - lazy-init
- (MainPresenter *)presenter
{
    if (_presenter == nil) {
        _presenter = [[MainPresenter alloc] initWithDelegate:self];
        [self addObserversForKVO];
    }
    return _presenter;
}

- (UIProgressView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0, kScreenWidth, 4);
        _progressView.progress = 0;
        _progressView.hidden = YES;
        _progressView.trackTintColor = [UIColor whiteColor];
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

- (void)dealloc
{
    if (_presenter) {
        [self removeObserversForKVO];
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _deviceArray = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

#pragma mark - KVO Observers
- (void)addObserversForKVO
{
    [self.presenter addObserver:self forKeyPath:@"connectedDevices" options:NSKeyValueObservingOptionNew context:nil];
    [self.presenter addObserver:self forKeyPath:@"progressValue" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserversForKVO
{
    [self.presenter removeObserver:self forKeyPath:@"connectedDevices"];
    [self.presenter removeObserver:self forKeyPath:@"progressValue"];
}

- (NSString *)title
{
    NSString *ssid = [Tools getCurrentSSID];
    return ssid.length ? ssid : @"非WiFi环境";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[NetworkManager shareManager] isWiFi]) {
        __weak typeof(self) wself = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前网络非WiFi环境，请打开WiFi后继续操作" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [wself.navigationController popViewControllerAnimated:YES];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (![[Tools getWlanIPAddress] hasPrefix:@"192.168"]) {
        [self makeToast:@"当前网络不是局域网"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"扫描中，请稍后..."];
    [self.presenter scanButtonClicked];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpTableView];
    
    // init network desc
    _localIP = [Tools getWlanIPAddress];
    _descArray = @[[WiFiExamDescModel createWithTitle:@"IP地址" desc:[NSString stringWithFormat:@"IP：%@",[Tools getServerWiFiIPAddress]]],
                   [WiFiExamDescModel createWithTitle:@"MAC地址" desc:[Tools getBSSID]],
                   [WiFiExamDescModel createWithTitle:@"子网掩码" desc:[Tools getWlanSubnetMask]]];
}

- (void)setUpTableView
{
    _listView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == self.presenter) {
        if ([keyPath isEqualToString:@"connectedDevices"]) {
            if (_deviceArray.count) {
                [_deviceArray removeAllObjects];
            }
            NSArray *temArray = [NSArray arrayWithArray:self.presenter.connectedDevices];
            for (Device *device in temArray) {
                if ([device.ipAddress isEqualToString:[Tools getServerWiFiIPAddress]]) continue;
                WiFiExamDeviceModel *model = [WiFiExamDeviceModel createWithBrand:device.brand ip:device.ipAddress];
                if ([device.ipAddress isEqualToString:_localIP]) {
                    model.brand = [NSString stringWithFormat:@"%@（本机）",model.brand];
                }
                [_deviceArray addObject:model];
            }
            [_listView reloadData];
        } else if ([keyPath isEqualToString:@"progressValue"]) {
            CGFloat progress = self.presenter.progressValue;
            if (progress == 1) {
                [self.progressView setProgress:0 animated:NO];
                self.progressView.hidden = YES;
            } else {
                [self.progressView setProgress:progress animated:YES];
                self.progressView.hidden = NO;
            }
        }
    }
}

#pragma mark - MainPresenterDelegate
- (void)mainPresenterIPSearchFinished
{
    [SVProgressHUD dismiss];
    self.progressView.hidden = YES;
    if (_badgeblock) {
        _badgeblock(self.presenter.connectedDevices.count);
    }
}

- (void)mainPresenterIPSearchFailed
{
    [SVProgressHUD dismiss];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _deviceArray.count;
    } else {
        return _descArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 67;
    } else {
        return 46;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WiFiExamCell *cell = nil;
    NSString *reusedIdentifier = !indexPath.section ? @"WiFiExamDeviceCell" : @"WiFiExamCell";
    cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"WiFiExamCell" owner:nil options:nil][indexPath.section];
    }
    if (indexPath.section == 0) {
        if (indexPath.row < _deviceArray.count) {
            [((WiFiExamDeviceCell *)cell) setDeviceValue:_deviceArray[indexPath.row]];
        }
    } else {
        if (indexPath.row < _descArray.count) {
            [((WiFiExamDescCell *)cell) setDescValue:_descArray[indexPath.row]];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 41;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *reuseIdentifier = @"WiFiExamSectionHeader";
    WiFiExamSectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseIdentifier];
    if (!header) {
        header = [[WiFiExamSectionHeader alloc] initWithReuseIdentifier:reuseIdentifier];
    }
    if (section == 0) {
        [header setTitle:[NSString stringWithFormat:@"在线设备%ld",_deviceArray.count]];
    } else {
        [header setTitle:@"网络详情"];
    }
    return header;
}

@end
