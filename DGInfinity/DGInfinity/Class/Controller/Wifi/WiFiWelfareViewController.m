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
    __weak IBOutlet UIButton *_commitBtn;
    
    __weak IBOutlet NSLayoutConstraint *_firstLblTop;
    __weak IBOutlet NSLayoutConstraint *_formTop;
    
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
    
    [self setUpSubViews];
    [self updateConstraint];
}

- (void)setUpSubViews
{
    // textfield
    NSDictionary *attriDic = @{NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium],
                               NSForegroundColorAttributeName: COLOR(180, 180, 180, 1)};
    _ssidField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入无线网络名称" attributes:attriDic];
    _passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入无线网络密码" attributes:attriDic];
}

- (void)updateConstraint
{
    if (IPHONE4) {
        _firstLblTop.constant = 14.0f;
        _formTop.constant = 16.0f;
    } else {
        _firstLblTop.constant *= [Tools layoutFactor];
        _formTop.constant *= [Tools layoutFactor];
    }
}

- (IBAction)textFieldEditingChanged:(id)sender {
    if (_ssidField.text.length && _passwordField.text.length) {
        _commitBtn.enabled = YES;
    } else {
        _commitBtn.enabled = NO;
    }
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
            _ssidField.text = nil;
            _passwordField.text = nil;
            _commitBtn.enabled = NO;
            [self makeToast:@"上报成功，东莞有你更精彩"];
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
