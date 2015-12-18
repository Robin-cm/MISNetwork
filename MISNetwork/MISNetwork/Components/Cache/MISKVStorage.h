//
//  MISKVStorage.h
//  MISNetwork
//
//  Created by CM on 15/12/17.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Storage type, indicated where the `YYKVStorageItem.value` stored.
 
 @discussion Typically, write data to sqlite is faster than extern file, but
 reading performance is dependent on data size. In my test (on iPhone 6 64G),
 read data from extern file is faster than from sqlite when the data is larger
 than 20KB.
 
 * If you want to store large number of small datas (such as contacts cache),
 use YYKVStorageTypeSQLite to get better performance.
 * If you want to store large files (such as image cache),
 use YYKVStorageTypeFile to get better performance.
 * You can use YYKVStorageTypeMixed and choice your storage type for each item.
 
 See <http://www.sqlite.org/intern-v-extern-blob.html> for more information.
 */
typedef NS_ENUM(NSUInteger, MISKVStorageType) {

    /// The `value` is stored as a file in file system.
    MISKVStorageTypeFile = 0,

    /// The `value` is stored in sqlite with blob type.
    MISKVStorageTypeSQLite = 1,

    /// The `value` is stored in file system or sqlite based on your choice.
    MISKVStorageTypeMixed = 2,
};

@interface MISKVStorageItem : NSObject

@property (nonatomic, strong) NSString* key; ///< key
@property (nonatomic, strong) NSData* value; ///< value
@property (nonatomic, strong) NSString* filename; ///< filename (nil if inline)
@property (nonatomic, assign) int size; ///< value's size in bytes
@property (nonatomic, assign) int modTime; ///< modification unix timestamp
@property (nonatomic, assign) int accessTime; ///< last access unix timestamp
@property (nonatomic, strong) NSData* extendedData; ///< extended data (nil if no extended data)

@end

@interface MISKVStorage : NSObject

#pragma mark - 属性

@property (nonatomic, readonly) NSString* path; ///< The path of this storage.
@property (nonatomic, readonly) MISKVStorageType type; ///< The type of this storage.
@property (nonatomic, assign) BOOL errorLogsEnabled; ///< Set `YES` to enable error logs for debug.

#pragma mark - 初始化

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype) new UNAVAILABLE_ATTRIBUTE;

/**
 The designated initializer.
 
 @param path  Full path of a directory in which the storage will write data. If
 the directory is not exists, it will try to create one, otherwise it will
 read the data in this directory.
 @param type  The storage type. After first initialized you should not change the
 type of the specified path.
 @return  A new storage object, or nil if an error occurs.
 @warning Multiple instances with the same path will make the storage unstable.
 */
- (instancetype)initWithPath:(NSString*)path type:(MISKVStorageType)type NS_DESIGNATED_INITIALIZER;

#pragma mark - 公共方法：保存

/**
 Save an item or update the item with 'key' if it already exists.
 
 @discussion This method will save the item.key, item.value, item.filename and
 item.extendedData to disk or sqlite, other properties will be ignored. item.key
 and item.value should not be empty (nil or zero length).
 
 If the `type` is YYKVStorageTypeFile, then the item.filename should not be empty.
 If the `type` is YYKVStorageTypeSQLite, then the item.filename will be ignored.
 It the `type` is YYKVStorageTypeMixed, then the item.value will be saved to file
 system if the item.filename is not empty, otherwise it will be saved to sqlite.
 
 @param item  An item.
 @return Whether succeed.
 */
- (BOOL)saveItem:(MISKVStorageItem*)item;

/**
 Save an item or update the item with 'key' if it already exists.
 
 @discussion This method will save the key-value pair to sqlite. If the `type` is
 YYKVStorageTypeFile, then this method will failed.
 
 @param key   The key, should not be empty (nil or zero length).
 @param value The key, should not be empty (nil or zero length).
 @return Whether succeed.
 */
- (BOOL)saveItemWithKey:(NSString*)key value:(NSData*)value;

/**
 Save an item or update the item with 'key' if it already exists.
 
 @discussion
 If the `type` is YYKVStorageTypeFile, then the `filename` should not be empty.
 If the `type` is YYKVStorageTypeSQLite, then the `filename` will be ignored.
 It the `type` is YYKVStorageTypeMixed, then the `value` will be saved to file
 system if the `filename` is not empty, otherwise it will be saved to sqlite.
 
 @param key           The key, should not be empty (nil or zero length).
 @param value         The key, should not be empty (nil or zero length).
 @param filename      The filename.
 @param extendedData  The extended data for this item (pass nil to ignore it).
 
 @return Whether succeed.
 */
