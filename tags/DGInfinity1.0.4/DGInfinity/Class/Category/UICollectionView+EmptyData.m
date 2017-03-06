//
//  UICollectionView+EmptyData.m
//  DGInfinity
//
//  Created by myeah on 16/11/4.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "UICollectionView+EmptyData.h"

@implementation UICollectionView (EmptyData)

- (void)displayWitMsg:(NSString *)message
         ForDataCount:(NSUInteger)rowCount
{
    if (rowCount == 0) {
        if (self.backgroundView == nil) {
            UILabel *messageLabel = [[UILabel alloc] init];
            messageLabel.text = message;
            messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            messageLabel.textColor = [UIColor lightGrayColor];
            messageLabel.textAlignment = NSTextAlignmentCenter;
            messageLabel.numberOfLines = 0;
            [messageLabel sizeToFit];
            self.backgroundView = messageLabel;
        }
    } else {
        if (self.backgroundView != nil) {
            self.backgroundView = nil;
        }
    }
}

@end
