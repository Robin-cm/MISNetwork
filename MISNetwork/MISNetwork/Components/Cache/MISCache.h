//
//  MISCache.h
//  MISNetwork
//
//  Created by CM on 15/12/16.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MISMemoryCache, MISDiskCache;

@interface MISCache : NSObject

/** The name of the cache, readonly. */
@property (copy, readonly) NSString* name;

/** The underlying memory cache. see `MISMemoryCache` for more information.*/
@property (strong, readonly) MISMemoryCache* memoryCache;

/** The underlying disk cache. see `MISDiskCache` for more information.*/
@property (strong, readonly) MISDiskCache* diskCache;

/**
 Create a new instance with the specified name.
 Multiple instances with the same name will make the cache unstable.
 
 @param name  The name of the cache. It will create a dictionary with the name in
 the app's caches dictionary for disk cache. Once initialized you should not
 read and write to this directory.
 @result A new cache object, or nil if an error occurs.
 @warning Multiple instances with the same name will make the storage unstable.
 */
- (instancetype)initWithName:(NSString*)name;

/**
 Create a new instance with the specified name.
 Multiple instances with the same name will make the cache unstable.
 
 @param path  Full path of a directory in which the cache will write data.
 Once initialized you should not read and write to this directory.
 @result A new cache object, or nil if an error occurs.
 @warning Multiple instances with the same path will make the storage unstable.
 */
- (instancetype)initWithPath:(NSString*)path NS_DESIGNATED_INITIALIZER;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype) new UNAVAILABLE_ATTRIBUTE;

#pragma mark - Access Methods
///=============================================================================
/// @name Access Methods
///=============================================================================

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

@end
