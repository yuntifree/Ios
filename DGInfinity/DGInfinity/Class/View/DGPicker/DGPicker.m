//
//  DGPicker.m
//  DGInfinity
//
//  Created by 刘启飞 on 2016/12/22.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "DGPicker.h"

@interface DGPicker () <UIPickerViewDataSource, UIPickerViewDelegate>

// view
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIPickerView *pickerView;

// data
@property (nonatomic, strong) NSArray *sexArray;

@end

@implementation DGPicker

- (void)dealloc
{
    DDDLog(@"DGPicker Dealloc");
}

#pragma mark - lazy init

- (UIToolbar *)toolBar
{
    if (_toolBar == nil) {
        _toolBar = [[UIToolbar alloc] init];
        _toolBar.backgroundColor = [UIColor whiteColor];
        [_toolBar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClick)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClick)]]];
        [self addSubview:_toolBar];
    }
    return _toolBar;
}

- (UIPickerView *)pickerView
{
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        [self addSubview:_pickerView];
    }
    return _pickerView;
}

- (NSArray *)sexArray
{
    if (_sexArray == nil) {
        _sexArray = @[@"男", @"女"];
    }
    return _sexArray;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = RGB(0x000000, 0.2);
        
        [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@44);
            make.top.equalTo(self.mas_bottom);
            make.bottom.equalTo(self.pickerView.mas_top);
        }];
        
        [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.equalTo(@150);
        }];
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];
    [self layoutIfNeeded];
    
    [self.toolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom).offset(-194);
    }];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
        [self layoutIfNeeded];
    }];
}

- (void)dismiss
{
    [self.toolBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - button action
- (void)cancelClick
{
    [self dismiss];
}

- (void)doneClick
{
    [self dismiss];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (PickerSourceTypeSex == _sourceType) {
        return 1;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (PickerSourceTypeSex == _sourceType) {
        return self.sexArray.count;
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (PickerSourceTypeSex == _sourceType) {
        return self.sexArray[row];
    }
    return @"";
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = RGB(0x000000, 0.2);
        }
    }
    
    //设置文字的属性
    UILabel *genderLabel = [UILabel new];
    genderLabel.textAlignment = NSTextAlignmentCenter;
    genderLabel.text = self.sexArray[row];
    genderLabel.font = SystemFont(20);
    
    return genderLabel;
}

@end
