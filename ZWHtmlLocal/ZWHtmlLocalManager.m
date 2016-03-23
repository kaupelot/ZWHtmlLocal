//
//  ZWHtmlLocalManager.m
//  ZWHtmlLocal
//
//  Created by walt zeng on 16/3/21.
//  Copyright © 2016年 walt zeng. All rights reserved.
//

#import "ZWHtmlLocalManager.h"
#import "ZWHtmlLocalDownloader.h"
#import "NSString+check.h"

@implementation ZWHtmlLocalManager

- (void)downloadFilesFrom:(NSString *)url
{
    [self getUrlsFrom:nil host:url];
}

// 取出所有需要的链接.host就是资源的源地址,用于取出地址host与协议.filePath是文本文件路径.
- (void)getUrlsFrom:(NSString *)filePath host:(NSString *)host
{
    NSString *urlPattern1 = @" src=\"([^<>]+?)\"";
    NSString *urlPattern2 = @" href=\"([^<>]+?)\"";
    NSString *urlPattern3 = @"url\\(\"\\.\\.\\/([^<>]+?)\"\\)"; // 不能取成根目录
    NSString *urlPattern4 = @"data-original=\"([^<>]+?)\""; // 用于取html中懒加载的资源.
    
    ZWHtmlLocalManager *manager = [[ZWHtmlLocalManager alloc] init];
    NSMutableArray *temp = [NSMutableArray array];
    [temp addObjectsFromArray:[manager drawPaths:filePath pattern:urlPattern1 source:host]];
    [temp addObjectsFromArray:[manager drawPaths:filePath pattern:urlPattern2 source:host]];
    [temp addObjectsFromArray:[manager drawPaths:filePath pattern:urlPattern3 source:host]];
    [temp addObjectsFromArray:[manager drawPaths:filePath pattern:urlPattern4 source:host]];
    
    [[ZWHtmlLocalDownloader shareData].fileArray addObjectsFromArray:temp];
    [[NSUserDefaults standardUserDefaults] setObject:[ZWHtmlLocalDownloader shareData].fileArray forKey:@"files"];
    
    [manager writeFileWith:temp];
}

- (void)writeFileWith:(NSArray *)array
{
    for (NSDictionary *dict in array) {
        NSMutableDictionary *geo = [NSMutableDictionary dictionary];
        [geo setValuesForKeysWithDictionary:dict];
        NSString *localAdd = [geo valueForKey:@"localAdd"];
        NSString *url = [geo valueForKey:@"url"];
        [[ZWHtmlLocalDownloader shareData] downloadFileToAddress:localAdd url:url success:^{
            if ([localAdd hasSuffix:@".css"]) { // 当css文件成功下载完成之后,进入开始获取数据
                NSString *indexHtml = [homePath stringByAppendingString:localAdd];
                [self getUrlsFrom:indexHtml host: url];
            }
        } failure:^(NSError *err) {
            NSLog(@"%@",err.localizedDescription);
            // 由于状态码不是200,说明文件不存在,所以需要从需求中删除.
            if (err.code == 404) {
                [[ZWHtmlLocalDownloader shareData].fileArray removeObject:dict];
                [[NSUserDefaults standardUserDefaults] setObject:[ZWHtmlLocalDownloader shareData].fileArray forKey:@"files"];
            }
        }];
        
    }
}

// 从html代码中取出符合要求的.source就是直接传入的网址.
- (NSArray *)drawPaths:(NSString *)textPath pattern:(NSString *)parttern source:(NSString *)source
{
    // 从路径取出文本文件
    NSString *content = [NSString stringWithContentsOfFile:textPath encoding:NSUTF8StringEncoding error:nil];
    if (content == nil) {
        return nil;
    }
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:parttern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSMutableArray *listImage = [NSMutableArray array];
    
    NSArray* matches = [regex matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
    
    BOOL change = NO; // 用于保存是否有变更状态.
    NSString *results = content; // 临时替换字符串.规避替换过程中的取值
    for (NSTextCheckingResult *match in matches) {
        NSInteger count = [match numberOfRanges];//匹配项
        for(NSInteger index = 0;index < count;index++){
            NSRange halfRange = [match rangeAtIndex:index];
            NSString *get = [content substringWithRange:halfRange];
            
            NSString *tempStr = [[get componentsSeparatedByString:@"/"] lastObject];
            if (index == 1 && [tempStr myContainsString:@"."] && ![get hasPrefix:@"\t"] && ![get hasPrefix:@"("]) { // 去除掉取到javascript的情况.最后字段需要有.表示文件,同时不能有问号,表明带参数跳转.资源文件是不带参数的.
                NSString *fileUrl = source; // 提取链接
                NSURL *temp = [NSURL URLWithString:source];
                NSString *tempGet = get;
                if ([get myContainsString:@"?"]) { // 如果包含参数,将参数去除掉.
                    get = [[get componentsSeparatedByString:@"?"] firstObject];
                }
                NSString *filePath = get;
                
                // 调试使用断点.
                if ([get myContainsString:@"srctag=xzydibudh5"]) {
                    
                }
                
                // 判断是否是网址
                if ([get isUrl] || [get hasPrefix:@"//"]) {
                    if ([get hasPrefix:@"//"]) {
                        get = [NSString stringWithFormat:@"http:%@",get];
                    }
                    fileUrl = get;
                    NSURL *url = [NSURL URLWithString:get];
                    NSString *temp = url.relativePath;
                    // 判断如果取到
                    if (temp.length == 0) {
                        break;
                    }
                    if ([temp hasPrefix:@"/"]) { // 将前缀去除
                        temp = [temp stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                    }
                    filePath = temp;
                    // 替换掉字符串,进行再次存储.
                    results = [results stringByReplacingOccurrencesOfString:tempGet withString:filePath];
                    change = YES;
                } else {
                    if ([get hasPrefix:@"/"]) { // 将前缀去除
                        get = [get stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                        // 所有需要替换的地方都有temp替换.以免错位.
                        results = [results stringByReplacingOccurrencesOfString:tempGet withString:get];
                        change = YES;
                    }
                    
                    NSString *relative = temp.relativePath;
                    NSString *pathStr = [source stringByReplacingCharactersInRange:NSMakeRange(source.length - relative.length, relative.length) withString:@""];
                    fileUrl = [NSString stringWithFormat:@"%@/%@",pathStr,get];
                }
                
                // 用model类分析数据
                NSMutableDictionary *model = [NSMutableDictionary dictionary];
                [model setValue:filePath forKey:@"localAdd"];
                [model setValue:fileUrl forKey:@"url"];
                
                [listImage addObject:model];
            }
        }
    }
    
    // 如果发生更改,再进行替换文件.
    if (change) {
        // 修正bug,重复路径.2016年01月19日
        BOOL succeed = [results writeToFile:textPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!succeed){
            // Handle error here
            NSLog(@"%@",error);
        }
    }
    NSLog(@"测试输入\n中关村大街");
    
    NSLog(@"%@",listImage);
    return listImage;
}

// 递归删除前面的字符.
- (NSString *)deleteBlank:(NSString *)string
{
    if ([string hasPrefix:@"\t"]) {
        string = [string stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
        string = [self deleteBlank:string];
    }
    return string;
}


@end
