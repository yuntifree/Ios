//
//  NewsViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsReportViewController.h"
#import "NewsVideoViewController.h"
#import "NewsBaseViewController.h"
#import "XHScrollMenu.h"
#import "NewsMenuModel.h"
#import "WebViewController.h"
#import "NewsCGI.h"
#import "LiveListViewController.h"
#import "JokeListViewController.h"

@interface NewsViewController () <UIScrollViewDelegate, XHScrollMenuDelegate>
{
    NSInteger _lastSelectedIndex;
}

@property (nonatomic, strong) NSMutableArray *menuModels;

@property (nonatomic, strong) XHScrollMenu *scrollMenu;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation NewsViewController

#pragma mark - lazy-init
- (NSMutableArray *)menuModels
{
    if (!_menuModels) {
        _menuModels = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _menuModels;
}

- (XHScrollMenu *)scrollMenu
{
    if (!_scrollMenu) {
        _scrollMenu = [[XHScrollMenu alloc] initWithFrame:self.navigationController.navigationBar.bounds];
        _scrollMenu.showIndicatorView = NO;
        _scrollMenu.buttonTitleEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
        _scrollMenu.delegate = self;
        self.navigationItem.titleView = _scrollMenu;
    }
    return _scrollMenu;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        CGFloat height = kScreenHeight - 20 - 44 - 49;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delaysContentTouches = NO;
        _scrollView.scrollsToTop = NO;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (NSString *)title
{
    return @"";
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastSelectedIndex = 0;
        _defaultType = 0;
        _jumped = NO;
    }
    return self;
}

- (void)setData:(NSDictionary *)data
{
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSArray *infos = data[@"infos"];
        if ([infos isKindOfClass:[NSArray class]]) {
            [self cleanAllData];
            NSMutableArray *menus = [[NSMutableArray alloc] initWithCapacity:1];
            for (NSDictionary *info in infos) {
                if (![self isSupportedCtype:[info[@"ctype"] integerValue]]) continue;
                NewsMenuModel *model = [NewsMenuModel createWithInfo:info];
                if (model.ctype == MenuCTypeLive) {
                    model.type = NT_LIVE;
                }
                [self.menuModels addObject:model];
                XHMenu *menu = [[XHMenu alloc] init];
                menu.title = model.title;
                menu.titleNormalColor = COLOR(255, 255, 255, 0.6);
                menu.titleSelectedColor = [UIColor whiteColor];
                menu.titleFont = SystemFont(17);
                [menus addObject:menu];
            }
            
            self.scrollMenu.menus = menus;
            self.scrollMenu.shouldUniformizeMenus = IPHONE6P ? menus.count <= 6 : menus.count <= 5;
            [self.scrollMenu reloadData];
            
            for (int i = 0; i < self.menuModels.count; i++) {
                NewsMenuModel *model = self.menuModels[i];
                NewsBaseViewController *vc = nil;
                switch (model.ctype) {
                    case MenuCTypeNews:
                    {
                        vc = [[NewsReportViewController alloc] init];
                    }
                        break;
                    case MenuCTypeVideo:
                    {
                        vc = [[NewsVideoViewController alloc] init];
                    }
                        break;
                    case MenuCTypeLive:
                    {
                        vc = [[LiveListViewController alloc] init];
                    }
                        break;
                    case MenuCTypeJoke:
                    {
                        vc = [[JokeListViewController alloc] init];
                    }
                        break;
                    default:
                        break;
                }
                if (vc) {
                    vc.type = model.type;
                    vc.view.frame = CGRectMake(i * kScreenWidth, 0, kScreenWidth, self.scrollView.height);
                    [self addChildViewController:vc];
                    [self.scrollView addSubview:vc.view];
                }
            }
            self.scrollView.contentSize = CGSizeMake(kScreenWidth * self.scrollView.subviews.count, self.scrollView.height);
            if (!self.jumped) {
                NSInteger week = [NSDate weekdayFromDate:[NSDate date]];
                NSString *hourStr = [NSDate stringWithDate:[NSDate date] formatStr:@"HH"];
                NSInteger hour = [hourStr integerValue];
                if (week >= 2 && week <= 6 && hour >= 8 && hour <= 19) { // 星期一到星期五 早8晚8
                    self.defaultType = NT_REPORT;
                } else {
                    self.defaultType = NT_LIVE;
                }
            }
            [self setCurrentPage:self.defaultType];
        }
    } else {
        self.title = @"头条";
    }
}

