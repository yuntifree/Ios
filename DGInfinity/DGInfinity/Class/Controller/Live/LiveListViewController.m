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

@interface LiveListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *_listView;
    
    NSInteger _offset;
    BOOL _isLoad;
    NSMutableArray *_liveList;
    int _retryCount;
}

@end

@implementation LiveListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _offset = 0;
        _retryCount = 3;
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
    _offset = 0;
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
    __weak typeof(self) wself = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *params = @{@"offset": @(_offset)};
    [manager GET:LiveListURL parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (_offset) {
            [_listView.mj_footer endRefreshing];
        } else {
            [_listView.mj_header endRefreshing];
        }
        if (responseObject && [responseObject isKindOfClass:[NSData class]]) {
            NSString *jsonString = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] deleteHeadEndSpace];
            jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
            id json = [Tools jsonStringToDictionary:jsonString];
            if (json && [json isKindOfClass:[NSDictionary class]]) {
                int errno_ = [json[@"errno"] intValue];
                if (!errno_) {
                    NSDictionary *data = json[@"data"];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        NSInteger tem = _offset;
                        _offset = [data[@"offset"] integerValue];
                        BOOL hasmore = [data[@"more"] boolValue];
                        if (!hasmore) {
                            [_listView.mj_footer endRefreshingWithNoMoreData];
                        } else {
                            if (!_listView.mj_footer) {
                                _listView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getLiveList)];
                            }
                        }
                        NSArray *list = data[@"list"];
                        if ([list isKindOfClass:[NSArray class]] && list.count) {
                            if (tem == 0) {
                                [_liveList removeAllObjects];
                            }
                            for (NSDictionary *info in list) {
                                LiveListModel *model = [LiveListModel createWithInfo:info];
                                [_liveList addObject:model];
                            }
                        } else {
                            if (!_liveList.count) {
                                if (_retryCount) { // 偶尔拉到的数据可能为空，增加重试机制
                                    [self performSelector:@selector(getLiveList) withObject:nil afterDelay:0.5];
                                    _retryCount--;
                                } else {
                                    [_listView configureNoNetStyleWithdidTapButtonBlock:^{
                                        [wself headerRefresh];
                                    } didTapViewBlock:^{
                                        
                                    }];
                                }
                            }
                        }
                        [_listView reloadData];
                    }
                } else {
                    [self makeToast:json[@"errmsg"]];
                }
            } else {
                [self makeToast:@"请求数据失败"];
            }
        } else {
            [self makeToast:@"请求数据失败"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (_offset) {
            [_listView.mj_footer endRefreshing];
        } else {
            [_listView.mj_header endRefreshing];
        }
        if (!_liveList.count) {
            [_listView configureNoNetStyleWithdidTapButtonBlock:^{
                [wself headerRefresh];
            } didTapViewBlock:^{
                
            }];
        } else {
            [self makeToast:@"网络不给力，请稍后再试"];
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
        WebViewController *vc = [[WebViewController alloc] init];
        vc.newsType = NT_LIVE;
        vc.url = [NSString stringWithFormat:@"%@%ld", LiveRoomURL, model.live_id];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
