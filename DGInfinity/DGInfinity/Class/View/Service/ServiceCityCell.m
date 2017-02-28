//
//  ServiceCityCell.m
//  DGInfinity
//
//  Created by 刘启飞 on 2017/2/27.
//  Copyright © 2017年 myeah. All rights reserved.
//

#import "ServiceCityCell.h"
#import "UIButton+Vertical.h"

@interface ServiceCityCell ()
{
    __weak IBOutlet UIButton *_button;
    
    ServiceCityModel *_model;
}
@end

@implementation ServiceCityCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_button verticalImageAndTitle:9];
}

- (void)setCityValue:(ServiceCityModel *)model
{
    _model = model;
    [_button yy_setImageWithURL:[NSURL URLWithString:model.img] forState:UIControlStateNormal options:YYWebImageOptionSetImageWithFadeAnimation];
    [_button setTitle:model.title forState:UIControlStateNormal];
}

- (IBAction)btnClick:(id)sender {
    if (_btnClick) {
        _btnClick(_model);
    }
}

@end
