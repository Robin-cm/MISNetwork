//  请求的基类
//  MISBaseRequest.m
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISBaseRequest.h"
#import "MISAppContext.h"
#import "MISRequestProxy.h"
#import "MISResponse.h"
#import "MISRequestCache.h"
#import "MISNetworkLogger.h"

@interface MISBaseRequest ()

#pragma mark - 属性:可写

/**
 *  返回的状态
 */
@property (nonatomic, readwrite) MISResponseType responseType;

/**
 *  请求ID的数组，保存所有的请求的ID
 */
@property (nonatomic) NSMutableArray* requestIds;

/**
 *  请求到的数据
 */
@property (nonatomic, strong, readwrite) id responseData;

@end

@implementation MISBaseRequest

#pragma mark - Getter

- (BOOL)isReachable
{
    BOOL isReachability = [MISAppContext sharedInstance].isReachable;
    if (!isReachability) {
        self.responseType = MISResponseTypeNoNetwork;
    }
    return isReachability;
}

- (BOOL)isLoading
{
    return self.requestIds.count > 0;
}

- (NSMutableArray*)requestIds
{
    if (!_requestIds) {
        _requestIds = [[NSMutableArray alloc] init];
    }
    return _requestIds;
}

#pragma mark - 初始化

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.requestDelegate = nil;
        self.requestInterceptor = nil;
        self.requestValidator = nil;

        self.responseData = nil;

        self.shouldCache = NO;

        //设置默认的返回状态
        _responseType = MISResponseTypeDefault;
        if ([self conformsToProtocol:@protocol(MISRequestProtocol)]) {
            //子类实现了MISBaseRequestProtocol接口
            self.child = (id<MISRequestProtocol>)self;
        }
    }
    return self;
}

#pragma mark - 销毁

- (void)dealloc
{
    //做一些销毁工作
    [self cancelAllRequests];
    self.requestIds = nil;
}

#pragma mark - 子类实现

- (NSDictionary*)reformeParams:(NSDictionary*)params
{
    return params;
}

#pragma mark - 子类可以实现，实现的话，必须先调用一下super的该方法：拦截器方法

- (BOOL)shouldSendRequestWithParams:(NSDictionary*)params
{
    BOOL res = YES;
    if (self.shouldSendRequestWithParamsBlock) {
        res = self.shouldSendRequestWithParamsBlock(params);
    }
    else if (self.requestInterceptor && [self.requestInterceptor respondsToSelector:@selector(request:shouldSendRequestWithParams:)]) {
        res = [self.requestInterceptor request:self shouldSendRequestWithParams:params];
    }
    return res;
}

- (void)afterRequestWithParams:(NSDictionary*)params
{
    if (self.afterRequestWithParamsBlock) {
        self.afterRequestWithParamsBlock(params);
    }
    else if (self.requestInterceptor && [self.requestInterceptor respondsToSelector:@selector(request:afterRequestWithParams:)]) {
        [self.requestInterceptor request:self afterRequestWithParams:params];
    }
}

#pragma mark - 公共方法

- (NSInteger)start
{
    NSDictionary* params = nil;
    if (self.paramsDatasource && [self.paramsDatasource respondsToSelector:@selector(paramsForRequest:)]) {
        params = [self.paramsDatasource paramsForRequest:self];
    }
    else if (self.paramsForRequest) {
        params = self.paramsForRequest();
    }
    else {
        NSLog(@"子类必须实现paramsDatasource或者paramsForRequest");
        return 0;
    }

    return [self startWithParams:params];
}

- (void)cancelAllRequests
{
    [[MISRequestProxy sharedInstance] cancelRequestWithRequestIds:self.requestIds];
    [self.requestIds removeAllObjects];
}

- (void)cancelRequestWithId:(NSInteger)requestId
{
    [[MISRequestProxy sharedInstance] cancelRequestWithRequestId:requestId];
    [self removeFromRequestIdsWithId:requestId];
}

