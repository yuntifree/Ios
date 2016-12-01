//
//  SearchViewController.m
//  DGInfinity
//
//  Created by myeah on 16/11/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "SearchViewController.h"
#import "WebViewController.h"
#import "UIButton+ResizableImage.h"
#import "AnimationManager.h"

@interface SearchViewController () <UITextFieldDelegate>
{
    UITextField *_inputField;
    UIButton *_searchBtn;
}
@end

@implementation SearchViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_inputField becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpSearchBar];
}

- (void)endEditing
{
    if (_inputField.isFirstResponder) {
        [_inputField resignFirstResponder];
    }
}

- (void)setUpSearchBar
{
    UIView *searchBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    searchBar.backgroundColor = COLOR(0, 156, 251, 1);
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(-8, 0, 44, 44);
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setBackgroundImage:ImageNamed(@"icon_back") forState:UIControlStateNormal];
    [searchBar addSubview:backBtn];
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backBtn.frame) + 8, 7, searchBar.width - 146, 30)];
    centerView.backgroundColor = [UIColor whiteColor];
    centerView.layer.cornerRadius = 8;
    centerView.layer.masksToBounds = YES;
    [searchBar addSubview:centerView];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:ImageNamed(@"input_Search_2")];
    iconView.origin = CGPointMake(12, 2);
    [centerView addSubview:iconView];
    
    _inputField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconView.frame) + 2, 0, centerView.width - 45, centerView.height)];
    _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputField.font = SystemFont(14);
    _inputField.textColor = COLOR(60, 60, 60, 1);
    _inputField.tintColor = COLOR(0, 156, 251, 1);
    NSDictionary *attriDic = @{NSFontAttributeName: SystemFont(14),
                               NSForegroundColorAttributeName: COLOR(180, 180, 180, 1)};
    _inputField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"搜索或输入网址" attributes:attriDic];
    [_inputField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    _inputField.returnKeyType = UIReturnKeySearch;
    _inputField.delegate = self;
    [centerView addSubview:_inputField];
    
    _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBtn.frame = CGRectMake(CGRectGetMaxX(centerView.frame) + 6, centerView.y, 76, 30);
    [_searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _searchBtn.titleLabel.font = SystemFont(14);
    [_searchBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_searchBtn addTarget:self action:@selector(searchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_searchBtn dg_setBackgroundImage:ImageNamed(@"input_Search_blue") forState:UIControlStateNormal];
    [searchBar addSubview:_searchBtn];
    
    self.navigationItem.titleView = searchBar;
}

- (void)backBtnClick:(UIButton *)button
{
    [self endEditing];
    [self.navigationController.view.window.layer addAnimation:[AnimationManager presentFadeAnimation] forKey:nil];
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

- (void)textFieldEditingChanged:(UITextField *)textField
{
    NSString *title = textField.text.length ? @"搜索" : @"取消";
    if (![_searchBtn.currentTitle isEqualToString:title]) {
        [_searchBtn setTitle:title forState:UIControlStateNormal];
    }
}

- (void)searchBtnClick:(UIButton *)button
{
    if ([button.currentTitle isEqualToString:@"取消"]) {
        [self backBtnClick:nil];
    } else {
        [self goWebPage];
    }
}

- (void)goWebPage
{
    [self endEditing];
    WebViewController *vc = [[WebViewController alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@%@", SearchURL, [[_inputField.text deleteHeadEndSpace] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    vc.url = url;
    vc.title = @"百度";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self endEditing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self goWebPage];
    return YES;
}

@end
