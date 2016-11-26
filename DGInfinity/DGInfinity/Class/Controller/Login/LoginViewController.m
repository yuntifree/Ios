//
//  LoginViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/3.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "LoginViewController.h"
#import "AccountCGI.h"
#import "CheckUtil.h"
#import "UIButton+ResizableImage.h"
#import "WebViewController.h"

#define SECONDS 60

@interface LoginViewController ()
{
    __weak IBOutlet UITextField *_phoneField;
    __weak IBOutlet UITextField *_codeField;
    __weak IBOutlet UIButton *_codeBtn;
    __weak IBOutlet UIButton *_okBtn;
    __weak IBOutlet NSLayoutConstraint *_logoTop;
    
    int _seconds;
}

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation LoginViewController

#pragma mark - lazy-init
- (NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)timerRun
{
    if (_seconds == 0) {
        _codeBtn.enabled = YES;
        [_codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.timer setFireDate:[NSDate distantFuture]];
    } else {
        [_codeBtn setTitle:[NSString stringWithFormat:@"%is",_seconds--] forState:UIControlStateNormal];
    }
}

- (void)invalidateTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpSubviews];
    if (SApp.username.length) {
        _phoneField.text = SApp.username;
        _codeBtn.enabled = YES;
    }
}

- (void)setUpSubviews
{
    // button
    [_codeBtn dg_setBackgroundImage:ImageNamed(@"Code_normal") forState:UIControlStateNormal];
    [_codeBtn dg_setBackgroundImage:ImageNamed(@"Code_press") forState:UIControlStateHighlighted];
    [_okBtn dg_setBackgroundImage:ImageNamed(@"Start button_normal") forState:UIControlStateNormal];
    [_okBtn dg_setBackgroundImage:ImageNamed(@"Start button_press") forState:UIControlStateHighlighted];
    
    // textfield
    NSDictionary *attriDic = @{NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightMedium],
                              NSForegroundColorAttributeName: COLOR(180, 180, 180, 1)};
    _phoneField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号" attributes:attriDic];
    _codeField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:attriDic];
    
    // layout
    _logoTop.constant = _logoTop.constant * [Tools layoutFactor];
}

- (IBAction)textFieldChanged:(id)sender {
    if (_phoneField.text.length) {
        _codeBtn.enabled = YES;
        if (_codeField.text.length) {
            _okBtn.enabled = YES;
        } else {
            _okBtn.enabled = NO;
        }
    } else {
        _codeBtn.enabled = NO;
    }
}

- (IBAction)getCode:(id)sender {
    if (![CheckUtil checkPhoneNumber:_phoneField.text]) {
        [self makeToast:@"请输入正确的手机号"];
        return;
    }
    [SVProgressHUD show];
    [AccountCGI getPhoneCode:_phoneField.text type:0 complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            _codeBtn.enabled = NO;
            _seconds = SECONDS;
            [self.timer setFireDate:[NSDate date]];
            [_codeField becomeFirstResponder];
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (IBAction)doRegister:(id)sender {
    if (!_phoneField.text.length || !_codeField.text.length) return;
    [SVProgressHUD show];
    [AccountCGI doRegister:_phoneField.text password:_codeField.text code:_codeField.text.integerValue complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                SApp.username = _phoneField.text;
                [MSApp setUserInfo:data];
                [self invalidateTimer];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNC_LOGIN object:nil];
            }
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (IBAction)onTapAgreement:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.url = AgreementURL;
    vc.title = @"软件许可及服务协议";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
