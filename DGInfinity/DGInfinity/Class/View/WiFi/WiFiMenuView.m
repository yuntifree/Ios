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
    
}
@end

@implementation WiFiMenuView

- (void)awakeFromNib
{
    [super awakeFromNib];
    PulsingHaloLayer *halo = [PulsingHaloLayer layer];
    halo.position = _connectBtn.center;
    [self.layer addSublayer:halo];
    [halo start];
}

@end
