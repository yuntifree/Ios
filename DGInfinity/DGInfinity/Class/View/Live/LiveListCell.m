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
    _nicknameLbl.text = [NSString stringWithFormat:@"%@",model.nickname];
    _watchesLbl.text = [NSString stringWithFormat:@"%ld人",model.watches];
    _locationLbl.text = [NSString stringWithFormat:@"%@",model.location];
}

@end
