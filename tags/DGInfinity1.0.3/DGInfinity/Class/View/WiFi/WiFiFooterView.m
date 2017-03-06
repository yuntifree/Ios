//
//  WiFiFooterView.m
//  DGInfinity
//
//  Created by myeah on 16/11/11.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiFooterView.h"
#import "UIButton+Vertical.h"

@interface WiFiFooterView () <UIScrollViewDelegate>
{
    IBOutletCollection(UIButton) NSArray *_sectionBtns;
    __weak IBOutlet UILabel *_totalLbl;
    __weak IBOutlet UILabel *_saveLbl;
    __weak IBOutlet UIScrollView *_banner;
    __weak IBOutlet UIPageControl *_pageControl;
    
    __weak IBOutlet NSLayoutConstraint *_sectionViewHeight;
    __weak IBOutlet NSLayoutConstraint *_serviceBottom;
    
    NSMutableArray *_banners;
    dispatch_source_t _timer;
}
@end

@implementation WiFiFooterView

- (void)dealloc
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _banners = [NSMutableArray arrayWithCapacity:5];
    
    _banner.delegate = self;
    
    for (UIButton *button in _sectionBtns) {
        [button verticalImageAndTitle:7];
    }
    
    _sectionViewHeight.constant = 110.5f;
    _serviceBottom.constant = 0;
}

- (void)setFrontInfo:(NSDictionary *)frontInfo
{
    NSDictionary *user = frontInfo[@"user"];
    if ([user isKindOfClass:[NSDictionary class]]) {
        _totalLbl.text = [NSString stringWithFormat:@"%ld",[user[@"total"] integerValue]];
        _saveLbl.text = [NSString stringWithFormat:@"%ld",[user[@"save"] integerValue]];
    }
    NSArray *banners = frontInfo[@"banner"];
    if ([banners isKindOfClass:[NSArray class]] && banners.count) {
        if (_banner.subviews.count) {
            [_banner.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [_banners removeAllObjects];
        }
        if (_timer) {
            dispatch_source_cancel(_timer);
            _timer = nil;
        }
        [_banners addObjectsFromArray:banners];
        _pageControl.numberOfPages = banners.count;
        _pageControl.hidden = banners.count == 1;
        [_pageControl setCurrentPage:0];
        if (banners.count > 1) {
            [_banners insertObject:banners.lastObject atIndex:0];
            [_banners addObject:banners.firstObject];
            [_banner setContentSize:CGSizeMake(_banners.count * _banner.width, _banner.height)];
            [_banner setContentOffset:CGPointMake(_banner.width, 0) animated:NO];
            [self fireTimer];
        } else {
            [_banner setContentSize:CGSizeMake(_banner.width, _banner.height)];
            [_banner setContentOffset:CGPointZero animated:NO];
        }
        for (int i = 0; i < _banners.count; i++) {
            NSDictionary *info = _banners[i];
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:_banner.bounds];
            imgView.x = i * _banner.width;
            imgView.tag = 10000 + i;
            imgView.backgroundColor = COLOR(240, 240, 240, 1);
            [imgView yy_setImageWithURL:[NSURL URLWithString:info[@"img"]] options:YYWebImageOptionSetImageWithFadeAnimation];
            imgView.userInteractionEnabled = YES;
            [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTap:)]];
            [_banner addSubview:imgView];
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

- (IBAction)btnClick:(UIButton *)sender {
    if (_block) {
        _block(sender.tag);
    }
}

- (void)bannerTap:(UITapGestureRecognizer *)sender {
    if (_tap) {
        NSInteger index = sender.view.tag - 10000;
        if (index < _banners.count) {
            _tap(_banners[index][@"dst"]);
        }
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
