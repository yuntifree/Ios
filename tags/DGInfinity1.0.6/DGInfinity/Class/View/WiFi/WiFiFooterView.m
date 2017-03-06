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
    
    __weak IBOutlet NSLayoutConstraint *_sectionViewHeight;
    __weak IBOutlet NSLayoutConstraint *_serviceBottom;
    
    NSMutableArray *_banners;
    dispatch_source_t _timer;
}
@end

@implementation WiFiFooterView

- (void)dealloc
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (UIButton *button in _sectionBtns) {
        [button verticalImageAndTitle:7];
    }
    
    _sectionViewHeight.constant = 110.5f;
    _serviceBottom.constant = 0;
}

- (void)setFrontInfo:(NSDictionary *)frontInfo
{
    NSDictionary *user = frontInfo[@"user"];
    if ([user isKindOfClass:[NSDictionary class]]) {
        _totalLbl.text = [NSString stringWithFormat:@"%ld",[user[@"total"] integerValue]];
        _saveLbl.text = [NSString stringWithFormat:@"%ld",[user[@"save"] integerValue]];
    }
}

- (IBAction)btnClick:(UIButton *)sender {
    if (_block) {
        _block(sender.tag);
    }
}

@end
