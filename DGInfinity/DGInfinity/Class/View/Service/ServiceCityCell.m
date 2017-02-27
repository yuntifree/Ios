//
//  ServiceCityCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/27.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "ServiceCityCell.h"

@interface ServiceCityCell ()
{
    __weak IBOutlet UIImageView *_iconView;
    __weak IBOutlet UILabel *_titleLbl;
    
}
@end

@implementation ServiceCityCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setTitle:(NSString *)title icon:(NSString *)icon
{
    _titleLbl.text = title;
    [_iconView yy_setImageWithURL:[NSURL URLWithString:icon] options:YYWebImageOptionSetImageWithFadeAnimation];
}

@end
