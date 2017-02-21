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
    NSString *url = info[@"headurl"];
    if ([url isKindOfClass:[NSString class]] && url.length) {
        [_headView yy_setImageWithURL:[NSURL URLWithString:info[@"headurl"]] placeholder:ImageNamed(@"my_ico_pic")];
    }
    NSString *nickname = info[@"nickname"];
    if ([nickname isKindOfClass:[NSString class]] && nickname.length) {
        _nameLbl.text = info[@"nickname"];
    }
    _descLbl.text = [NSString stringWithFormat:@"您已连接东莞无线%ld次，为您节省流量费用%ld元",[info[@"total"] integerValue], [info[@"save"] integerValue]];
}

- (void)setNickname:(NSString *)nickname
{
    _nameLbl.text = nickname;
}

- (void)setHead:(NSString *)headurl
{
    [_headView yy_setImageWithURL:[NSURL URLWithString:headurl] placeholder:ImageNamed(@"my_ico_pic")];
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
