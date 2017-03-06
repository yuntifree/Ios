//
//  ServiceViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ServiceViewController.h"
#import "WebViewController.h"
#import "ServiceCell.h"
#import "ServiceHeaderView.h"
#import "ServiceSectionHeader.h"
#import "ServiceCellModel.h"
#import "ServiceCGI.h"
#import "ServiceSectionModel.h"
#import "DGNavigationViewController.h"
#import "SearchViewController.h"
#import "AnimationManager.h"

// banner 上方链接栏
static NSString *url[] = {
    @"http://jump.luna.58.com/i/29Zo",
    @"http://jump.luna.58.com/i/29Zp",
    @"http://jump.luna.58.com/i/29Zq",
    @"http://jump.luna.58.com/i/29Zr",
    @"http://jump.luna.58.com/i/29Zs"
};

// title
static NSString *title[] = {
    @"招聘",
    @"二手",
    @"租房",
    @"家政",
    @"更多"
};

const CGFloat headerHeight = 108.0;
const CGFloat padingHeight = 20.0;

@interface ServiceViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *_listView;
    ServiceHeaderView *_header;
    UIView *_padingView;
    
    NSMutableArray *_dataArray;
}

@end

@implementation ServiceViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpTitleView];
    [self setUpCollectionView];
    [self getServices];
}

- (void)setUpTitleView
{
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 36, 30)];
    searchView.backgroundColor = COLOR(1, 135, 238, 1);
    searchView.layer.cornerRadius = 8;
    searchView.layer.masksToBounds = YES;
    [searchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goSearch)]];
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:ImageNamed(@"ico_search")];
    icon.origin = CGPointMake(12, 2);
    [searchView addSubview:icon];
    
    UILabel *placeholder = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, searchView.width - 80, searchView.height)];
    placeholder.text = @"搜索或输入网址";
    placeholder.font = SystemFont(14);
    placeholder.textColor = COLOR(252, 252, 252, 0.6);
    [searchView addSubview:placeholder];
    
    self.navigationItem.titleView = searchView;
}

- (void)goSearch
{
    DGNavigationViewController *nav = [[DGNavigationViewController alloc] initWithRootViewController:[SearchViewController new]];
    [self.view.window.layer addAnimation:[AnimationManager presentFadeAnimation] forKey:nil];
    [self presentViewController:nav animated:NO completion:nil];
}

- (void)setUpCollectionView
{
    _listView.delegate = self;
    _listView.dataSource = self;
    [_listView registerNib:[UINib nibWithNibName:@"ServiceCell" bundle:nil] forCellWithReuseIdentifier:@"ServiceCell"];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_listView.collectionViewLayout;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(kScreenWidth / 4.0, 81.0);
    
    _header = [[ServiceHeaderView alloc] initWithFrame:CGRectMake(0, -headerHeight - padingHeight, kScreenWidth, headerHeight)];
    _header.hidden = YES;
    __weak typeof(self) wself = self;
    _header.headClick = ^(NSInteger tag) {
        ReportClickModel *model = [ReportClickModel new];
        model.id_ = tag + 1;
        model.type = RCT_SERVICE;
        [SApp reportClick:model];
        [wself openWebVCWithTitle:title[tag] url:url[tag]];
    };
    [_listView addSubview:_header];
    
    _padingView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_header.frame), kScreenWidth, padingHeight)];
    _padingView.backgroundColor = RGB(0xf5f5f5, 1);
    _padingView.hidden = YES;
    [_listView addSubview:_padingView];
    
    _listView.contentInset = UIEdgeInsetsMake(headerHeight + _padingView.height, 0, 0, 0);
    
    [_listView registerNib:[UINib nibWithNibName:@"ServiceSectionHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ServiceSectionHeader"];
    
    _listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    _listView.mj_header.ignoredScrollViewContentInsetTop = headerHeight + _padingView.height;
}

- (void)headerRefresh
{
    [self getServices];
}

- (void)getServices
{
    [ServiceCGI getServices:^(DGCgiResult *res) {
        [_listView.mj_header endRefreshing];
        if (E_OK == res._errno) {
            _header.hidden = NO;
            _padingView.hidden = NO;
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *services = data[@"services"];
                if ([services isKindOfClass:[NSArray class]]) {
                    if (_dataArray.count) {
                        [_dataArray removeAllObjects];
                    }
                    for (NSDictionary *info in services) {
                        ServiceSectionModel *model = [ServiceSectionModel createWithInfo:info];
                        [_dataArray addObject:model];
                    }
                }
                [_listView reloadData];
            }
        } else {
            if (!_dataArray.count) {
                _header.hidden = YES;
                _padingView.hidden = YES;
            }
            if (E_CGI_FAILED == res._errno) {
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

- (void)openWebVCWithTitle:(NSString *)title url:(NSString *)url
{
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.title = title;
    webVC.url = url;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[section];
        return [sModel.items count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ServiceCell" forIndexPath:indexPath];
    if (indexPath.section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[indexPath.section];
        if (indexPath.row < sModel.items.count) {
            ServiceCellModel *model = sModel.items[indexPath.row];
            [cell setTitle:model.title icon:model.icon];
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ServiceSectionHeader *header = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ServiceSectionHeader" forIndexPath:indexPath];
        if (indexPath.section < _dataArray.count) {
            ServiceSectionModel *sModel = _dataArray[indexPath.section];
            [header setTitle:sModel.title];
        }
    }
    return header;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[indexPath.section];
        if (indexPath.row < sModel.items.count) {
            ServiceCellModel *model = sModel.items[indexPath.row];
            ReportClickModel *rcModel = [ReportClickModel new];
            rcModel.id_ = model.sid;
            rcModel.type = RCT_SERVICE;
            [SApp reportClick:rcModel];
            [self openWebVCWithTitle:model.title url:model.dst];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 56);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [colView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:RGB(0xf2f2f2, 1)];
}

- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [colView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
}

@end
