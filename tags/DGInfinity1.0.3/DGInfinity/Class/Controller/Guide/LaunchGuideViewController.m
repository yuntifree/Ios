//
//  LaunchGuideViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/22.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "LaunchGuideViewController.h"

@interface LaunchGuideViewController ()

@end

@implementation LaunchGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.contentSize = CGSizeMake(kScreenWidth * 3, kScreenHeight);
    scroll.pagingEnabled = YES;
    scroll.delaysContentTouches = NO;
    scroll.bounces = NO;
    [self.view addSubview:scroll];
    
    NSArray *imgArray = @[@"img_Loading1.png", @"img_Loading2.png", @"img_Loading3.png"];
    for (int i = 0; i < imgArray.count; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * kScreenWidth, 0, kScreenWidth, kScreenHeight)];
        NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imgArray[i]];
        imgView.image = [UIImage imageWithContentsOfFile:imagePath];
        [scroll addSubview:imgView];
    }
    
    UIButton *goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    goBtn.frame = CGRectMake(kScreenWidth * 2 + (kScreenWidth - 176) / 2, kScreenHeight - 100 * [Tools layoutFactor], 176, 40);
    goBtn.layer.cornerRadius = 8;
    goBtn.layer.borderWidth = 1;
    goBtn.layer.borderColor = COLOR(74, 144, 226, 1).CGColor;
    goBtn.titleLabel.font = SystemFont(18);
    [goBtn setTitleColor:COLOR(74, 144, 226, 1) forState:UIControlStateNormal];
    [goBtn setTitleColor:COLOR(74, 144, 226, 0.6) forState:UIControlStateHighlighted];
    [goBtn setTitle:@"立即体验" forState:UIControlStateNormal];
    [goBtn addTarget:self action:@selector(goBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:goBtn];
}

- (void)goBtnClick:(UIButton *)button
{
    if (_block) {
        _block();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
