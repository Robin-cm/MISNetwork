//
//  MISRequestProxy.h
//  MISNetwork
//
//  Created by CM on 15/12/2.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MISNetworkConfig.h"

@interface MISRequestProxy : NSObject

#pragma mark - 获取单例

/**
 *  获取单例
 *
 *  @return 实例
 */
+ (instancetype) sharedInstance;

#pragma mark - 公共方法

/**
 *  取消请求
 *
 *  @param requestId 请求的ID
 */
- (void) cancelRequestWithRequestId:(NSInteger)requestId;


/**
 *  取消多个请求
 *
 *  @param requestIds 请求ID的数组
 */
- (void) cancelRequestWithRequestIds:(NSArray*)requestIds;

#pragma mark - 公共方法：请求

/**
 *  发送GET请求
 *
 *  @param params     参数
 *  @param baseUrl    基本URL
 *  @param methodName 请求方法
 *  @param success    成功回调
 *  @param fail       失败回调
 *
 *  @return 请求的ID
 */
- (NSInteger) callGetRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail;


/**
 *  发送GET请求
 *
 *  @param params        参数
 *  @param baseUrl       基本URL
 *  @param methodName    请求方法
 *  @param progressBlock 下载进度
 *  @param success       成功回调
 *  @param fail          失败回调
 *
 *  @return 请求的ID
 */
- (NSInteger) callGetRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName downloadProgressBlock:(ProgressBlock)progressBlock success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail;


/**
 *  发送POST请求
 *
 *  @param params     参数
 *  @param baseUrl    基本URL
 *  @param methodName 请求方法
 *  @param success    成功回调
 *  @param fail       错误回调
 *
 *  @return 请求ID
 */
- (NSInteger) callPostRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail;


/**
 *  发送POST请求,上传媒体信息
 *
 *  @param params        参数
 *  @param baseUrl       基本地址
 *  @param methodName    请求方法
 *  @param bodyBlock     消息体回调，用来添加Data
 *  @param progressBlock 上传进度
 *  @param success       成功回调
 *  @param fail          错误回调
 *
 *  @return 请求ID
 */
- (NSInteger) callPostRequestWithParams:(NSDictionary *)params baseUrl:(NSString *)baseUrl methodName:(NSString *)methodName constructingBodyWithBlock:(ConstructingBodyBlock)bodyBlock uploadProgressBlock:(ProgressBlock)progressBlock success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail;


/**
 *  发送DELETE请求
 *
 *  @param params     参数
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param success    成功回调
 *  @param fail       错误回调
 *
 *  @return 请求ID
 */
- (NSInteger) callDeleteRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail;


/**
 *  发送DELETE请求
 *
 *  @param params     参数
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param success    成功回调
 *  @param fail       错误回调
 *
 *  @return 请求ID
 */
- (NSInteger) callPutRequestWithParams:(NSDictionary*)params baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName success:(MISRequestCallBack)success fail:(MISRequestCallBack)fail;



@end
