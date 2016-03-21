//
//  NSString+check.m
//  leancloud
//
//  Created by wang on 15/8/20.
//  Copyright (c) 2015年 wang. All rights reserved.
//

#import "NSString+check.h"
#import <CommonCrypto/CommonDigest.h>
static NSString *const uq_URLReservedChars  = @"￼=,!$&'()*+;@?\r\n\"<>#\t :/";
static NSString *const kQuerySeparator      = @"&";
static NSString *const kQueryDivider        = @"=";
static NSString *const kQueryBegin          = @"?";
static NSString *const kFragmentBegin       = @"#";
@implementation NSString (check)

- (NSString *)timestamp
{
    //获取系统当前的时间戳
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timestamp = [NSString stringWithFormat:@"%0.f", a];
    return timestamp;
}

- (NSString*) sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);  // (int)转型是添加上去的,可能有错误的返回字符.
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString *)MD5String {  // 此处生成的大写字符的md5 **
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

- (BOOL)isEmailAddress
{
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

// 判断是否是链接
- (BOOL)isUrl
{
    NSString *      regex = @"[a-zA-z]+://[^\\s]*";
    NSPredicate *  pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

// 检查是否数字.
-(BOOL)asNumber
{
    NSString *regEx = @"^-?\\d+.?\\d?";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    BOOL isMatch            = [pred evaluateWithObject:self];
    return isMatch;
}

// 根据字体和文字计算高度
+ (CGFloat)stringHeight:(NSString *)aString Font:(CGFloat)font
{
    CGRect r = [aString boundingRectWithSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width - 60, 2000) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName :  [UIFont systemFontOfSize:font]} context:nil];
    
    return r.size.height + 10;
}

// 将汉字转化成拼音的系统方法
- (NSString *)pinyin
{
    NSMutableString *str = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    NSString *pinYin = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    return pinYin;
}

- (CGFloat)stringHeightWithFont:(CGFloat)font Width:(CGFloat)width
{
    CGRect r = [self boundingRectWithSize:CGSizeMake(width, 2000) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName :  [UIFont systemFontOfSize:font]} context:nil];
    
    return r.size.height + 10;
}

- (BOOL)isTelephone
{
//    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
//    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
//    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
//    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    NSString * ALL = @"^((13)|(14)|(15)|(17)|(18))\\d{9}$";
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
//    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
//    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    NSPredicate *regextestALL = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ALL];
    
    return  [regextestALL evaluateWithObject:self] ||
    [regextestphs evaluateWithObject:self];
}


- (BOOL)isPassword
{
    NSString *      regex = @"(^[A-Za-z0-9]{6,20}$)";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:self];
}

- (NSString *)replaceUnicode:(NSString *)unicodeStr {
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
//    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
//                                                          mutabilityOption:NSPropertyListImmutable
//                                                                    format:NULL
//                                                          errorDescription:NULL];
    NSString *returnStr = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

// 最好用的一个方法
- (NSString *)urlencode
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

//  原有方法 2016年02月01日
//- (NSString *)urlencode
//{
//    NSMutableString *output = [NSMutableString string];
//    const unsigned char *source = (const unsigned char *)[self UTF8String];
//    int sourceLen = (int)strlen((const char *)source);
//    for (int i = 0; i < sourceLen; ++i) {
//        const unsigned char thisChar = source[i];
//        if (thisChar == ' '){
//            [output appendString:@"+"];
//        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
//                   (thisChar >= 'a' && thisChar <= 'z') ||
//                   (thisChar >= 'A' && thisChar <= 'Z') ||
//                   (thisChar >= '0' && thisChar <= '9')) {
//            [output appendFormat:@"%c", thisChar];
//        } else {
//            [output appendFormat:@"%%%02X", thisChar];
//        }
//    }
//    return output;
//}

/*
汉字与utf8相互转化:

NSString* strA = [@"%E4%B8%AD%E5%9B%BD"stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
NSString *strB = [@"中国"stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];



NSString 转化为utf8:

NSString *strings = [NSStringstringWithFormat:@"abc"];

NSLog(@"strings : %@",strings);

CF_EXPORT
CFStringRef CFURLCreateStringByAddingPercentEscapes(CFAllocatorRef allocator,CFStringReforiginalString,CFStringRef charactersToLeaved, CFStringReflegalURLCharactersToBeEscaped,CFStringEncoding encoding);

NSString *encodedValue = (__bridge NSString*)CFURLCreateStringByAddingPercentEscapes(nil,(__bridgeCFStringRef)strings,nil, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
*/


// iso8859－1 到 unicode编码转换:

- (NSString *)changeISO88591StringToUnicodeString:(NSString *)iso88591String
{
    
    NSMutableString *srcString = [[NSMutableString alloc]initWithString:iso88591String];
    
    [srcString replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSLiteralSearch range:NSMakeRange(0, [srcString length])];
    [srcString replaceOccurrencesOfString:@"&#x" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [srcString length])];
    
    NSMutableString *desString = [[NSMutableString alloc]init];
    
    NSArray *arr = [srcString componentsSeparatedByString:@";"];
    
    for(int i=0;i<[arr count]-1;i++){
        
        NSString *v = [arr objectAtIndex:i];
        char *c = malloc(3);
//        int value = [StringUtil changeHexStringToDecimal:v];
        int value = [v intValue];
        c[1] = value  &0x00FF;
        c[0] = value >>8 &0x00FF;
        c[2] = '\0';
        [desString appendString:[NSString stringWithCString:c encoding:NSUnicodeStringEncoding]];
        free(c);
    }
    
    return desString;
}


