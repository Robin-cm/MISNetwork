//
//  MISNetworkLogger.h
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MISResponse;

@interface MISNetworkLogger : NSObject

#pragma mark - 类方法

/**
 *  打印请求信息
 *
 *  @param request       请求实例
 *  @param url           请求地址
 *  @param params        请求参数
 *  @param requestMethod 请求类型
 */
+ (void) loginfoWithRequest:(NSURLRequest*)request url:(NSString*)url params:(NSDictionary*)params requestMethod:(NSString*)requestMethod;


/**
 *  打印返回信息
 *
 *  @param response       返回
 *  @param responseString 请求
 *  @param request        请求
 *  @param error          错误
 */
+ (void) loginfoWithResponse:(NSHTTPURLResponse*)response responseString:(NSString*)responseString request:(NSURLRequest*)request error:(NSError*)error;


/**
 *  打印缓存的数据
 *
 *  @param response
 *  @param methodName
 *  @param baseUrl
 */
+ (void) loginfoWithCachedResponse:(MISResponse*)response methodName:(NSString*)methodName baseUrl:(NSString*)baseUrl;

@end
