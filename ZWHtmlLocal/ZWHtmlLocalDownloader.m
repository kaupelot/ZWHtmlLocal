//
//  ZWHtmlLocalDownloader.m
//  ZWHtmlLocal
//
//  Created by walt zeng on 16/3/21.
//  Copyright © 2016年 walt zeng. All rights reserved.
//

#import "ZWHtmlLocalDownloader.h"

#define documentPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define homePath [documentPath stringByAppendingString:@"/homepage/"]

static ZWHtmlLocalDownloader *data = nil;
@implementation ZWHtmlLocalDownloader

+ (ZWHtmlLocalDownloader *)shareData
{
    if (data == nil) {
        data = [[ZWHtmlLocalDownloader alloc] init];
    }
    return data;
}

- (NSMutableArray *)fileArray
{
    if (_fileArray == nil) {
        NSArray *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"files"];
        _fileArray = [NSMutableArray arrayWithArray:temp];
    }
    return _fileArray;
}

// 下载并写入bannner图片.此方法仅操作沙盒中homepage文件夹下的写入动作.
- (void)downloadFileToAddress:(NSString *)address url:(NSString *)url success:(void (^)(void))success failure:(void (^)(NSError* err))failure
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    // 检测传过来的地址是否包含"/"
    if ([address hasPrefix:@"/"]) {
        address = [address stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    NSString *download = [homePath stringByAppendingString:address];
    
    // 建立下载队列,管理下载对象.
    if (self.downloadArray == nil) {
        self.downloadArray = [NSMutableArray array];
    }
    if ([self.downloadArray containsObject:download]) {
        return;
    } else {
        [self.downloadArray addObject:download];
    }
    
    // 从文件地址取出文件夹地址.
    NSArray *array = [download componentsSeparatedByString:@"/"];
    NSString *last = array.lastObject;
    NSString *direct = [download stringByReplacingOccurrencesOfString:last withString:@""];
    
    // 判断目录是否存在,
    BOOL isDirectory = NO;
    BOOL directoryExists = [[NSFileManager defaultManager] fileExistsAtPath:direct isDirectory:&isDirectory];
    if (directoryExists) {
        NSLog(@"isDirectory: %d", isDirectory);
    } else {
        NSError *error = nil;
        BOOL down = [[NSFileManager defaultManager] createDirectoryAtPath:direct withIntermediateDirectories:YES attributes:nil error:&error];
        NSLog(@"success 1: %i", down);
        if (!down) {
            NSLog(@"Failed to create directory with error: %@", [error description]);
        }
    }
    
    // 将文件写入目录
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        if (data && httpResponse.statusCode == 200) { // 通过head的status判断来确定是否可以加载.
            NSError *error;
            BOOL succeed = [data writeToFile:download options:NSDataWritingAtomic error:&error];
            if (succeed) {
                if (success != nil) {
                    success();
                }
            } else {
                NSLog(@"%@",error);
                if (failure != nil ) {
                    failure(error);
                }
            }
        } else { // 返回error,把错误传输出去.
            [self.downloadArray removeObject:download]; // 从下载队列中去除,方便再次下载.
            // 由于状态码不是200,说明文件不存在,所以需要从需求中删除.
            error = [NSError errorWithDomain:url code:httpResponse.statusCode userInfo:nil];
            if (failure != nil ) {
                failure(error);
            }
        }
    }];
    [task resume];
}


@end