- (BOOL)saveItemWithKey:(NSString*)key
                  value:(NSData*)value
               filename:(NSString*)filename
           extendedData:(NSData*)extendedData;

#pragma mark - 公共方法：删除

/**
 Remove an item with 'key'.
 
 @param key The item's key.
 @return Whether succeed.
 */
- (BOOL)removeItemForKey:(NSString*)key;

/**
 Remove items with an array of keys.
 
 @param keys An array of specified keys.
 
 @return Whether succeed.
 */
- (BOOL)removeItemForKeys:(NSArray*)keys;

/**
 Remove all items which `value` is larger than a specified size.
 
 @param size  The maximum size in bytes.
 @return Whether succeed.
 */
- (BOOL)removeItemsLargerThanSize:(int)size;

/**
 Remove all items which last access time is earlier than a specified timestamp.
 
 @param time  The specified unix timestamp.
 @return Whether succeed.
 */
- (BOOL)removeItemsEarlierThanTime:(int)time;

/**
 Remove items to make the total size not larger than a specified size.
 The least recently used (LRU) items will be removed first.
 
 @param maxSize The specified size in bytes.
 @return Whether succeed.
 */
- (BOOL)removeItemsToFitSize:(int)maxSize;

/**
 Remove items to make the total count not larger than a specified count.
 The least recently used (LRU) items will be removed first.
 
 @param maxCount The specified item count.
 @return Whether succeed.
 */
- (BOOL)removeItemsToFitCount:(int)maxCount;

/**
 Remove all items in background queue.
 
 @discussion This method will remove the files and sqlite database to a trash
 folder, and then clear the folder in background queue. So this method is much
 faster than `removeAllItemsWithProgressBlock:endBlock:`.
 
 @return Whether succeed.
 */
- (BOOL)removeAllItems;

/**
 Remove all items.
 
 @warning You should not send message to this instance in these blocks.
 @param progress This block will be invoked during removing, pass nil to ignore.
 @param end      This block will be invoked at the end, pass nil to ignore.
 */
- (void)removeAllItemsWithProgressBlock:(void (^)(int removedCount, int totalCount))progress
                               endBlock:(void (^)(BOOL error))end;

#pragma mark - 取值

/**
 Get item with a specified key.
 
 @param key A specified key.
 @return Item for the key, or nil if not exists / error occurs.
 */
- (MISKVStorageItem*)getItemForKey:(NSString*)key;

/**
 Get item information with a specified key.
 The `value` in this item will be ignored.
 
 @param key A specified key.
 @return Item information for the key, or nil if not exists / error occurs.
 */
- (MISKVStorageItem*)getItemInfoForKey:(NSString*)key;

/**
 Get item value with a specified key.
 
 @param key  A specified key.
 @return Item's value, or nil if not exists / error occurs.
 */
- (NSData*)getItemValueForKey:(NSString*)key;

/**
 Get items with an array of keys.
 
 @param keys  An array of specified keys.
 @return An array of `YYKVStorageItem`, or nil if not exists / error occurs.
 */
- (NSArray*)getItemForKeys:(NSArray*)keys;

/**
 Get item infomartions with an array of keys.
 The `value` in items will be ignored.
 
 @param keys  An array of specified keys.
 @return An array of `YYKVStorageItem`, or nil if not exists / error occurs.
 */
- (NSArray*)getItemInfoForKeys:(NSArray*)keys;

/**
 Get items value with an array of keys.
 
 @param keys  An array of specified keys.
 @return A dictionary which key is 'key' and value is 'value', or nil if not
 exists / error occurs.
 */
- (NSDictionary*)getItemValueForKeys:(NSArray*)keys;

#pragma mark - 公共方法：获取状态

/**
 Whether an item exists for a specified key.
 
 @param key  A specified key.
 
 @return `YES` if there's an item exists for the key, `NO` if not exists or an error occurs.
 */
- (BOOL)itemExistsForKey:(NSString*)key;

/**
 Get total item count.
 @return Total item count, -1 when an error occurs.
 */
- (int)getItemsCount;

/**
 Get item value's total size in bytes.
 @return Total size in bytes, -1 when an error occurs.
 */
- (int)getItemsSize;

@end
