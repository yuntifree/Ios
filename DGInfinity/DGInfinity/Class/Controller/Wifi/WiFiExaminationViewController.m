//
//  WiFiExaminationViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiExaminationViewController.h"
#import "WiFiExamCell.h"
#import "WiFiExamSectionHeader.h"
#import "NetworkManager.h"
#import "RMPingCenter.h"
#import "RMConnectedDevice.h"

@interface WiFiExaminationViewController () <UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UITableView *_listView;
    
    NSMutableArray *_deviceArray;
    NSArray *_descArray;
    NSString *_localIP;
    NSString *_serverIP;
}

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *progressTimer;

@end

@implementation WiFiExaminationViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - lazy-init
- (UIProgressView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0.5, kScreenWidth, 2);
        _progressView.progress = 0;
        _progressView.hidden = YES;
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = RGB(0x68CDFF, 1);
        _progressView.transform = CGAffineTransformMakeScale(1.0, 1.5);
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _deviceArray = [NSMutableArray arrayWithCapacity:10];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devicesChanged) name:NOTIFICATION_CONNECTED_DEVICE_LIST_CHANGED_USING_PING object:nil];
    }
    return self;
}

- (NSString *)title
{
    NSString *ssid = [Tools getCurrentSSID];
    return ssid.length ? ssid : @"非WiFi环境";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak typeof(self) wself = self;
    if (![[NetworkManager shareManager] isWiFi]) {
        [self showAlertWithTitle:@"提示" message:@"当前网络非WiFi环境，请打开WiFi后继续操作" cancelTitle:@"知道了" cancelHandler:^(UIAlertAction *action) {
            [wself.navigationController popViewControllerAnimated:YES];
        } defaultTitle:nil defaultHandler:nil];
        return;
    }
    
    [[RMPingCenter sharedInstance] scan];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    [[RMPingCenter sharedInstance] stop];
}

- (void)startTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
}

- (void)updateProgress
{
    if (self.progressView.progress < 1) {
        [self.progressView setProgress:self.progressView.progress + 0.002 animated:YES];
        self.progressView.hidden = NO;
    } else {
        [self performSelector:@selector(delayToHideProgress) withObject:nil afterDelay:0.5];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpTableView];
    
    // init network desc
    _localIP = [Tools getWlanIPAddress];
    _serverIP = [Tools getServerWiFiIPAddress];
    _descArray = @[[WiFiExamDescModel createWithTitle:@"网关地址" desc:[NSString stringWithFormat:@"IP：%@",_serverIP]],
                   [WiFiExamDescModel createWithTitle:@"MAC地址" desc:[Tools getBSSID]],
                   [WiFiExamDescModel createWithTitle:@"子网掩码" desc:[Tools getWlanSubnetMask]]];
}

- (void)setUpTableView
{
    _listView.tableFooterView = [UIView new];
}

- (void)devicesChanged
{
    if (_deviceArray.count) {
        [_deviceArray removeAllObjects];
    }
    NSArray *temArray = [NSArray arrayWithArray:[[RMPingCenter sharedInstance] getConnectedDevice]];
    for (RMConnectedDevice *device in temArray) {
        if ([device.ip isEqualToString:_serverIP]) continue;
        WiFiExamDeviceModel *model = [WiFiExamDeviceModel createWithBrand:device.brand ip:device.ip hostname:device.dev_name];
        if ([device.ip isEqualToString:_localIP]) {
            model.hostname = [NSString stringWithFormat:@"%@（本机）",[UIDevice currentDevice].name];
            [_deviceArray insertObject:model atIndex:0];
        } else {
            [_deviceArray addObject:model];
        }
    }
    
    [_listView reloadData];
    if (_badgeblock) {
        _badgeblock(_deviceArray.count);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)delayToHideProgress
{
    [self.progressView setProgress:0 animated:NO];
    self.progressView.hidden = YES;
    [self.progressTimer invalidate];
    self.progressTimer = nil;
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
