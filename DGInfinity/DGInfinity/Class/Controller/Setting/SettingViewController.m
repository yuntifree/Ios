//
//  SettingViewController.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingModel.h"
#import "SettingCell.h"
#import "SettingHeaderView.h"
#import "SettingFooterView.h"
#import "WebViewController.h"

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_listView;
    
    BOOL _isScaned;
}

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SettingViewController

- (NSArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = @[[SettingModel createWithTitle:@"清理缓存" desc:nil],
                       [SettingModel createWithTitle:@"关于我们" desc:nil]];
    }
    return _dataArray;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isScaned = NO;
    }
    return self;
}

- (NSString *)title
{
    return @"设置";
}

- (void)backBtnClick:(id)sender
{
    MobClick(@"setting_cancel");
    [super backBtnClick:sender];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isScaned) {
        [SVProgressHUD showWithStatus:@"扫描缓存中..."];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_isScaned) {
        [[YYWebImageManager sharedManager].cache.diskCache totalCostWithBlock:^(NSInteger totalCost) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _isScaned = YES;
                [SVProgressHUD dismiss];
                SettingModel *model = self.dataArray.firstObject;
                model.desc = [NSString stringWithFormat:@"%.1lfM", totalCost / 1024.0 / 1024.0];
                [_listView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpListView];
}

- (void)setUpListView
{
    SettingHeaderView *header = [[SettingHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth * 209 / 375)];
    _listView.tableHeaderView = header;
    CGFloat footerHeight = kScreenHeight - 64 - header.height - self.dataArray.count * 55 - 50 - 20;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, footerHeight)];
    SettingFooterView *footer = [[SettingFooterView alloc] initWithFrame:footerView.bounds];
    __weak typeof(self) wself = self;
    footer.tap = ^ {
        WebViewController *vc = [[WebViewController alloc] init];
        vc.url = AgreementURL;
        vc.title = @"软件许可及服务协议";
        [wself.navigationController pushViewController:vc animated:YES];
    };
    [footerView addSubview:footer];
    _listView.tableFooterView = footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.dataArray.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 55;
    } else {
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:nil options:nil][0];
        }
        if (indexPath.row < self.dataArray.count) {
            SettingModel *model = self.dataArray[indexPath.row];
            [(SettingCell *)cell setTitle:model.title desc:model.desc arrowHiden:indexPath.row == 0];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingExitCell"];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:nil options:nil][1];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    } else {
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                SettingModel *model = self.dataArray[0];
                YYDiskCache *diskCache = [YYWebImageManager sharedManager].cache.diskCache;
                if (model.desc.doubleValue >= 0.1) { // 大于或等于102.4k
                    [diskCache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showWithStatus:@"清理缓存中..."];
                        });
                    } endBlock:^(BOOL error) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [SVProgressHUD showSuccessWithStatus:@"缓存已清除"];
                            SettingModel *model = self.dataArray[indexPath.row];
                            model.desc = @"0.0M";
                            [_listView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        });
                    }];
                }
            }
                break;
            case 1:
            {
                WebViewController *vc = [[WebViewController alloc] init];
                vc.url = AboutmeURL;
                vc.title = @"关于我们";
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
    } else {
        [self showAlertWithTitle:@"确定退出当前账号?" message:nil cancelTitle:@"取消" cancelHandler:nil defaultTitle:@"确定退出" defaultHandler:^(UIAlertAction *action) {
            [SVProgressHUD show];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
                [MSApp destory];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNC_LOGOUT object:nil];
            });
        }];
    }
}

@end
