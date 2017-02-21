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

- (void)setIcon:(NSString *)imageName title:(NSString *)title
{
    _iconView.image = ImageNamed(imageName);
    _titleLbl.text = title;
}

@end
