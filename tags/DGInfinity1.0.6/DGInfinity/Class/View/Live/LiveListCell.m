//
//  LiveListCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/8.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "LiveListCell.h"

@interface LiveListCell ()
{
    __weak IBOutlet UIImageView *_imgView;
    __weak IBOutlet UILabel *_nicknameLbl;
    __weak IBOutlet UILabel *_watchesLbl;
    __weak IBOutlet UILabel *_locationLbl;
    __weak IBOutlet UIImageView *_headView;
    
    __weak IBOutlet NSLayoutConstraint *_watchesLblWidth;
}
@end

@implementation LiveListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setLiveListValue:(LiveListModel *)model
{
    [_imgView yy_setImageWithURL:[NSURL URLWithString:model.img] options:YYWebImageOptionSetImageWithFadeAnimation];
    [_headView yy_setImageWithURL:[NSURL URLWithString:model.avatar] options:YYWebImageOptionSetImageWithFadeAnimation];
    if ([model.nickname isKindOfClass:[NSString class]] && model.nickname.length) {
        _nicknameLbl.text = model.nickname;
    } else {
        _nicknameLbl.text = @"主播";
    }
    if (model.watches >= 10000) {
        _watchesLbl.text = [NSString stringWithFormat:@"%ld万",model.watches / 10000];
    } else {
        _watchesLbl.text = [NSString stringWithFormat:@"%ld",model.watches];
    }
    if ([model.location isKindOfClass:[NSString class]] && model.location.length) {
        _locationLbl.text = [NSString stringWithFormat:@"%@",model.location];
    } else {
        _locationLbl.text = @"难道在火星?";
    }
    
    CGSize size = [_watchesLbl sizeThatFits:CGSizeZero];
    _watchesLblWidth.constant = ceil(size.width);
}

@end
