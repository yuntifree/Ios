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

- (void)setTitle:(NSString *)title desc:(NSString *)desc
{
    _titleLbl.text = title;
    _descLbl.text = desc;
}

@end
