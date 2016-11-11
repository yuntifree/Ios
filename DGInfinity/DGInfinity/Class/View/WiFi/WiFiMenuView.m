//
//  WiFiMenuView.m
//  DGInfinity
//
//  Created by myeah on 16/11/9.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiMenuView.h"
#import "PulsingHaloLayer.h"

@interface WiFiMenuView ()
{
    __weak IBOutlet UIButton *_connectBtn;
    __weak IBOutlet UILabel *_statusLbl;
    __weak IBOutlet UILabel *_temperatureLbl;
    __weak IBOutlet UILabel *_weatherLbl;
    __weak IBOutlet UILabel *_hotLbl;
    
    __weak IBOutlet NSLayoutConstraint *_connectBtnTop;
    __weak IBOutlet NSLayoutConstraint *_statusLblBottom;
}
@end

@implementation WiFiMenuView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _connectBtnTop.constant *= [Tools layoutFactor];
    _statusLblBottom.constant *= [Tools layoutFactor];
    
    PulsingHaloLayer *halo = [PulsingHaloLayer layer];
    halo.position = CGPointMake(kScreenWidth / 2, _connectBtnTop.constant + 56.5);
    [self.layer addSublayer:halo];
    [halo start];
}

- (void)setWeather:(NSDictionary *)weather
{
    _temperatureLbl.text = [NSString stringWithFormat:@"%ld°C",[weather[@"temp"] integerValue]];
    _weatherLbl.text = weather[@"info"];
}

- (void)setHotNews:(NSString *)title
{
    _hotLbl.text = [NSString stringWithFormat:@"东莞头条：%@",title];
    _hotLbl.userInteractionEnabled = YES;
}

- (IBAction)menuViewTap:(UITapGestureRecognizer *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(WiFiMenuViewClick:)]) {
        [_delegate WiFiMenuViewClick:sender.view.tag];
    }
}

- (IBAction)connectBtnClick:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(WiFiMenuViewClick:)]) {
        [_delegate WiFiMenuViewClick:sender.tag];
    }
}

@end
