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
#import "FeedBackViewController.h"

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_listView;
    
}

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SettingViewController

- (NSArray *)dataArray
{
    if (_dataArray == nil) {
        NSString *totalCost = [NSString stringWithFormat:@"%.1lfM",[YYWebImageManager sharedManager].cache.diskCache.totalCost / 1024.0 / 1024.0];
        _dataArray = @[[SettingModel createWithTitle:@"清理缓存" desc:totalCost],
                       [SettingModel createWithTitle:@"意见反馈" desc:nil],
                       [SettingModel createWithTitle:@"关于我们" desc:nil]];
    }
    return _dataArray;
}

- (NSString *)title
{
    return @"通用设置";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpListView];
}

- (void)setUpListView
{
    [_listView registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellReuseIdentifier:@"SettingCell"];
    SettingHeaderView *header = [[SettingHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth * 209 / 375)];
    _listView.tableHeaderView = header;
    CGFloat footerHeight = IPHONE4 ? 80 : kScreenHeight - 64 - header.height - 165;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    if (indexPath.row < self.dataArray.count) {
        SettingModel *model = self.dataArray[indexPath.row];
        [cell setTitle:model.title desc:model.desc];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            YYDiskCache *diskCache = [YYWebImageManager sharedManager].cache.diskCache;
            if (diskCache.totalCount) {
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
            FeedBackViewController *vc = [[FeedBackViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
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
}

@end
