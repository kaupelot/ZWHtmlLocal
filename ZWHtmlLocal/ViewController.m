//
//  ViewController.m
//  ZWHtmlLocal
//
//  Created by walt zeng on 16/3/21.
//  Copyright © 2016年 walt zeng. All rights reserved.
//

#import "ViewController.h"
#import "ZWHtmlLocalManager.h"
#import "ZWHtmlLocalDownloader.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    
//    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    [self.webView loadRequest:request];
//
    [self loadHtml];
    
}

// 测试加载资源
- (void)loadHtml
{
    NSString *indexHtml = [homePath stringByAppendingString:@"/index.html"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:indexHtml isDirectory:NULL] || ![[NSUserDefaults standardUserDefaults] boolForKey:@"allFiles"]) {
        
        [self changeSourceWith:indexHtml];
    }
    
    NSString *appHtml = [NSString stringWithContentsOfFile:indexHtml encoding:NSUTF8StringEncoding error:nil];
    NSURL *baseURL = [NSURL fileURLWithPath:indexHtml];
    //    NSURL *baseURL = nil;
    if (appHtml == nil) { // 如果使用中文编码,会显示空.
        NSData *txtData = [NSData dataWithContentsOfFile:indexHtml];
        [self.webView loadData:txtData MIMEType:@"text/html" textEncodingName:@"GBK" baseURL:baseURL];
    } else {
        [self.webView loadHTMLString:appHtml baseURL:baseURL];
    }
}

// 更改资源地址
- (void)changeSourceWith:(NSString *)indexHtml
{
    if ([DEFAULTS boolForKey:@"allFiles"]) {
        NSLog(@"allFiles");
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:indexHtml isDirectory:NULL] ) {
        NSLog(@"exist");
    }
    [DEFAULTS setBool:YES forKey:@"localHome"];
    indexHtml = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];  // 引入本地的默认的文件.
    ZWHtmlLocalManager *manager = [[ZWHtmlLocalManager alloc] init];
    [manager downloadFilesFrom:@"http://www.youku.com"];
    // 还是改回完全重新获取页面的模式,一次删除所有记录.
}

- (IBAction)switch:(id)sender {
    
    [self loadHtml];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
