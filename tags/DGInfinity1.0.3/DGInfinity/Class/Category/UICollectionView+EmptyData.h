//
//  UICollectionView+EmptyData.h
//  DGInfinity
//
//  Created by myeah on 16/11/4.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (EmptyData)

- (void)displayWitMsg:(NSString *)message
         ForDataCount:(NSUInteger)rowCount;

@end
