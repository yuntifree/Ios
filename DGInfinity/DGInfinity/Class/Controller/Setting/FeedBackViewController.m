//
//  FeedBackViewController.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "FeedBackViewController.h"
#import "SettingCGI.h"

@interface FeedBackViewController () <UITextViewDelegate>
{
    __weak IBOutlet UITextView *_inputTextView;
    __weak IBOutlet UILabel *_placeholderLbl;
    __weak IBOutlet UIButton *_submitBtn;
    
}
@end

@implementation FeedBackViewController

- (NSString *)title
{
    return @"意见反馈";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)submitBtnClick:(UIButton *)sender {
    if (![_inputTextView.text deleteHeadEndSpace].length) {
        [self makeToast:@"内容不能为空"];
        return;
    }
    if ([_inputTextView.text deleteHeadEndSpace].length > 120) {
        [self makeToast:@"字数超出最大限制"];
        return;
    }
    
    [self.view endEditing:YES];
    
    NSString *content = [[_inputTextView.text deleteHeadEndSpace] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    [SettingCGI feedBack:content complete:^(DGCgiResult *res) {
        if (E_OK == res._errno) {
            _inputTextView.text = nil;
            _placeholderLbl.hidden = NO;
            _submitBtn.enabled = NO;
            [self makeToast:@"提交成功，感谢您的反馈"];
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length) {
        _placeholderLbl.hidden = YES;
        _submitBtn.enabled = YES;
    } else {
        _placeholderLbl.hidden = NO;
        _submitBtn.enabled = NO;
    }
}

@end
