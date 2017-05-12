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
#import <JavaScriptCore/JavaScriptCore.h>

@interface MFWKWebView ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>
@property (nonatomic,strong) WKWebView * wkWebView;
@property (nonatomic,strong) UIProgressView * progressView;
@property (nonatomic,strong) NSMutableArray * leftItems;
@property (nonatomic,strong) NSMutableArray * rightItems;
@end

@implementation MFWKWebView

- (void)viewDidLoad {
    [super viewDidLoad];

    _leftItems = [NSMutableArray new];
     
    _rightItems = [NSMutableArray new];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadUrl];
    [self configUI];
    [self configLeftBar];
    [self configRightBar];
}
-(void)loadUrl{
    NSString * urlStr = @"https://www.baidu.com";
    NSURL * url = [NSURL URLWithString:urlStr];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.wkWebView loadRequest:request];
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
    [self.view addSubview:self.wkWebView];
    [self.view insertSubview:self.wkWebView belowSubview:_progressView];
}
-(WKWebView*)wkWebView{
    if (!_wkWebView) {
        WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc]init];
        config.userContentController = [[WKUserContentController alloc]init];
        /*
         *  只需在响应的js 代码中插入 
         *  window.webkit.messageHandlers.APPJS.postMessage({body: 'goback'}); 
         *  即可通过代理 userContentController didReceiveScriptMessage 接收到 js 的传值和调用 
         */
        [config.userContentController addScriptMessageHandler:self name:@"APPJS"];
        config.preferences.javaScriptEnabled=YES;
        _wkWebView = [[WKWebView alloc]initWithFrame:self.view.frame configuration:config];
        [_wkWebView addObserver:self forKeyPath:MFWKWebViewObserver options:NSKeyValueObservingOptionNew context:nil];
        _wkWebView.scrollView.bounces=NO;
        _wkWebView.navigationDelegate=self;
        _wkWebView.UIDelegate=self;
        return _wkWebView;
    } 
    return _wkWebView;
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
#pragma javascript - oc 
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
    if ([message.name isEqualToString:@"APPJS"]) {
        if ([message.body[@"body"] isEqualToString:@"goback"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else if ([message.body[@"body"] isEqualToString:@"Login"]){
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

#pragma - WKwkWebViewDelegate
-(void) wkWebView:(WKWebView *)wkWebView didStartProvisionalNavigation:(WKNavigation *)navigation{
        
}
-(void) wkWebView:(WKWebView *)wkWebView didCommitNavigation:(WKNavigation *)navigation{
    // start load web
}
-(void) wkWebView:(WKWebView *)wkWebView didFinishNavigation:(WKNavigation *)navigation{
    //    次此方法只能在finish 代理中执行 
    //    oc 调用js 把代码注入js  需在js中实现一样的方法 即可通过下面方法 将js 代码注入 
    //    NSString * jsStr = [NSString stringWithFormat:@"takeTooken(%@)",[DYUserDefault userDefault].userToken];
    //    [self.wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable response,NSError * _Nullable  error){
    //        
    //    }];
    
    // finish load web 
    if ([self.wkWebView canGoBack]&&_leftItems.count==1) {
        UIBarButtonItem * left2 = [[UIBarButtonItem alloc]initWithTitle:@"close" style:UIBarButtonItemStyleDone target:self action:@selector(shutdone)];
        [_leftItems addObject:left2];
        [self.navigationItem setLeftBarButtonItems:_leftItems animated:YES];
    }else{
        if (_leftItems.count==2) {
            [_leftItems removeLastObject];
            [self.navigationItem setLeftBarButtonItems:_leftItems animated:YES];
        }
    }
}
#pragma js调用原生弹窗 
//-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
//
//}
//
//-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
//    
//}
//-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
//
//}
//-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
//    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"h5Container" message:message preferredStyle:UIAlertControllerStyleAlert];  
//
//    [alertView addAction:[UIAlertAction actionWithTitle:@"我很确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {  
//        completionHandler();  
//    }]];  
//    [self presentViewController:alertView animated:YES completion:nil];  
//}
#pragma - navBtn
-(void)back{
    if ([self.wkWebView canGoBack]) {
        [self.wkWebView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
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
