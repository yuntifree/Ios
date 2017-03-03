//
//  PickHeadCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/21.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "PickHeadCell.h"

@interface PickHeadCell ()
{
    __weak IBOutlet UIButton *_headView;
    __weak IBOutlet UILabel *_descLbl;
    __weak IBOutlet UILabel *_ageLbl;
    
    NSString *_headurl;
}
@end

@implementation PickHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _ageLbl.hidden = YES;
}

- (void)setPickHeadValue:(PickHeadModel *)model
{
    _headurl = model.headurl;
    [_headView yy_setBackgroundImageWithURL:[NSURL URLWithString:model.headurl] forState:UIControlStateNormal placeholder:ImageNamed(@"my_ico_pic") options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    _descLbl.text = model.desc;
    _ageLbl.text = model.age;
}

- (IBAction)headClick:(id)sender {
    if (_HeadTap) {
        _HeadTap(_headurl);
    }
}

@end
