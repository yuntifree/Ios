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
    
    BOOL _hasName;
    int _randomCount;
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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hasName = NO;
        _randomCount = 0;
    }
    return self;
}

- (NSString *)title
{
    return @"昵称";
}

- (void)backBtnClick:(id)sender
{
    MobClick(@"profile_name_cancel");
    [super backBtnClick:sender];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = RGB(0xf2f2f2, 1);
    if ([SApp.nickname isKindOfClass:[NSString class]] && SApp.nickname.length) {
        _textField.text = SApp.nickname;
        _hasName = YES;
    }
    
    [self getRankNick];
}

- (void)textFieldSetPlaceholder
{
    if (self.nameSet.count) {
        NSDictionary *attriDic = @{NSFontAttributeName: SystemFont(14),
                                   NSForegroundColorAttributeName: COLOR(180, 180, 180, 1)};
        NSString *placeHolder = self.nameSet.anyObject;
        [self.nameSet removeObject:placeHolder];
        if (!_hasName) {
            _textField.text = nil;
        } else {
            _hasName = NO;
        }
        _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[placeHolder deleteHeadEndSpace] attributes:attriDic];
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
                if ([nicknames isKindOfClass:[NSArray class]] && nicknames.count) {
                    [self.nameSet addObjectsFromArray:nicknames];
                    [self textFieldSetPlaceholder];
                }
            }
        } else {
            [self makeToast:res.desc];
            if (_hasName) _hasName = NO;
        }
    }];
}

- (IBAction)refreshBtnClick:(id)sender {
    _randomCount++;
    switch (_randomCount) {
        case 1:
            MobClick(@"profile_name_random");
            break;
        case 3:
            MobClick(@"profile_name_random_3");
            break;
        case 5:
            MobClick(@"profile_name_random_5");
            break;
        default:
            break;
    }
    [self textFieldSetPlaceholder];
}

- (IBAction)sureBtnClick:(id)sender {
    NSString *nickname = [_textField.text deleteHeadEndSpace];
    if (!nickname.length && !_textField.attributedPlaceholder.length) {
        [self makeToast:@"昵称不能为空"];
        return;
    }
    
    if (nickname.length > 12) {
        [self makeToast:@"昵称的最大长度为12个字符"];
        return;
    }
    
    if (!nickname.length) {
        nickname = _textField.attributedPlaceholder.string;
        MobClick(@"profile_name_random_ok");
    } else {
        MobClick(@"profile_name_ok");
    }
    
    [self.view endEditing:YES];
    [SVProgressHUD show];
    [UserInfoCGI modUserInfo:@"nickname" value:nickname complete:^(DGCgiResult *res) {
        [SVProgressHUD dismiss];
        if (E_OK == res._errno) {
            SApp.nickname = nickname;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNCRefreshUserInfo object:nickname];
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
