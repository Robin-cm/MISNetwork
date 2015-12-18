//
//  MISMemoryCache.m
//  MISNetwork
//
//  Created by CM on 15/12/16.
//  Copyright © 2015年 changmin. All rights reserved.
//

#import "MISMemoryCache.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>
#import <pthread.h>
#import <CoreFoundation/CoreFoundation.h>
#import <QuartzCore/QuartzCore.h>

static inline dispatch_queue_t MISMemoryCacheGetReleaseQueue()
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

#pragma mark - _MISLinkedMapNode

/**
 A node in linked map.
 Typically, you should not use this class directly.
 */
@interface _MISLinkedMapNode : NSObject {
@package
    __unsafe_unretained _MISLinkedMapNode* _prev; // retained by dic
    __unsafe_unretained _MISLinkedMapNode* _next; // retained by dic
    id _key;
    id _value;
    NSUInteger _cost;
    NSTimeInterval _time;
}
@end

@implementation _MISLinkedMapNode
@end

#pragma mark - _MISLinkedMap

/**
 A linked map used by MISMemoryCache.
 It's not thread-safe and does not validate the parameters.
 
 Typically, you should not use this class directly.
 */
@interface _MISLinkedMap : NSObject {
@package
    CFMutableDictionaryRef _dic; // do not set object directly
    NSUInteger _totalCost;
    NSUInteger _totalCount;
    _MISLinkedMapNode* _head; // MRU, do not change it directly
    _MISLinkedMapNode* _tail; // LRU, do not change it directly
    BOOL _releaseOnMainThread;
    BOOL _releaseAsynchronously;
}

/// Insert a node at head and update the total cost.
/// Node and node.key should not be nil.
- (void)insertNodeAtHead:(_MISLinkedMapNode*)node;

/// Bring a inner node to header.
/// Node should already inside the dic.
- (void)bringNodeToHead:(_MISLinkedMapNode*)node;

/// Remove a inner node and update the total cost.
/// Node should already inside the dic.
- (void)removeNode:(_MISLinkedMapNode*)node;

/// Remove tail node if exist.
- (_MISLinkedMapNode*)removeTailNode;

/// Remove all node in background queue.
- (void)removeAll;

@end

@implementation _MISLinkedMap

- (instancetype)init
{
    self = [super init];
    _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    _releaseOnMainThread = NO;
    _releaseAsynchronously = YES;
    return self;
}

- (void)dealloc
{
    CFRelease(_dic);
}

- (void)insertNodeAtHead:(_MISLinkedMapNode*)node
{
    CFDictionarySetValue(_dic, (__bridge const void*)(node->_key), (__bridge const void*)(node));
    _totalCost += node->_cost;
    _totalCount++;
    if (_head) {
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    }
    else {
        _head = _tail = node;
    }
}

- (void)bringNodeToHead:(_MISLinkedMapNode*)node
{
    if (_head == node)
        return;

    if (_tail == node) {
        _tail = node->_prev;
        _tail->_next = nil;
    }
    else {
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

- (void)removeNode:(_MISLinkedMapNode*)node
{
    CFDictionaryRemoveValue(_dic, (__bridge const void*)(node->_key));
    _totalCost -= node->_cost;
    _totalCount--;
    if (node->_next)
        node->_next->_prev = node->_prev;
    if (node->_prev)
        node->_prev->_next = node->_next;
    if (_head == node)
        _head = node->_next;
    if (_tail == node)
        _tail = node->_prev;
}

- (_MISLinkedMapNode*)removeTailNode
{
    if (!_tail)
        return nil;
    _MISLinkedMapNode* tail = _tail;
    CFDictionaryRemoveValue(_dic, (__bridge const void*)(_tail->_key));
    _totalCost -= _tail->_cost;
    _totalCount--;
    if (_head == _tail) {
        _head = _tail = nil;
    }
    else {
        _tail = _tail->_prev;
        _tail->_next = nil;
    }
    return tail;
}

- (void)removeAll
{
    _totalCost = 0;
    _totalCount = 0;
    _head = nil;
    _tail = nil;
    if (CFDictionaryGetCount(_dic) > 0) {
        CFMutableDictionaryRef holder = _dic;
        _dic = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

        if (_releaseAsynchronously) {
            dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : MISMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                CFRelease(holder); // hold and release in specified queue
            });
        }
        else if (_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CFRelease(holder); // hold and release in specified queue
            });
        }
        else {
            CFRelease(holder);
        }
    }
}

@end

@implementation MISMemoryCache {
    OSSpinLock _lock;
    _MISLinkedMap* _lru;
    dispatch_queue_t _queue;
}

