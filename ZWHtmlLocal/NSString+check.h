//
//  NSString+check.h
//  leancloud
//
//  Created by wang on 15/8/20.
//  Copyright (c) 2015年 wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (check)

- (NSString *)timestamp;

- (NSString*) sha1;

- (NSString *)MD5String;

- (BOOL)isTelephone;

- (BOOL)isPassword;

- (BOOL)isEmailAddress;
// 检查是否数字
-(BOOL)asNumber;
// 判断是否是链接
- (BOOL)isUrl;
// 十六进制颜色转化
+ (UIColor *) colorWithHexString: (NSString *)color;

// 自适应高度使用
+ (CGFloat)stringHeight:(NSString *)aString Font:(CGFloat)font;
- (CGFloat)stringHeightWithFont:(CGFloat)font Width:(CGFloat)width;
// 网页链接编码
- (NSString *)urlencode;
// 汉字转拼音
- (NSString *)pinyin;
// 转码备用方法
- (NSString *)replaceUnicode:(NSString *)unicodeStr;
- (NSString *)changeISO88591StringToUnicodeString:(NSString *)iso88591String;
- (NSString *)unicodeToNSString:(NSString *)unicodeStr;
// 富文本
-(void)fuwenbenLabel:(UILabel *)labell FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor;
// 网址query中提取字典
- (NSMutableDictionary *)dictionaryFromQueryComponents;
// 将字典中提取出query
+ (NSString *)serializeParams:(NSDictionary *)params;
// 为了iOS8以下使用contain句法.
- (BOOL)myContainsString:(NSString*)other;
@end