// unicode转码
- (NSString *)unicodeToNSString:(NSString *)unicodeStr

{
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"&#"withString:@""];
    
    NSArray *arr = [tempStr1 componentsSeparatedByString:@";"];
    
    NSString *abc=@"";
    
    for(NSString *v in arr)
        
    {
        
        char *c = malloc(2);
        
        int value = [v intValue];
        
        c[1] = value  & 0x00FF;
        
        c[0] = value >> 8 & 0x00FF;
        
        NSString *bb=[NSString stringWithCString:c encoding:NSUnicodeStringEncoding];
        
        abc = [NSString stringWithFormat:@"%@%@",abc,bb];
        
        free(c);
        
    }
    
    return abc;
}

// 富文本使用方法
-(void)fuwenbenLabel:(UILabel *)labell FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    labell.text = self;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:labell.text];
    
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    labell.attributedText = str;
}

// 网址query中提取字典 https://github.com/itsthejb/NSURL-QueryDictionary
- (NSMutableDictionary *)dictionaryFromQueryComponents
{
    NSMutableDictionary *mute = @{}.mutableCopy;
    for (NSString *query in [self componentsSeparatedByString:kQuerySeparator]) {
        NSArray *components = [query componentsSeparatedByString:kQueryDivider];
        if (components.count == 0) {
            continue;
        }
        NSString *key = [components[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id value = nil;
        if (components.count == 1) {
            // key with no value
            value = [NSNull null];
        }
        if (components.count == 2) {
            value = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            // cover case where there is a separator, but no actual value
            value = [value length] ? value : [NSNull null];
        }
        if (components.count > 2) {
            // invalid - ignore this pair. is this best, though?
            continue;
        }
        mute[key] = value ?: [NSNull null];
    }
    return mute.count ? mute.copy : nil;
}

// 将字典中提取出query
+ (NSString *)serializeParams:(NSDictionary *)params {
    NSMutableArray *pairs = NSMutableArray.array;
    for (NSString *key in params.keyEnumerator) {
        id value = params[key];
        if ([value isKindOfClass:[NSDictionary class]])
            for (NSString *subKey in value)
                [pairs addObject:[NSString stringWithFormat:@"%@[%@]=%@", key, subKey, [self escapeValueForURLParameter:[value objectForKey:subKey]]]];
        
        else if ([value isKindOfClass:[NSArray class]])
            for (NSString *subValue in value)
                [pairs addObject:[NSString stringWithFormat:@"%@[]=%@", key, [self escapeValueForURLParameter:subValue]]];
        
        else
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [self escapeValueForURLParameter:value]]];
        
    }
    return [pairs componentsJoinedByString:@"&"];
}


+ (NSString *)escapeValueForURLParameter:(NSString *)valueToEscape {
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) valueToEscape,NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

// 为了iOS8以下使用contain句法.
- (BOOL)myContainsString:(NSString*)other {
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

@end
