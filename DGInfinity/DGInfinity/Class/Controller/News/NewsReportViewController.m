//
//  NewsReportViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/27.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsReportViewController.h"
#import "NewsCGI.h"
#import "NewsReportCell.h"
#import "NewsReportModel.h"
#import "WebViewController.h"

@interface NewsReportViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_listView;
    
    NSMutableArray *_newsArray;
    NSInteger _minseq;
}
@end

@implementation NewsReportViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _newsArray = [NSMutableArray arrayWithCapacity:20];
        _minseq = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpTableView];
    [self getNews];
}

- (void)setUpTableView
{
    _listView.tableFooterView = [UIView new];
    _listView.estimatedRowHeight = 100;
    _listView.rowHeight = UITableViewAutomaticDimension;
    _listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    _listView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getNews)];
}

- (void)headerRefresh
{
    _minseq = 0;
    [_listView.mj_footer resetNoMoreData];
    [self getNews];
}

- (void)getNews
{
    [NewsCGI getHot:NT_REPORT seq:_minseq complete:^(DGCgiResult *res) {
        if (_minseq) {
            [_listView.mj_footer endRefreshing];
        } else {
            [_listView.mj_header endRefreshing];
        }
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                BOOL hasmore = [data[@"hasmore"] boolValue];
                if (!hasmore) {
                    [_listView.mj_footer endRefreshingWithNoMoreData];
                }
                NSArray *infos = data[@"infos"];
                if ([infos isKindOfClass:[NSArray class]]) {
                    if (_minseq == 0) {
                        [_newsArray removeAllObjects];
                    }
                    for (NSDictionary *info in infos) {
                        NewsReportModel *model = [NewsReportModel createWithInfo:info];
                        [_newsArray addObject:model];
                        if (!_minseq || _minseq > model.seq) {
                            _minseq = model.seq;
                        }
                    }
                }
                [_listView reloadData];
            }
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView displayWitMsg:@"没有相关数据" ForDataCount:_newsArray.count];
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
        [SApp reportClick:[ReportClickModel createWithReportModel:model]];
        NSURL *url = [NSURL URLWithString:model.dst];
        if ([url.scheme isEqualToString:@"itms"] || [url.scheme isEqualToString:@"itms-apps"]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            WebViewController *vc = [[WebViewController alloc] init];
            vc.url = model.dst;
            vc.newsType = NT_REPORT;
            vc.title = model.title;
            [self.navigationController pushViewController:vc animated:YES];
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
