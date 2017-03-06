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
    
}
@end

@implementation ServiceCell

- (void)setTitle:(NSString *)title
{
    _titleLbl.text = title;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
