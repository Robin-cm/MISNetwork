//  请求返回
//  MISResponse.m
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISResponse.h"

@interface MISResponse ()

/**
 *  返回的状态
 */
@property (nonatomic, assign, readwrite) MISResponseStatus status;


/**
 *  返回内容字符串
 */
@property (nonatomic, copy, readwrite) NSString *contentString;


/**
 *  返回内容
 */
@property (nonatomic, copy, readwrite) id content;


/**
 *  请求的ID
 */
@property (nonatomic, assign, readwrite) NSInteger requestId;


/**
 *  请求的类
 */
@property (nonatomic, copy, readwrite) NSURLRequest* request;


/**
 *  返回的data
 */
@property (nonatomic, copy, readwrite) NSData* responseData;


/**
 *  是否要缓存
 */
@property (nonatomic, assign, readwrite) BOOL isCache;

@end

@implementation MISResponse

#pragma mark - 初始化

- (instancetype) initWithResponseString:(NSString*)responseString responseData:(NSData*)responseData requestId:(NSInteger)requestId request:(NSURLRequest*)request params:(NSDictionary*)params error:(NSError*)error
{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.status = [self responseStatusWithError:error];
        self.requestId = requestId;
        self.request = request;
        self.responseData = responseData;
        self.requestParams = params;
        self.isCache = NO;
        
        if (responseData) {
            self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        }
        else {
            self.content = nil;
        }
    }
    return self;
}


- (instancetype) initWithData:(NSData*)data
{
    self = [super init];
    if (self) {
        self.contentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.status = [self responseStatusWithError:nil];
        self.requestId = 0;
        self.request = nil;
        self.responseData = [data copy];
        self.content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        self.isCache = YES;
    }
    return self;
}


#pragma mark - 自定义私有方法

- (MISResponseStatus) responseStatusWithError:(NSError*)error
{
    if(error){
        MISResponseStatus result = MISResponseStatusNoNetwork;
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = MISResponseStatusTimeout;
        }
        return result;
    }else{
        return MISResponseStatusSuccess;
    }
}

@end
