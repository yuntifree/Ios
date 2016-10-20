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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 10, 24, 24);
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIGraphicsBeginImageContextWithOptions(backBtn.frame.size, 0, [UIScreen mainScreen].scale);
    [[UIColor clearColor] set];
    UIRectFill(CGRectMake(0, 0, backBtn.frame.size.width, backBtn.frame.size.height));
    
    UIImage *image = ImageNamed(@"icon_back");
    [image drawInRect:CGRectMake(0, (backBtn.frame.size.height - image.size.height)/2, image.size.width, image.size.height) blendMode:kCGBlendModeNormal alpha:0.5];
    UIImage *highLightedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [backBtn setBackgroundImage:image forState:UIControlStateNormal];
    [backBtn setBackgroundImage:highLightedImage forState:UIControlStateHighlighted];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFixedSpace target: nil action: nil];
    fixedSpaceBarButtonItem.width = -5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:fixedSpaceBarButtonItem, backBarButtonItem, nil];
}

- (void)backBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showHint:(NSString *)hint
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:hint message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
