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
        [self showAlertWithTitle:@"提示" message:@"无法获取位置信息，建议开启定位服务" cancelTitle:@"忽略" cancelHandler:nil defaultTitle:@"开启" defaultHandler:^(UIAlertAction *action) {
            [Tools openSetting];
        }];
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
