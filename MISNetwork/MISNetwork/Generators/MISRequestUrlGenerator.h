//
//  MISRequestUrlGenerator.h
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MISRequestUrlGenerator : NSObject

#pragma mark - 类方法

/**
 *  生成请求的URL地址
 *
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *
 *  @return 请求地址
 */
+ (NSString*) urlStringWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName;


/**
 *  生成请求的URL地址
 *
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param params     参数字典
 *
 *  @return 请求地址
 */
+ (NSString*) urlStringWithBaseUrl:(NSString *)baseUrl methodName:(NSString *)methodName params:(NSDictionary*)params;

@end