#pragma mark - 私有方法

/**
 *  递归trim
 */
- (void)_trimRecursively
{
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self)
            return;
        [self _trimInBackground];
        [self _trimRecursively];
    });
}

/**
 *  后台trim
 */
- (void)_trimInBackground
{
    dispatch_async(_queue, ^{
        [self _trimToCost:self->_costLimit];
        [self _trimToCount:self->_countLimit];
        [self _trimToAge:self->_ageLimit];
    });
}

/**
 *  trim到cost
 *
 *  @param costLimit 
 */
- (void)_trimToCost:(NSUInteger)costLimit
{
    BOOL finish = NO;
    OSSpinLockLock(&_lock);
    if (costLimit == 0) {
        [_lru removeAll];
        finish = YES;
    }
    else if (_lru->_totalCost <= costLimit) {
        finish = YES;
    }
    OSSpinLockUnlock(&_lock);
    if (finish)
        return;

    NSMutableArray* holder = [NSMutableArray new];
    while (!finish) {
        if (OSSpinLockTry(&_lock)) {
            if (_lru->_totalCost > costLimit) {
                _MISLinkedMapNode* node = [_lru removeTailNode];
                if (node)
                    [holder addObject:node];
            }
            else {
                finish = YES;
            }
            OSSpinLockUnlock(&_lock);
        }
        else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MISMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

/**
 *  trim到count
 *
 *  @param countLimit 
 */
- (void)_trimToCount:(NSUInteger)countLimit
{
    BOOL finish = NO;
    OSSpinLockLock(&_lock);
    if (countLimit == 0) {
        [_lru removeAll];
        finish = YES;
    }
    else if (_lru->_totalCount <= countLimit) {
        finish = YES;
    }
    OSSpinLockUnlock(&_lock);
    if (finish)
        return;

    NSMutableArray* holder = [NSMutableArray new];
    while (!finish) {
        if (OSSpinLockTry(&_lock)) {
            if (_lru->_totalCount > countLimit) {
                _MISLinkedMapNode* node = [_lru removeTailNode];
                if (node)
                    [holder addObject:node];
            }
            else {
                finish = YES;
            }
            OSSpinLockUnlock(&_lock);
        }
        else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MISMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

/**
 *  trim age
 *
 *  @param ageLimit 
 */
- (void)_trimToAge:(NSTimeInterval)ageLimit
{
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    OSSpinLockLock(&_lock);
    if (ageLimit <= 0) {
        [_lru removeAll];
        finish = YES;
    }
    else if (!_lru->_tail || (now - _lru->_tail->_time) <= ageLimit) {
        finish = YES;
    }
    OSSpinLockUnlock(&_lock);
    if (finish)
        return;

    NSMutableArray* holder = [NSMutableArray new];
    while (!finish) {
        if (OSSpinLockTry(&_lock)) {
            if (_lru->_tail && (now - _lru->_tail->_time) > ageLimit) {
                _MISLinkedMapNode* node = [_lru removeTailNode];
                if (node)
                    [holder addObject:node];
            }
            else {
                finish = YES;
            }
            OSSpinLockUnlock(&_lock);
        }
        else {
            usleep(10 * 1000); //10 ms
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MISMemoryCacheGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count]; // release in queue
        });
    }
}

/**
 *  接受到内存警告处理
 */
- (void)_appDidReceiveMemoryWarningNotification
{
    if (self.didReceiveMemoryWarningBlock) {
        self.didReceiveMemoryWarningBlock(self);
    }
    if (self.shouldRemoveAllObjectsOnMemoryWarning) {
        [self removeAllObjects];
    }
}

/**
 *  接收到切换到后台处理
 */
- (void)_appDidEnterBackgroundNotification
{
    if (self.didEnterBackgroundBlock) {
        self.didEnterBackgroundBlock(self);
    }
    if (self.shouldRemoveAllObjectsWhenEnteringBackground) {
        [self removeAllObjects];
    }
}

#pragma mark - 公共的方法：生命周期

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = OS_SPINLOCK_INIT;
        _lru = [_MISLinkedMap new];
        _queue = dispatch_queue_create("com.misnetwork.cache.memory", DISPATCH_QUEUE_SERIAL);

        _countLimit = NSUIntegerMax;
        _costLimit = NSUIntegerMax;
        _ageLimit = DBL_MAX;
        _autoTrimInterval = 5.0;
        _shouldRemoveAllObjectsOnMemoryWarning = YES;
        _shouldRemoveAllObjectsWhenEnteringBackground = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];

        [self _trimRecursively];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_lru removeAll];
}

