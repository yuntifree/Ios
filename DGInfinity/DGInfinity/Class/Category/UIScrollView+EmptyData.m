//
//  UIScrollView+EmptyData.m
//  DGInfinity
//
//  Created by myeah on 16/11/23.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "UIScrollView+EmptyData.h"
#import <UIScrollView+EmptyDataSet.h>

@interface DGEmptyDataSetStyle : NSObject <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
{
    NSString *_title;
    NSString *_description;
    NSString *_image;
    NSString *_buttonTitle;
    NSString *_buttonBackgroundImage;
}

@property (nonatomic, copy) void (^didTapButtonBlock)(void);
@property (nonatomic, copy) void (^didTapViewBlock)(void);

@end

@implementation DGEmptyDataSetStyle

- (instancetype)initWithView:(UIScrollView *)scrollView
                       title:(NSString *)title
                 description:(NSString *)description
                       image:(NSString *)image
                 buttonTitle:(NSString *)buttonTitle
       buttonBackgroundImage:(NSString *)buttonBackgroundImage
           didTapButtonBlock:(void(^)(void))didTapButtonBlock
             didTapViewBlock:(void(^)(void))didTapViewBlock
{
    self = [super init];
    if (self) {
        _title = title;
        _description = description;
        _image = image;
        _buttonTitle = buttonTitle;
        _buttonBackgroundImage = buttonBackgroundImage;
        self.didTapButtonBlock = didTapButtonBlock;
        self.didTapViewBlock = didTapViewBlock;
        
        scrollView.emptyDataSetSource = self;
        scrollView.emptyDataSetDelegate = self;
    }
    return self;
}

#pragma mark - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return ImageNamed(_image);
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSDictionary *attributes = @{NSFontAttributeName: SystemFont(18),
                                 NSForegroundColorAttributeName: COLOR(155, 155, 155, 1)};
    
    return [[NSAttributedString alloc] initWithString:_title attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSDictionary *attributes = @{NSFontAttributeName: SystemFont(14),
                                 NSForegroundColorAttributeName: COLOR(155, 155, 155, 1)};
    
    return [[NSAttributedString alloc] initWithString:_description attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightMedium],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    return [[NSAttributedString alloc] initWithString:_buttonTitle attributes:attributes];
}

- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    NSString *suffix = nil;
    if (state == UIControlStateNormal) {
        suffix = @"_nor";
    } else if (state == UIControlStateHighlighted) {
        suffix = @"_press";
    }
    NSString *imageName = [_buttonBackgroundImage stringByAppendingString:suffix];
    UIImage *image = ImageNamed(imageName);
    CGFloat imageW = image.size.width * 0.5;
    CGFloat imageH = image.size.height * 0.5;
    UIImage *img = [image resizableImageWithCapInsets:UIEdgeInsetsMake(imageH, imageW, imageH, imageW) resizingMode:UIImageResizingModeTile];
    return [img imageWithAlignmentRectInsets:UIEdgeInsetsMake(0, -100 * [Tools layoutFactor], 0, -100 * [Tools layoutFactor])];
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 24.0f;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    if (self.didTapViewBlock) {
        self.didTapViewBlock();
    }
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    if (self.didTapButtonBlock) {
        self.didTapButtonBlock();
    }
}

@end

@interface UIScrollView ()

@property (nonatomic, strong) DGEmptyDataSetStyle *emptyStyle;

@end

@implementation UIScrollView (EmptyData)

- (void)configureEmptyDataSetStyleWithtitle:(NSString *)title
                                description:(NSString *)description
                                      image:(NSString *)image
                                buttonTitle:(NSString *)buttonTitle
                      buttonBackgroundImage:(NSString *)buttonBackgroundImage
                          didTapButtonBlock:(void(^)(void))didTapButtonBlock
                            didTapViewBlock:(void(^)(void))didTapViewBlock
{
    if (!self.emptyStyle) {
        self.emptyStyle = [[DGEmptyDataSetStyle alloc] initWithView:self
                                                              title:title
                                                        description:description
                                                              image:image
                                                        buttonTitle:(NSString *)buttonTitle
                                              buttonBackgroundImage:(NSString *)buttonBackgroundImage
                                                  didTapButtonBlock:(void(^)(void))didTapButtonBlock
                                                    didTapViewBlock:(void(^)(void))didTapViewBlock];
    }
}

- (void)configureNoNetStyleWithdidTapButtonBlock:(void (^)(void))didTapButtonBlock didTapViewBlock:(void (^)(void))didTapViewBlock
{
    [self configureEmptyDataSetStyleWithtitle:@"抱歉，网络请求失败"
                                  description:@"请检查您的网络"
                                        image:@"no net"
                                  buttonTitle:@"重新加载"
                        buttonBackgroundImage:@"btn_open"
                            didTapButtonBlock:didTapButtonBlock
                              didTapViewBlock:didTapViewBlock];
}

- (void)reloadEmptyDataSet
{
    [self reloadEmptyDataSet];
}

#pragma mark - AssociatedObject
static char const *kDGEmptyDataSetSource = "dgEmptyDataSetSource";

- (DGEmptyDataSetStyle *)emptyStyle {
    return objc_getAssociatedObject(self, kDGEmptyDataSetSource);
}

- (void)setEmptyStyle:(DGEmptyDataSetStyle *)emptyStyle {
    objc_setAssociatedObject(self, kDGEmptyDataSetSource, emptyStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
