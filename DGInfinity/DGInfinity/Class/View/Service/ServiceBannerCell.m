//
//  ServiceBannerCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/27.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "ServiceBannerCell.h"

#define TileInitialTag 10000

@interface ServiceBannerCell () <UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *_banner;
    __weak IBOutlet UIPageControl *_pageControl;
    
    NSArray *_bannerModels;
    NSTimer *_timer;
}
@end

@implementation ServiceBannerCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _banner.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopTimer) name:kNCServiceViewControllerDealloc object:nil];
}

- (void)setBannerValue:(ServiceSectionModel *)model
{
    if (_banner.subviews.count) {
        [_banner.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    [self stopTimer];
    _bannerModels = model.items;
    _pageControl.numberOfPages = model.items.count;
    _pageControl.hidden = model.items.count == 1;
    [_pageControl setCurrentPage:0];
    CGFloat itemWidth = 0;
    CGFloat itemHeight = 0;
    CGFloat padding = 0;
    if ([model.title isEqualToString:@""]) {
        itemWidth = kScreenWidth;
        itemHeight = kScreenWidth / 375 * 67;
    } else {
        itemWidth = kScreenWidth - 24;
        itemHeight = kScreenWidth / 357 * 74;
        padding = 12;
    }
    NSInteger imageViewCount = 0;
    if (model.items.count > 1) {
        imageViewCount = 3;
        [_banner setContentSize:CGSizeMake(imageViewCount * kScreenWidth, itemHeight)];
        _banner.contentOffset = CGPointMake(kScreenWidth, 0);
    } else {
        imageViewCount = 1;
        [_banner setContentSize:CGSizeMake(kScreenWidth, itemHeight)];
        _banner.contentOffset = CGPointZero;
    }
    for (int i = 0; i < imageViewCount; i++) {
        NSInteger index = 0;
        if (i == 0) {
            index = _bannerModels.count - 1;
        } else if (i == 1) {
            index = 0;
        } else {
            index = 1;
        }
        
        ServiceBannerModel *md = _bannerModels[index];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
        imgView.x = i * kScreenWidth + padding;
        imgView.tag = TileInitialTag + index;
        imgView.backgroundColor = COLOR(240, 240, 240, 1);
        [imgView yy_setImageWithURL:[NSURL URLWithString:md.img] options:YYWebImageOptionSetImageWithFadeAnimation];
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTap:)]];
        [_banner addSubview:imgView];
    }
    [self startTimer];
}

- (void)bannerTap:(UITapGestureRecognizer *)sender {
    if (_tapBlock) {
        NSInteger index = sender.view.tag - TileInitialTag;
        if (index < _bannerModels.count) {
            _tapBlock(_bannerModels[index]);
        }
    }
}

- (void)startTimer
{
    if (_bannerModels.count > 1) {
        _timer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)nextPage
{
    // 执行了setContentOffset:方法,系统会自动调用scrollViewDidEndScrollingAnimation:方法,在这个方法里面再设置回偏移量等于一倍的宽度,同时更换各个imageview的图片,那么还是相当于中间的那个imageView显示在屏幕上
    [_banner setContentOffset:CGPointMake(kScreenWidth * 2, 0) animated:YES];
}

- (void)updateContent
{
    // 先判断出scrollView的操作行为是向左向右还是不动
    int flag;
    if (_banner.contentOffset.x > kScreenWidth) {
        flag = 1;
    } else if (_banner.contentOffset.x == 0) {
        flag = -1;
    } else {
        return;
    }
    
    for (UIImageView *imgView in _banner.subviews) {
        NSInteger index = imgView.tag + flag;
        if (index < TileInitialTag) {
            index = _bannerModels.count - 1 + TileInitialTag;
        } else if (index >= _bannerModels.count + TileInitialTag) {
            index = TileInitialTag;
        }
        imgView.tag = index;
        ServiceBannerModel *md = _bannerModels[index - TileInitialTag];
        [imgView yy_setImageWithURL:[NSURL URLWithString:md.img] options:YYWebImageOptionSetImageWithFadeAnimation];
    }
    
    _pageControl.currentPage = [_banner.subviews[1] tag] - TileInitialTag;
    _banner.contentOffset = CGPointMake(kScreenWidth, 0);
}

#pragma mark - UIScrollViewDelegate
// 人为拖拽停止并且减速完全停止时会调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateContent];
}

// 用户开始拖拽,停止定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}

// 用户停止拖拽,开启定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}

// 在调用setContentOffset方法的时候，会触发此代理方法
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateContent];
}

@end
