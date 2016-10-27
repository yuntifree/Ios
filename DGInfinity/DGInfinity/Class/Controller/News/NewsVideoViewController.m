//
//  NewsVideoViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/27.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsVideoViewController.h"
#import "NewsCGI.h"
#import "NewsVideoModel.h"
#import "NewsVideoCell.h"
#import <MediaPlayer/MediaPlayer.h>

@interface NewsVideoViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_listView;
    
    NSMutableArray *_videosArray;
    NSInteger _minseq;
}
@end

@implementation NewsVideoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _videosArray = [NSMutableArray arrayWithCapacity:20];
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
    [_listView registerNib:[UINib nibWithNibName:@"NewsVideoCell" bundle:nil] forCellReuseIdentifier:@"NewsVideoCell"];
    _listView.tableFooterView = [UIView new];
    _listView.rowHeight = (kScreenWidth - 30) / 1.85 + 70;
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
    [NewsCGI getHot:NT_VIDEO seq:_minseq complete:^(DGCgiResult *res) {
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
                        [_videosArray removeAllObjects];
                    }
                    for (NSDictionary *info in infos) {
                        NewsVideoModel *model = [NewsVideoModel createWithInfo:info];
                        [_videosArray addObject:model];
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
    return _videosArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsVideoCell"];
    if (indexPath.row < _videosArray.count) {
        [cell setNewsVideoValue:_videosArray[indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _videosArray.count) {
        NewsVideoModel *model = _videosArray[indexPath.row];
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:model.dst]];
        [self presentMoviePlayerViewControllerAnimated:player];
    }
}

@end
