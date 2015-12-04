//
//  MISBaseRequest.h
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MISNetworkConfig.h"

/**
 *  请求的接口协议，子类必须实现
 */
@protocol MISRequestProtocol <NSObject>

@required

/**
 *  基本的请求URL，比如http://api.aspirecn.com
 *
 *  @return url
 */
- (NSString*) baseUrl;

/**
 *  请求的方法，比如/xxx/xxx/
 *
 *  @return 方法路径
 */
- (NSString*) methodName;

/**
 *  请求的类型，比如MISRequestMethodGET
 *
 *  @return 请求类型
 */
- (MISRequestMethod) requestMethod;

@optional

/**
 *  改正请求参数
 *
 *  @param params 参数
 *
 *  @return 返回新的参数字典
 */
- (NSDictionary*) reformeParams:(NSDictionary*)params;

@end


#pragma mark - 参数数据源：delegate和block两种方式

/**
 *  请求的参数数据源
 */
@protocol MISRequestParamDatasource <NSObject>

@required

/**
 *  请求的参数字典
 *
 *  @return 参数字典
 */
- (NSDictionary*) paramsForRequest;


@end

/**
 *  请求的参数的回调
 *
 *  @return 请求的参数字典
 */
typedef NSDictionary*(^MISRequestParamBlock)();


#pragma mark - 请求的拦截器：delegate和block两种方式

@class MISBaseRequest;

@protocol MISRequestInterceptor <NSObject>

@optional

/**
 *  是否发送请求
 *
 *  @param request MISBaseRequest类
 *  @param params  参数
 *
 *  @return 是否发送
 */
- (BOOL) request:(MISBaseRequest*)request shouldSendRequestWithParams:(NSDictionary*)params;


/**
 *  请求以后调用
 *
 *  @param request 请求类
 *  @param params  参数
 */
- (void) request:(MISBaseRequest *)request afterRequestWithParams:(NSDictionary *)params;

/**
 *  成功回调之前调用
 *
 *  @param request  请求类
 *  @param response 返回数据类
 */
- (void) request:(MISBaseRequest *)request beforePreformSuccessWithResponse:(MISResponse*)response;

/**
 *  成功回调之后调用
 *
 *  @param request  请求类
 *  @param response 返回数据类
 */
- (void) request:(MISBaseRequest *)request afterPreformSuccessWithResponse:(MISResponse*)response;


/**
 *  错误回调之前调用
 *
 *  @param request  请求类
 *  @param response 返回数据类
 */
- (void) request:(MISBaseRequest *)request beforePreformFailWithResponse:(MISResponse*)response;

/**
 *  错误回调之后调用
 *
 *  @param request  请求类
 *  @param response 返回数据类
 */
- (void) request:(MISBaseRequest *)request afterPreformFailWithResponse:(MISResponse*)response;


@end


#pragma mark - 请求的校验器：delegate和block两种

@protocol MISRequestValidator <NSObject>

@optional

/**
 *  进行参数的校验
 *
 *  @param request 请求类
 *  @param params  参数
 *
 *  @return 是否正确
 */
- (BOOL) request:(MISBaseRequest*)request isRequestCorrectWithParams:(NSDictionary*)params;


/**
 *  返回数据是否正确
 *
 *  @param request      请求类
 *  @param responseData 返回数据
 *
 *  @return 是否正确
 */
- (BOOL) request:(MISBaseRequest *)request isResponseCorrectWithResponseData:(id)responseData;

@end


#pragma mark - 请求的代理：delegate和block两种

@protocol MISRequestDelegate <NSObject>

@required

/**
 *  请求失败
 *
 *  @param request 请求类
 */
- (void) successWithRequest:(MISBaseRequest*)request;

/**
 *  请求失败
 *
 *  @param request 请求类
 */
- (void) failWithRequest:(MISBaseRequest*)request;

@optional

/**
 *  上传进度
 *
 *  @param bytesWritten
 *  @param totalBytesWritten
 *  @param totalBytesExpectedToWrite
 *  @param request
 */
- (void) uploadProgressWithBytesWritten:(NSUInteger)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite request:(MISBaseRequest*)request;


/**
 *  下载进度
 *
 *  @param bytesWritten
 *  @param totalBytesWritten
 *  @param totalBytesExpectedToWrite
 *  @param request
 */
- (void) downloadProgressWithBytesWritten:(NSUInteger)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite request:(MISBaseRequest*)request;


/**
 *  添加data到消息体
 *
 *  @param request  请求类
 *  @param formData 表单信息
 */
