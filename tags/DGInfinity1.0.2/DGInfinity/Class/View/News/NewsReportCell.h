//
//  NewsReportCell.h
//  DGInfinity
//
//  Created by myeah on 16/10/20.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsReportModel.h"

@interface NewsReportCell : UITableViewCell

+ (instancetype)getNewsReportCell:(UITableView *)tableView model:(NewsReportModel *)model;
- (void)setNewsReportValue:(NewsReportModel *)model;

@end

@interface NewsReport3PCell : NewsReportCell

@end

@interface NewsReport1PCell : NewsReportCell

@end

@interface NewsReportNPCell : NewsReportCell

@end

@interface NewsReportADCell : NewsReportCell

@end
