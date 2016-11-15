//
//  WiFiQrcodeFailViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiQrcodeFailViewController.h"

@interface WiFiQrcodeFailViewController ()

@end

@implementation WiFiQrcodeFailViewController

- (NSString *)title
{
    return @"扫码快连";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"wif_qrcode_fail"]];
    [imageView sizeToFit];
    imageView.center = CGPointMake(self.view.width / 2, 51.0 / 667 * kScreenHeight + imageView.height / 2);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview: imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, kScreenWidth, 22)];
    label.y = imageView.y + imageView.height + 21;
    label.font = [UIFont systemFontOfSize: 18];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UICOLOR_ARGB(0xff888999);
    label.text = @"抱歉，无效二维码";
    label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview: label];
    
    CGFloat bottom = label.y + label.height;
    label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, kScreenWidth, 18)];
    label.y = bottom + 14;
    label.font = [UIFont systemFontOfSize: 14];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UICOLOR_ARGB(0xffaaabbb);
    label.text = @"该二维码不是免费WiFi";
    label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview: label];
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.width - 90) / 2, label.y + label.height + (IPHONE4 ? 10 : 45), 90, 30);
    [button setTitle: @"重新扫码" forState: UIControlStateNormal];
    [button setTitleColor: UICOLOR_ARGB(0xff259cff) forState: UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize: 18];
    [button addTarget: self action: @selector(tappedRetryButton:) forControlEvents: UIControlEventTouchUpInside];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview: button];
    
    label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, kScreenWidth, 16)];
    label.y = self.view.height - 30 - 16;
    label.font = [UIFont systemFontOfSize: 12];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UICOLOR_ARGB(0xffaaabbb);
    label.text = @"暂不识别非免费WiFi的二维码";
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview: label];
}

- (void)tappedBackButton:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated: YES];
}

- (void)tappedRetryButton:(id)sender
{
    [self.navigationController popViewControllerAnimated: YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
