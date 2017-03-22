//
//  SettingCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "SettingCell.h"

@interface SettingCell ()
{
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UILabel *_descLbl;
    __weak IBOutlet UIImageView *_arrowView;
    
    __weak IBOutlet NSLayoutConstraint *_descLblRight;
}
@end

@implementation SettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title desc:(NSString *)desc arrowHiden:(BOOL)hiden
{
    _titleLbl.text = title;
    _descLbl.text = desc;
    _arrowView.hidden = hiden;
    _descLblRight.constant = hiden ? 12 : 32;
}

@end

@implementation SettingExitCell

@end
