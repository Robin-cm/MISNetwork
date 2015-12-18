//  硬盘缓存
//  MISDiskCache.h
//  MISNetwork
//
//  Created by CM on 15/12/16.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MISDiskCache : NSObject

#pragma mark - 属性

/**
 *  缓存的名称
 */
@property (copy) NSString* name;

/**
 *  缓存的路径
 */
@property (copy) NSString* path;

/**
 If the object's data size (in bytes) is larger than this value, then object will
 be stored as a file, otherwise the object will be stored in sqlite.
 
 0 means all objects will be stored as separated files, NSUIntegerMax means all
 objects will be stored in sqlite.
 
 如果对象的大小大于这个值，对象会被保存为文件，否则会保存到sqlite数据库中
 
 The default value is 20480 (20KB).
 默认的大小是20KB
 */
@property (readonly) NSUInteger inlineThreshold;

/**
 If this block in not nil, then the block will be used to archive object instead
 of NSKeyedArchiver. You can use this block to support the objects which do not
 conform to the `NSCoding` protocol.
 
 如果这个block不为空，这个block将被用来归档对象，来替代 NSKeyedArchiver，你可以在这归档那些没有实现 NSCoding 的协议的对象
 
 The default value is nil.
 默认是nil
 */
@property (copy) NSData* (^customArchiveBlock)(id object);

/**
 If this block in not nil, then the block will be used to unarchive object instead
 of NSKeyedUnarchiver. You can use this block to support the objects which do not
 conform to the `NSCoding` protocol.
 
 如果这个block不为空，这个block将被用反来归档对象，来替代 NSKeyedUnarchiver，你可以在这归档那些没有实现 NSCoding 的协议的对象
 
 The default value is nil.
 默认是nil
 */
@property (copy) id (^customUnarchiveBlock)(NSData* data);

/**
 When an object needs to be saved as a file, this block will be invoked to generate
 a file name for a specified key. If the block is nil, the cache use md5(key) as
 default file name.
 
 当对象需要保存成文件时，这个block用来把key生成一个文件名，如果这个block是nil，讲会用MD5算法生成默认的文件名
 
 The default value is nil.
 默认的是nil
 */
@property (copy) NSString* (^customFilenameBlock)(NSString* key);

#pragma mark - 属性：限制

/**
 The maximum number of objects the cache should hold.
 
 可以保存的对象的最大个数
 
 @discussion The default value is NSUIntegerMax, which means no limit.
 This is not a strict limit — if the cache goes over the limit, some objects in the
 cache could be evicted later in background queue.
 默认值是 NSUIntegerMax，表示没有限制。这不是一个严格的限制 - 如果缓存大于这个限制，一些对象会在后台被清理掉
 */
@property (assign) NSUInteger countLimit;

/**
 The maximum total cost that the cache can hold before it starts evicting objects.
 
 在开始清理之前，可以保存的对象个数的最大数
 
 @discussion The default value is NSUIntegerMax, which means no limit.
 This is not a strict limit — if the cache goes over the limit, some objects in the
 cache could be evicted later in background queue.
 默认值是 NSUIntegerMax，表示没有限制。这不是一个严格的限制 - 如果缓存大于这个限制，一些对象会在后台被清理掉
 */
@property (assign) NSUInteger costLimit;

/**
 The maximum expiry time of objects in cache.
 缓存的有效期
 
 @discussion The default value is DBL_MAX, which means no limit.
 This is not a strict limit — if an object goes over the limit, the objects could
 be evicted later in background queue.
 默认的值是 DBL_MAX，表示没有限制。这不是个严格的限制，如果对象超过这个时间限制，对象可能在后台被清理
 */
@property (assign) NSTimeInterval ageLimit;

/**
 The minimum free disk space (in bytes) which the cache should kept.
 最小的可使用空间
 
 @discussion The default value is 0, which means no limit.
 If the free disk space is lower than this value, the cache will remove objects
 to free some disk space. This is not a strict limit—if the free disk space goes
 over the limit, the objects could be evicted later in background queue.
 */
@property (assign) NSUInteger freeDiskSpaceLimit;

/**
 The auto trim check time interval in seconds. Default is 60 (1 minute).
 自动检查的时间，默认是60秒
 
 @discussion The cache holds an internal timer to check whether the cache reaches
 its limits, and if the limit is reached, it begins to evict objects.
 */
@property (assign) NSTimeInterval autoTrimInterval;

#pragma mark - 初始化

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype) new UNAVAILABLE_ATTRIBUTE;

/**
 Create a new cache based on the specified path.
 根据路径来创建一个新的缓存对象
 
 @param path Full path of a directory in which the cache will write data.
 Once initialized you should not read and write to this directory.
 
 @return A new cache object, or nil if an error occurs.
 
 @warning Multiple instances with the same path will make the storage unstable.
 */
- (instancetype)initWithPath:(NSString*)path;

