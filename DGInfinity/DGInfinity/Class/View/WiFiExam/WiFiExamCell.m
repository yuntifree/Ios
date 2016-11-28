//
//  WiFiExamCell.m
//  DGInfinity
//
//  Created by myeah on 16/11/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "WiFiExamCell.h"

@implementation WiFiExamCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 0.5);  //线宽
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, 230.0 / 255.0, 230.0 / 255.0, 230.0 / 255.0, 1.0);  //线的颜色
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, 12, rect.size.height - 0.5);  //起点坐标
    CGContextAddLineToPoint(context, rect.size.width - 12, rect.size.height - 0.5);   //终点坐标
    
    CGContextStrokePath(context);
    
}

@end

@interface WiFiExamDeviceCell ()
{
    __weak IBOutlet UILabel *_brandLbl;
    __weak IBOutlet UILabel *_ipLbl;
    
}
@end

@implementation WiFiExamDeviceCell

- (void)setDeviceValue:(WiFiExamDeviceModel *)model
{
    _brandLbl.text = model.brand.length ? model.brand : @"未知设备";
    _ipLbl.text = [NSString stringWithFormat:@"IP：%@",model.ip];
}

@end

@interface WiFiExamDescCell ()
{
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UILabel *_descLbl;
    
}
@end

@implementation WiFiExamDescCell

- (void)setDescValue:(WiFiExamDescModel *)model
{
    _titleLbl.text = model.title;
    _descLbl.text = model.desc;
}

@end
