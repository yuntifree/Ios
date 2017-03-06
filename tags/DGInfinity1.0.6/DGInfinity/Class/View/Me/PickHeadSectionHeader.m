//
//  PickHeadSectionHeader.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/21.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "PickHeadSectionHeader.h"

@interface PickHeadSectionHeader ()
{
    __weak IBOutlet UIImageView *_iconView;
    
}
@end

@implementation PickHeadSectionHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIcon:(NSString *)imageName
{
    _iconView.image = ImageNamed(imageName);
}

@end