/**
 The designated initializer.
 
 @param path       Full path of a directory in which the cache will write data.
 Once initialized you should not read and write to this directory.
 
 @param threshold  The data store inline threshold in bytes. If the object's data
 size (in bytes) is larger than this value, then object will be stored as a
 file, otherwise the object will be stored in sqlite. 0 means all objects will
 be stored as separated files, NSUIntegerMax means all objects will be stored
 in sqlite. If you don't know your object's size, 20480 is a good choice.
 After first initialized you should not change this value of the specified path.
 
 @return A new cache object, or nil if an error occurs.
 
 @warning Multiple instances with the same path will make the storage unstable.
 */
- (instancetype)initWithPath:(NSString*)path
             inlineThreshold:(NSUInteger)threshold NS_DESIGNATED_INITIALIZER;

#pragma mark - 公共方法

/**
 Returns a boolean value that indicates whether a given key is in cache.
 This method may blocks the calling thread until file read finished.
 
 @param key A string identifying the value. If nil, just return NO.
 @return Whether the key is in cache.
 */
- (BOOL)containsObjectForKey:(NSString*)key;

/**
 Returns a boolean value with the block that indicates whether a given key is in cache.
 This method returns immediately and invoke the passed block in background queue
 when the operation finished.
 
 @param key   A string identifying the value. If nil, just return NO.
 @param block A block which will be invoked in background queue when finished.
 */
- (void)containsObjectForKey:(NSString*)key withBlock:(void (^)(NSString* key, BOOL contains))block;

/**
 Returns the value associated with a given key.
 This method may blocks the calling thread until file read finished.
 
 @param key A string identifying the value. If nil, just return nil.
 @return The value associated with key, or nil if no value is associated with key.
 */
- (id<NSCoding>)objectForKey:(NSString*)key;

/**
 Returns the value associated with a given key.
 This method returns immediately and invoke the passed block in background queue
 when the operation finished.
 
 @param key A string identifying the value. If nil, just return nil.
 @param block A block which will be invoked in background queue when finished.
 */
- (void)objectForKey:(NSString*)key withBlock:(void (^)(NSString* key, id<NSCoding> object))block;

/**
 Sets the value of the specified key in the cache.
 This method may blocks the calling thread until file write finished.
 
 @param object The object to be stored in the cache. If nil, it calls `removeObjectForKey:`.
 @param key    The key with which to associate the value. If nil, this method has no effect.
 */
- (void)setObject:(id<NSCoding>)object forKey:(NSString*)key;

/**
 Sets the value of the specified key in the cache.
 This method returns immediately and invoke the passed block in background queue
 when the operation finished.
 
 @param object The object to be stored in the cache. If nil, it calls `removeObjectForKey:`.
 @param block  A block which will be invoked in background queue when finished.
 */
- (void)setObject:(id<NSCoding>)object forKey:(NSString*)key withBlock:(void (^)(void))block;

/**
 Removes the value of the specified key in the cache.
 This method may blocks the calling thread until file delete finished.
 
 @param key The key identifying the value to be removed. If nil, this method has no effect.
 */
- (void)removeObjectForKey:(NSString*)key;

/**
 Removes the value of the specified key in the cache.
 This method returns immediately and invoke the passed block in background queue
 when the operation finished.
 
 @param key The key identifying the value to be removed. If nil, this method has no effect.
 @param block  A block which will be invoked in background queue when finished.
 */
- (void)removeObjectForKey:(NSString*)key withBlock:(void (^)(NSString* key))block;

/**
 Empties the cache.
 This method may blocks the calling thread until file delete finished.
 */
- (void)removeAllObjects;

/**
 Empties the cache.
 This method returns immediately and invoke the passed block in background queue
 when the operation finished.
 
 @param block  A block which will be invoked in background queue when finished.
 */
- (void)removeAllObjectsWithBlock:(void (^)(void))block;

/**
 Empties the cache with block.
 This method returns immediately and executes the clear operation with block in background.
 
 @warning You should not send message to this instance in these blocks.
 @param progress This block will be invoked during removing, pass nil to ignore.
 @param end      This block will be invoked at the end, pass nil to ignore.
 */
- (void)removeAllObjectsWithProgressBlock:(void (^)(int removedCount, int totalCount))progress
                                 endBlock:(void (^)(BOOL error))end;

/**
 Returns the number of objects in this cache.
 This method may blocks the calling thread until file read finished.
 
 @return The total objects count.
 */
- (NSInteger)totalCount;

/**
 Get the number of objects in this cache.
 This method returns immediately and invoke the passed block in background queue
 when the operation finished.
 
 @param block  A block which will be invoked in background queue when finished.
 */
- (void)totalCountWithBlock:(void (^)(NSInteger totalCount))block;

/**
 Returns the total cost (in bytes) of objects in this cache.
 This method may blocks the calling thread until file read finished.
 
 @return The total objects cost in bytes.
 */
- (NSInteger)totalCost;

/**
 Get the total cost (in bytes) of objects in this cache.
 This method returns immediately and invoke the passed block in background queue
 when the operation finished.
 
 @param block  A block which will be invoked in background queue when finished.
 */
- (void)totalCostWithBlock:(void (^)(NSInteger totalCost))block;

@end
