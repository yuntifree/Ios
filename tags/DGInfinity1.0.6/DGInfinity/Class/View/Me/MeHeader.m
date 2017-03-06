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
    [self setHead:info[@"headurl"]];
    [self setNickname:info[@"nickname"]];
    _descLbl.text = [NSString stringWithFormat:@"您已连接东莞无线%ld次，为您节省流量费用%ld元",[info[@"total"] integerValue], [info[@"save"] integerValue]];
}

- (void)setNickname:(NSString *)nickname
{
    if ([nickname isKindOfClass:[NSString class]] && nickname.length) {
        _nameLbl.text = nickname;
    }
    
}

- (void)setHead:(NSString *)headurl
{
    if ([headurl isKindOfClass:[NSString class]] && headurl.length) {
        [_headView yy_setImageWithURL:[NSURL URLWithString:headurl] placeholder:_headView.image options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
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
