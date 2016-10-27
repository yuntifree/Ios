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

@interface NewsViewController () <UIScrollViewDelegate>
{
    __weak IBOutlet UIView *_titleView;
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
    
    [self setUpTitleView];
    [self setUpScrollView];
}

- (void)setUpTitleView
{
    _titleView.layer.shadowColor = [UIColor blackColor].CGColor;
    _titleView.layer.shadowOpacity = 0.8;
    _selectedBtn = (UIButton *)[_titleView viewWithTag:1000];
}

- (void)setUpScrollView
{
    CGFloat height = kScreenHeight - 20 - 44 - 40 - 49;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, height)];
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

- (IBAction)titleBtnClick:(UIButton *)sender {
    [self changeContentWithPage:sender.tag - 1000];
}

- (void)changeContentWithPage:(NSInteger)page
{
    UIButton *button = (UIButton *)[_titleView.subviews objectAtIndex:page];
    if (!button.selected) {
        button.selected = YES;
        _selectedBtn.selected = NO;
        _selectedBtn = button;
        [_scrollView setContentOffset:CGPointMake(page * kScreenWidth, 0) animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self changeContentWithPage:scrollView.contentOffset.x / scrollView.width];
}

@end