- (void)pauseRequestWithId:(NSInteger)requestId
{
    [[MISRequestProxy sharedInstance] pauseRequestWithRequestId:requestId];
}

- (void)resumeRequestWithId:(NSInteger)requestId
{
    [[MISRequestProxy sharedInstance] resumeRequestWithRequestId:requestId];
}

- (BOOL)isRequestPausedWithId:(NSInteger)requestId
{
    return [[MISRequestProxy sharedInstance] isRequestPausedWithRequestId:requestId];
}

#pragma mark - 自定义私有方法

/**
 *  开始请求
 *
 *  @param params 参数
 *
 *  @return 请求的ID
 */
- (NSInteger)startWithParams:(NSDictionary*)params
{
    NSInteger requestId = 0;
    params = [self reformeParams:params];
    if ([self shouldSendRequestWithParams:params]) {
        if ([self isRequestCorrectWithParams:params]) {

            if (self.shouldCache && [self hasCacheWithParams:params]) {
                return 0;
            }

            //校验通过
            if (self.isReachable) {
                //有网络
                switch (self.child.requestMethod) {
                case MISRequestMethodGET:
                    requestId = [self startGetRequestWithParams:params];
                    break;
                case MISRequestMethodPOST:
                    requestId = [self startPostRequestWithParams:params];
                    break;
                case MISRequestMethodDELETE:
                    requestId = [self startDeleteRequestWithParams:params];
                    break;
                case MISRequestMethodPUT:
                    requestId = [self startPutRequestWithParams:params];
                    break;

                default:
                    break;
                }
                [self.requestIds addObject:@(requestId)];
                NSMutableDictionary* requestedParams = [params mutableCopy];
                requestedParams[kMISRequestId] = @(requestId);
                [self afterRequestWithParams:params];
                return requestId;
            }
            else {
                //没有网络
                [self failWithResponse:nil errorType:MISResponseTypeNoNetwork];
            }
        }
        else {
            //参数错误
            [self failWithResponse:nil errorType:MISResponseTypeParamsError];
        }
    }
    return requestId;
}

/**
 *  开始GET请求
 *
 *  @param params 参数
 */
- (NSInteger)startGetRequestWithParams:(NSDictionary*)params
{
    return [[MISRequestProxy sharedInstance] callGetRequestWithParams:params
        baseUrl:self.child.baseUrl
        methodName:self.child.methodName
        downloadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            if (self.downloadBlock) {
                self.downloadBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            }
            else if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(downloadProgressWithBytesWritten:totalBytesWritten:totalBytesExpectedToWrite:request:)]) {
                [self.requestDelegate downloadProgressWithBytesWritten:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite request:self];
            }
        }
        success:^(MISResponse* response) {
            [self successWithResponse:response];
        }
        fail:^(MISResponse* response) {
            [self failWithResponse:response errorType:MISResponseTypeNoContent];
        }];
}

/**
 *  开始POST请求
 *
 *  @param params 参数
 */
- (NSInteger)startPostRequestWithParams:(NSDictionary*)params
{
    return [[MISRequestProxy sharedInstance] callPostRequestWithParams:params
        baseUrl:self.child.baseUrl
        methodName:self.child.methodName
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (self.bodyBlock) {
                self.bodyBlock(formData);
            }
            else if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(request:constructingBodyWithFormdata:)]) {
                [self.requestDelegate request:self constructingBodyWithFormdata:formData];
            }
        }
        uploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            if (self.uploadBlock) {
                self.uploadBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
            }
            else if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(downloadProgressWithBytesWritten:totalBytesWritten:totalBytesExpectedToWrite:request:)]) {
                [self.requestDelegate downloadProgressWithBytesWritten:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite request:self];
            }
        }
        success:^(MISResponse* response) {
            if (self.successBlock) {
                self.successBlock();
            }
            else if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(successWithRequest:)]) {
                [self.requestDelegate successWithRequest:self];
            }
        }
        fail:^(MISResponse* response) {
            if (self.failBlock) {
                self.failBlock();
            }
            else if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(failWithRequest:)]) {
                [self.requestDelegate failWithRequest:self];
            }
        }];
}

