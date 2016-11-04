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

#define SECONDS 5

@interface LoginViewController ()
{
    __weak IBOutlet UITextField *_phoneField;
    __weak IBOutlet UITextField *_codeField;
    __weak IBOutlet UIButton *_codeBtn;
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
