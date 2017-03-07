//
//  LeftUserinfoView.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/24.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "LeftUserinfoView.h"

@interface LeftUserinfoView ()
{
    UIView *_backView;
    UIImageView *_headView;
    UILabel *_nameLbl;
}
@end

@implementation LeftUserinfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backView = [[UIView alloc] initWithFrame:CGRectMake(21, 3, 50, 20)];
        _backView.backgroundColor = COLOR(0, 0, 0, 0.2);
        _backView.layer.cornerRadius = 10;
        _backView.layer.masksToBounds = YES;
        [self addSubview:_backView];
        
        _headView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 26, 26)];
        _headView.layer.borderColor = COLOR(210, 210, 210, 1).CGColor;
        _headView.layer.borderWidth = 0.5;
        _headView.layer.masksToBounds = YES;
        _headView.layer.cornerRadius = 13;
        _headView.contentMode = UIViewContentModeScaleAspectFill;
        _headView.image = ImageNamed(@"my_ico_pic");
        [self addSubview:_headView];
        
        _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 6, 60, 14)];
        _nameLbl.font = [UIFont systemFontOfSize:10 weight:UIFontWeightLight];
        _nameLbl.textColor = [UIColor whiteColor];
        [self addSubview:_nameLbl];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)]];
    }
    return self;
}

- (void)refreshUserinfo
{
    if ([SApp.headurl isKindOfClass:[NSString class]] && SApp.headurl.length) {
        [_headView yy_setImageWithURL:[NSURL URLWithString:SApp.headurl] placeholder:_headView.image options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    } else {
        _headView.image = ImageNamed(@"my_ico_pic");
    }
    if ([SApp.nickname isKindOfClass:[NSString class]] && SApp.nickname.length) {
        _nameLbl.text = SApp.nickname;
    } else {
        _nameLbl.text = @"东莞无限";
    }
    
    CGSize size = [_nameLbl sizeThatFits:CGSizeZero];
    CGFloat maxWidth = kScreenWidth / 3 - 40;
    if (size.width > maxWidth) {
        size.width = maxWidth;
    }
    _nameLbl.width = size.width;
    _backView.width = size.width + 13 + 12;
    self.width = _backView.width + 21;
}

- (void)onTap
{
    if (_tapBlock) {
        _tapBlock();
    }
}

@end
