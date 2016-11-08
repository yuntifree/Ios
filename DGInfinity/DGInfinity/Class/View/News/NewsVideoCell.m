//
//  NewsVideoCell.m
//  DGInfinity
//
//  Created by myeah on 16/10/27.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsVideoCell.h"

@interface NewsVideoCell ()
{
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UIImageView *_imgView;
    __weak IBOutlet UILabel *_sourceLbl;
    __weak IBOutlet UILabel *_dateLbl;
    __weak IBOutlet UILabel *_playLbl;
    
}
@end

@implementation NewsVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNewsVideoValue:(NewsVideoModel *)model
{
    _titleLbl.text = model.title;
    if (model.images.count) {
        [_imgView yy_setImageWithURL:[NSURL URLWithString:model.images[0]] options:YYWebImageOptionSetImageWithFadeAnimation];
    }
    _sourceLbl.text = model.source;
    _dateLbl.text = model.date;
    _playLbl.text = [NSString stringWithFormat:@"%ld次播放",model.play];
}

@end
