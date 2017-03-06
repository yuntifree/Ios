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
}

- (void)setCityValue:(ServiceCityModel *)model
{
    _model = model;
    [_button yy_setImageWithURL:[NSURL URLWithString:model.img] forState:UIControlStateNormal placeholder:ImageNamed(@"cooperation.png") options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        [_button setImage:[UIImage reSizeImage:image toSize:CGSizeMake(44, 44)] forState:UIControlStateNormal];
    }];
    [_button setTitle:model.title forState:UIControlStateNormal];
    [_button verticalImageAndTitle:9];
}

- (IBAction)btnClick:(id)sender {
    if (_btnClick) {
        _btnClick(_model);
    }
}

@end
