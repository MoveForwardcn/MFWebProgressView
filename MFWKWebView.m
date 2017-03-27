//
//  MFWKWebView.m
//  MFWebProgressView
//
//  Created by htkg on 17/3/27.
//  Copyright © 2017年 MF. All rights reserved.
//
#define MFWKWebViewObserver @"estimatedProgress"
#define MFProgressColor  [UIColor redColor]
#import "MFWKWebView.h"
#import <WebKit/WebKit.h>

@interface MFWKWebView ()<WKNavigationDelegate>
@property (nonatomic,strong) WKWebView * wkWebView;
@property (nonatomic,strong) UIProgressView * progressView;
@property (nonatomic,strong) NSMutableArray * leftItems;
@property (nonatomic,strong) NSMutableArray * rightItems;
@property (nonatomic,copy) NSString * currentUrl;
@end

@implementation MFWKWebView

- (void)viewDidLoad {
    [super viewDidLoad];

    _leftItems = [NSMutableArray new];
     
    _rightItems = [NSMutableArray new];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self configUI];
    [self configLeftBar];
    [self configRightBar];
}
-(void)configLeftBar{
    UIBarButtonItem * left1 = [[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [_leftItems addObject:left1];
    [self.navigationItem setLeftBarButtonItems:self.leftItems animated:YES];
}
-(void)configRightBar{
    UIBarButtonItem * right1 = [[UIBarButtonItem alloc]initWithTitle:@"done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    [_rightItems addObject:right1];
    [self.navigationItem setRightBarButtonItems:self.rightItems animated:YES];
}
-(void)configUI{
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    _progressView.tintColor = MFProgressColor;
    _progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:_progressView];

    _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _wkWebView.navigationDelegate=self;
    [_wkWebView addObserver:self forKeyPath:MFWKWebViewObserver options:NSKeyValueObservingOptionNew context:nil];
    
    NSURL * url = [NSURL URLWithString:self.baseUrl];
    NSURLRequest * req = [NSURLRequest requestWithURL:url];
    [_wkWebView loadRequest:req];
    
    [self.view insertSubview:_wkWebView belowSubview:_progressView];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:MFWKWebViewObserver] && object == _wkWebView) {
        float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        if (progress == 1) {
            [_progressView setHidden:YES];
            [_progressView setProgress:0 animated:YES];
        }else{
            [_progressView setProgress:progress animated:YES];
            [_progressView setHidden:NO];
            
        }
    }
}

#pragma - WKWebViewDelegate
-(void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    self.currentUrl = [NSString stringWithFormat:@"%@",webView.URL];
    if (![self.baseUrl isEqualToString:self.currentUrl]) {
        UIBarButtonItem * left2 = [[UIBarButtonItem alloc]initWithTitle:@"close" style:UIBarButtonItemStyleDone target:self action:@selector(shutdone)];
        if (_leftItems.count<2) {
            [_leftItems addObject:left2];
        }
        
        [self.navigationItem setLeftBarButtonItems:_leftItems animated:YES];
    }
}

#pragma - navBtn
-(void)back{
    
    if ([self.baseUrl isEqualToString:self.currentUrl]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.wkWebView goBack];
    }
}
-(void)done{
    NSLog(@"right click");
}
-(void)shutdone{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
