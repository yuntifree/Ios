//
//  LiveListViewController.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/8.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "LiveListViewController.h"
#import <AFNetworking.h>
#import "LiveListModel.h"
#import "LiveListCell.h"
#import "WebViewController.h"
#import "LiveCGI.h"

@interface LiveListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *_listView;
    
    NSInteger _minseq;
    BOOL _isLoad;
    NSMutableArray *_liveList;
}

@end

@implementation LiveListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _minseq = 0;
        _isLoad = NO;
        _liveList = [NSMutableArray arrayWithCapacity:10];
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
    
    [self setUpListView];
}

- (void)setUpListView
{
    _listView.delegate = self;
    _listView.dataSource = self;
    [_listView registerNib:[UINib nibWithNibName:@"LiveListCell" bundle:nil] forCellWithReuseIdentifier:@"LiveListCell"];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_listView.collectionViewLayout;
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 0, 0);
    layout.itemSize = CGSizeMake((kScreenWidth - 3) / 2, (kScreenWidth - 3) / 2 * 190 / 186 + 50);
    _listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
}

- (void)headerRefresh
{
    _minseq = 0;
    [_listView.mj_footer resetNoMoreData];
    [self getLiveList];
}

- (void)loadData
{
    if (!_isLoad) {
        _isLoad = YES;
        [self getLiveList];
    }
}

- (void)getLiveList
{
    [LiveCGI getLiveInfo:_minseq complete:^(DGCgiResult *res) {
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
                        _listView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getLiveList)];
                    }
                }
                NSArray *infos = data[@"list"];
                if ([infos isKindOfClass:[NSArray class]] && infos.count) {
                    if (_minseq == 0) {
                        [_liveList removeAllObjects];
                    }
                    for (NSDictionary *info in infos) {
                        LiveListModel *model = [LiveListModel createWithInfo:info];
                        [_liveList addObject:model];
                        if (!_minseq || _minseq > model.seq) {
                            _minseq = model.seq;
                        }
                    }
                } else {
                    if (!_liveList.count) {
                        [self makeToast:@"暂时没有主播直播，请稍后重试"];
                    }
                }
                [_listView reloadData];
            }
        } else {
            if (E_CGI_FAILED == res._errno && !_liveList.count) {
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

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _liveList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LiveListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LiveListCell" forIndexPath:indexPath];
    if (indexPath.row < _liveList.count) {
        [cell setLiveListValue:_liveList[indexPath.row]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _liveList.count) {
        LiveListModel *model = _liveList[indexPath.row];
        [SApp reportClick:[ReportClickModel createWithLiveListModel:model]];
        WebViewController *vc = [[WebViewController alloc] init];
        vc.newsType = NT_LIVE;
        vc.url = [NSString stringWithFormat:@"%@%ld", LiveRoomURL, model.live_id];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
