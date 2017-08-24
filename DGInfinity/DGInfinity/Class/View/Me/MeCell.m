//
//  MeCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/20.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "MeCell.h"

@interface MeCell ()
{
    __weak IBOutlet UIImageView *_iconView;
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UILabel *_descLbl;
    __weak IBOutlet UIView *_redPoint;
    
}
@end

@implementation MeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMenuValue:(MeMenuModel *)model
{
    _iconView.image = ImageNamed(model.icon);
    _titleLbl.text = model.title;
    if (model.desc.length) {
        _descLbl.text = model.desc;
    } else {
        _descLbl.text = @"";
    }
    _redPoint.hidden = !model.showPoint;
}

@end
