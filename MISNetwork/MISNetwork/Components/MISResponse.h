//
//  MISResponse.h
//  MISNetwork
//
//  Created by CM on 15/12/3.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MISNetworkConfig.h"

@interface MISResponse : NSObject

#pragma mark - 属性

/**
 *  返回的状态
 */
@property (nonatomic, assign, readonly) MISResponseStatus status;


/**
 *  返回内容字符串
 */
@property (nonatomic, copy, readonly) NSString *contentString;


/**
 *  返回内容
 */
@property (nonatomic, copy, readonly) id content;


/**
 *  请求的ID
 */
@property (nonatomic, assign, readonly) NSInteger requestId;


/**
 *  请求的类
 */
@property (nonatomic, copy, readonly) NSURLRequest* request;


/**
 *  请求参数
 */
@property (nonatomic, copy) NSDictionary* requestParams;


/**
 *  返回的data
 */
@property (nonatomic, copy, readonly) NSData* responseData;


/**
 *  是否要缓存
 */
@property (nonatomic, assign, readonly) BOOL isCache;


#pragma mark - 初始化

/**
 *  初始化
 *
 *  @param responseString 返回String
 *  @param responseData   返回NSData
 *  @param requestId      请求ID
 *  @param request        请求类
 *  @param params         参数
 *  @param error          错误，nil说明成功
 *
 *  @return 实例
 */
- (instancetype) initWithResponseString:(NSString*)responseString responseData:(NSData*)responseData requestId:(NSInteger)requestId request:(NSURLRequest*)request params:(NSDictionary*)params error:(NSError*)error;

/**
 *  初始化，从缓存中得到数据
 *
 *  @param data 数据
 *
 *  @return 实例
 */
- (instancetype) initWithData:(NSData*)data;

@end
