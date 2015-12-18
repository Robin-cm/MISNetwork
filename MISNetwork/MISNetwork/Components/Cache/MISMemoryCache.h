//
//  MISMemoryCache.h
//  MISNetwork
//
//  Created by CM on 15/12/16.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MISMemoryCache : NSObject

#pragma mark - 属性

/**
 *  缓存的名称
 */
@property (copy) NSString* name;

/**
 *  能够缓存的总数，只读属性
 */
@property (assign, readonly) NSUInteger totalCount;

/**
 *  已经缓存的个数，只读属性
 */
@property (assign, readonly) NSUInteger totalCost;

#pragma mark - 属性：限制

/**
 *  能够缓存的最大数据个数
 *  默认值是 NSUIntegerMax，表示没有限制
 */
@property (assign) NSUInteger countLimit;

/**
 *  
 */
@property (assign) NSUInteger costLimit;

/**
 *  
 */
@property (assign) NSUInteger ageLimit;

/**
 *  
 */
@property (assign) NSTimeInterval autoTrimInterval;

/**
 *  在内存不足时是否清空所有的缓存，默认值是YES
 */
@property (assign) BOOL shouldRemoveAllObjectsOnMemoryWarning;

/**
 *  在切换到后台时是不是清空所有的缓存，默认值是YES
 */
@property (assign) BOOL shouldRemoveAllObjectsWhenEnteringBackground;

/**
 *  在接受到内存不足警告时，执行的回调，默认为nil
 */
@property (copy) void (^didReceiveMemoryWarningBlock)(MISMemoryCache* cache);

/**
 *  在切换到后台时，执行的回调，默认为nil
 */
@property (copy) void (^didEnterBackgroundBlock)(MISMemoryCache* cache);

/**
 *  是否在主线程上释放缓存，默认值是NO
 */
@property (assign) BOOL releaseOnMainThread;

/**
 *  是否异步释放缓存，默认值是YES
 */
@property (assign) BOOL releaseAsynchronously;

#pragma mark - 公共方法

/**
 *  是否有key对应的缓存
 *
 *  @param key  key值
 *
 *  @return key对应的缓存
 */
- (BOOL)containsObjectForKey:(id)key;

/**
 *  得到key对应的缓存
 *
 *  @param key key值
 *
 *  @return 对应的缓存
 */
- (id)objectForKey:(id)key;

/**
 *  设置key对应的缓存值，cost为0
 *
 *  @param object 缓存的内容
 *  @param key    key值
 */
- (void)setObject:(id)object forKey:(id)key;

/**
 *  设置key对应的缓存值
 *
 *  @param object 缓存的内容
 *  @param key    key值
 *  @param cost   花费
 */
- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost;

/**
 *  删除key对应的缓存
 *
 *  @param key key值
 */
- (void)removeObjectForKey:(id)key;

/**
 *  删除所有的缓存
 */
- (void)removeAllObjects;

#pragma mark - 公共方法：trim

/**
 *  Removes objects from the cache with LRU, until the `totalCount` is below or equal to
 the specified value.
 *
 *  @param count The total count allowed to remain after the cache has been trimmed.
 */
- (void)trimToCount:(NSUInteger)count;

/**
 *  Removes objects from the cache with LRU, until the `totalCost` is or equal to
 the specified value.
 *
 *  @param cost The total cost allowed to remain after the cache has been trimmed.
 */
- (void)trimToCost:(NSUInteger)cost;

/**
 *  Removes objects from the cache with LRU, until all expiry objects removed by the
 specified value.
 *
 *  @param age The maximum age (in seconds) of objects.
 */
- (void)trimToAge:(NSTimeInterval)age;

@end
