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
#import "NewsTitleView.h"

@interface NewsViewController () <UIScrollViewDelegate>
{
    NewsTitleView *_titleView;
    UIScrollView *_scrollView;
    
    UIButton *_selectedBtn;
}
@end

@implementation NewsViewController

- (NSString *)title
{
    return @"头条";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpScrollView];
    [self setUpTitleView];
}

- (void)setUpTitleView
{
    _titleView = [[NewsTitleView alloc] initWithFrame:CGRectMake(0, 0, 148, 44)];
    self.navigationItem.titleView = _titleView;
    __weak typeof(_scrollView) ws = _scrollView;
    _titleView.block = ^ (NSInteger tag) {
        [ws setContentOffset:CGPointMake(tag * kScreenWidth, 0) animated:YES];
    };
}

- (void)setUpScrollView
{
    CGFloat height = kScreenHeight - 20 - 44 - 49;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, height)];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(2 * kScreenWidth, 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    [self.view sendSubviewToBack:_scrollView];
    
    NewsReportViewController *reportVC = [[NewsReportViewController alloc] init];
    reportVC.view.frame = CGRectMake(0, 0, kScreenWidth, height);
    [self addChildViewController:reportVC];
    [_scrollView addSubview:reportVC.view];
    
    NewsVideoViewController *videoVC = [[NewsVideoViewController alloc] init];
    videoVC.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, height);
    [self addChildViewController:videoVC];
    [_scrollView addSubview:videoVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_titleView changeBtn:scrollView.contentOffset.x / scrollView.width + 1000];
}

@end