/**
 *  开始DELETE请求
 *
 *  @param params 参数
 */
- (NSInteger)startDeleteRequestWithParams:(NSDictionary*)params
{
    return [[MISRequestProxy sharedInstance] callDeleteRequestWithParams:params
        baseUrl:self.child.baseUrl
        methodName:self.child.methodName
        success:^(MISResponse* response) {
            if (self.successBlock) {
                self.successBlock();
            }
            else if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(successWithRequest:)]) {
                [self.requestDelegate successWithRequest:self];
            }
        }
        fail:^(MISResponse* response) {
            if (self.failBlock) {
                self.failBlock();
            }
            else if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(failWithRequest:)]) {
                [self.requestDelegate failWithRequest:self];
            }
        }];
}

/**
 *  开始PUT请求
 *
 *  @param params 参数
 */
- (NSInteger)startPutRequestWithParams:(NSDictionary*)params
{
    return [[MISRequestProxy sharedInstance] callPutRequestWithParams:params
        baseUrl:self.child.baseUrl
        methodName:self.child.methodName
        success:^(MISResponse* response) {
            if (self.successBlock) {
                self.successBlock();
            }
            else if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(successWithRequest:)]) {
                [self.requestDelegate successWithRequest:self];
            }
        }
        fail:^(MISResponse* response) {
            if (self.failBlock) {
                self.failBlock();
            }
            else if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(failWithRequest:)]) {
                [self.requestDelegate failWithRequest:self];
            }
        }];
}

/**
 *  请求参数是否正确
 *
 *  @param params 参数字典
 *
 *  @return 是否正确
 */
- (BOOL)isRequestCorrectWithParams:(NSDictionary*)params
{
    BOOL res = YES;
    if (self.requestValidator && [self.requestValidator respondsToSelector:@selector(request:isRequestCorrectWithParams:)]) {
        res = [self.requestValidator request:self isRequestCorrectWithParams:params];
    }
    else if (self.isRequestCorrectWithParamsBlock) {
        res = self.isRequestCorrectWithParamsBlock(params);
    }
    return res;
}

/**
 *  返回的数据是否正确
 *
 *  @param responseData 返回的数据
 *
 *  @return 是否正确
 */
- (BOOL)isResponseCorrectWithResponseData:(id)responseData
{
    BOOL res = YES;
    if (self.requestValidator && [self.requestValidator respondsToSelector:@selector(request:isResponseCorrectWithResponseData:)]) {
        res = [self.requestValidator request:self isResponseCorrectWithResponseData:responseData];
    }
    else if (self.isResponseCorrectWithResponseDataBlock) {
        res = self.isResponseCorrectWithResponseDataBlock(responseData);
    }
    return res;
}

/**
 *  成功回调之前
 *
 *  @param response 返回
 */
- (void)beforePreformSuccessWithResponse:(MISResponse*)response
{
    if (self.beforePreformSuccessWithResponseBlock) {
        self.beforePreformSuccessWithResponseBlock(response);
    }
    else if (self.requestInterceptor && [self.requestInterceptor respondsToSelector:@selector(request:beforePreformSuccessWithResponse:)]) {
        [self.requestInterceptor request:self beforePreformSuccessWithResponse:response];
    }
}

/**
 *  成功回调之后
 *
 *  @param response 返回
 */
- (void)afterPreformSuccessWithResponse:(MISResponse*)response
{
    if (self.afterPreformSuccessWithResponseBlock) {
        self.afterPreformSuccessWithResponseBlock(response);
    }
    else if (self.requestInterceptor && [self.requestInterceptor respondsToSelector:@selector(request:afterPreformSuccessWithResponse:)]) {
        [self.requestInterceptor request:self afterPreformSuccessWithResponse:response];
    }
}

