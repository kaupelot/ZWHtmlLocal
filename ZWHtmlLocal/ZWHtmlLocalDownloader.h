//
//  ZWHtmlLocalDownloader.h
//  ZWHtmlLocal
//
//  Created by walt zeng on 16/3/21.
//  Copyright © 2016年 walt zeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWHtmlLocalDownloader : NSObject

@property (strong, nonatomic) NSMutableArray *fileArray;
@property (strong, nonatomic) NSMutableArray *downloadArray;

+ (ZWHtmlLocalDownloader *)shareData; // 单例

// 此方法仅操作沙盒中homepage文件夹下的写入动作.有一段时间没有敲代码了,想到自己的堕落实在是悔不应该.
- (void)downloadFileToAddress:(NSString *)address url:(NSString *)url success:(void (^)(void))success failure:(void (^)(NSError* err))failure;

@end
