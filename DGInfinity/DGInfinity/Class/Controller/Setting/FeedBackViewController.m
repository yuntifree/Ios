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
    __weak IBOutlet UITextField *_contactField;
    
}
@end

@implementation FeedBackViewController

- (NSString *)title
{
    return @"反馈问题";
}

- (void)backBtnClick:(id)sender
{
    MobClick(@"feedback_cancel");
    [super backBtnClick:sender];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = RGB(0xf0f0f0, 1);
    
    [self setUpSubViews];
}

- (void)setUpSubViews
{
    NSDictionary *attriDic = @{NSFontAttributeName: SystemFont(14),
                               NSForegroundColorAttributeName: COLOR(180, 180, 180, 1)};
    _contactField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入您的手机或QQ号码" attributes:attriDic];
}

- (IBAction)submitBtnClick:(UIButton *)sender {
    NSString *content = [_inputTextView.text deleteHeadEndSpace];
    if (!content.length) {
        [self makeToast:@"内容不能为空"];
        return;
    }
    if (content.length > 120) {
        [self makeToast:@"字数超出最大限制"];
        return;
    }
    NSString *contact = nil;
    if (_contactField.text.length) {
        contact = [_contactField.text deleteHeadEndSpace];
    }
    
    [self.view endEditing:YES];
    
    content = [content stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    [SVProgressHUD show];
    [SettingCGI feedBack:content contact:contact complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            _inputTextView.text = nil;
            if (contact && !contact.length) {
                _contactField.text = nil;
            }
            _placeholderLbl.hidden = NO;
            _submitBtn.enabled = NO;
            [self.navigationController popViewControllerAnimated:YES];
            [[UIApplication sharedApplication].keyWindow.rootViewController makeToast:@"提交成功，感谢您的反馈"];
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
