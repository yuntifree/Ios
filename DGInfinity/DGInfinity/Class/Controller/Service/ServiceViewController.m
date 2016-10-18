//
//  ServiceViewController.m
//  DGInfinity
//
//  Created by myeah on 16/10/17.
//  Copyright © 2016年 myeah. All rights reserved.
//

#import "ServiceViewController.h"
#import "WebViewController.h"

@interface ServiceViewController ()

@end

@implementation ServiceViewController

- (NSString *)title
{
    return @"服务";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testClick:(id)sender {
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.url = @"http://www.gdcredit.gov.cn/fuwudating!toQiYeService.do";
//    webVC.url = @"http://www.baidu.com";
    [self.navigationController pushViewController:webVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
