//
//  WiFiWelfareViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/18.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiWelfareViewController.h"
#import "WiFiCGI.h"

@interface WiFiWelfareViewController ()
{
    __weak IBOutlet UITextField *_ssidField;
    __weak IBOutlet UITextField *_passwordField;
    
}
@end

@implementation WiFiWelfareViewController

- (NSString *)title
{
    return @"WiFi公益";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)commitBtnClick:(id)sender {
    if (!_ssidField.text.length || !_passwordField.text.length) return;
    if (![[BaiduMapSDK shareBaiduMapSDK] locationServicesEnabled]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"无法获取位置信息，建议开启定位服务" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"开启" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [Tools openSetting];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [SVProgressHUD show];
    CLLocationCoordinate2D coordinate = [[BaiduMapSDK shareBaiduMapSDK] getUserLocation].location.coordinate;
    [WiFiCGI reportWifi:_ssidField.text password:_passwordField.text longitudu:coordinate.longitude latitude:coordinate.latitude complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            [self makeToast:@"上报成功，感谢您的无私奉献"];
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
