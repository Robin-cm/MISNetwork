//
//  MISNetworkUtil.m
//  MISNetwork
//
//  Created by CM on 15/12/4.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISNetworkUtil.h"

@implementation MISNetworkUtil

/**
 *  字典的参数转换成字符串
 *
 *  @param params     参数字典
 *  @param urlEncoded 是不是要URL转义
 *
 *  @return 字符串
 */
+ (NSString*) paramsStringFromParams:(NSDictionary*)params urlEncoded:(BOOL)urlEncoded
{
    return [self paramsStringFromArray:[self sortedArrayFromParams:params urlEncoded:urlEncoded]];
}


+ (NSString*) paramsStringFromArray:(NSArray*)params
{
    if(!params) return nil;
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    NSArray *sortedParams = [params sortedArrayUsingSelector:@selector(compare:)];
    [sortedParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([paramString length] == 0) {
            [paramString appendFormat:@"%@", obj];
        } else {
            [paramString appendFormat:@"&%@", obj];
        }
    }];
    
    return paramString;
}

+ (NSArray*) sortedArrayFromParams:(NSDictionary*)params urlEncoded:(BOOL)urlEncoded
{
    if(!params) return nil;
    
    NSMutableArray* result = [[NSMutableArray alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@", obj];
        }
        if (urlEncoded) {
            obj = (NSString*)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)obj, NULL, (CFStringRef) @"!*'();:@&;=+$,/?%#[]", kCFStringEncodingUTF8));
        }
        if ([obj length] > 0) {
            [result addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    NSArray* sortedResult = [result sortedArrayUsingSelector:@selector(compare:)];
    return sortedResult;
}

@end