/**
 *  错误回调之前
 *
 *  @param response 返回信息
 */
- (void)beforePreformFailWithResponse:(MISResponse*)response
{
    if (self.beforePreformFailWithResponseBlock) {
        self.beforePreformFailWithResponseBlock(response);
    }
    else if (self.requestInterceptor && [self.requestInterceptor respondsToSelector:@selector(request:beforePreformFailWithResponse:)]) {
        [self.requestInterceptor request:self beforePreformFailWithResponse:response];
    }
}

/**
 *  错误回调之后
 *
 *  @param response 返回信息
 */
- (void)afterPreformFailWithResponse:(MISResponse*)response
{
    if (self.afterPreformFailWithResponseBlock) {
        self.afterPreformFailWithResponseBlock(response);
    }
    else if (self.requestInterceptor && [self.requestInterceptor respondsToSelector:@selector(request:afterPreformFailWithResponse:)]) {
        [self.requestInterceptor request:self afterPreformFailWithResponse:response];
    }
}

/**
 *  请求成功
 *
 *  @param response 返回信息
 */
- (void)successWithResponse:(MISResponse*)response
{
    if (response.content) {
        self.responseData = [response.content copy];
    }
    else {
        self.responseData = [response.responseData copy];
    }

    [self removeFromRequestIdsWithId:response.requestId];

    if ([self isResponseCorrectWithResponseData:self.responseData]) {
        if (self.shouldCache && !response.isCache) {

            //如果需要缓存的话，在这里缓存返回来的数据
            [[MISRequestCache sharedInstance] cacheDataWithData:response.responseData baseUrl:self.child.baseUrl methodName:self.child.methodName params:response.requestParams];
        }

        [self beforePreformSuccessWithResponse:response];
        if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(successWithRequest:)]) {
            [self.requestDelegate successWithRequest:self];
        }
        else if (self.successBlock) {
            self.successBlock();
        }
        [self afterPreformSuccessWithResponse:response];
    }
    else {
        [self failWithResponse:response errorType:MISResponseTypeNoContent];
    }
}

/**
 *  请求失败
 *
 *  @param response  返回信息
 *  @param errorType 错误信息
 */
- (void)failWithResponse:(MISResponse*)response errorType:(MISResponseType)errorType
{
    self.responseType = errorType;
    [self removeFromRequestIdsWithId:response.requestId];
    [self beforePreformFailWithResponse:response];
    if (self.requestDelegate && [self.requestDelegate respondsToSelector:@selector(failWithRequest:)]) {
        [self.requestDelegate failWithRequest:self];
    }
    else if (self.successBlock) {
        self.failBlock();
    }
    [self afterPreformFailWithResponse:response];
}

/**
 *  删除请求ID列表中的对应的ID
 *
 *  @param requestId 要删除的请求ID
 */
- (void)removeFromRequestIdsWithId:(NSInteger)requestId
{
    NSNumber* requestIdToRemove = nil;
    for (NSNumber* storedRequestId in self.requestIds) {
        if ([storedRequestId integerValue] == requestId) {
            requestIdToRemove = storedRequestId;
            break;
        }
    }
    if (requestIdToRemove) {
        [self.requestIds removeObject:requestIdToRemove];
    }
}

/**
 *  是不是有缓存，没有缓存就添加到缓存
 *
 *  @param params 参数
 *
 *  @return 是不是缓存
 */
- (BOOL)hasCacheWithParams:(NSDictionary*)params
{
    NSData* result = [[MISRequestCache sharedInstance] cachedDataWithBaseUrl:self.child.baseUrl methodName:self.child.methodName params:params];
    if (!result) {
        return NO;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        MISResponse* response = [[MISResponse alloc] initWithData:result];
        response.requestParams = params;
        [MISNetworkLogger loginfoWithCachedResponse:response methodName:self.child.methodName baseUrl:self.child.baseUrl];
        [self successWithResponse:response];
    });

    return YES;
}

@end
