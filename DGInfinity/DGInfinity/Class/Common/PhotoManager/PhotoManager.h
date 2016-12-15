//
//  PhotoManager.h
//  DGInfinity
//
//  Created by myeah on 16/12/15.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoManager;

@protocol PhotoManagerDelegate <NSObject>

- (void)photoManager:(PhotoManager *)manager didFinishPickImage:(UIImage *)image;

@end

@interface PhotoManager : NSObject

+ (instancetype)shareManager;
- (void)showPhotoPicker:(UIViewController <PhotoManagerDelegate> *)viewController;

@end
