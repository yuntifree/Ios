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
}

- (IBAction)lookForMoreNews:(id)sender {
    
}

- (IBAction)bannerTap:(id)sender {
    
}

@end
