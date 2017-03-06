//
//  ServiceSectionHeader.m
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ServiceSectionHeader.h"

@interface ServiceSectionHeader ()
{
    
    __weak IBOutlet UIImageView *_iconView;
    __weak IBOutlet UILabel *_titleLbl;
    
}
@end

@implementation ServiceSectionHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setTitle:(NSString *)title icon:(NSString *)url
{
    [_iconView yy_setImageWithURL:[NSURL URLWithString:url] options:YYWebImageOptionSetImageWithFadeAnimation];
    _titleLbl.text = title;
}

@end
