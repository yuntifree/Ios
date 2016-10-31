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

@interface ServiceViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *_listView;
    
    NSMutableArray *_dataArray;
}

@property (nonatomic, strong) NSArray *sectionArray;

@end

@implementation ServiceViewController

#pragma mark - lazy-init

- (NSArray *)sectionArray
{
    if (_sectionArray == nil) {
        _sectionArray = @[@"智慧政务", @"交通出行", @"医疗服务", @"网上充值"];
    }
    return _sectionArray;
}

- (NSString *)title
{
    return @"服务";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 构造假数据
    NSArray *array = @[@[@{@"title": @"工商查询", @"url": @"http://www.gdcredit.gov.cn/fuwudating!toQiYeService.do"},
                         @{@"title": @"就业补贴", @"url": @"http://shenbao.dg.gov.cn/dgcsfw_zfb/csfw/dg_qxj/weixinportal.jsp"},
                         @{@"title": @"违章查询", @"url": @"http://112.74.64.177:8080/Traffic/ViolationByVehicleLicense"},
                         @{@"title": @"客运查询", @"url": @"http://183.6.161.195:8089/select.html"},
                         @{@"title": @"积分入户", @"url": @"http://shenbao.dg.gov.cn/dgcsfw_zfb/csfw/dg_rlzy/pages/jfrh-serach-zfb.jsp"},
                         @{@"title": @"积分入学", @"url": @"http://shenbao.dg.gov.cn/dgcsfw_zfb/csfw/dg_rlzy/pages/jfrx-serach-zfb.jsp"}],
                       @[@{@"title": @"公交查询", @"url": @"http://www.baidu.com"},
                         @{@"title": @"火车票", @"url": @"http://www.baidu.com"},
                         @{@"title": @"汽车票", @"url": @"http://www.baidu.com"},
                         @{@"title": @"飞机票", @"url": @"http://www.baidu.com"},
                         @{@"title": @"便民打车", @"url": @"http://www.baidu.com"}],
                       @[@{@"title": @"预约挂号", @"url": @"http://www.baidu.com"},
                         @{@"title": @"医院查询", @"url": @"http://www.baidu.com"}],
                       @[@{@"title": @"手机话费", @"url": @"http://www.baidu.com"},
                         @{@"title": @"手机流量", @"url": @"http://www.baidu.com"},
                         @{@"title": @"水费", @"url": @"http://www.baidu.com"},
                         @{@"title": @"电费", @"url": @"http://www.baidu.com"},
                         @{@"title": @"煤气费", @"url": @"http://www.baidu.com"}],
                       ];
    _dataArray = [NSMutableArray arrayWithCapacity:4];
    for (NSArray *sub in array) {
        NSMutableArray *tem = [NSMutableArray arrayWithCapacity:6];
        for (NSDictionary *info in sub) {
            [tem addObject:[ServiceCellModel createWithInfo:info]];
        }
        [_dataArray addObject:tem];
    }
    //
    
    [self setUpCollectionView];
    [self getServices];
}

- (void)setUpCollectionView
{
    _listView.delegate = self;
    _listView.dataSource = self;
    [_listView registerNib:[UINib nibWithNibName:@"ServiceCell" bundle:nil] forCellWithReuseIdentifier:@"ServiceCell"];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_listView.collectionViewLayout;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(kScreenWidth / 3.0, 44.0);
    
    ServiceHeaderView *header = [[ServiceHeaderView alloc] initWithFrame:CGRectMake(0, -100, kScreenWidth, 100)];
    __weak typeof(self) wself = self;
    header.headClick = ^(NSInteger tag) {
        [wself openWebVC:@"http://news.sina.com.cn"];
    };
    [_listView addSubview:header];
    _listView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0);
    
    [_listView registerNib:[UINib nibWithNibName:@"ServiceSectionHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ServiceSectionHeader"];
}

- (void)getServices
{
    [ServiceCGI getServices:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                DDDLog(@"----%@",data);
            }
        } else {
            [self showHint:res.desc];
        }
    }];
}

- (void)openWebVC:(NSString *)url
{
    WebViewController *webVC = [[WebViewController alloc] init];
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
    return [_dataArray[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ServiceCell" forIndexPath:indexPath];
    if (indexPath.section < _dataArray.count) {
        NSArray *array = _dataArray[indexPath.section];
        if (indexPath.row < array.count) {
            ServiceCellModel *model = array[indexPath.row];
            [cell setTitle:model.title];
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ServiceSectionHeader *header = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ServiceSectionHeader" forIndexPath:indexPath];
        [header setTitle:self.sectionArray[indexPath.section]];
    }
    return header;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section < _dataArray.count) {
        NSArray *array = _dataArray[indexPath.section];
        if (indexPath.row < array.count) {
            ServiceCellModel *model = array[indexPath.row];
            [self openWebVC:model.url];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(kScreenWidth, 35);
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
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:RGB(0xf2f2f2, 1)];
}

- (void)collectionView:(UICollectionView *)colView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
}

@end