- (void) request:(MISBaseRequest*)request constructingBodyWithFormdata:(id<AFMultipartFormData>)formData;


@end


#pragma mark - MISBaseRequest类开始


@interface MISBaseRequest : NSObject

#pragma mark - 属性:协议

/**
 *  子类实例
 */
@property (nonatomic, weak) NSObject<MISRequestProtocol> *child;


/**
 *  参数的数据源
 */
@property (nonatomic, weak) id<MISRequestParamDatasource> paramsDatasource;


/**
 *  拦截器
 */
@property (nonatomic, weak) id<MISRequestInterceptor> requestInterceptor;


/**
 *  请求的校验器
 */
@property (nonatomic, weak) id<MISRequestValidator> requestValidator;


/**
 *  请求代理
 */
@property (nonatomic, weak) id<MISRequestDelegate> requestDelegate;

#pragma mark - block相关

/**
 *  请求的参数block
 */
@property (nonatomic, copy) MISRequestParamBlock paramsForRequest;

#pragma mark - block相关:拦截器

/**
 *  是否发送请求block
 */
@property (nonatomic, copy) MISParamsValidatorBlock shouldSendRequestWithParamsBlock;


/**
 *  请求后调用
 */
@property (nonatomic, copy) MISParamsBlock afterRequestWithParamsBlock;


/**
 *  成功回调之前调用
 */
@property (nonatomic, copy) void(^beforePreformSuccessWithResponseBlock)(MISResponse* response);


/**
 *  成功回调之后调用
 */
@property (nonatomic, copy) void(^afterPreformSuccessWithResponseBlock)(MISResponse* response);


/**
 *  错误回调之前调用
 */
@property (nonatomic, copy) void(^beforePreformFailWithResponseBlock)(MISResponse* response);


/**
 *  错误回调之后调用
 */
@property (nonatomic, copy) void(^afterPreformFailWithResponseBlock)(MISResponse* response);


#pragma mark - block相关：校验器

/**
 *  进行参数的校验
 */
@property (nonatomic, copy) MISParamsValidatorBlock isRequestCorrectWithParamsBlock;


/**
 *  返回数据校验
 */
@property (nonatomic, copy) BOOL(^isResponseCorrectWithResponseDataBlock)(id responseData);


#pragma mark - block相关：请求回调


/**
 *  请求成功回调
 */
@property (nonatomic, copy) void(^successBlock)();


/**
 *  请求失败回调
 */
@property (nonatomic, copy) void(^failBlock)();

/**
 *  上传回调
 */
@property (nonatomic, copy) ProgressBlock uploadBlock;


/**
 *  下载回调
 */
@property (nonatomic, copy) ProgressBlock downloadBlock;


/**
 *  消息体回调
 */
@property (nonatomic, copy) ConstructingBodyBlock bodyBlock;


#pragma mark - 属性:可读

/**
 *  返回的状态
 */
@property (nonatomic, readonly) MISResponseType responseType;

/**
 *  网络是否有效
 */
@property (nonatomic, assign, readonly, getter=isReachable) BOOL reachable;

/**
 *  是否正在加载
 */
@property (nonatomic, assign, readonly, getter=isLoading) BOOL loading;


/**
 *  请求到的数据
 */
@property (nonatomic, strong, readonly) id responseData;


/**
 *  是否缓存
 */
@property (nonatomic, assign) BOOL shouldCache;


#pragma mark - 子类实现：重组参数数组

/**
 *  重组参数
 *
 *  @param params 原来的参数
 *
 *  @return 新的参数
 */
- (NSDictionary*) reformeParams:(NSDictionary*)params;

#pragma mark - 子类可以实现，实现的话，必须先调用一下super的该方法：拦截器方法

/**
 *  参数是否正确，正确才能够继续请求
 *
 *  @param params 参数字典
 *
 *  @return 是否正确
 */
- (BOOL) shouldSendRequestWithParams:(NSDictionary*)params;


/**
 *  请求以后调用
 *
 *  @param params 参数
 */
- (void) afterRequestWithParams:(NSDictionary*)params;

#pragma mark - 公共方法

/**
 *  开始请求
 *
 *  @return 返回请求ID
 */
- (NSInteger) start;

/**
 *  取消所有的请求
 */
- (void) cancelAllRequests;

/**
 *  取消ID对应的请求
 *
 *  @param requestId 请求ID
 */
- (void) cancelRequestWithId:(NSInteger)requestId;


@end
