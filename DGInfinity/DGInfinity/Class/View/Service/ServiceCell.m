//
//  ServiceCell.m
//  DGInfinity
//
//  Created by myeah on 16/10/19.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ServiceCell.h"

@interface ServiceCell ()
{
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UIImageView *_iconView;
    
}
@end

@implementation ServiceCell

- (void)setTitle:(NSString *)title icon:(NSString *)icon
{
    _titleLbl.text = title;
    [_iconView yy_setImageWithURL:[NSURL URLWithString:icon] options:YYWebImageOptionSetImageWithFadeAnimation];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
