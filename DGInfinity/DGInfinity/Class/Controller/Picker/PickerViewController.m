//
//  PickerViewController.m
//  DGInfinity
//
//  Created by myeah on 16/12/16.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "PickerViewController.h"

@interface PickerViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

// view
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIPickerView *pickerView;

// data
@property (nonatomic, strong) NSArray *sexArray;

@end

@implementation PickerViewController

#pragma mark - lazy init

- (UIToolbar *)toolBar
{
    if (_toolBar == nil) {
        _toolBar = [[UIToolbar alloc] init];
        [_toolBar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClick)],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClick)]]];
        [self.view addSubview:_toolBar];
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
        [self.view addSubview:_pickerView];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@150);
    }];
    
    [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@44);
        make.bottom.equalTo(self.pickerView.mas_top);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button action
- (void)cancelClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneClick
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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

@end
