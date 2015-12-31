//
//  MISRequestProxy.m
//  MISNetwork
//
//  Created by CM on 15/12/2.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISRequestProxy.h"
#import "AFNetworking.h"
#import "MISRequestGenerator.h"
#import "MISResponse.h"
#import "MISNetworkLogger.h"

@interface MISRequestProxy ()

/**
 *  AFNetworking请求
 */
@property (nonatomic) AFHTTPRequestOperationManager* requestOperationManager;

/**
 *  记录的请求ID
 */
@property (nonatomic, strong) NSNumber* recordedRequestId;

/**
 *  请求ID的列表
 */
@property (nonatomic, strong) NSMutableDictionary* dispatchTable;

@end

@implementation MISRequestProxy

#pragma mark - Getter

- (AFHTTPRequestOperationManager*)requestOperationManager
{
    if (!_requestOperationManager) {
        _requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
        _requestOperationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _requestOperationManager;
}

- (NSMutableDictionary*)dispatchTable
{
    if (!_dispatchTable) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

#pragma mark - 获取单例

+ (instancetype)sharedInstance
{
    static MISRequestProxy* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[MISRequestProxy alloc] init];
        }
    });
    return instance;
}

#pragma mark - 公共方法：取消

- (void)cancelRequestWithRequestId:(NSInteger)requestId
{
    NSOperation* requestOperation = self.dispatchTable[@(requestId)];
    if (requestOperation) {
        [requestOperation cancel];
        [self.dispatchTable removeObjectForKey:@(requestId)];
    }
}

- (void)cancelRequestWithRequestIds:(NSArray*)requestIds
{
    for (NSNumber* requestId in requestIds) {
        [self cancelRequestWithRequestId:requestId.integerValue];
    }
}

- (void)pauseRequestWithRequestId:(NSInteger)requestId
{
    AFHTTPRequestOperation* requestOperation = self.dispatchTable[@(requestId)];
    if (requestOperation && !requestOperation.isPaused) {
        [requestOperation pause];
    }
}

- (void)resumeRequestWithRequestId:(NSInteger)requestId
{
    AFHTTPRequestOperation* requestOperation = self.dispatchTable[@(requestId)];
    if (requestOperation && requestOperation.isPaused) {
        [requestOperation resume];
    }
}

- (BOOL)isRequestPausedWithRequestId:(NSInteger)requestId
{
    BOOL res = NO;
    AFHTTPRequestOperation* requestOperation = self.dispatchTable[@(requestId)];
    if (requestOperation) {
        res = requestOperation.isPaused;
    }
    return res;
}

#pragma mark - 公共方法

- (NSInteger)callGetRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail
{
    NSURLRequest* request = [[MISRequestGenerator sharedInstance] requestOfGetWithBaseUrl:baseUrl methodName:methodName params:params];

    NSInteger requestId = [self requestWithRequest:request params:params uploadBlock:nil downloadBlock:nil successBlock:success failBlock:fail];
    return requestId;
}

- (NSInteger)callGetRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName downloadProgressBlock:(ProgressBlock)progressBlock success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail
{
    NSURLRequest* request = [[MISRequestGenerator sharedInstance] requestOfGetWithBaseUrl:baseUrl methodName:methodName params:params];
    NSInteger requestId = [self requestWithRequest:request params:params uploadBlock:nil downloadBlock:progressBlock successBlock:success failBlock:fail];
    return requestId;
}

- (NSInteger)callPostRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail
{
    NSURLRequest* request = [[MISRequestGenerator sharedInstance] requestOfPostWithBaseUrl:baseUrl methodName:methodName params:params];
    NSInteger requestId = [self requestWithRequest:request params:params uploadBlock:nil downloadBlock:nil successBlock:success failBlock:fail];
    return requestId;
}

- (NSInteger)callPostRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName constructingBodyWithBlock:(ConstructingBodyBlock)bodyBlock uploadProgressBlock:(ProgressBlock)progressBlock success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail
{
    NSURLRequest* request = [[MISRequestGenerator sharedInstance] requestOfPostWithBaseUrl:baseUrl methodName:methodName params:params constructingBodyWithBlock:bodyBlock];
    NSInteger requestId = [self requestWithRequest:request params:params uploadBlock:progressBlock downloadBlock:nil successBlock:success failBlock:fail];
    return requestId;
}

