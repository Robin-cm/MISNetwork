//
//  MISRequestCache.h
//  MISNetwork
//
//  Created by CM on 15/12/4.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MISRequestCache : NSObject

#pragma mark - 类方法

/**
 *  初始化，获取单例
 *
 *  @return 实例
 */
+ (instancetype)sharedInstance;

#pragma mark - 类公共方法

/**
 *  生成缓存的key值
 *
 *  @param baseUrl    基本路径
 *  @param methodName 请求方法
 *  @param params     参数
 *
 *  @return key值
 */
- (NSString*)cacheKeyWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params;

/**
 *  得到缓存数据
 *
 *  @param key 键值
 *
 *  @return 缓存数据
 */
- (NSData*)cachedDataWithKey:(NSString*)key;

/**
 *  得到混存的数据
 *
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param params     参数
 *
 *  @return 缓存数据
 */
- (NSData*)cachedDataWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params;

/**
 *  缓存数据
 *
 *  @param data 数据
 *  @param key  键值
 */
- (void)cacheDataWithData:(NSData*)data key:(NSString*)key;

/**
 *  混存数据
 *
 *  @param data       数据
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param params     参数
 */
- (void)cacheDataWithData:(NSData*)data baseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params;

/**
 *  删除缓存数据
 *
 *  @param key KEY值
 */
- (void)deleteCachedDataWithKey:(NSString*)key;

/**
 *  删除缓存数据
 *
 *  @param baseUrl    基本地址
 *  @param methodName 请求方法
 *  @param params     参数
 */
- (void)deleteCachedDataWithBaseUrl:(NSString*)baseUrl methodName:(NSString*)methodName params:(NSDictionary*)params;

/**
 *  清空缓存
 */
- (void)clean;

@end

//@interface MISRequestCacheObject : NSObject
//
//@property (nonatomic, copy, readonly) NSData* content;
//
//@property (nonatomic, copy, readonly) NSDate* lastUpdateTime;
//
//@property (nonatomic, assign, readonly) BOOL isOutdated;
//
//@property (nonatomic, assign, readonly) BOOL isEmpty;
//
//- (instancetype)initWithContent:(NSData*)content;
//
//- (void)updateContent:(NSData*)content;
//
//@end
