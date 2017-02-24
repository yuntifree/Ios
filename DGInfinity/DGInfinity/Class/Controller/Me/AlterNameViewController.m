//
//  AlterNameViewController.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/20.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "AlterNameViewController.h"
#import "UserInfoCGI.h"

@interface AlterNameViewController ()
{
    __weak IBOutlet UITextField *_textField;
    
}

@property (nonatomic, strong) NSMutableSet *nameSet;

@end

@implementation AlterNameViewController

#pragma mark - lazy-init
- (NSMutableSet *)nameSet
{
    if (_nameSet == nil) {
        _nameSet = [NSMutableSet setWithCapacity:10];
    }
    return _nameSet;
}

- (NSString *)title
{
    return @"昵称";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = RGB(0xf2f2f2, 1);
    
    [self getRankNick];
}

- (void)textFieldSetPlaceholder
{
    if (self.nameSet.count) {
        NSDictionary *attriDic = @{NSFontAttributeName: SystemFont(14),
                                   NSForegroundColorAttributeName: COLOR(180, 180, 180, 1)};
        NSString *placeHolder = self.nameSet.anyObject;
        [self.nameSet removeObject:placeHolder];
        _textField.text = nil;
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:attriDic];
    } else {
        [SVProgressHUD show];
        [self getRankNick];
    }
}

- (void)getRankNick
{
    [UserInfoCGI getRandNick:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            NSDictionary *data = res.data[@"data"];
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSArray *nicknames = data[@"nicknames"];
                if ([nicknames isKindOfClass:[NSArray class]]) {
                    [self.nameSet addObjectsFromArray:nicknames];
                    [self textFieldSetPlaceholder];
                }
            }
        } else {
            [self makeToast:res.desc];
        }
    }];
}

- (IBAction)refreshBtnClick:(id)sender {
    [self textFieldSetPlaceholder];
}

- (IBAction)sureBtnClick:(id)sender {
    if (!_textField.text.length && !_textField.attributedPlaceholder.length) {
        [self makeToast:@"昵称不能为空"];
        return;
    }
    
    if (_textField.text.length > 12) {
        [self makeToast:@"昵称的最大长度为12个字符"];
        return;
    }
    
    NSString *nickname;
    if (_textField.text.length) {
        nickname = _textField.text;
    } else {
        nickname = _textField.attributedPlaceholder.string;
    }
    
    [self.view endEditing:YES];
    [SVProgressHUD show];
    [UserInfoCGI modUserInfo:@"nickname" value:nickname complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNCModNickname object:nickname];
            [self.navigationController popViewControllerAnimated:YES];
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
