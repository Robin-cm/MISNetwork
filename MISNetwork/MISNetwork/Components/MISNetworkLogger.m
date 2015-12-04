//  打印LOG
//  MISNetworkLogger.m
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISNetworkLogger.h"
#import "MISResponse.h"

@implementation MISNetworkLogger

#pragma mark - 类方法

+ (void) loginfoWithRequest:(NSURLRequest*)request url:(NSString*)url params:(NSDictionary*)params requestMethod:(NSString*)requestMethod
{
#ifdef DEBUG
    NSMutableString* logString = [NSMutableString stringWithString:@"\n\n**************************************************************\n*                       请求开始                       *\n**************************************************************\n\n"];
    
    [logString appendFormat:@"请求地址：\t\t%@\n", url];
    [logString appendFormat:@"请求类型:\t\t\t%@\n", requestMethod];
    [logString appendFormat:@"请求参数:\n%@", params];
    [logString appendFormat:@"\n\n请求 头信息:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    [logString appendFormat:@"\n\n请求 消息体:\n\t%@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    
    [logString appendFormat:@"\n\n**************************************************************\n*                          请求结束                        *\n**************************************************************\n\n\n\n"];
    
    NSLog(@"%@", logString);
#endif
}

+ (void) loginfoWithResponse:(NSHTTPURLResponse*)response responseString:(NSString*)responseString request:(NSURLRequest*)request error:(NSError*)error
{
#ifdef DEBUG
    BOOL shouldLogError = error ? YES : NO;
    
    NSMutableString* logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                        请求 返回开始                        =\n==============================================================\n\n"];
    
    [logString appendFormat:@"Status:\t%ld\t(%@)\n\n", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]];
    [logString appendFormat:@"Content:\n\t%@\n\n", responseString];
    if (shouldLogError) {
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }
    
    [logString appendString:@"\n---------------  Related Request Content  --------------\n"];
    
    [logString appendFormat:@"\n\n请求 头信息:\n%@", request.allHTTPHeaderFields ? request.allHTTPHeaderFields : @"\t\t\t\t\tN/A"];
    [logString appendFormat:@"\n\n请求 消息体:\n\t%@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]];
    
    [logString appendFormat:@"\n\n==============================================================\n=                        请求 返回结束                        =\n==============================================================\n\n\n\n"];
    
    NSLog(@"%@", logString);
#endif
}



+ (void) loginfoWithCachedResponse:(MISResponse*)response methodName:(NSString*)methodName baseUrl:(NSString*)baseUrl
{
#ifdef DEBUG
    NSMutableString* logString = [NSMutableString stringWithString:@"\n\n==============================================================\n=                      Cached Response                       =\n==============================================================\n\n"];
    
    [logString appendFormat:@"API Name:\t\t%@\n", methodName];
    [logString appendFormat:@"Service:\t\t%@\n", baseUrl];
    [logString appendFormat:@"Method Name:\t%@\n", methodName];
    [logString appendFormat:@"Params:\n%@\n\n", response.requestParams];
    [logString appendFormat:@"Content:\n\t%@\n\n", response.contentString];
    
    [logString appendFormat:@"\n\n==============================================================\n=                        Response End                        =\n==============================================================\n\n\n\n"];
    NSLog(@"%@", logString);
#endif
}


@end
