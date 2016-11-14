//
//  WiFiFooterView.m
//  DGInfinity
//
//  Created by myeah on 16/11/11.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiFooterView.h"
#import "UIButton+Vertical.h"

@interface WiFiFooterView ()
{
    IBOutletCollection(UIButton) NSArray *_sectionBtns;
    __weak IBOutlet UILabel *_totalLbl;
    __weak IBOutlet UILabel *_saveLbl;
    __weak IBOutlet UIImageView *_banner;
    
}
@end

@implementation WiFiFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (UIButton *button in _sectionBtns) {
        [button verticalImageAndTitle:2];
    }
}

- (void)setFrontInfo:(NSDictionary *)frontInfo
{
    NSDictionary *user = frontInfo[@"user"];
    if ([user isKindOfClass:[NSDictionary class]]) {
        _totalLbl.text = [NSString stringWithFormat:@"%ld",[user[@"total"] integerValue]];
        _saveLbl.text = [NSString stringWithFormat:@"%ld",[user[@"save"] integerValue]];
    }
    NSDictionary *banner = frontInfo[@"banner"];
    if ([banner isKindOfClass:[NSDictionary class]]) {
        [_banner yy_setImageWithURL:[NSURL URLWithString:banner[@"img"]] options:YYWebImageOptionSetImageWithFadeAnimation];
        _banner.userInteractionEnabled = YES;
    }
}

- (IBAction)btnClick:(UIButton *)sender {
    if (_block) {
        _block(sender.tag);
    }
}

- (IBAction)bannerTap:(UITapGestureRecognizer *)sender {
    if (_block) {
        _block(sender.view.tag);
    }
}

@end
