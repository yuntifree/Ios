//
//  JokeListViewController.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/23.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "JokeListViewController.h"
#import "JokeCGI.h"
#import "JokeModel.h"
#import "JokeListCell.h"

@interface JokeListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UITableView *_listView;
    
    NSMutableArray *_jokes;
    NSInteger _minseq;
    BOOL _isLoad;
}
@end

@implementation JokeListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _jokes = [NSMutableArray arrayWithCapacity:20];
        _minseq = 0;
        _isLoad = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpTableView];
}

- (void)setScrollsToTop:(BOOL)scrollsToTop
{
    _listView.scrollsToTop = scrollsToTop;
}

- (void)setUpTableView
{
    _listView.tableFooterView = [UIView new];
    _listView.estimatedRowHeight = 100;
    _listView.rowHeight = UITableViewAutomaticDimension;
    _listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    [_listView registerNib:[UINib nibWithNibName:@"JokeListCell" bundle:nil] forCellReuseIdentifier:@"JokeListCell"];
}

- (void)headerRefresh
{
    _minseq = 0;
    [_listView.mj_footer resetNoMoreData];
    [self getJokes];
}

- (void)loadData
{
    if (!_isLoad) {
        _isLoad = YES;
        [self getJokes];
    }
}

- (void)getJokes
{
    [JokeCGI getJokes:_minseq complete:^(DGCgiResult *res) {
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
                        _listView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getJokes)];
                    }
                }
                NSArray *infos = data[@"infos"];
                if ([infos isKindOfClass:[NSArray class]]) {
                    if (_minseq == 0) {
                        [_jokes removeAllObjects];
                    }
                    for (NSDictionary *info in infos) {
                        JokeModel *model = [JokeModel createWithInfo:info];
                        [_jokes addObject:model];
                        if (!_minseq || _minseq > model.seq) {
                            _minseq = model.seq;
                        }
                    }
                }
                [_listView reloadData];
            }
        } else {
            if (E_CGI_FAILED == res._errno && !_jokes.count) {
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

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _jokes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JokeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JokeListCell"];
    if (indexPath.row < _jokes.count) {
        [cell setJokeValue:_jokes[indexPath.row]];
    }
    __weak typeof(self) wself = self;
    cell.evaluatedBlock = ^ {
        [wself makeToast:@"你已经评价过啦"];
    };
    cell.likeOrUnlikeBlock = ^(JokeModel *model) {
        [SApp reportClick:[ReportClickModel createWithJokeModel:model]];
    };
    return cell;
}

@end
