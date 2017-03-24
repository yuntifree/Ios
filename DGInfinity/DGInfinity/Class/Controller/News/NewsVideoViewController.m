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
#import "WebViewController.h"

@interface NewsVideoViewController () <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UITableView *_listView;
    
    NSMutableArray *_videosArray;
    NSInteger _minseq;
    BOOL _isLoad;
}

@property (nonatomic, strong) NSMutableSet *mobSet;

@end

@implementation NewsVideoViewController

#pragma mark - lazy-init
- (NSMutableSet *)mobSet
{
    if (!_mobSet) {
        _mobSet = [NSMutableSet set];
    }
    return _mobSet;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _videosArray = [NSMutableArray arrayWithCapacity:20];
        _minseq = 0;
        _isLoad = NO;
    }
    return self;
}

- (void)setScrollsToTop:(BOOL)scrollsToTop
{
    _listView.scrollsToTop = scrollsToTop;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpTableView];
}

- (void)setUpTableView
{
    [_listView registerNib:[UINib nibWithNibName:@"NewsVideoCell" bundle:nil] forCellReuseIdentifier:@"NewsVideoCell"];
    _listView.tableFooterView = [UIView new];
    _listView.rowHeight = (kScreenWidth - 40) * 168 / 334 + 52;
    _listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
}

- (void)headerRefresh
{
    _minseq = 0;
    [_listView.mj_footer resetNoMoreData];
    [self getNews];
}

- (void)loadData
{
    if (!_isLoad) {
        _isLoad = YES;
        [self getNews];
    }
}

- (void)getNews
{
    [NewsCGI getHot:self.type seq:_minseq complete:^(DGCgiResult *res) {
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
                } else {
                    if (!_listView.mj_footer) {
                        _listView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getNews)];
                    }
                }
                if (_minseq == 0) {
                    [_videosArray removeAllObjects];
                }
                NSDictionary *top = data[@"top"];
                if ([top isKindOfClass:[NSDictionary class]]) {
                    NewsVideoTopModel *model = [NewsVideoTopModel createWithInfo:top];
                    [_videosArray addObject:model];
                }
                NSArray *infos = data[@"infos"];
                if ([infos isKindOfClass:[NSArray class]]) {
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
            if (E_CGI_FAILED == res._errno && !_videosArray.count) {
                __weak typeof(self) wself = self;
                [_listView configureNoNetStyleWithdidTapButtonBlock:^{
                    [wself headerRefresh];
                } didTapViewBlock:^{
                    
                }];
            } else {
                [self makeToast:res.desc];
            }
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
        id model = _videosArray[indexPath.row];
        if ([model isKindOfClass:[NewsVideoModel class]]) {
            [cell setNewsVideoValue:model];
        } else {
            [cell setNewsVideoTopValue:model];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _videosArray.count) {
        id obj = _videosArray[indexPath.row];
        WebViewController *vc = [[WebViewController alloc] init];
        if ([obj isKindOfClass:[NewsVideoModel class]]) {
            NewsVideoModel *model = (NewsVideoModel *)obj;
            if (!model.read) {
                model.read = YES;
                model.play++;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            [self.mobSet addObject:@(model.id_)];
            if (self.mobSet.count == 3) {
                MobClick(@"video_triple_view");
            } else if (self.mobSet.count == 5) {
                MobClick(@"video_penta_view");
            }
            [SApp reportClick:[ReportClickModel createWithVideoModel:model]];
            vc.url = model.dst;
            vc.newsType = NT_VIDEO;
            vc.title = model.title;
        } else {
            NewsVideoTopModel *model = (NewsVideoTopModel *)obj;
            vc.url = model.dst;
            vc.title = model.title;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