- (NSInteger)callDeleteRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail
{
    NSURLRequest* request = [[MISRequestGenerator sharedInstance] requestOfDeleteWithBaseUrl:baseUrl methodName:methodName params:params];
    NSInteger requestId = [self requestWithRequest:request params:params uploadBlock:nil downloadBlock:nil successBlock:success failBlock:fail];
    return requestId;
}

- (NSInteger)callPutRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail
{
    NSURLRequest* request = [[MISRequestGenerator sharedInstance] requestOfPutWithBaseUrl:baseUrl methodName:methodName params:params];
    NSInteger requestId = [self requestWithRequest:request params:params uploadBlock:nil downloadBlock:nil successBlock:success failBlock:fail];
    return requestId;
}

#pragma mark - 自定义私有方法

/**
 *  请发送请求
 *
 *  @param request       请求实例
 *  @param uploadBlock   上传进度
 *  @param downloadBlock 下载进度
 *  @param successBlock  成功回调
 *  @param failBlock     错误回调
 *
 *  @return 请求ID
 */
- (NSInteger)requestWithRequest:(NSURLRequest*)request params:(NSDictionary*)params uploadBlock:(ProgressBlock)uploadBlock downloadBlock:(ProgressBlock)downloadBlock successBlock:(MISRequestCallBack)successBlock failBlock:(MISRequestCallBack)failBlock
{
    NSNumber* requestId = [self randomRequestId];

    AFHTTPRequestOperation* httpRequestOperation = [self.requestOperationManager HTTPRequestOperationWithRequest:request
        success:^(AFHTTPRequestOperation* operation, id responseObject) {
            //已经保存的请求，马上要删掉，因为已经请求完成了
            AFHTTPRequestOperation* storedOperation = self.dispatchTable[requestId];
            if (!storedOperation) {
                //返回，因为请求的列表中没有，说明请求取消，或者已经请求完成了，不能重复
                return;
            }
            else {
                //请求成功，直接从列表中删除
                [self.dispatchTable removeObjectForKey:requestId];
            }

            [MISNetworkLogger loginfoWithResponse:operation.response responseString:operation.responseString request:operation.request error:nil];

            MISResponse* response = [[MISResponse alloc] initWithResponseString:operation.responseString responseData:operation.responseData requestId:requestId.integerValue request:operation.request params:params error:nil];

            successBlock ? successBlock(response) : nil;

        }
        failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            //已经保存的请求，马上要删掉，因为已经请求完成了
            AFHTTPRequestOperation* storedOperation = self.dispatchTable[requestId];
            if (!storedOperation) {
                //返回，因为请求的列表中没有，说明请求取消，或者已经请求完成了，不能重复
                return;
            }
            else {
                //请求成功，直接从列表中删除
                [self.dispatchTable removeObjectForKey:requestId];
            }

            [MISNetworkLogger loginfoWithResponse:operation.response responseString:operation.responseString request:operation.request error:error];

            MISResponse* response = [[MISResponse alloc] initWithResponseString:operation.responseString responseData:operation.responseData requestId:requestId.integerValue request:operation.request params:params error:error];

            failBlock ? failBlock(response) : nil;
        }];

    if (uploadBlock) {
        [httpRequestOperation setUploadProgressBlock:uploadBlock];
    }

    if (downloadBlock) {
        [httpRequestOperation setDownloadProgressBlock:downloadBlock];
    }

    self.dispatchTable[requestId] = httpRequestOperation;
    [[self.requestOperationManager operationQueue] addOperation:httpRequestOperation];
    return requestId.integerValue;
}

/**
 *  得到一个随机的请求ID
 *
 *  @return 请求ID
 */
- (NSNumber*)randomRequestId
{
    if (!_recordedRequestId) {
        _recordedRequestId = @(1);
    }
    else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        }
        else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

@end
