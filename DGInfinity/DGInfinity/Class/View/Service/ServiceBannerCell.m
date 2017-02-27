//
//  ServiceBannerCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/27.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "ServiceBannerCell.h"

@interface ServiceBannerCell () <UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *_banner;
    __weak IBOutlet UIPageControl *_pageControl;
    
    NSMutableArray *_banners;
    dispatch_source_t _timer;
}
@end

@implementation ServiceBannerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _banners = [NSMutableArray arrayWithCapacity:5];
    _banner.delegate = self;
}

- (void)setBannerValue:(ServiceSectionModel *)model
{
    if (_banner.subviews.count) {
        [_banner.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_banners removeAllObjects];
    }
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    [_banners addObjectsFromArray:model.items];
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
    if (model.items.count > 1) {
        [_banners insertObject:model.items.lastObject atIndex:0];
        [_banners addObject:model.items.firstObject];
        [_banner setContentSize:CGSizeMake(_banners.count * kScreenWidth, itemHeight)];
        [_banner setContentOffset:CGPointMake(kScreenWidth, 0) animated:NO];
        [self fireTimer];
    } else {
        [_banner setContentSize:CGSizeMake(kScreenWidth, itemHeight)];
        [_banner setContentOffset:CGPointZero animated:NO];
    }
    for (int i = 0; i < _banners.count; i++) {
        ServiceBannerModel *md = _banners[i];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
        imgView.x = i * kScreenWidth + padding;
        imgView.tag = 10000 + i;
        imgView.backgroundColor = COLOR(240, 240, 240, 1);
        [imgView yy_setImageWithURL:[NSURL URLWithString:md.img] options:YYWebImageOptionSetImageWithFadeAnimation];
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTap:)]];
        [_banner addSubview:imgView];
    }
}

- (void)bannerTap:(UITapGestureRecognizer *)sender {
    if (_tapBlock) {
        NSInteger index = sender.view.tag - 10000;
        if (index < _banners.count) {
            _tapBlock(_banners[index]);
        }
    }
}

- (void)fireTimer
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 5.0 * NSEC_PER_SEC, 0);
    __weak typeof(self) wself = self;
    dispatch_source_set_event_handler(_timer, ^{
        [wself timerRun];
    });
    dispatch_resume(_timer);
}

- (void)timerRun
{
    NSInteger index = _banner.contentOffset.x / _banner.width;
    if (index > 0 && index < _banners.count - 1) {
        [UIView animateWithDuration:0.25 animations:^{
            [_banner setContentOffset:CGPointMake((index + 1) * _banner.width, 0)];
        } completion:^(BOOL finished) {
            [self updateContent];
        }];
    }
}

- (void)updateContent
{
    NSInteger index = _banner.contentOffset.x / _banner.width;
    if (index == 0) {
        [_banner setContentOffset:CGPointMake((_banners.count - 2) * _banner.width, 0) animated:NO];
        [_pageControl setCurrentPage:_banners.count - 3];
    } else if (index == _banners.count - 1) {
        [_banner setContentOffset:CGPointMake(_banner.width, 0) animated:NO];
        [_pageControl setCurrentPage:0];
    } else {
        [_pageControl setCurrentPage:index - 1];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateContent];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_timer) {
        dispatch_suspend(_timer);
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (_timer) {
        dispatch_resume(_timer);
    }
}

@end
