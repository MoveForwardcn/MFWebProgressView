//
//  BaseViewController.m
//  MFWebProgressView
//
//  Created by htkg on 17/3/27.
//  Copyright © 2017年 MF. All rights reserved.
//

#import "BaseViewController.h"
#import "MFWKWebView.h"
@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)btnclick:(id)sender {
    MFWKWebView * wk = [MFWKWebView new];
    wk.baseUrl = @"https://github.com/MoveForwardcn";
    [self.navigationController pushViewController:wk animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
