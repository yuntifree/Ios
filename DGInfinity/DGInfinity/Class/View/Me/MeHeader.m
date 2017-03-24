//
//  MeHeader.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/20.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "MeHeader.h"

@interface MeHeader ()
{
    __weak IBOutlet UIImageView *_headView;
    __weak IBOutlet UILabel *_nameLbl;
    __weak IBOutlet UILabel *_descLbl;
    
}
@end

@implementation MeHeader

- (void)setHeaderValue:(NSDictionary *)info
{
    NSString *tip = info[@"tip"];
    if ([tip isKindOfClass:[NSString class]] && tip.length) {
        _descLbl.text = tip;
    } else {
        _descLbl.text = [NSString stringWithFormat:@"您已连接东莞无线%ld次，为您节省流量费用%ld元",[info[@"total"] integerValue], [info[@"save"] integerValue]];
    }
}

- (void)refreshUserinfo
{
    if ([SApp.headurl isKindOfClass:[NSString class]] && SApp.headurl.length) {
        [_headView yy_setImageWithURL:[NSURL URLWithString:SApp.headurl] placeholder:_headView.image options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    }
    if ([SApp.nickname isKindOfClass:[NSString class]] && SApp.nickname.length) {
        _nameLbl.text = SApp.nickname;
    }
}

- (IBAction)headViewTap:(UITapGestureRecognizer *)sender {
    if (_headTap) {
        _headTap();
    }
}

- (IBAction)writeViewTap:(UITapGestureRecognizer *)sender {
    if (_writeTap) {
        _writeTap();
    }
}

@end
