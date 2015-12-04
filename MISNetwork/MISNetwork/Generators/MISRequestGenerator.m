//
//  MISRequestGenerator.m
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISRequestGenerator.h"
#import "AFNetworking.h"
#import "MISRequestUrlGenerator.h"
#import "MISRequestParamsGenerator.h"
#import "MISNetworkLogger.h"

@interface MISRequestGenerator ()

#pragma mark - 属性

/**
 *  请求的序列化类
 */
@property (nonatomic) AFHTTPRequestSerializer *requestSerializer;

@end

@implementation MISRequestGenerator

#pragma mark - Getter

- (AFHTTPRequestSerializer*) requestSerializer
{
    if(!_requestSerializer){
        _requestSerializer = [[AFHTTPRequestSerializer alloc] init];
        _requestSerializer.timeoutInterval = kMISRequestTimeoutSecondsDefault;
        _requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _requestSerializer;
}

#pragma mark - 初始化，单例

+ (instancetype) sharedInstance
{
    static MISRequestGenerator *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!instance){
            instance = [[MISRequestGenerator alloc] init];
        }
    });
    return instance;
}


#pragma mark - 公共方法

- (NSURLRequest*) requestOfGetWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params
{
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:[MISRequestParamsGenerator commonParams]];
    [allParams addEntriesFromDictionary:params];
    [allParams addEntriesFromDictionary:[MISRequestParamsGenerator getCustomCommonParams]];
    NSString *url = [MISRequestUrlGenerator urlStringWithBaseUrl:baseUrl methodName:methodName params:allParams];
    if(!url) return nil;
    
    NSMutableURLRequest* request = [self.requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:nil];

    [MISNetworkLogger loginfoWithRequest:request url:url params:allParams requestMethod:@"GET"];
    return request;
}


- (NSURLRequest*) requestOfPostWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params
{
    NSString *url = [MISRequestUrlGenerator urlStringWithBaseUrl:baseUrl methodName:methodName params:[MISRequestParamsGenerator commonParams]];
    if(!url) return nil;
    
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [allParams addEntriesFromDictionary:[MISRequestParamsGenerator getCustomCommonParams]];
    NSMutableURLRequest* request = [self.requestSerializer requestWithMethod:@"POST" URLString:url parameters:allParams error:nil];
    
    [MISNetworkLogger loginfoWithRequest:request url:url params:allParams requestMethod:@"POST"];
    return request;
}


- (NSURLRequest*) requestOfPostWithBaseUrl:(NSString *)baseUrl methodName:(NSString *)methodName params:(NSDictionary *)params constructingBodyWithBlock:(ConstructingBodyBlock)bodyBlock
{
    NSString *url = [MISRequestUrlGenerator urlStringWithBaseUrl:baseUrl methodName:methodName params:[MISRequestParamsGenerator commonParams]];
    if(!url) return nil;
    
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [allParams addEntriesFromDictionary:[MISRequestParamsGenerator getCustomCommonParams]];
    
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:allParams constructingBodyWithBlock:bodyBlock error:nil];
    
    [MISNetworkLogger loginfoWithRequest:request url:url params:allParams requestMethod:@"POST"];
    return request;
}


- (NSURLRequest*) requestOfDeleteWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params
{
    NSString *url = [MISRequestUrlGenerator urlStringWithBaseUrl:baseUrl methodName:methodName params:[MISRequestParamsGenerator commonParams]];
    if(!url) return nil;
    
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [allParams addEntriesFromDictionary:[MISRequestParamsGenerator getCustomCommonParams]];
    
    NSMutableURLRequest* request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:url parameters:allParams error:nil];
    [MISNetworkLogger loginfoWithRequest:request url:url params:allParams requestMethod:@"DELETE"];
    return request;
}


- (NSURLRequest*) requestOfPutWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params
{
    NSString *url = [MISRequestUrlGenerator urlStringWithBaseUrl:baseUrl methodName:methodName params:[MISRequestParamsGenerator commonParams]];
    if(!url) return nil;
    
    NSMutableDictionary *allParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [allParams addEntriesFromDictionary:[MISRequestParamsGenerator getCustomCommonParams]];
    
    NSMutableURLRequest* request = [self.requestSerializer requestWithMethod:@"PUT" URLString:url parameters:allParams error:nil];
    [MISNetworkLogger loginfoWithRequest:request url:url params:allParams requestMethod:@"PUT"];
    return request;
}



@end