#pragma mark - 公共的方法: Getter

- (NSUInteger)totalCount
{
    OSSpinLockLock(&_lock);
    NSUInteger count = _lru->_totalCount;
    OSSpinLockUnlock(&_lock);
    return count;
}

- (NSUInteger)totalCost
{
    OSSpinLockLock(&_lock);
    NSUInteger totalCost = _lru->_totalCost;
    OSSpinLockUnlock(&_lock);
    return totalCost;
}

- (BOOL)releaseInMainThread
{
    OSSpinLockLock(&_lock);
    BOOL releaseInMainThread = _lru->_releaseOnMainThread;
    OSSpinLockUnlock(&_lock);
    return releaseInMainThread;
}

- (BOOL)releaseAsynchronously
{
    OSSpinLockLock(&_lock);
    BOOL releaseAsynchronously = _lru->_releaseAsynchronously;
    OSSpinLockUnlock(&_lock);
    return releaseAsynchronously;
}

#pragma mark - Setter

- (void)setReleaseOnMainThread:(BOOL)releaseOnMainThread
{
    OSSpinLockLock(&_lock);
    _lru->_releaseOnMainThread = releaseOnMainThread;
    OSSpinLockUnlock(&_lock);
}

- (void)setReleaseAsynchronously:(BOOL)releaseAsynchronously
{
    OSSpinLockLock(&_lock);
    _lru->_releaseAsynchronously = releaseAsynchronously;
    OSSpinLockUnlock(&_lock);
}

#pragma mark - 公共方法

- (BOOL)containsObjectForKey:(id)key
{
    if (!key)
        return NO;
    OSSpinLockLock(&_lock);
    BOOL contains = CFDictionaryContainsKey(_lru->_dic, (__bridge const void*)(key));
    OSSpinLockUnlock(&_lock);
    return contains;
}

- (id)objectForKey:(id)key
{
    if (!key)
        return nil;
    OSSpinLockLock(&_lock);
    _MISLinkedMapNode* node = CFDictionaryGetValue(_lru->_dic, (__bridge const void*)(key));
    if (node) {
        node->_time = CACurrentMediaTime();
        [_lru bringNodeToHead:node];
    }
    OSSpinLockUnlock(&_lock);
    return node ? node->_value : nil;
}

- (void)setObject:(id)object forKey:(id)key
{
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost
{
    if (!key)
        return;
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    OSSpinLockLock(&_lock);
    _MISLinkedMapNode* node = CFDictionaryGetValue(_lru->_dic, (__bridge const void*)(key));
    NSTimeInterval now = CACurrentMediaTime();
    if (node) {
        _lru->_totalCost -= node->_cost;
        _lru->_totalCost += cost;
        node->_cost = cost;
        node->_time = now;
        node->_value = object;
        [_lru bringNodeToHead:node];
    }
    else {
        node = [_MISLinkedMapNode new];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [_lru insertNodeAtHead:node];
    }
    if (_lru->_totalCost > _costLimit) {
        dispatch_async(_queue, ^{
            [self trimToCost:_costLimit];
        });
    }
    if (_lru->_totalCount > _countLimit) {
        _MISLinkedMapNode* node = [_lru removeTailNode];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MISMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        }
        else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    OSSpinLockUnlock(&_lock);
}

- (void)removeObjectForKey:(id)key
{
    if (!key)
        return;
    OSSpinLockLock(&_lock);
    _MISLinkedMapNode* node = CFDictionaryGetValue(_lru->_dic, (__bridge const void*)(key));
    if (node) {
        [_lru removeNode:node];
        if (_lru->_releaseAsynchronously) {
            dispatch_queue_t queue = _lru->_releaseOnMainThread ? dispatch_get_main_queue() : MISMemoryCacheGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        }
        else if (_lru->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    OSSpinLockUnlock(&_lock);
}

- (void)removeAllObjects
{
    OSSpinLockLock(&_lock);
    [_lru removeAll];
    OSSpinLockUnlock(&_lock);
}

- (void)trimToCount:(NSUInteger)count
{
    if (count == 0) {
        [self removeAllObjects];
        return;
    }
    [self _trimToCount:count];
}

- (void)trimToCost:(NSUInteger)cost
{
    [self _trimToCost:cost];
}

- (void)trimToAge:(NSTimeInterval)age
{
    [self _trimToAge:age];
}

- (NSString*)description
{
    if (_name)
        return [NSString stringWithFormat:@"<%@: %p> (%@)", self.class, self, _name];
    else
        return [NSString stringWithFormat:@"<%@: %p>", self.class, self];
}

@end
