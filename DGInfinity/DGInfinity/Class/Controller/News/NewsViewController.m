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
    
    NewsReportViewController *_reportVC;
    NewsVideoViewController *_videoVC;
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
    __weak typeof(self) wself = self;
    _titleView.block = ^ (NSInteger tag) {
        [ws setContentOffset:CGPointMake(tag * kScreenWidth, 0) animated:YES];
        [wself setScrollsToTopWithTag:tag];
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
    _scrollView.delaysContentTouches = NO;
    _scrollView.scrollsToTop = NO;
    [self.view addSubview:_scrollView];
    [self.view sendSubviewToBack:_scrollView];
    
    _reportVC = [[NewsReportViewController alloc] init];
    _reportVC.view.frame = CGRectMake(0, 0, kScreenWidth, height);
    [self addChildViewController:_reportVC];
    [_scrollView addSubview:_reportVC.view];
    
    _videoVC = [[NewsVideoViewController alloc] init];
    _videoVC.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, height);
    [self addChildViewController:_videoVC];
    [_scrollView addSubview:_videoVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentPage:(NSInteger)index
{
    self.view.backgroundColor = [UIColor whiteColor]; // 隐式调用viewDidLoad
    [_scrollView setContentOffset:CGPointMake(index * kScreenWidth, 0) animated:NO];
    [_titleView changeBtn:index + 1000];
    [self setScrollsToTopWithTag:index];
}

- (void)setScrollsToTopWithTag:(NSInteger)tag
{
    _reportVC.scrollsToTop = !tag;
    _videoVC.scrollsToTop = tag > 0;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger tag = scrollView.contentOffset.x / scrollView.width;
    [_titleView changeBtn:tag + 1000];
    [self setScrollsToTopWithTag:tag];
}

@end