- (void)cleanAllData
{
    if (self.menuModels.count) {
        [self.menuModels removeAllObjects];
    }
    if (self.scrollView.subviews.count) {
        [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
}

- (BOOL)isSupportedCtype:(NSInteger)ctype
{
    return ctype == MenuCTypeNews || ctype == MenuCTypeVideo || ctype == MenuCTypeWeb || ctype == MenuCTypeLive || ctype == MenuCTypeJoke;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.menuModels.count) {
        [self getMenu];
    } else {
        [self setCurrentPage:self.defaultType];
    }
}

- (void)getMenu
{
    [NewsCGI getMenu:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                self.data = data;
            }
        } else {
            self.title = @"头条";
            if (E_CGI_FAILED != res._errno) {
                [self makeToast:res.desc];
            } else {
                __weak typeof(self) wself = self;
                [self.scrollView configureNoNetStyleWithdidTapButtonBlock:^{
                    [wself getMenu];
                } didTapViewBlock:^{
                    
                }];
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleChildViewControllerLoadDataWithIndex:(NSInteger)index
{
    if (index >= self.childViewControllers.count) return;
    NewsBaseViewController *vc = self.childViewControllers[index];
    [vc loadData];
    // 预加载相邻两个页面数据
    /*
    if (!index) {
        if (index + 1 < self.childViewControllers.count) {
            NewsBaseViewController *backVC = self.childViewControllers[index + 1];
            [backVC loadData];
        }
    } else if (index > 0 && index < self.childViewControllers.count - 1) {
        NewsBaseViewController *frontVC = self.childViewControllers[index - 1];
        [frontVC loadData];
        NewsBaseViewController *backVC = self.childViewControllers[index + 1];
        [backVC loadData];
    } else {
        NewsBaseViewController *frontVC = self.childViewControllers[index - 1];
        [frontVC loadData];
    }
     */
}

- (void)setCurrentPage:(NSInteger)type
{
    if (type == -1) return;
    self.scrollView.scrollEnabled = YES;
    self.defaultType = -1;
    __block NSInteger index = 0;
    [self.menuModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NewsMenuModel *model = (NewsMenuModel *)obj;
        if (model.type == type) {
            index = idx;
            *stop = YES;
        }
    }];
    [self.scrollView setContentOffset:CGPointMake(index * kScreenWidth, 0) animated:NO];
    [self.scrollMenu setSelectedIndex:index animated:YES calledDelegate:NO];
    [self setScrollsToTopWithTag:index];
    [self handleChildViewControllerLoadDataWithIndex:index];
}

- (void)setScrollsToTopWithTag:(NSInteger)tag
{
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NewsBaseViewController *vc = (NewsBaseViewController *)obj;
        vc.scrollsToTop = idx == tag;
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger tag = scrollView.contentOffset.x / scrollView.width;
    [self setScrollsToTopWithTag:tag];
    [self.scrollMenu setSelectedIndex:tag animated:YES calledDelegate:NO];
    [self handleChildViewControllerLoadDataWithIndex:tag];
}

#pragma mark - XHScrollMenuDelegate
- (void)scrollMenuWillSelect:(XHScrollMenu *)scrollMenu menuIndex:(NSUInteger)selectIndex
{
    _lastSelectedIndex = self.scrollMenu.selectedIndex;
}

- (void)scrollMenuDidSelected:(XHScrollMenu *)scrollMenu menuIndex:(NSUInteger)selectIndex
{
    NewsMenuModel *model = self.menuModels[selectIndex];
    switch (model.ctype) {
        case MenuCTypeNews:
        case MenuCTypeVideo:
        case MenuCTypeLive:
        case MenuCTypeJoke:
        {
            [self.scrollView setContentOffset:CGPointMake(selectIndex * kScreenWidth, 0) animated:NO];
            [self setScrollsToTopWithTag:selectIndex];
            [self handleChildViewControllerLoadDataWithIndex:selectIndex];
        }
            break;
        case MenuCTypeWeb:
        {
            WebViewController *vc = [[WebViewController alloc] init];
            vc.url = model.dst;
            [self.navigationController pushViewController:vc animated:YES];
            [self.scrollMenu setSelectedIndex:_lastSelectedIndex animated:NO calledDelegate:NO];
        }
            break;
        default:
            break;
    }
}

@end
