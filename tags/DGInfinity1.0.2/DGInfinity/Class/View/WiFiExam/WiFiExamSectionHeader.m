//
//  WiFiExamSectionHeader.m
//  DGInfinity
//
//  Created by myeah on 16/11/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiExamSectionHeader.h"

@interface WiFiExamSectionHeader ()
{
    UILabel *_titleLbl;
}
@end

@implementation WiFiExamSectionHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 200, 17)];
        _titleLbl.font = SystemFont(12);
        _titleLbl.textColor = COLOR(0, 156, 251, 1);
        [self addSubview:_titleLbl];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(12, 40.5, kScreenWidth - 24, 0.5)];
        line.backgroundColor = COLOR(230, 230, 230, 1);
        [self addSubview:line];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLbl.text = title;
}

@end
