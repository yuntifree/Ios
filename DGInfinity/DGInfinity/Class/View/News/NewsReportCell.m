//
//  NewsReportCell.m
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsReportCell.h"

@interface NewsReportCell ()
{
    __weak IBOutlet UILabel *_titleLbl;
    IBOutletCollection(UIImageView) NSArray *_imgViews;
    __weak IBOutlet UILabel *_sourceLbl;
    __weak IBOutlet UILabel *_timeLbl;
}
@end

@implementation NewsReportCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNewsReportValue:(NewsReportModel *)model
{
    _titleLbl.text = model.title;
    for (int i = 0; i < _imgViews.count; i++) {
        UIImageView *imgView = _imgViews[i];
        if (i < model.images.count) {
            [imgView yy_setImageWithURL:[NSURL URLWithString:model.images[i]] options:YYWebImageOptionSetImageWithFadeAnimation];
            imgView.hidden = NO;
        } else {
            imgView.hidden = YES;
        }
    }
    _sourceLbl.text = model.source;
    _timeLbl.text = model.ctime;
}

@end
