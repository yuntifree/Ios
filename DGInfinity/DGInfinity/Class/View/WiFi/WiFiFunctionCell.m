//
//  WiFiFunctionCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/24.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "WiFiFunctionCell.h"

@interface WiFiFunctionCell ()
{
    __weak IBOutlet UIImageView *_iconView;
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UILabel *_descLbl;
    __weak IBOutlet UILabel *_badgeLbl;
    
    __weak IBOutlet NSLayoutConstraint *_badgeLblWidth;
}
@end

@implementation WiFiFunctionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFunctionValue:(WiFiFunctionModel *)model
{
    _iconView.image = ImageNamed(model.imageName);
    _titleLbl.text = model.title;
    _descLbl.text = model.desc;
    if (model.badge) {
        _badgeLbl.hidden = NO;
        _badgeLbl.text = [NSString stringWithFormat:@"%ld",model.badge];
        CGSize size = [_badgeLbl sizeThatFits:CGSizeZero];
        _badgeLblWidth.constant = size.width + 12;
    } else {
        _badgeLbl.hidden = YES;
    }
}

@end
