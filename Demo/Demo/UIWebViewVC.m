//
//  UIWebViewVC.m
//  Demo
//
//  Created by wujun on 2020/6/23.
//  Copyright © 2020 Company. All rights reserved.
//

#import "UIWebViewVC.h"
#import <WebKit/WebKit.h>

@interface UIWebViewVC ()
@property (nonatomic,strong)WKWebView *webView;
@end

@implementation UIWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

-(void)WKWebViewMethod{
    //创建一个WKWebView，由于wkwebView执行js代码是异步过程，所以需要引用wkwebView对象
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    //创建一个self的弱引用，防止循环引用
    __weak typeof(self) weakSelf = self;
    //执行js代码，获取wkwebview中的userAgent
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
       //创建强引用
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //执行结果result为获取到的useragent值
        NSString *userAgent = result;
        //给useragent追加自己需要的内容
        userAgent = [userAgent stringByAppendingString:@" /sa-sdk-ios "];
        //将UserAgent 字典内容注册到NSUserDefaults中
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":userAgent}];
        //释放webView
        strongSelf.webView = nil;
    }];
}

-(void)UIWebViewMethod{
    //创建一个空的UIWebView
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    //取出UIWebView的UserAgent
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    //给UserAgent添加自己需要的内容
    userAgent = [userAgent stringByAppendingString:@" /sa-sdk-ios "];
    //将UserAgent字典内容注册到NSUserDefaults中
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":userAgent}];
}


@end
