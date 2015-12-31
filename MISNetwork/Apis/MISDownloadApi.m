//
//  MISDownloadApi.m
//  MISNetwork
//
//  Created by CM on 15/12/30.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISDownloadApi.h"

@interface MISDownloadApi () <MISRequestProtocol>

@end

@implementation MISDownloadApi

/**
 *  基本的请求URL，比如http://api.aspirecn.com
 *
 *  @return url
 */
- (NSString*)baseUrl
{
    return @"http://10.115.241.13";
}

/**
 *  请求的方法，比如/xxx/xxx/
 *
 *  @return 方法路径
 */
- (NSString*)methodName
{
    return @"/files/A0700000052531AD/dldir1.qq.com/weixin/android/weixin638android680.apk";
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
