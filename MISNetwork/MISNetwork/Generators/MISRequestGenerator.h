//  UIRequest生成器
//  MISRequestGenerator.h
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MISNetworkConfig.h"


@interface MISRequestGenerator : NSObject

#pragma mark - 初始化，单例

/**
 *  初始化，得到单例
 *
 *  @return 实例
 */
+ (instancetype) sharedInstance;

#pragma mark - 公共方法

/**
 *  得到一个GET的请求
 *
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param params     参数字典
 *
 *  @return 请求实例
 */
- (NSURLRequest*) requestOfGetWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params;


/**
 *  请求简单的POST请求
 *
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param params     参数字典
 *
 *  @return 请求实例
 */
- (NSURLRequest*) requestOfPostWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params;


/**
 *  请求带有媒体数据的POST请求
 *
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param params     参数字典
 *  @param bodyBlock  消息体添加回调
 *
 *  @return 请求实例
 */
- (NSURLRequest*) requestOfPostWithBaseUrl:(NSString *)baseUrl methodName:(NSString *)methodName params:(NSDictionary *)params constructingBodyWithBlock:(ConstructingBodyBlock)bodyBlock;


/**
 *  请求delete请求
 *
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param params     参数字典
 *
 *  @return 请求实例
 */
- (NSURLRequest*) requestOfDeleteWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params;

/**
 *  请求Put请求
 *
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param params     参数字典
 *
 *  @return 请求实例
 */
- (NSURLRequest*) requestOfPutWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params;

@end
