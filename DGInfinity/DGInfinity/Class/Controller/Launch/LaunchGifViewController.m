//
//  LaunchGifViewController.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/3/13.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "LaunchGifViewController.h"

@interface LaunchGifViewController ()
{
    UIImageView *_gifView;
}
@end

@implementation LaunchGifViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _gifView.image = _gifView.animationImages.lastObject;
    [_gifView startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KNC_LOGIN object:nil];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _gifView = [UIImageView new];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:12];
    for (int i = 0; i < 12; i++) {
        NSString *imageName = [[NSString alloc] initWithFormat:@"gif_%c.png",i + 97];
        [images addObject:ImageForPath(imageName)];
    }
    _gifView.animationImages = images;
    _gifView.animationRepeatCount = 1;
    _gifView.animationDuration = 1.5;
    [self.view addSubview:_gifView];
    [_gifView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@113);
        make.height.equalTo(@113);
        make.top.equalTo(self.view).offset(175 * [Tools layoutFactor]);
    }];
    
    UIImageView *sloganView = [UIImageView new];
    sloganView.image = ImageForPath(@"loading_img_text.png");
    [self.view addSubview:sloganView];
    [sloganView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@216);
        make.height.equalTo(@54);
        make.top.equalTo(_gifView.mas_bottom).offset(18);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
