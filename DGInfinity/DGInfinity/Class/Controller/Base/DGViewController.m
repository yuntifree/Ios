//
//  DGViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGViewController.h"

@interface DGViewController ()

@end

@implementation DGViewController

- (void)dealloc
{
    DDDLog(@"%@ Dealloc",MobClick_getVCName);
}

- (UIButton *)backBtn
{
    if (_backBtn == nil) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(10, 10, 24, 24);
        [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIGraphicsBeginImageContextWithOptions(_backBtn.frame.size, 0, [UIScreen mainScreen].scale);
        [[UIColor clearColor] set];
        UIRectFill(CGRectMake(0, 0, _backBtn.frame.size.width, _backBtn.frame.size.height));
        
        UIImage *image = ImageNamed(@"icon_back");
        [image drawInRect:CGRectMake(0, (_backBtn.frame.size.height - image.size.height)/2, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:0.5];
        UIImage *highLightedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [_backBtn setBackgroundImage:image forState:UIControlStateNormal];
        [_backBtn setBackgroundImage:highLightedImage forState:UIControlStateHighlighted];
    }
    return _backBtn;
}

- (UIButton *)closeBtn
{
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(0, 0, 44, 44);
        [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _closeBtn;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    MobClickBegin;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    MobClickEnd;
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if ([self.navigationController.viewControllers count] > 1) {
        [self setUpBackItem];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)setUpBackItem
{
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFixedSpace target: nil action: nil];
    fixedSpaceBarButtonItem.width = -5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixedSpaceBarButtonItem, backBarButtonItem, nil];
}

- (void)setUpCloseItem
{
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.backBtn];
    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFixedSpace target: nil action: nil];
    UIBarButtonItem *closeBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.closeBtn];
    fixedSpaceBarButtonItem.width = -5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:backBarButtonItem, closeBarButtonItem, nil];
}

- (void)backBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeBtnClick:(id)sender
{
    
}

- (void)showHint:(NSString *)hint
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:hint message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
