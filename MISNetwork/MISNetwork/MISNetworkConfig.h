//  配置信息
//  MISNetworkConfig.h
//  MISNetwork
//
//  Created by CM on 15/12/2.
//  Copyright © 2015年 changmin. All rights reserved.
//

#ifndef MISNetworkConfig_h
#define MISNetworkConfig_h

/**
 *  请求方法
 */
typedef NS_ENUM(NSInteger, MISRequestMethod) {
    /**
     *  GET请求
     */
    MISRequestMethodGET,
    /**
     *  POST请求
     */
    MISRequestMethodPOST,
    /**
     *  DELETE请求
     */
    MISRequestMethodDELETE,
    /**
     *  PUT请求
     */
    MISRequestMethodPUT
};

/**
 *  请求的返回状态
 */
typedef NS_ENUM(NSInteger, MISResponseType) {
    /**
     *  默认状态，还没有产生请求
     */
    MISResponseTypeDefault,
    /**
     *  请求成功
     */
    MISResponseTypeSuccess,
    /**
     *  请求返回数据成功，但是数据不正确
     */
    MISResponseTypeNoContent,
    /**
     *  参数错误，发生在发送请求之前，不会发送请求
     */
    MISResponseTypeParamsError,
    /**
     *  请求超时
     */
    MISResponseTypeTimeout,
    /**
     *  没有网络连接
     */
    MISResponseTypeNoNetwork
};


/**
 *  返回状态
 */
typedef NS_ENUM(NSInteger, MISResponseStatus) {
    /**
     *  返回成功
     */
    MISResponseStatusSuccess,
    /**
     *  请求超时
     */
    MISResponseStatusTimeout,
    /**
     *  没有可用网络
     */
    MISResponseStatusNoNetwork
};

#pragma mark - 引入包

#import "AFNetworking.h"

@class MISResponse;

#pragma mark - 常量

/**
 *  默认的超时时间
 */
static NSTimeInterval const kMISRequestTimeoutSecondsDefault = 20.f;

/**
 *  在调用成功后的params字典里面，用这个key可以取出requestID
 */
static NSString* const kMISRequestId = @"kMISRequestId";

/**
 *  5分钟的cache过期时间
 */
static NSTimeInterval kMISCacheOutdateTimeSeconds = 300;

/**
 *  最多1000条cache
 */
static NSUInteger kMISCacheCountLimit = 1000;

/**
 *  超时时间，用的地方给赋值
 */
//extern NSTimeInterval const kMISRequestTimeoutSeconds;


#pragma mark - block定义

/**
 *  请求返回回调
 */
typedef void(^MISRequestCallBack)(MISResponse* response);

/**
 *  参数校验block
 *
 *  @param params 参数
 *
 *  @return BOOL
 */
typedef BOOL(^MISParamsValidatorBlock)(NSDictionary* params);

/**
 *  参数
 *
 *  @param params 参数
 */
typedef void(^MISParamsBlock)(NSDictionary* params);

/**
 *  请求body中添加data的回调
 *
 *  @param formData data
 */
typedef void(^ConstructingBodyBlock)(id<AFMultipartFormData> formData);

/**
 *  上传的过程回调
 *
 *  @param bytesWritten              已经上传大小
 *  @param totalBytesWritten         总共上传大小
 *  @param totalBytesExpectedToWrite 
 */
typedef void (^ProgressBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);

#endif /* MISNetworkConfig_h */
