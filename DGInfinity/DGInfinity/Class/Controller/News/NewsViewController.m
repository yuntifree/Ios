//
//  NewsViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCGI.h"
#import "NewsReportCell.h"
#import "NewsReportModel.h"
#import "WebViewController.h"

@interface NewsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_listView;
    
    NSMutableArray *_newsArray;
    NSInteger _minseq;
}
@end

@implementation NewsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _newsArray = [NSMutableArray arrayWithCapacity:20];
        _minseq = 0;
    }
    return self;
}

- (NSString *)title
{
    return @"头条";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpTableView];
    [self getNews];
}

- (void)setUpTableView
{
    [_listView registerNib:[UINib nibWithNibName:@"NewsReportCell" bundle:nil] forCellReuseIdentifier:@"NewsReportCell"];
    _listView.tableFooterView = [UIView new];
    _listView.rowHeight = (kScreenWidth - 30 - 6) / 3 / 1.5 + 70;
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
                        [_newsArray addObject:model] ;
                        if (!_minseq || _minseq > model.seq) {
                            _minseq = model.seq;
                        }
                    }
                }
                [_listView reloadData];
            }
        } else {
            [self showHint:res.desc];
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
    return _newsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsReportCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsReportCell"];
    if (indexPath.row < _newsArray.count) {
        [cell setNewsReportValue:_newsArray[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _newsArray.count) {
        NewsReportModel *model = _newsArray[indexPath.row];
        WebViewController *vc = [[WebViewController alloc] init];
        vc.url = model.dst;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
