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
#import "ServiceSectionFooter.h"
#import "ServiceCellModel.h"
#import "ServiceCGI.h"
#import "ServiceSectionModel.h"
#import "DGNavigationViewController.h"
#import "SearchViewController.h"
#import "AnimationManager.h"
#import "ServiceBannerCell.h"
#import "ServiceCityCell.h"

@interface ServiceViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *_listView;
    ServiceHeaderView *_header;
    UIView *_padingView;
    
    NSMutableArray *_dataArray;
}

@end

@implementation ServiceViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNCServiceViewControllerDealloc object:nil];
}

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
    [self getDiscovery];
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
    placeholder.text = @"点击搜索";
    placeholder.font = SystemFont(14);
    placeholder.textColor = COLOR(252, 252, 252, 0.6);
    [searchView addSubview:placeholder];
    
    self.navigationItem.titleView = searchView;
}

- (void)goSearch
{
    MobClick(@"life_search");
    DGNavigationViewController *nav = [[DGNavigationViewController alloc] initWithRootViewController:[SearchViewController new]];
    [self.view.window.layer addAnimation:[AnimationManager presentFadeAnimation] forKey:nil];
    [self presentViewController:nav animated:NO completion:nil];
}

- (void)setUpCollectionView
{
    _listView.delegate = self;
    _listView.dataSource = self;
    
    [_listView registerNib:[UINib nibWithNibName:@"ServiceSectionHeader" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ServiceSectionHeader"];
    [_listView registerNib:[UINib nibWithNibName:@"ServiceSectionFooter" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ServiceSectionFooter"];
    [_listView registerNib:[UINib nibWithNibName:@"ServiceBannerCell" bundle:nil] forCellWithReuseIdentifier:@"ServiceBannerCell"];
    [_listView registerNib:[UINib nibWithNibName:@"ServiceCityCell" bundle:nil] forCellWithReuseIdentifier:@"ServiceCityCell"];
    [_listView registerNib:[UINib nibWithNibName:@"ServiceCell" bundle:nil] forCellWithReuseIdentifier:@"ServiceCell"];
    _listView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
}

- (void)headerRefresh
{
    [self getDiscovery];
}

- (void)getDiscovery
{
    [ServiceCGI getDiscovery:^(DGCgiResult *res) {
        [_listView.mj_header endRefreshing];
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                if (_dataArray.count) {
                    [_dataArray removeAllObjects];
                }
                NSArray *banners = data[@"banners"];
                if ([banners isKindOfClass:[NSArray class]] && banners.count) {
                    ServiceSectionModel *model = [ServiceSectionModel new];
                    model.title = @"";
                    for (NSDictionary *info in banners) {
                        ServiceBannerModel *md = [ServiceBannerModel createWithInfo:info];
                        md.rcType = RCT_BANNERCLICK;
                        [model.items addObject:md];
                    }
                    [_dataArray addObject:model];
                }
                NSArray *urbanservices = data[@"urbanservices"];
                if ([urbanservices isKindOfClass:[NSArray class]] && urbanservices.count) {
                    ServiceSectionModel *model = [ServiceSectionModel new];
                    model.title = @"城市服务";
                    for (NSDictionary *info in urbanservices) {
                        ServiceCityModel *md = [ServiceCityModel createWithInfo:info];
                        md.rcType = RCT_URBANSERVICE;
                        [model.items addObject:md];
                    }
                    [_dataArray addObject:model];
                }
                NSArray *recommends = data[@"recommends"];
                if ([recommends isKindOfClass:[NSArray class]] && recommends.count) {
                    ServiceSectionModel *model = [ServiceSectionModel new];
                    model.title = @"精品推荐";
                    for (NSDictionary *info in recommends) {
                        ServiceBannerModel *md = [ServiceBannerModel createWithInfo:info];
                        md.rcType = RCT_RECOMMENDCLICK;
                        [model.items addObject:md];
                    }
                    [_dataArray addObject:model];
                }
                NSArray *services = data[@"services"];
                if ([services isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *info in services) {
                        ServiceSectionModel *model = [ServiceSectionModel createWithInfo:info];
                        [_dataArray addObject:model];
                    }
                }
                [_listView reloadData];
            }
        } else {
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
    if (title.length) webVC.title = title;
    webVC.url = url;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleMobClick:(NSString *)title
{
    NSString *event = nil;
    if ([title isEqualToString:@"招聘"]) {
        event = @"life_recruit";
    } else if ([title isEqualToString:@"二手"]) {
        event = @"life_secondhand";
    } else if ([title isEqualToString:@"租房"]) {
        event = @"life_rental";
    } else if ([title isEqualToString:@"家政"]) {
        event = @"life_service";
    } else if ([title isEqualToString:@"更多"]) {
        event = @"life_more";
    } else if ([title isEqualToString:@"社保查询"]) {
        event = @"life_socialinsurance";
    } else if ([title isEqualToString:@"积分入户"]) {
        event = @"life_integralhome";
    } else if ([title isEqualToString:@"发票真伪"]) {
        event = @"life_invoice";
    } else if ([title isEqualToString:@"违章查询"]) {
        event = @"life_peccancy";
    } else if ([title isEqualToString:@"积分入学"]) {
        event = @"life_integralstudy";
    } else if ([title isEqualToString:@"公交查询"]) {
        event = @"life_bus";
    } else if ([title isEqualToString:@"火车票"]) {
        event = @"life_trainticket";
    } else if ([title isEqualToString:@"汽车票"]) {
        event = @"life_busticket";
    } else if ([title isEqualToString:@"飞机票"]) {
        event = @"life_planeticket";
    } else if ([title isEqualToString:@"预约挂号"]) {
        event = @"life_docappointment";
    } else if ([title isEqualToString:@"医院查询"]) {
        event = @"life_hospitical";
    }
    if (event.length) MobClick(event);
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
        if ([sModel.title isEqualToString:@""] || [sModel.title isEqualToString:@"精品推荐"]) {
            return 1;
        } else {
            return sModel.items.count;
        }
    }
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[section];
        if ([sModel.title isEqualToString:@"城市服务"]) {
            return UIEdgeInsetsMake(0, (kScreenWidth - 44 * 5) / 6, 20, (kScreenWidth - 44 * 5) / 6);
        } else if ([sModel.title isEqualToString:@"精品推荐"]) {
            return UIEdgeInsetsMake(0, 0, 16, 0);
        }
    }
    return UIEdgeInsetsZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[indexPath.section];
        if ([sModel.title isEqualToString:@""]) {
            return CGSizeMake(kScreenWidth, kScreenWidth / 375 * 67);
        } else if ([sModel.title isEqualToString:@"城市服务"]) {
            return CGSizeMake(44, 73);
        } else if ([sModel.title isEqualToString:@"精品推荐"]) {
            return CGSizeMake(kScreenWidth, kScreenWidth / 357 * 74);
        } else {
            return CGSizeMake(kScreenWidth / 4.0, 81.0);
        }
    }
    return CGSizeZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (indexPath.section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[indexPath.section];
        NSString *reuseIdentifier = nil;
        if ([sModel.title isEqualToString:@""] || [sModel.title isEqualToString:@"精品推荐"]) {
            reuseIdentifier = @"ServiceBannerCell";
        } else if ([sModel.title isEqualToString:@"城市服务"]) {
            reuseIdentifier = @"ServiceCityCell";
        } else {
            reuseIdentifier = @"ServiceCell";
        }
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        __weak typeof(self) wself = self;
        if (indexPath.row < sModel.items.count) {
            if ([sModel.title isEqualToString:@""] || [sModel.title isEqualToString:@"精品推荐"]) {
                ServiceBannerCell *bannerCell = (ServiceBannerCell *)cell;
                [bannerCell setBannerValue:sModel];
                bannerCell.tapBlock = ^ (ServiceBannerModel *model) {
                    ReportClickModel *rcModel = [ReportClickModel new];
                    rcModel.id_ = model.id_;
                    rcModel.type = model.rcType;
                    [SApp reportClick:rcModel];
                    if (model.type == JumpType_Web) {
                        [wself openWebVCWithTitle:nil url:model.dst];
                    } else if (model.type == JumpType_Application) {
                        [wself gotoNewsTabWithDst:model.dst];
                    }
                };
            } else if ([sModel.title isEqualToString:@"城市服务"]) {
                ServiceCityModel *model = sModel.items[indexPath.row];
                ServiceCityCell *cityCell = (ServiceCityCell *)cell;
                [cityCell setCityValue:model];
                cityCell.btnClick = ^ (ServiceCityModel *model) {
                    ReportClickModel *rcModel = [ReportClickModel new];
                    rcModel.id_ = model.id_;
                    rcModel.type = model.rcType;
                    [SApp reportClick:rcModel];
                    [wself openWebVCWithTitle:model.title url:model.dst];
                };
            } else {
                ServiceCellModel *model = sModel.items[indexPath.row];
                [((ServiceCell *)cell) setTitle:model.title icon:model.icon];
            }
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        ServiceSectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ServiceSectionHeader" forIndexPath:indexPath];
        if (indexPath.section < _dataArray.count) {
            ServiceSectionModel *sModel = _dataArray[indexPath.section];
            [header setTitle:sModel.title];
        }
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        ServiceSectionFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"ServiceSectionFooter" forIndexPath:indexPath];
        return footer;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (indexPath.section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[indexPath.section];
        if ([sModel.title isEqualToString:@""] || [sModel.title isEqualToString:@"精品推荐"]) {
            
        } else if ([sModel.title isEqualToString:@"城市服务"]) {
            
        } else {
            ServiceCellModel *model = sModel.items[indexPath.row];
            ReportClickModel *rcModel = [ReportClickModel new];
            rcModel.id_ = model.sid;
            rcModel.type = model.rcType;
            [SApp reportClick:rcModel];
            [self openWebVCWithTitle:model.title url:model.dst];
        }
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[section];
        if ([sModel.title isEqualToString:@"城市服务"]) {
            return 20;
        } else {
            return 0;
        }
    }
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    if (section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[section];
        if ([sModel.title isEqualToString:@"城市服务"]) {
            return floor((kScreenWidth - 44 * 5) / 6);
        } else {
            return 0;
        }
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[section];
        if ([sModel.title isEqualToString:@""]) {
            return CGSizeZero;
        } else {
            return CGSizeMake(kScreenWidth, 56);
        }
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section < _dataArray.count) {
        ServiceSectionModel *sModel = _dataArray[section];
        if ([sModel.title isEqualToString:@""]) {
            return CGSizeZero;
        } else {
            return CGSizeMake(kScreenWidth, 12);
        }
    }
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
