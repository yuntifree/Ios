//
//  NewsReportCell.m
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "NewsReportCell.h"

@implementation NewsReportCell

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

+ (instancetype)getNewsReportCell:(UITableView *)tableView model:(NewsReportModel *)model
{
    NewsReportCell *cell = nil;
    NSString *reuseIdentifier = nil;
    NSInteger index = 0;
    if (model.stype == RT_NEWS) {
        if (model.images.count) {
            if (model.images.count == 3) {
                reuseIdentifier = @"NewsReport3PCell";
                index = 0;
            } else {
                reuseIdentifier = @"NewsReport1PCell";
                index = 1;
            }
        } else {
            reuseIdentifier = @"NewsReportNPCell";
            index = 2;
        }
    } else {
        reuseIdentifier = @"NewsReportADCell";
        index = 3;
    }
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"NewsReportCell" owner:nil options:nil][index];
    }
    [cell setNewsReportValue:model];
    return cell;
}

- (void)setNewsReportValue:(NewsReportModel *)model
{
    
}

@end

@interface NewsReport3PCell ()
{
    __weak IBOutlet UILabel *_titleLbl;
    IBOutletCollection(UIImageView) NSArray *_imgViews;
    __weak IBOutlet UILabel *_sourceLbl;
    __weak IBOutlet UILabel *_timeLbl;
    __weak IBOutlet UILabel *_dateLbl;
    
}
@end

@implementation NewsReport3PCell

- (void)setNewsReportValue:(NewsReportModel *)model
{
    _titleLbl.text = model.title;
    for (int i = 0; i < model.images.count; i++) {
        [_imgViews[i] yy_setImageWithURL:[NSURL URLWithString:model.images[i]] options:YYWebImageOptionSetImageWithFadeAnimation];
    }
    _sourceLbl.text = model.source;
    _timeLbl.text = model.time;
    _dateLbl.text = model.date;
    
    if (model.read) {
        _titleLbl.textColor = COLOR(132, 132, 132, 1);
    } else {
        _titleLbl.textColor = COLOR(67, 67, 67, 1);
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

@end

@interface NewsReport1PCell ()
{
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UILabel *_sourceLbl;
    __weak IBOutlet UILabel *_timeLbl;
    __weak IBOutlet UILabel *_dateLbl;
    __weak IBOutlet UIImageView *_imgView;
    
}
@end

@implementation NewsReport1PCell

- (void)setNewsReportValue:(NewsReportModel *)model
{
    _titleLbl.text = model.title;
    _sourceLbl.text = model.source;
    _timeLbl.text = model.time;
    _dateLbl.text = model.date;
    if (model.images.count) {
        [_imgView yy_setImageWithURL:[NSURL URLWithString:model.images[0]] options:YYWebImageOptionSetImageWithFadeAnimation];
    }
    
    if (model.read) {
        _titleLbl.textColor = COLOR(132, 132, 132, 1);
    } else {
        _titleLbl.textColor = COLOR(67, 67, 67, 1);
    }
}

@end

@interface NewsReportNPCell()
{
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UILabel *_sourceLbl;
    __weak IBOutlet UILabel *_timeLbl;
    __weak IBOutlet UILabel *_dateLbl;
}
@end

@implementation NewsReportNPCell

- (void)setNewsReportValue:(NewsReportModel *)model
{
    _titleLbl.text = model.title;
    _sourceLbl.text = model.source;
    _timeLbl.text = model.time;
    _dateLbl.text = model.date;
    
    if (model.read) {
        _titleLbl.textColor = COLOR(132, 132, 132, 1);
    } else {
        _titleLbl.textColor = COLOR(67, 67, 67, 1);
    }
}

@end

@interface NewsReportADCell ()
{
    __weak IBOutlet UILabel *_titleLbl;
    __weak IBOutlet UIImageView *_imgView;
    __weak IBOutlet UILabel *_sourceLbl;
}
@end

@implementation NewsReportADCell

- (void)setNewsReportValue:(NewsReportModel *)model
{
    _titleLbl.text = model.title;
    _sourceLbl.text = model.source;
    if (model.images.count) {
        [_imgView yy_setImageWithURL:[NSURL URLWithString:model.images[0]] options:YYWebImageOptionSetImageWithFadeAnimation];
    }
    
    if (model.read) {
        _titleLbl.textColor = COLOR(132, 132, 132, 1);
    } else {
        _titleLbl.textColor = COLOR(67, 67, 67, 1);
    }
}

@end
