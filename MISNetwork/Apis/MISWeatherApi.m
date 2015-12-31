//
//  MISWeatherApi.m
//  MISNetwork
//
//  Created by CM on 15/12/30.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISWeatherApi.h"

@interface MISWeatherApi () <MISRequestProtocol>

@end

@implementation MISWeatherApi

/**
 *  基本的请求URL，比如http://api.aspirecn.com
 *
 *  @return url
 */
- (NSString*)baseUrl
{
    return @"http://apicloud.mob.com";
}

/**
 *  请求的方法，比如/xxx/xxx/
 *
 *  @return 方法路径
 */
- (NSString*)methodName
{
    return @"/weather/query";
}

/**
 *  请求的类型，比如MISRequestMethodGET
 *
 *  @return 请求类型
 */
- (MISRequestMethod)requestMethod
{
    return MISRequestMethodGET;
}

@end
